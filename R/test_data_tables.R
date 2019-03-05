# library(data.table)
#
# PR = fread("~/Projects/retentiontimealignment/Data/annotated_data.csv")
# head(PR)
# PR[run == 1L, charge]
# PR[, charge, run]
# PR[, .(charge, run)]
# PR[, .(charge, run, sequence)]
# PR[, .(median_charge=median(charge)), run]
#
# pr = PR[, .(id, run, rt)]
# pr = unique(pr, by=c('id', 'rt'))
# system.time({
#   pr[,med_d:=rt-median(rt), by=id]
# })
#
# prw = dcast(pr, id ~ run, value.var = 'rt')
# prw
# ncol(prw)
#   rowSums(is.na(prw))
#
# prw[,2:11][, median]
# prw[,2:11][, median(.SD), by=..I]
#
# library(matrixStats)
# rowMedians = matrixStats::rowMedians
#
# prw_m = as.matrix(prw[,2:11])
# meds = rowMedians(prw_m, na.rm=T)
#
#
#
#
#
# pr[,list(run, rt)]
# pr[,.(run, rt)]
# pr[,.(dupa = run, chuj = rt)]
# pr[run > 3,]
# pr[run > 3,.N]
# pr[run > 3,.(.N)]
# pr[, sum(run + rt > 3)]
# # grouping by both run and id and getting counts.
# pr[, .N, .(run, id)]
# # pr %>% group_by(run, id) %>% count
# columns = c('id', 'run', 'rt')
# pr[, ..columns] # simpler then using dplyr
# # like: look for columns one level up, in the global
# # environment... this makes no sense.
# pr[, columns, with=F]
# w = seq(0,1,.01)
# pr[, quantile(rt, w),
#    by=.(group=ifelse(run<5,'a','b'))]
#
# pr[,rt:=NULL]
# pr$dupa = 1
#
#
#
#
