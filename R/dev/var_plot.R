library(data.table)
library(ggplot2)
library(LFQBench2)

# path = path.expand('~/Projects/LFQBench2/data/peptides.csv')
path = path.expand('~/Projects/retentiontimealignment/Data/annotated_data.csv')
D = fread(path)
ids = D$id
runs = D$run
rt = D$rt

S = get_smoothed_data(rt, runs, ids)
S[,run:=ordered(run)]
o = plot_dist_to_reference(S)


Z <- S
Z[, `:=`(top=NULL, bot=NULL)]
p = plot_dist_to_reference(Z)
p + geom_hline(yintercept=0, linetype='dashed')

o = ggplot(S, aes(x=x, group=run))
if("top" %in% colnames(S) & "bot" %in% colnames(S)){
	o = o + geom_line(aes(y=top), linetype='dashed')
	o = o + geom_line(aes(y=bot), linetype='dashed')
}
o = o + geom_line(aes(y=mid, color=run)) +
	theme_classic() +
	xlab('Reference Retention Time') +
	ylab('Distance to Reference')
z3 = o + facet_wrap(~run) + geom_hline(yintercept=0, linetype='dotted')
cowplot::ggsave(filename=path.expand("~/Projects/LFQBench2/LFQBench2/picts/dist2meds3.jpg"), z3, width=25, height=10)