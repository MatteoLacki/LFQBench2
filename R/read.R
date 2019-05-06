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
  if(length(list(...))>0){# some arguments were passed for wide2long
    o = wide2long(...)
  }
  return(o)
}


#' Read an ISOQuant csv peptide report.
#'
#' @param path Path to the report.
#' @return Wide or long data.table
#' @importFrom data.table fread
#' @export
read_isoquant_peptide_report = function(path, ...){
  o = fread(path)
  o[o == ""] = NA
  if(length(list(...))>0){# some arguments were passed for wide2long
    o = wide2long(...)
  }
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
  if(length(list(...))>0){# some arguments were passed for wide2long
    o = wide2long(...)
  }
  return(o)
}
