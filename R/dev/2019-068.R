library(LFQBench2)

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

LI = data.table::melt(I$I, variable.name='I_col_name')
merge(LI, I$design, by='I_col_name')

species = get_species(species_col=R[['accession']],
                      species_pattern=".*_(.*)")
MI = get_ratios_of_medians(I$I, I$design, species, sampleComposition)
plots = plot_ratios(MI$I_cleanMeds, MI$sampleComposition)
plots$main



# peptides
P = read_wide_report(peptide_rep)
I = get_intensities(P,
                    I_col_pattern=".* SYE (:condition:.) 1:3 (:tech_repl:.)")
species = get_species(species_col=P[['accession']],
                      species_pattern=".*_(.*)")
MI = get_ratios_of_medians(I$I, I$design, species, sampleComposition)
plots = plot_ratios(MI$I_cleanMeds, MI$sampleComposition)
plots$main

# I_col_pattern=
