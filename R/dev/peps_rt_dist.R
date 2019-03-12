library(LFQBench2)
library(data.table)


# Path to a file with data
path = path.expand('~/Projects/retentiontimealignment/Data/annotated_data.csv')
D = fread(path)

# We need to have following columns:
rt = D$rt # recorded retention times (but any other value will do, like drift times from IMS)
runs = D$run # which run was the retention time recorded at?
ids = D$id # which peptide was measured

S = get_smoothed_data(rt, runs, ids) # get the data for plotting
S[,run:=ordered(run)] # change run to ordered factor, for ggplot to be happy
plot_dist_to_reference(S)

z = plot_dist_to_reference(S)
cowplot::ggsave(filename=path.expand("~/Projects/LFQBench2/LFQBench2/picts/dist2meds.jpg"), z, width=25, height=10)


Z <- S
S[, `:=`(top=NULL, bot=NULL)]
z2 = plot_dist_to_reference(Z)
cowplot::ggsave(filename=path.expand("~/Projects/LFQBench2/LFQBench2/picts/dist2meds2.jpg"), z2, width=25, height=10)