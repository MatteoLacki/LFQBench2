library(readr)
library(tidyverse)

# D = read_delim("~/Projects/LFQBench2/CSV_DATA/2016-141 HYE nano2018_20180716_120min_nano_paper.csv",
#                ";", escape_double = FALSE, trim_ws = TRUE)
# D[D == 'NULL'] = NA
# D = D %>%
#   filter(!is.na(sequence)) %>%
#   mutate(id = paste0(sequence, modification)) %>%
#   select(id, run, rt)
# save(D, file="~/Projects/LFQBench2/CSV_DATA/2016-141 HYE nano2018_20180716_120min_nano_paper.Rd")
load(file="~/Projects/LFQBench2/CSV_DATA/2016-141 HYE nano2018_20180716_120min_nano_paper.Rd")

# D is in long format, need to make it wide.
# deduplicate
D = D %>% group_by(id, run) %>% mutate(n = n()) %>% ungroup %>% filter(n == 1) %>% select(-n)
DL = D

DW = spread(DL, run, rt)
colnames(DW)[-1] = paste('run_', colnames(DW)[-1], sep='')
observed_cnt = ncol(DW) - 1 - rowSums(is.na(DW))

min_observed_cnt = 2
window_size = 11

DW2 = DW[observed_cnt >= min_observed_cnt,]
DW_ = as.matrix(DW2[,-1])
medians = apply(DW_, 1, median, na.rm = T)

runmed_na = function(run, medians, window_size=21, df=100){
  run_cent = medians - run
  C = run[!is.na(run)]
  RC = run_cent[!is.na(run)]
  i = order(C)
  C = C[i]
  RC = RC[i]
  RC = stats::runmed(RC, k=window_size)
  ss = smooth.spline(C, RC, df=df)
  # plot(C, RC)
  # x = seq(min(C), max(C), length.out = 10000)
  # lines(predict(ss, x), col='red')
  W = C + residuals(ss)
  W = W[order(i)]
  run[!is.na(run)] = W
  return(run)
}

DW__ = apply(DW_, 2, runmed_na, medians, 31, 100)
medians__ = apply(DW__, 1, median, na.rm = T)
demed = sweep(DW__, 1, medians__)

plot(DW_[,1], demed[,1], pch='.', ylim=c(-2,2))
DM = sweep(DW_, 1, medians)
plot(DW_[,1], DM[,1], pch='.', ylim=c(-2,2))


peptide_report = read_csv("~/Projects/retentiontimealignment/Data/annotated_data.csv")
DL = peptide_report %>% select(run, rt, sequence, modification) %>%
  mutate(id = ifelse(is.na(modification), sequence, paste(sequence, modification, sep='_'))) %>%
  select(-sequence, -modification)

min_observed_cnt = 5

DW = DL %>% spread(run, rt)
colnames(DW)[-1] = paste('run', colnames(DW)[-1], sep = "_")
run_cnt = ncol(DW) - 1 - rowSums(is.na(DW))
DW = DW[run_cnt >= min_observed_cnt,]
DW_ = as.matrix(DW[,-1])
medians = apply(DW_, 1, median, na.rm=T)

# why it takes 7 secs???
DL %>%
  group_by(id) %>%
  mutate(n = n()) %>%
  ungroup %>%
  filter(n >= min_observed_cnt) %>%
  group_by(id) %>%
  mutate(d_med = median(rt) - rt) %>%
  ungroup


