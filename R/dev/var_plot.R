library(data.table)
library(ggplot2)

# path = path.expand('~/Projects/LFQBench2/data/peptides.csv')
path = path.expand('~/Projects/retentiontimealignment/Data/annotated_data.csv')
D = fread(path)
ids = D$id
runs = D$run
rt = D$rt

D = fread(path)
ids = D$id
runs = D$run
rt = D$rt


S = get_smoothed_data(rt, runs, ids)
S[,run:=ordered(run)]
plot_dist_to_reference(S)

Z <- S
Z[, `:=`(top=NULL, bot=NULL)]
plot_dist_to_reference(Z)

