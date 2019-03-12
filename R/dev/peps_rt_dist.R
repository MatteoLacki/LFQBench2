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
z = plot_dist_to_reference(S)

ggsave(filename=path.expand("~/Projects/LFQBench2/LFQBench2/picts/dist2meds.jpg"), z, width=25, height=10)


Z <- S
Z[, `:=`(top=NULL, bot=NULL)]
plot_dist_to_reference(Z)
