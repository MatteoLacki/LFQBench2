#' Read an ISOQuant protein report.
#'
#' @param path Path to the protein report.
#' @param long_df Should the output be in the long format? [default = FALSE]
#' @param intensity_pattern A pattern that will select columns with intensities [default = '[A|B][:space:][:digit:]']
#' @param sheet Which excell sheet should be imported [default="TOP3 quantification"]
#' @return Wide or long data.table
#' @export
read_isoquant_protein_report = function(path, long_df=FALSE, intensity_pattern="[A|B][:space:][:digit:]", sheet="TOP3 quantification")
{
  o = as.data.table(read_excel(path, sheet=sheet, skip=1))
  o[o == ""] = NA
  o[, path:=path][, grep("AVERAGE", colnames(o)):=NULL] # add path, remove AVEAGEs
  if(long_df) o = melt(o,
                       measure.vars=str_which(colnames(o), intensity_pattern),
                       na.rm=T,
                       variable.factor=F,
                       variable.name="cond",
                       value.name="intensity")
  return(o)
}


#' Read an ISOQuant csv peptide report.
#'
#' @param path Path to the report.
#' @param long_df Should the output be in the long format? [default = FALSE]
#' @param intensity_pattern A pattern that will select columns with intensities [default = "intensity in"]
#' @return Wide or long data.table
#' @export
read_isoquant_peptide_report = function(path, long_df = FALSE, intensity_pattern = "intensity in")
{
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
#' @export
read_isoquant_simple_protein_report = function(path, long_df=FALSE, intensity_pattern="[A|B][:space:][:digit:]"){
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

