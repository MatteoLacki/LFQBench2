library(data.table)
library(matrixStats)

PR = fread("~/Projects/retentiontimealignment/Data/annotated_data.csv")
D = PR[,.(id,run,rt)]

min_observed_cnt = 2
window_size = 11

D = D[, run_cnt:=length(rt), by=id
      ][ run_cnt>=min_observed_cnt ]

D = unique( D, by=c('id','run') )
D[, run := paste0("run_", run) ]
DW = dcast(D, id + run_cnt ~run, value.var = 'rt')

# D[,med:=median(rt),by=id]
DW_m = as.matrix(DW[,!1:2])
pep_medians = rowMedians(DW_m, na.rm=T)
d2medians = -sweep(DW_m, 1, pep_medians)
rowQuantiles(d2medians, na.rm=T, probs=c(.2,.5,.8))

d2medians = as.data.table(d2medians)
d2medians$med = pep_medians
d2medians$peptide = DW$id
d2medians = d2medians[order(med)]

# d2medians[, as.data.table(colQuantiles(as.matrix(.SD))),
#           by=round(med,1)]
d2medians = melt(d2medians, id.vars = c('peptide', 'med'),
                 variable.name = "run",
                 value.name = "rt",
                 na.rm=T)


p = seq(0,1,length.out=1000)
probs=c(.2,.5,.8)
cols = paste0("q_", probs)
d2medians[,lapply(probs, function(prob) quantile(rt, prob)),
           by = .(run, round(med,1))]
DT = d2medians[, .(med_rt=median(rt), mad_rt=mad(rt)),
                 .(run, med_rd=round(med, 0))]

library(ggplot2)
library(ggthemes)

ggplot(DT, aes(x=med_rd, y=med_rt, group=run, color=run))+
  geom_line() +
  ylim(-1, 1) +
  theme_tufte()




