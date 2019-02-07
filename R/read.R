require(dplyr)
require(tidyr)

#' Parse an excel ISOQuant protein report.
#'
#' Prepare the data in the long format, so that it is easier to combine it.
#'
#' @param path Path
#' @param col_pattern A pattern that will select columns with intensities.
#' @param sheet Which excell sheet should be imported?
#' @param sample_no2bio_rep An additional data.frame mapping sample numbers to biological replicates.
#' @return Standard long format data frame object.
#' @export
isoquant_report = function(path,
                           col_pattern,
                           sheet="TOP3 quantification",
                           sample_no2bio_rep=NA)
{
  contains = dplyr::contains
  DW = readxl::read_excel(path, sheet=sheet, skip=1)
  DW$file = path
  DW = dplyr::select(DW, -contains('AVERAGE'))
  # averages are not interesting for the analysis and we can easily get them later on.
  DL = tidyr::gather(DW, "condition", "intensity",
                     contains(col_pattern), na.rm = T)
  # na.rm makes the long format meaningfully smaller.
  colnames(DL) = make.names(colnames(DL))
  DL = tidyr::separate(DL, condition, c('project', 'partner', 'run'), sep=" ")
  get_k_part = function(strings, k) sapply(strsplit(strings, '-'), '[[', k)
  DL = dplyr::mutate(DL, run = as.integer(run),
              sample_no = as.integer(get_k_part(project, 3)))
  if(typeof(sample_no2bio_rep) != 'logical'){
    DL = dplyr::left_join(DL, sample_no2bio_rep, by='sample_no')
  }
  DL
}


