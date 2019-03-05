# library(data.table)
# library(matrixStats)
#
# # PR = fread("/home/matteo/Projects/retentiontimealignment/Data/annotated_and_unanottated_data.csv")
# # PR[PR=='NULL'] = NA
# # D = PR[!is.na(sequence)][,id:=paste(sequence, modification, sep='_')][,.(id,run,rt)]
# # fwrite(D, file="/home/matteo/Projects/retentiontimealignment/Data/annotated_data.csv")
# D = fread("~/Projects/retentiontimealignment/Data/annotated_data.csv")
#
# # PR = fread("~/Projects/retentiontimealignment/Data/annotated_data.csv")
# # D = PR[,.(id,run,rt)]
#
# min_observed_cnt = 2
# window_size = 11
# mad_cnt = 2
# spline.df = 30
# grid.points.cnt = 100
#
# D = D[, run_cnt:=length(rt), by=id
#       ][ run_cnt>=min_observed_cnt ]
#
# D = unique( D, by=c('id','run') )
# D[, run := paste0("run_", run) ]
# DW = dcast(D, id + run_cnt ~run, value.var = 'rt')
# DW_m = as.matrix(DW[,!1:2])
# # getting the reference run (to be plotted on the x axis)
# pep_medians = rowMedians(DW_m, na.rm=T)
# # this is a nice desciption of the peptides, but we need to describe the runs instead
# # pep_mads = rowMads(DW_m, na.rm=T)
#
# # getting distances to the  reference median run
# d2medians = -sweep(DW_m, 1, pep_medians)
#
# # we switch between the wide and long mode for efficiency of the calculation of medians
# # pep_mads = rowMads(d2medians, na.rm=T)
#
# d2medians = as.data.table(d2medians)
# d2medians$med = pep_medians
# d2medians$peptide = DW$id
# d2medians = d2medians[order(med)]
# d2medians = melt(d2medians, id.vars = c('peptide', 'med'),
#                  variable.name = "run",
#                  value.name = "rt_ref_d",
#                  na.rm=T)
# d2medians[, roll_med_rt := stats::runmed(rt_ref_d, k=window_size, endrule='constant'), by=run
#           ][, roll_mad_rt := stats::runmed(abs(rt_ref_d - roll_med_rt), k=window_size, endrule='constant'), by=run]
#
# ref.min = min(d2medians$med)
# ref.max = max(d2medians$med)
# ref.grid = seq(ref.min, ref.max, length.out=grid.points.cnt)
# S = function(x, y, df, grid) predict(smooth.spline(x, y, df=df), grid)
#
# mid = d2medians[, S(med, roll_med_rt, spline.df, ref.grid), by=run]
# colnames(mid)[3] = 'mid'
# top = d2medians[, S(med, roll_med_rt + mad_cnt * roll_mad_rt, spline.df, ref.grid), by=run]
# colnames(top)[3] = 'top'
# bot = d2medians[, S(med, roll_med_rt - mad_cnt * roll_mad_rt, spline.df, ref.grid), by=run]
# colnames(bot)[3] = 'bot'
# SD = mid[top, on=c('run', 'x')][bot, on=c('run', 'x')]
# SD[top<=mid, top:=mid][bot>=mid, bot:=mid]
#
# run_no = 'run_1'
# with(d2medians[run==run_no,],
#      {plot(med, rt_ref_d, pch='.', ylim = c(-4, 4))
#       # lines(med, roll_med_rt, col='red')
#       # lines(med, roll_med_rt + mad_cnt*roll_mad_rt, col='orange')
#       # lines(med, roll_med_rt - mad_cnt*roll_mad_rt, col='orange')
#       with(SD[run==run_no],
#            lines(x, mid, col='blue'))
#       with(SD[run==run_no],
#            lines(x, bot, col='blue'))
#       with(SD[run==run_no],
#            lines(x, top, col='blue'))
#       })
# SD[, run:=as.integer(gsub("run_", "", SD$run))]
#
# library(ggplot2)
# library(ggthemes)

# ggplot(SD[run <= 3], aes(x=x, group=ordered(run))) +
#   geom_ribbon(aes(ymin=bot, ymax=top), alpha=.2) +
#   geom_hline(yintercept = 0, linetype='dashed') +
#   geom_line(aes(y=mid, color=ordered(run)), size=1) +
#   cowplot::theme_cowplot() +
#   labs(color="run") +
#   xlab("Reference Run") +
#   ylab("Distance to Reference Run")
#
#
#
# ggplot(SD, aes(x=x, group=ordered(run))) +
#   geom_hline(yintercept = 0, linetype='dashed') +
#   geom_line(aes(y=mid, color=ordered(run)), size=1) +
#   cowplot::theme_cowplot() +
#   labs(color="run") +
#   xlab("Reference Run") +
#   ylab("Distance to Reference Run")

