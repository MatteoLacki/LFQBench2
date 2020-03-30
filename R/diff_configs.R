#' Open ISOQuant config.
#'
#' Open ISOQuant config from an excel protein quantification report.
#'
#' @param path Read configuration from report.
#' @return data.table
#' @importFrom data.table as.data.table
#' @importFrom readxl read_excel
#' @export
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
#' @export 
read_isoquant_config = function(path, ...)
  switch(
    tools::file_ext(path),
    'ini' = read_isoquant_config_from_ini,
    'xlsx' = read_isoquant_config_from_report,
    stop('File type with his extension not handled.')
  )(path)


