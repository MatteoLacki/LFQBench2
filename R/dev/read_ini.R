library(LFQBench2)
library(data.table)


path = "~/Projects/LFQBench2/data/20200206_isoquant.ini"


#' Read ISOQuant ini report.
#' 
#' Read a separate .ini file containing ISOQuant configuration.
#' 
#' @param path Path to the config file (output of ISOQuant config exporter).
#' @return data.table with config pairs: parameter-value
#' @importFrom data.table fread
#' @export 
read_isoquant_config_from_ini = function(path){
  conf = fread(path, sep='=', skip=1L, col.names=c('parameter','value'))
  return(conf)
}

read_isoquan_config = function(path, ...)
  switch(
    tools::file_ext(path),
    'ini' = read_isoquant_config_from_ini,
    'xlsx' = read_isoquant_config_from_report,
    stop('File type with his extension not handled.')
  )(path)


A = read_isoquant_config_from_ini("~/Projects/LFQBench2/data/20200206_isoquant.ini")
B = read_isoquant_config_from_report('~/Projects/lab_analysis/kuner/kuner_2018_072/data/obelix/output/2018-072 Kuner Cerebbellum Obelix_user designed 20190206-142325_quantification_report.xlsx')

View(diff_isoquant_configs(list(a=A, b=B)))

View(A)
