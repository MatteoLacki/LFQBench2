library(LFQBench2)
library(stringr)
library(data.table)

dp = "~/Projects/LFQBench2/data/2019-068/long_runs/2019-068_PYE_1_3_IMS_user designed 20200131-171545_"
peptide_rep = paste0(dp, "peptide_quantification_report.csv")
protein_rep = paste0(dp, "quantification_report.xlsx")

P = read_report(peptide_rep,
                I_col_pattern="intensity in 2019-068-03 SYE (:condition:.) 1:3 (:tech_repl:.)")
R = read_report(protein_rep,
                I_col_pattern="2019-068-03 SYE (:condition:.) 1:3 (:tech_repl:.)")

D = R
species_col = 'accession'
sampleComposition = data.frame(
  species = c("HUMAN","YEAS8", "ECOLI"),
  A       = c(  135,     03,      12  ),
  B       = c(  135,     09,      06  )
)

if( "origin" %in% colnames(D) ) stop('Rename column "origin", as we use it!')
species = unlist(D[, species_col, with=FALSE])
D$origin = str_match(species, ".*_(.*)")[,2]
species_present = unique(origin)
if(!all(sampleComposition$species %in% species_present)) stop('Species not found among the peptides: ')


table(origin)


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
