library(stringr)
library(tidyverse)
library(ggthemes)
library(LFQBench2)
library(cowplot)

# peptides = "~/Projects/LFQBench2/HYE/peptides.csv"
path = '/home/matteo/Projects/LFQBench2/tests/data/ISOQuant_pep_2016-010_HYE110_UDMSE_peptide_quantification_report.csv'
organisms = data.frame(
  name = c("HUMAN","YEAS8", "ECOLI"),
  A = c(  67,     30,       3   ),
  B = c(  67,      3,      30   )
)

hye_plots = function(path,
                     organiosms,
                     condition_replacement="intensity in HYE110_",
                     add_trend=FALSE)
{
  peps = peptide_quantification_report(peptides, "intensity in ")
  peps = peps %>%
    mutate(organism = factor(stringr::str_split_fixed(peps$entry, "_", 2)[,2]),
           condition = stringr::str_replace(condition, condition_replacement,"")) %>%
    separate(condition, c("sample", "run"), sep=' ', remove = F) %>%
    mutate(run = as.integer(run))
  assertthat::assert_that(all(organisms$name %in% levels(peps$organism)))

  HYE =
    peps %>% group_by(sample, organism, entry) %>%
    summarize(intensity=median(intensity)) %>%
    ungroup %>%
    filter(organism %in% organisms$name) %>%
    spread(sample, intensity) %>%
    na.omit()

  real_ratios = organisms %>% mutate(ratios = A/B) %>% select(name, ratios) %>% rename(organism=name)

  density2d =
    HYE %>%
    ggplot(aes(x=A, y=A/B, color=organism)) +
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


X = hye_plots(path, organisms)

ggsave("/home/matteo/Projects/LFQBench2/tests/plots/no_trend_lines.png",
       width = 12, height=20, units='cm')
ggsave("/home/matteo/Projects/LFQBench2/tests/plots/with_trend_lines.png",
       width = 12, height=20, units='cm')

ggsave("/home/matteo/Projects/LFQBench2/tests/plots/density.png",
       width = 12, height=12, units='cm')
