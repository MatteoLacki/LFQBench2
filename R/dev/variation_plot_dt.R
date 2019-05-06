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
D = read_isoquant_peptide_report(path,
                                 I_col_pattern="intensity in HYE110_(.) (.)",
                                 I_col_pattern_group_names=c("cond", "tech_repl"))

D_meds = preprocess_peptides_4_intensity_plots(D)

# preprocess_4_intensity_plots = function(D) UseMethod("preprocess_4_intensity_plots", D)
# preprocess_4_intensity_plots.peptide = function(...) preprocess_peptides_4_intensity_plots(...)
# preprocess_4_intensity_plots(D)

good_species = c("HUMAN", "ECOLI", "YEAS8")
D_meds_good = D_meds[species %in% good_species]

organisms = data.frame(
  name = c("HUMAN","YEAS8", "ECOLI"),
  A = c(  67,     30,       3   ),
  B = c(  67,      3,      30   )
)
o = plot_proteome_mix(D_meds_good, organisms, bins=100)
W = plot_grid(plotlist=o, nrow=1, align='h', axis='l')

ids = D_meds_good$id
species = D_meds_good$species
A = D_meds_good$A
B = D_meds_good$

plot_proteome_mix2 = function(ids, species, A, B, organisms,
                              bins=100)
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
  o$hex = base +
    geom_hex(aes(fill=species, alpha=..count..), bins=bins) +
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
plts = plot_proteome_mix2(ids, species, A, B, organisms)

plot_proteome_mix = function(X, ...){
  X = unlist(list(as.list(X), list(...)), F)
  do.call(plot_proteome_mix2, X)
}

plts = plot_proteome_mix(D_meds_good, organisms, bins=100)
plts[[2]]

