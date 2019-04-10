library(LFQBench2)

path = "~/Projects/LFQBench2/data/peptides.csv"
path = path.expand(path)

D = read_isoquant_peptide_report(path, long_df=T)

preprocess_peptides_4_intensity_plots(D)


