#' Plot relative ratios of the mixed proteomes.
#'
#' @param path Path to the human-yeast-ecoli report.
#' @param organisms A data.frame with columns 'name' (of the species), 'A' (relative ratios of proteome in sample A), and 'B' (relative ratios of proteome in sample B).
#' @param condition_replacement Part of the column name with intensities in the original report, that must be replaced by an empty string.
#' @param add_trend Add in lines describing the relationship between median intensity and the ratios of median intensities.
#' @return A list with two ggplot objects.
#' @export
hye_plots = function(path,
                     organisms,
                     condition_replacement="intensity in HYE110_",
                     add_trend=FALSE)
{
  peps = peptide_quantification_report(path, "intensity in ")
  peps = mutate(peps,
                organism = factor(str_split_fixed(peps$entry, "_", 2)[,2]),
                condition = str_replace(condition, condition_replacement,"")) %>%
    separate(condition, c("sample", "run"), sep=' ', remove = F) %>%
    mutate(run = as.integer(run))
  stopifnot(all(organisms$name %in% levels(peps$organism)))

  HYE = peps %>%
    group_by(sample, organism, entry) %>%
    summarize(intensity=median(intensity)) %>%
    ungroup %>%
    filter(organism %in% organisms$name) %>%
    spread(sample, intensity) %>%
    na.omit()

  real_ratios = organisms %>%
    mutate(ratios = A/B) %>%
    select(name, ratios) %>%
    rename(organism=name)

  density2d =
    ggplot(HYE, aes(x=A, y=A/B, color=organism)) +
    geom_hline(data = real_ratios, aes(yintercept=ratios)) +
    geom_density_2d(size=1, alpha=.8, n=100, contour=T) +
    scale_x_continuous(trans = 'log10') +
    scale_y_continuous(trans = 'log10') +
    theme_tufte() +
    xlab("Intensity A") +
    ylab("Intensity A / Intensity B") +
    theme(legend.position="bottom")

  if(add_trend) density2d = density2d + geom_smooth(se = F, linetype='dashed')

  density =
    HYE %>%
    ggplot(aes(x = A / B, color=organism, fill=organism)) +
    geom_density(alpha=.5) +
    scale_x_continuous(trans = 'log10') +
    theme_tufte() +
    xlab("Intensity A / Intensity B") +
    theme(legend.position="bottom")

  return(list(density=density, density2d=density2d))
}

