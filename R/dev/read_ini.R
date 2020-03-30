library(LFQBench2)
library(data.table)

path = "~/Projects/LFQBench2/data/20200206_isoquant.ini"

read_isoquant_configs("~/Projects/LFQBenchData/data/20200206_isoquant.ini")
read_isoquant_configs("~/Projects/lab_analysis/kuner/kuner_2018_072/data/obelix/output/2018-072 Kuner Cerebbellum Obelix_user designed 20190206-142325_quantification_report.xlsx")

paths = c(A="~/Projects/LFQBenchData/data/20200206_isoquant.ini",
          B='~/Projects/lab_analysis/kuner/kuner_2018_072/data/obelix/output/2018-072 Kuner Cerebbellum Obelix_user designed 20190206-142325_quantification_report.xlsx')

read_isoquant_configs(paths)
View(diff_isoquant_configs(read_isoquant_configs(paths)))

