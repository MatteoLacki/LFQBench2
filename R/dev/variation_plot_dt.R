library(LFQBench2)
library(data.table)
library(matrixStats)
library(stringr)
library(ggplot2)
library(scales)

# PR = fread("/home/matteo/Projects/retentiontimealignment/Data/annotated_and_unanottated_data.csv")
# PR[PR=='NULL'] = NA
# D = PR[!is.na(sequence)][,id:=paste(sequence, modification, sep='_')][,.(id,run,rt)]
# fwrite(D, file="/home/matteo/Projects/retentiontimealignment/Data/annotated_data.csv")
INPUT = fread("~/Projects/retentiontimealignment/Data/annotated_data.csv")

# PR = fread("~/Projects/retentiontimealignment/Data/annotated_data.csv")
# D = PR[,.(id,run,rt)]

min_observed_cnt = 2
window_size = 11
mad_cnt = 2
spline.df = 30
grid.points.cnt = 100

SD = LFQBench2::get_smoothed_data(INPUT$rt, INPUT$run, INPUT$id)


path = '~/Projects/LFQBench2/tests/data/ISOQuant_pep_2016-010_HYE110_UDMSE_peptide_quantification_report.csv'
path = path.expand(path)

D = read_isoquant_peptide_report(path)
class(D)
D = read_isoquant_peptide_report(path, I_col_pattern="intensity in HYE110_(.) (.)",
                                 I_col_pattern_group_names=c("cond", "tech_repl"))

class(D)


class(bubba) <- append(class(bubba),"Flamboyancy")


preprocess_4_intensity_plots = function(D,
                                        entry_specie_sep = "_",
                                        cond_run_sep = " ")
{
  D[,id:=ifelse(is.na(modifier), sequence, paste0(sequence, modifier, sep="_"))]
  D = D[!is.na(entry),.(id, entry, cond, intensity)]
  entry_species = str_split_fixed(D$entry, entry_specie_sep, 2)
  D$entry = entry_species[,1]
  D$species = entry_species[,2]
  D$cond = str_replace(D$cond, "intensity in HYE110_", "")
  cond_run = str_split_fixed(D$cond, cond_run_sep, 2)
  D$cond = cond_run[,1]
  D$run = as.integer(cond_run[,2])
  D_meds = D[,.(intensity_med=median(intensity), run_cnt=.N), by=.(id, cond, species)]
  D_meds = dcast(D_meds, id + species ~ cond, value.var = 'intensity_med')
  D_meds_good = D_meds[complete.cases(D_meds)]
  D_meds_good
}

good_species = c("HUMAN", "ECOLI", "YEAS8")
D_meds_good = preprocess_4_intensity_plots(D)
D_meds_good = D_meds_good[species %in% good_species]

organisms = data.frame(
  name = c("HUMAN","YEAS8", "ECOLI"),
  A = c(  67,     30,       3   ),
  B = c(  67,      3,      30   )
)


plot_proteome_mix2 = function(ids, species, A, B, organisms,
                              bins=300)
{
  D = data.frame(id=ids, species=species, A=A, B=B)
  organisms$ratio = with(organisms, B/A)
  o = list()
  base = ggplot(D, aes(x=A, y=B/A))
  o$scatterplot = base +
    geom_point(size=1) +
    geom_hline(data=organisms, aes(yintercept=ratio, color=name), size=1) +
    scale_x_log10(labels=comma) +
    scale_y_log10(labels=comma, breaks=organisms$ratio) +
    geom_hline(data=organisms, aes(yintercept=ratio, color=name), size=1) +
    theme_classic()
  o$hex_dens2d = base +
    geom_hex(bins=bins) +
    geom_density_2d(aes(color=species), contour=T) +
    scale_x_log10(labels=scales::comma) +
    scale_y_log10(labels=scales::comma, breaks=organisms$ratio) +
    geom_hline(data=organisms, aes(yintercept=ratio, color=name), size=1) +
    theme_classic()
  o$dens2d = base +
    geom_density_2d(aes(color=species), contour=T) +
    scale_x_log10(labels=scales::comma) +
    scale_y_log10(labels=scales::comma, breaks=organisms$ratio) +
    geom_hline(data=organisms, aes(yintercept=ratio, color=name), size=1) +
    theme_classic()
  return(o)
}

plot_proteome_mix = function(X, ...){
  X = unlist(list(as.list(X), list(...)), F)
  do.call(plot_proteome_mix2, X)
}


o = plot_proteome_mix(D_meds_good, organisms, bins=100)
o$scatterplot
o$hex_dens2d
o$dens2d

# D = D[, run_cnt:=length(rt), by=id
#       ][ run_cnt>=min_observed_cnt ]
#
# D = unique( D, by=c('id','run') )
# D[, run := paste0("run_", run) ]
# DW = dcast(D, id + run_cnt ~run, value.var = 'rt')
# DW_m = as.matrix(DW[,!1:2])
# getting the reference run (to be plotted on the x axis)
# pep_medians = rowMedians(DW_m, na.rm=T)
# this is a nice desciption of the peptides, but we need to describe the runs instead
# pep_mads = rowMads(DW_m, na.rm=T)

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

