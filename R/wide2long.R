#' Reshape a wide report into a long format.
#'
#' Data in wide format has one peptide/protein per row, and multple columns with intensities.
#' Data in long format has one intensity per row and more than one row corresponds to the same molecule.
#' The long format is convenient for merging multiple reports and for plotting with ggplot2.
#'
#' @param wide_report A report in a wide format.
#' @param I_col_pattern A pattern selecting columns with intensities; consult the `stringr` package.
#' @param I_col_pattern_group_names Names of the groups defined in the intensity pattern. If left NA, group names will be automatically generated.
#' @return A report in a long format.
#' @importFrom data.table as.data.table melt
#' @importFrom stringr str_match str_which
#' @examples
#' data(simple_protein_report)
#' # Columns 'A 1', 'A 2', 'A 3'. 'A 4', 'B 1', 'B 2', 'B 3', 'B 4'.
#' # wide2long(simple_protein_report, '(.) (.)', c('condition', 'technical_replicate'))
#' @export
wide2long = function(wide_report,
                     I_col_pattern,
                     I_col_pattern_group_names=NA){
    I_cols = as.data.table(str_match(colnames(wide_report), I_col_pattern))
    if(any(is.na(I_col_pattern_group_names))){
      # there were no group names, os some where NA
      I_col_pattern_group_names = paste("group", 1:(ncol(I_cols)-1), sep='_')
    }
    colnames(I_cols) = c('I_col_name', I_col_pattern_group_names)
    idx_intensity = str_which(colnames(wide_report), I_col_pattern)
    I_cols = I_cols[idx_intensity,]
    long_report = melt(wide_report,
                       measure.vars=idx_intensity,
                       na.rm=T,
                       variable.factor=F,
                       variable.name='I_col_name',
                       value.name="intensity")[I_cols, on='I_col_name']
  return(long_report)
}
