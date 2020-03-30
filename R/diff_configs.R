#' Read ISOQuant ini configuration.
#'
#' Read a separate .ini file containing ISOQuant configuration.
#'
#' @param path Path to the config file (output of ISOQuant config exporter).
#' @return data.table with config pairs: parameter-value
#' @importFrom data.table fread
read_isoquant_config_from_ini = function(path){
  conf = fread(path, sep='=', skip=1L, col.names=c('parameter','value'))
  return(conf)
}

#' Open ISOQuant config.
#'
#' Open ISOQuant config from an excel protein quantification report.
#'
#' @param path Read configuration from report.
#' @return data.table
#' @importFrom data.table as.data.table
#' @importFrom readxl read_excel
read_isoquant_config_from_report = function(path){
    conf = read_excel(path, sheet='config')
    conf = as.data.table(conf[2:nrow(conf), 3:ncol(conf)])
    return(conf)
}

#' Show differences between config files in ISOQuant protein quantification reports.
#' 
#' Outputs a data.table with parameters in the first column and values
#' for particular configurations in the other.
#' 
#' @param configs Named list of configs.
#' @return A data.table with parameters that differ.
#' @importFrom data.table rbindlist dcast
#' @export
diff_isoquant_configs = function(configs){
  lconfs = rbindlist(configs, idcol = 'organ')
  wconfs = dcast(lconfs, parameter~organ, value.var='value', 
                 fun.aggregate = function(x) paste(x, collapse=' '))
  any_diffs = apply(wconfs[,-1], 1, function(v) any(v!=v[1]))
  res = wconfs[any_diffs]
  if (nrow(res) == 0) print('Configs are the same.')
  return(res)
}

#' Read ISOQuant configuration.
#' 
#' Read in the parameters of a project.
#' 
#' @param path Path to the config file (output of ISOQuant config exporter) or a protein quantification report.
#' @param Additional parameters to the specific reader.
#' @return data.table with config pairs: parameter-value
#' @importFrom data.table fread
read_isoquant_config = function(path, ...)
  switch(
    tools::file_ext(path),
    'ini' = read_isoquant_config_from_ini,
    'xlsx' = read_isoquant_config_from_report,
    stop('File type with his extension not handled.')
  )(path)

Listolize = function(foo, ...) function(x) if(length(x)==1) foo(x) else lapply(x,foo,...)

#' Read ISOQuant configurations.
#' 
#' Read in the parameters from either ini files or protein quantification reports.
#' 
#' @param paths Paths to the config file (output of ISOQuant config exporter) or a protein quantification report. If one path is submitted, the output will be a single data.table instead of a list of data.tables.
#' @param Additional parameters to the specific reader.
#' @return list of data.tables or a single data.table with config pairs: parameter-value
#' @importFrom data.table fread
#' @export
read_isoquant_configs = Listolize(read_isoquant_config)
