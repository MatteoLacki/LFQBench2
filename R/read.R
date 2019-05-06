#' Read an ISOQuant protein report.
#'
#' @param path Path to the protein report.
#' @param long_df Should the output be in the long format? [default = FALSE]
#' @param I_col_pattern A pattern selecting columns with intensities [default = '[A|B][:space:][:digit:]']
#' @param I_col_pattern_group_names Names of the groups defined in the intensity pattern.
#' @param sheet Which excell sheet should be imported [default="TOP3 quantification"]
#' @return Wide or long data.table
#' @importFrom data.table as.data.table melt
#' @importFrom readxl read_excel
#' @importFrom stringr str_match str_which
#' @export
read_isoquant_protein_report = function(path,
                                        long_df=FALSE,
                                        I_col_pattern="[A|B][:space:][:digit:]",
                                        I_col_pattern_group_names=NA,
                                        sheet="TOP3 quantification"){
  o = as.data.table(read_excel(path, sheet=sheet, skip=1))
  o[o == ""] = NA
  o[, grep("AVERAGE",colnames(o)):=NULL] # add path, remove AVEAGEs
  if(long_df){
    I_cols = as.data.table(str_match(colnames(o), I_col_pattern))
    if(any(is.na(I_col_pattern_group_names))){
      # there were no group names, os some where NA
      I_col_pattern_group_names = paste("group", 1:(ncol(I_cols)-1), sep='_')
    }
    colnames(I_cols) = c('I_col_name', I_col_pattern_group_names)
    idx_intensity = str_which(colnames(o), I_col_pattern)
    I_cols = I_cols[idx_intensity,]
    o = melt(o,
             measure.vars=idx_intensity,
             na.rm=T,
             variable.factor=F,
             variable.name='I_col_name',
             value.name="intensity")[I_cols,
                                     on='I_col_name']
  }
  return(o)
}

#' Read an ISOQuant csv peptide report.
#'
#' @param path Path to the report.
#' @param long_df Should the output be in the long format? [default = FALSE]
#' @param intensity_pattern A pattern that will select columns with intensities [default = "intensity in"]
#' @return Wide or long data.table
#' @import data.table
#' @export
read_isoquant_peptide_report = function(path,
                                        long_df = FALSE,
                                        intensity_pattern = "intensity in"){
  o = fread(path)
  o[o == ""] = NA
  o$path = path
  if(long_df) o = melt(o,
                       measure.vars=patterns(intensity_pattern),
                       na.rm=T,
                       variable.factor=F,
                       variable.name="cond",
                       value.name="intensity")
  return(o)
}

#' Read a simple protein ISOQuant report.
#'
#' @param path Path to the report.
#' @param long_df Should the output be in the long format? [default = FALSE]
#' @param intensity_pattern A pattern that will select columns with intensities [default = '[A|B][:space:][:digit:]']
#' @return Wide or long data.table
#' @importFrom data.table fread melt
#' @importFrom stringr str_which
#' @export
read_isoquant_simple_protein_report = function(path,
                                               long_df=FALSE,
                                               intensity_pattern="[A|B][:space:][:digit:]"){
  o = fread(path)
  o[o == ""] = NA
  o$path = path
  if(long_df) o = melt(o, measure.vars=str_which(colnames(o), intensity_pattern),
                          na.rm=T,
                          variable.factor=F,
                          variable.name="cond",
                          value.name="intensity")
  return(o)
}

#' Read an IsoQuant report.
#'
#' @param report Which report is being read? ["protein", "peptide", "simple_protein"]
#' @param ... Parameters to the called function.
#' @return Wide or long data.table
#' @export
read_isoquant = function(report="protein", ...)
{
  parse=function(...) stop('Report type can be either "protein", "peptide", or "simple_protein".') # guardian
  if(report == "protein") parse=read_isoquant_protein_report
  if(report == "peptide") parse=read_isoquant_peptide_report
  if(report == "simple_protein") parse=read_isoquant_simple_protein_report
  return(parse(...))
}
