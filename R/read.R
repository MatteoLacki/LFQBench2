' Read an ISOQuant protein report.
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


#' Read a file with intensities (peptide/protein/whatever).
#'
#' Optionally, collect the intensity columns into one column (long format).
#'
#' @param path Path to the report.
#' @param ... Optional parameters for the wide2long function.
#' @return Wide or long data.table
#' @importFrom data.table fread
#' @importFrom readxl read_excel
#' @export
read_report = function(path,
                       I_col_pattern="",
                       sheet="TOP3 quantification",
                       drop_na_columns=T){
  if(tools::file_ext(path) == 'csv'){
    o = fread(path)
  } else {
    o = read_excel(path, sheet=sheet, skip=1)
  }
  o = as.data.table(o)
  o[o == ""] = NA
  attr(o, 'orientation') = 'wide'
  if(drop_na_columns){
    cols_to_elim = o[,lapply(.SD, function(x) sum(is.na(x)))] == nrow(o)
    cols_to_elim = colnames(cols_to_elim)[cols_to_elim]
    if(length(cols_to_elim) > 0) o[,(cols_to_elim):=NULL]
  }
  if(I_col_pattern != '') return(wide2long(o, I_col_pattern))
  else return(o)
}
