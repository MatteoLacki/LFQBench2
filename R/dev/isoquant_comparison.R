# Comparing different executions of the same isoquant projects
library(LFQBench2)

dp = "~/Projects/LFQBench2/data/iso_comparison"
comps = list.files(dp)

peptides = Sys.glob(file.path(dp,'*/*.csv'))
proteins = Sys.glob(file.path(dp,'*/*.xlsx'))
names(proteins) = names(peptides) = comps

peptides = lapply(peptides, read_wide_report)
proteins = lapply(proteins, read_wide_report, skip=1, sheet="TOP3 quantification")

sapply(peptides, nrow)
sapply(proteins, nrow)

P = peptides[[1]]

unique_peptides = lapply(peptides, function(P){
  I = get_intensities(P, I_col_pattern="intensity in 2019-013-(:cond:...) 1")
  uni = sort(paste(P$sequence, P$modifier, P$frag_string, sep="_"))
  return(uni)
})

combs = combn(length(peptides), 2, simplify=F)
sapply(combs, function(x) all(unique_peptides[[x[1]]] == unique_peptides[[x[2]]]))

unique_proteins = lapply(proteins, function(P){
  I = get_intensities(P, I_col_pattern="2019-013-(:cond:...) 1")
  uni = sort(paste(P$sequence, P$modifier, P$frag_string, sep="_"))
  return(uni)
})
sapply(combs, function(x) all(unique_peptides[[x[1]]] == unique_peptides[[x[2]]]))
