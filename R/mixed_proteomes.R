#' Prepare peptide data for the intensity comparison plots.
#'
#' @param D Peptide report (columns 'modifier', 'sequence', 'entry', 'intensity' required).
#' @param entry_species_sep What sign separates the protein entries from the species description in the 'entry' column?
#' @param cond_run_sep What sign separates the condition from the run label in the 'cond' column?
#' @return Data for proteome intensity plots.
#' @import data.table
#' @importFrom stringr str_replace
#' @importFrom stats median
#' @export
preprocess_peptides_4_intensity_plots = function(D,
                                                 entry_species_sep = "_",
                                                 cond_run_sep = " ")
{
  D$id = ifelse(is.na(D$modifier), D$sequence, paste0(D$sequence, D$modifier, sep="_"))
  D = D[!is.na(entry),.(id, entry, cond, intensity)]
  entry_species = str_split_fixed(D$entry, entry_species_sep, 2)
  D$entry = entry_species[,1]
  D$species = entry_species[,2]
  D$cond = str_replace(D$cond, "intensity in HYE110_", "")
  cond_run = str_split_fixed(D$cond, cond_run_sep, 2)
  D$cond = cond_run[,1]
  D$run = as.integer(cond_run[,2])
  D_meds = D[,.(intensity_med=median(intensity), run_cnt=.N), by=.(id, cond, species)]
  D_meds = dcast(D_meds, id + species ~ cond, value.var = 'intensity_med')
  D_meds_good = D_meds[complete.cases(D_meds)]
  D_meds_good
}

#' Prepare protein data for the intensity comparison plots.
#'
#' @param D Protein report (columns 'entry', 'cond', 'intensity' required).
#' @param entry_species_sep What sign separates the protein entries from the species description in the 'entry' column?
#' @param cond_run_sep What sign separates the condition from the run label in the 'cond' column?
#' @return Data for proteome intensity plots.
#' @import data.table
#' @importFrom stringr str_detect
#' @importFrom stats median complete.cases
#' @export
preprocess_proteins_4_intensity_plots = function(D,
                                        entry_species_sep = "_",
                                        cond_run_sep = " "){
  # setting local vars to None to avoid Notes popping up in CRAN.
  entry=cond=intensity=run=species=NULL
  # It only makes the love-hate relationship with R more interesting.

  D = D[!is.na(entry),.(entry, cond, intensity)][!str_detect(entry, "_CONTA")]
  D[, c('entry', 'species') := tstrsplit(entry, entry_species_sep)]
  D[, c('cond', 'run') := tstrsplit(cond, cond_run_sep) ][, run:=as.integer(run)]
  D_meds = D[,.(intensity_med=median(intensity), run_cnt=.N), by=.(entry, cond, species)]
  D_meds = dcast(D_meds, entry + species ~ cond, value.var = 'intensity_med')
  D_meds_good = D_meds[complete.cases(D_meds)]
  colnames(D_meds_good)[1] = 'id'
  D_meds_good
}


#' Plot proteome data.
#'
#' @param species Tags identifying the species a protein/peptides comes from.
#' @param A The intensities gathered with preteomes in ratios A.
#' @param B The intensities gathered with preteomes in ratios B.
#' @param organisms A data.frame containing names of species and the ratios with which these are mixed by the experimentalist.
#' @param bins The number of bins used for hexagonal binning in 'geom_hex'.
#' @return List of three different ggplots.
#' @importFrom ggplot2 ggplot geom_point geom_hline geom_label scale_x_log10 scale_y_log10 theme_classic theme geom_hex geom_density_2d
#' @export
plot_proteome_mix2 = function(species, A, B, organisms, bins=100){
  # setting local vars to None to avoid Notes popping up in CRAN.
  ratio=comma=NULL
  # It only makes the love-hate relationship with R more interesting.

  D = data.frame(species=species, A=A, B=B)
  D = D[species %in% organisms$species,]
  organisms$ratio = with(organisms, B/A)
  o = list()
  max_A = max(D$A)
  base = ggplot(D, aes(x=A, y=B/A))
  o$scatterplot = base +
    geom_point(aes(color=species), size=1) +
    geom_hline(data=organisms, aes(yintercept=ratio), size=1) +
    geom_label(data=organisms, aes(x=max_A, y=ratio, label=species)) +
    scale_x_log10(labels=comma) +
    scale_y_log10(labels=comma, breaks=organisms$ratio) +
    theme_classic() +
    theme(legend.position = "bottom")
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
    geom_hline(data=organisms, aes(yintercept=ratio), size=1) +
    geom_label(data=organisms, aes(x=max_A, y=ratio, label=species)) +
    theme_classic() +
    theme(legend.position = "bottom")
  return(o)
}


#' Plot proteome data.
#'
#' @param X Data.frame/table with columns 'species', 'A', 'B' (and potentially others).
#' @param ... Other parameters to plot_proteome_mix2 (like bins) that don't appear in X already.
#' @return List of three different ggplots.
#' @export
plot_proteome_mix = function(X, ...){
  X = unlist(list(as.list(X), list(...)), F)
  do.call(plot_proteome_mix2, X)
}

#' Get species tags from a species column.
#'
#' @param I data.table with intensities in wide format.
#' @param design experimental design for columns in I.
#' @param sampleComposition composition of spiked in samples
#' @return list with the main plot, scatterplot, and boxplots.
#' @importFrom ggplot2 ggplot geom_hline geom_point geom_boxplot scale_x_log10 scale_y_log10 theme_minimal xlab ylab theme element_blank
#' @importFrom cowplot align_plots plot_grid
#' @export
plot_ratios = function(clean_meds, sampleComposition){
  conditions = colnames(clean_meds)[1:2]
  # scatterplot log(intensity in condition 1) ~ log(ratio of intensities)
  p = ggplot() +
    geom_hline(data=sampleComposition, aes(yintercept=ratios, color=species)) +
    # geom_hex(data=clean_meds, aes(x=get(conditions[1]), y=I_ratio, fill=species), alpha=.3, bins=100) +
    geom_point(data=clean_meds, aes(x=get(conditions[1]), y=I_ratio, color=species),
               alpha=.7, size=1) +
    scale_x_log10() +
    scale_y_log10() +
    theme_minimal() +
    xlab(paste0("log(", conditions[1],")")) +
    ylab("log(Intensity Ratio)") +
    theme(legend.position='left')

  # boxplots log(ratio of intensities)
  b = ggplot() +
    geom_hline(data=sampleComposition, aes(yintercept=ratios, color=species)) +
    geom_boxplot(data=clean_meds, aes(x=species, y=I_ratio, fill=species), alpha=.5) +
    scale_y_log10(position = "right") +
    theme_minimal() +
    ylab("log(Intensity Ratio)") +
    theme(legend.position='none',
          axis.text.x=element_blank(),
          axis.title.x=element_blank(),
          axis.ticks.x=element_blank())
  pb = align_plots(p, b, align = 'h', axis = 'r')
  names(pb) = c('scatterplot', 'boxplot')
  final_plot = plot_grid(pb$scatterplot, pb$boxplot, rel_widths = c(4,1))
  return(list(main=final_plot, scatterplot=p, boxplot=b))
}
