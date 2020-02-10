# library(devtools)
library(LFQBench2)
library(ggplot2)
library(cowplot)
library(microbenchmark)

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
p = plot_ratios(MI$I_meds, MI$sampleComposition)

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





ggplot() +
geom_density(data=I_meds, aes(x=I_ratio, color=species), alpha=.5) +
theme_minimal() +
scale_x_log10()

ggplot() +
geom_vline(data=sampleComposition, aes(xintercept=ratios, color=species)) +
geom_density(data=meds, aes(x=I_ratio, fill=species), alpha=.5) +
theme_minimal() +
scale_x_log10() +
xlab(paste('Intensity Ratio (', colnames(meds)[1], ':', colnames(meds)[2],')'))

MI$I_meds

get_metrics = function(){

  #
  # implement
}


