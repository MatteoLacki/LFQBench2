ecoli = I_meds_no_NA[species=='ECOLI']
hist(abs(ecoli$I_ratio_expected - ecoli$I_ratio_real))
median(abs(log10(ecoli$I_ratio_expected) - log10(ecoli$I_ratio_real)))

library(ggplot2)

plot_hist = function(meds, sampleComposition){
  emp_meds = meds[,.(emp_med=median(I_ratio,na.rm=T)),by=species]
  p = ggplot() +
    geom_histogram(data=meds, aes(x=I_ratio, fill=species), alpha=.2) +
    geom_vline(data=sampleComposition, aes(xintercept=ratios, color=species)) +
    geom_vline(data=emp_meds, aes(xintercept=emp_med, group=species), linetype='dashed') +
    theme_minimal() +
    scale_x_log10() +
    xlab(paste('Intensity Ratio (', colnames(meds)[1], ':', colnames(meds)[2],')')) +
    facet_grid(.~species)
  return(p)
}
plot_hist(I_meds, sC) + coord_flip()
sampleComposition = sC

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
    theme(legend.position='left')
  hist2 = plot_hist(meds, sampleComposition) +
    scale_x_log10(position = "top") +
    # theme(legend.position='none',
    #       axis.text.y=element_blank(),
    #       axis.title.y=element_blank(),
    #       axis.ticks.y=element_blank(),
    #       strip.background = element_blank(),
    #       strip.text.x = element_blank()) +
    coord_flip()
  p = align_plots(scat2, hist2, align = 'h', axis = 'ltb')
  plot_grid(p[[1]], p[[2]], rel_widths = c(4,2), nrow=1)
}
