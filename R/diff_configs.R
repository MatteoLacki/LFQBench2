#' Open ISOQuant config.
#'
#' Open ISOQuant config from an excel protein quantification report.
#'
#' @param path
#' @return data.table
#' @importFrom data.table as.data.table
#' @importFrom readxl read_excel
#' @export
read_isoquant_config_from_report = function(path){
    conf = read_excel(path, sheet='config')
    conf = as.data.table(conf[2:nrow(conf), 3:ncol(conf)])
    return(conf)
}

#TODO: add read_isoquant_config_from_ini and read_isoquant_config. 


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

