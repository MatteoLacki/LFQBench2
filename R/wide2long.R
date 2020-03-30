#' Parse column pattern.
#'
#' The parser uses a slighttly modified version of 'stringr' library.
#' The modification lets you name the groups.
#' A group is a regular expression in brackets, like '(...)'.
#' You can name the group by supplying it between two columns, for instance
#' (:condition:...) will match a group of 3 symbols (the three dots), and call
#' that group 'condition'.
#'
#' @param s Teh pattern to match
#' @return a list with the pattern without group names, and the found names.
#' @importFrom stringr str_extract_all str_extract str_sub str_replace_all
#' @export
parse_pattern = function(s){
  names = str_extract_all(s, "\\([^\\)]*\\)")[[1]]
  if(length(names) == 0) stop(paste0("Your 'PPPATTERN' has no groups [i.e. (.), or (:name:)]: '", s,"'"))
  names = str_extract(names, "\\(\\:[^:]+:")
  names = str_sub(names, 3L, -2L)# no brackets
  names[is.na(names)] = paste("group", 1:sum(is.na(names)), sep='_')
  s_out = str_replace_all(s, "\\(\\:[^:]+:", "(")
  return(list(pattern=s_out, names=names))
}


#' Reshape a wide report into a long format.
#'
#' Data in wide format has one peptide/protein per row, and multple columns with intensities.
#' Data in long format has one intensity per row and more than one row corresponds to the same molecule.
#' The long format is convenient for merging multiple reports and for plotting with ggplot2.
#'
#' @param wide_report A report in a wide format.
#' @param I_col_pattern A pattern selecting columns with intensities; consult the `stringr` package. Additionally, you can specify the group name by including it between the colons.
#' @return A report in a long format.
#' @importFrom data.table as.data.table melt
#' @importFrom stringr str_match str_which
#' @examples
#' data(simple_protein_report)
#' # Columns 'A 1', 'A 2', 'A 3'. 'A 4', 'B 1', 'B 2', 'B 3', 'B 4'.
#' # wide2long(simple_protein_report, '(:condition:.) (:technical_replicate:.)')
#' @export
wide2long = function(wide_report, I_col_pattern){
  p_pat = parse_pattern(I_col_pattern)
  I_cols = str_match_all(colnames(wide_report), p_pat$pattern)
  where_pattern = sapply(I_cols, length) > 0
  idx_intensity = colnames(wide_report)[where_pattern]
  if(!any(where_pattern)) stop("Pattern not found among column names.")
  I_cols = rbindlist(lapply(I_cols[where_pattern], as.data.frame))
  colnames(I_cols) = c("I_col_name", p_pat$names)
  long_report = melt(wide_report,
                     measure.vars=idx_intensity,
                     na.rm=T,
                     variable.factor=F,
                     variable.name='I_col_name',
                     value.name="intensity")[I_cols, on='I_col_name']
  attr(long_report, 'groups') = p_pat$names
  attr(long_report, 'orientation') = 'long'
  class(long_report) = class(wide_report)
  return(long_report)
}



#' Read and combine multiple reports.
#' 
#' Read in, transform from wide to long format, and bind the results togeter.
#' Add in the 'file' column to represent the original report.
#' 
#' @param report Character vector with paths to the read in.
#' @param ... Further parameters to read_isoquant_protein_report.
#' @return A data.table with combined results.
#' @export
read_isoquant_protein_reports = function(reports, ...){
  DL = lread(reports, read_isoquant_protein_report, ...)
  DL = data.table::rbindlist(DL, idcol='file')
  colnames(DL) = make.names(colnames(DL)) #TODO: this should be in the bloody read_isoquant_protein_report
  DL  
}
