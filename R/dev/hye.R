path = '~/Projects/LFQBench2/tests/data/ISOQuant_pep_2016-010_HYE110_UDMSE_peptide_quantification_report.csv'
path = path.expand(path)
D = LFQBench2::read_isoquant_peptide_report(path, T, "intensity in")

