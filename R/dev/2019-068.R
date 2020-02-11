# library(devtools)
library(LFQBench2)
library(ggplot2)
library(cowplot)
library(microbenchmark)
library(data.table)

dp = "~/Projects/LFQBench2/data/2019-068/long_runs/2019-068_PYE_1_3_IMS_user designed 20200131-171545_"
peptide_rep = paste0(dp, "peptide_quantification_report.csv")
protein_rep = paste0(dp, "quantification_report.xlsx")

sampleComposition = data.frame(
  species = c("HUMAN","YEAS8", "ECOLI"),
  A       = c(  135,     03,      12  ),
  B       = c(  135,     09,      06  )
)

# proteins
R = read_wide_report(protein_rep, skip=1, sheet="TOP3 quantification")
I = get_intensities(R, I_col_pattern=".* SYE (:condition:.) 1:3 (:tech_repl:.)")

# LI = data.table::melt(I$I, variable.name='I_col_name')
# merge(LI, I$design, by='I_col_name')
species = get_species(species_col=R[['accession']], species_pattern=".*_(.*)")
MI = get_ratios_of_medians(I$I, I$design, species, sampleComposition)
plot_ratios(MI$I_cleanMeds, MI$sampleComposition)

# peptides
P = read_wide_report(peptide_rep)
I = get_intensities(P,I_col_pattern=".* SYE (:condition:.) 1:3 (:tech_repl:.)")
species = get_species(species_col=P[['accession']], species_pattern=".*_(.*)")
MI = get_ratios_of_medians(I$I, I$design, species, sampleComposition)
p = plot_ratios(MI$I_cleanMeds, MI$sampleComposition)

save_plot(filename=file.path("~/Projects/LFQBench2/data/2019-068",'with_contaminants.png'), p,
    base_height=10)

# R = read_wide_report(protein_rep, skip=1, sheet="TOP3 quantification")
# I = get_intensities(R, I_col_pattern="(:year:....)-(:experiment_no:...)-(:something:..) SYE (:condition:.) 1:3 (:technical_replicate:.)")
# LI = data.table::melt(I$I, variable.name='I_col_name')
# merge(LI, I$design, by='I_col_name')

sC = MI$sampleComposition
I_meds = MI$I_cleanMeds

get_condition_columns = function(D) lapply(split(I$design, I$design$condition), '[[', 'I_col_name')
count_NA = function(X) rowSums(is.na(X))
get_NA_stats = function(I, design){
    conds = get_condition_columns(design)
    NA_in_conds = I[,lapply(conds, function(cond) count_NA(I[,cond,with=F]))]
    table(NA_in_conds)
}
NA_stats = get_NA_stats(I$I, I$design)
I_meds
ggplot(I_meds) +
  geom_freqpoly(aes(x=I_ratio, color=species), bins=50) +
  geom_vline(data=sC, aes(xintercept=ratios, color=species))+
  scale_x_log10()


sC = as.data.table(sC)

I_meds_no_NA = I_meds[!is.na(I_meds$I_ratio)]
I_meds_no_NA = merge(I_meds_no_NA, sC[,c('species','ratios')], by='species')
I_meds_no_NA[,I_real_ratio:=rat]
setnames(I_meds_no_NA, c('ratios','I_ratio'), c('I_ratio_expected', 'I_ratio_real'))
species_log10mads = I_meds_no_NA[,.(log10mad=median(abs(log10(I_ratio_real)-log10(I_ratio_expected)))), by=species]
global_log10mad = I_meds_no_NA[,.(log10mad=median(abs(log10(I_ratio_real)-log10(I_ratio_expected))))]

probs = c(.05, .95)
meds = MI$I_cleanMeds
M = meds[,.(quants = log10(quantile(I_ratio, probs, na.rm=T))), by=species]
M$quant = rep.int(probs, nrow(M)/2)
dcast(M, 'species ~ quant', value.var='quants')

# the ugliest code since a loooong time.
all_hist = hist(log10(I_meds$I_ratio), plot=F, breaks=50)
disc = I_meds[,.(hist(log10(I_ratio), breaks=all_hist$breaks, plot=F)$counts), by=species]
disc$mids = rep.int(all_hist$mids, 3)
disc = dcast(disc, 'mids~species', value.var='V1')
disc$tag = apply(disc[,2:4], 1, which.max)
disc$max_cnt = apply(disc[,2:4], 1, max)
d_ms = diff(disc$tag)
d_ms[d_ms != 0] = 1
disc$groups = c(0, cumsum(d_ms))
discStats = disc[,.(min_mid=min(mids),
                    max_mid=max(mids),
                    tag=tag[1],
                    len=.N,
                    cnt=sum(max_cnt)), by=groups]

discStats$majority_species = colnames(disc)[2:4][discStats$tag]
discStatsCompact = discStats[,.SD[which.max(cnt)], by=majority_species]




get_metrics = function(){

  #
  # implement
}


