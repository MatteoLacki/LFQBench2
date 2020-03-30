#' Read an ISOQuant protein report.
#'
#' @param path Path to the protein report.
#' @param sheet Which excell sheet should be imported [default="TOP3 quantification"]
#' @param ... Optional parameters for the wide2long function.
#' @return Wide or long data.table
#' @importFrom data.table as.data.table
#' @importFrom readxl read_excel
#' @export
read_isoquant_protein_report = function(path,
                                        sheet="TOP3 quantification",
                                        ...
){
  o = as.data.table(read_excel(path, sheet=sheet, skip=1))
  o[o == ""] = NA
  o[, grep("AVERAGE", colnames(o)):=NULL] # remove AVERAGEs
  attr(o, 'orientation') = 'wide'
  class(o) = append(class(o), "protein")
  if(length(list(...))>0) o = wide2long(o, ...)
  return(o)
}


#' Read an ISOQuant csv peptide report.
#'
#' @param path Path to the report.
#' @param ... Optional parameters for the wide2long function.
#' @return Wide or long data.table
#' @importFrom data.table fread
#' @export
read_isoquant_peptide_report = function(path, ...){
  o = fread(path)
  o[o == ""] = NA
  attr(o, 'orientation') = 'wide'
  class(o) = append(class(o), "peptide")
  if(length(list(...))>0) o = wide2long(o, ...)
  return(o)
}


#' Read a simple protein ISOQuant report.
#'
#' @param path Path to the report.
#' @param ... Optional parameters for the wide2long function.
#' @return Wide or long data.table
#' @importFrom data.table fread melt
#' @importFrom stringr str_which
#' @export
read_isoquant_simple_protein_report = function(path, ...){
  o = fread(path)
  o[o == ""] = NA
  attr(o, 'orientation') = 'wide'
  class(o) = append(class(o), "protein")
  if(length(list(...))>0) o = wide2long(o, ...)
  return(o)
}


#' Read a file with intensities (peptide/protein/whatever) in columns (wide format).
#'
#' All empty cells are replaced with NAs.
#' Optionally, columns entirely filled with NAs are droped.
#'
#' @param path Path to the report.
#' @param drop_na_columns Drop empty columns.
#' @param ... Optional parameters for either data.table::fread or readxl::read_excel
#' @return Wide data.table.
#' @importFrom data.table fread
#' @importFrom readxl read_excel
#' @export
read_wide_report = function(path, drop_na_columns=T, ...){
  if(tools::file_ext(path) == 'csv'){
    o = fread(path, ...)
  } else {
    o = read_excel(path, ...)
  }
  o = as.data.table(o)
  o[o == ""] = NA
  attr(o, 'orientation') = 'wide'
  if(drop_na_columns){
    cols_to_elim = o[,lapply(.SD, function(x) sum(is.na(x)))] == nrow(o)
    cols_to_elim = colnames(cols_to_elim)[cols_to_elim]
    if(length(cols_to_elim) > 0) o[,(cols_to_elim):=NULL]
  }
  return(o)
}

#' Read a objects from paths to a named list.
#'
#' Reads objects from paths and makes a list with opened objects named after the paths.
#'
#' @param paths Array of paths.
#' @param reader Function used to read objects stored under paths.
#' @param ... Further arguments to the reader.
#' @return A list of opened objects.
#' @export
lread = function(paths, reader, ...){
  res = lapply(paths, reader, ...)
  names(res) = paths
  return(res)
}
