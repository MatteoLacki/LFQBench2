library(LFQBench2)

dp = "~/Projects/LFQBench2/data/2019-068/long_runs/2019-068_PYE_1_3_IMS_user designed 20200131-171545_"
peptide_rep = paste0(dp, "peptide_quantification_report.csv")
protein_rep = paste0(dp, "quantification_report.xlsx")

P = read_isoquant_peptide_report(peptide_rep,
  I_col_pattern="intensity in 2019-068-03 SYE (:condition:.) 1:3 (:tech_repl:.)")

R = read_isoquant_protein_report(protein_rep,
  I_col_pattern="(:year:....)-(:sample:...)-(:no:..) SYE (:condition:.) 1:3 (:tech_repl:.)")

R = read_isoquant_protein_report(protein_rep,
                                 I_col_pattern="2019-(:UTE:...)-.* SYE (:condition:.) 1:3 (:replicate:.)")


read_isoquant_protein_report(protein_rep)
D = R

data4intensityPlots = function(D,
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




preprocess_peptides_4_intensity_plots(P)
