library(LFQBench2)
library(ggplot2)

files = "/Users/matteo/Projects/LFQBench2/data/batch"
files = list.files(files, full.names = T)

x = read_isoquant_protein_report(files[1], long_df = FALSE)
x
read_isoquant_protein_report(files[1], long_df = TRUE,
                             intensity_pattern = "2018-072-0[:digit:]")

D = list()
for(f in files){
  D[[f]] = read_isoquant_protein_report(f, long_df = TRUE,
                                        intensity_pattern = "2018-072")
}

D = lapply(files,
           read_isoquant_protein_report,
           long_df = TRUE,
           intensity_pattern = "2018-072")

X = data.table::rbindlist(D, fill=T, use.names = T)
colnames(X)
View(X)


ggplot(X, aes(x=intensity)) + geom_histogram() + facet_wrap(~cond) + scale_x_log10()
