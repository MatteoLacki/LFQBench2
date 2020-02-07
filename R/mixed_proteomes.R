#' Get species tags from a species column.
#'
#' This works on the output of 'get_ratios_of_medians'.
#'
#' @param meds Median intensities to plot.
#' @param sampleComposition composition of spiked in samples (with column ratios)
#' @return a ggplot showing the ratios of intensities in two different conditions
#' @importFrom ggplot2 ggplot geom_hline geom_point geom_smooth scale_x_log10 scale_y_log10 theme_minimal xlab ylab theme
#' @export
plot_scatter = function(meds, sampleComposition){
  p = ggplot() +
    geom_hline(data=sampleComposition, aes(yintercept=ratios, color=species)) +
    geom_point(data=meds, aes(x=get(colnames(meds)[1]), y=I_ratio, color=species),
               alpha=.5, size=1) +
    geom_smooth(data=meds, aes(x=get(colnames(meds)[1]),
                               y=I_ratio, color=species),
                method='auto',
                se=F) +
    scale_x_log10() +
    scale_y_log10() +
    theme_minimal() +
    xlab(paste("Intensity of", colnames(meds)[1])) +
    ylab(paste('Intensity Ratio (', colnames(meds)[1], ':', colnames(meds)[2],')'))
  return(p)
}

#' Get species tags from a species column.
#'
#' This works on the output of 'get_ratios_of_medians'.
#'
#' @param meds Median intensities to plot.
#' @param sampleComposition composition of spiked in samples (with column ratios)
#' @return a ggplot showing the ratios of intensities in two different conditions
#' @importFrom ggplot2 ggplot geom_hline aes geom_boxplot scale_y_log10 theme_minimal xlab ylab theme
#' @export
plot_boxplots = function(meds, sampleComposition){
  p = ggplot() +
    geom_hline(data=sampleComposition,
               aes(yintercept=ratios, color=species)) +
    geom_boxplot(data=meds,
                 aes(x=species, y=I_ratio, fill=species), alpha=.5) +
    theme_minimal() +
    xlab("Species") +
    ylab(paste('Intensity Ratio (', colnames(meds)[1], ':', colnames(meds)[2],')'))
  return(p)
}

#' Get species tags from a species column.
#'
#' This works on the output of 'get_ratios_of_medians'.
#'
#' @param meds Median intensities to plot.
#' @param sampleComposition composition of spiked in samples (with column ratios)
#' @return a ggplot showing the ratios of intensities in two different conditions
#' @importFrom ggplot2 ggplot geom_vline geom_density geom_smooth scale_x_log10 scale_y_log10 theme_minimal xlab ylab theme
#' @export
plot_density = function(meds, sampleComposition){
  p = ggplot() +
    geom_vline(data=sampleComposition, aes(xintercept=ratios, color=species)) +
    geom_density(data=meds, aes(x=I_ratio, fill=species), alpha=.5) +
    theme_minimal() +
    scale_x_log10() +
    xlab(paste('Intensity Ratio (', colnames(meds)[1], ':', colnames(meds)[2],')'))
  return(p)
}

#' Get species tags from a species column.
#'
#' @param meds Median intensities to plot.
#' @param sampleComposition composition of spiked in samples (with column ratios)
#' @return a ggplot showing the ratios of intensities in two different conditions
#' @importFrom ggplot2 coord_flip scale_y_reverse theme scale_y_log10 element_blank
#' @importFrom cowplot align_plots plot_grid
#' @export
plot_ratios = function(meds, sampleComposition){
  dens2 = plot_density(meds, sampleComposition) +
          coord_flip() + scale_y_reverse() + theme(legend.position='left')
  boxp2 = plot_boxplots(meds, sampleComposition) +
          scale_y_log10(position = "right") +
          theme(legend.position='none',
                axis.text.x=element_blank(),
                axis.title.x=element_blank(),
                axis.ticks.x=element_blank())
  scat2 = plot_scatter(meds, sampleComposition) +
          theme(legend.position='none', axis.title.y=element_blank())
  p = align_plots(dens2, scat2, boxp2, align = 'h', axis = 'r')
  return(plot_grid(p[[1]], p[[2]], p[[3]], rel_widths = c(2,4,1), nrow=1))
}
