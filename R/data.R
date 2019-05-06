#' An example of a simple protein report prepared with IsoQuant.
#'
#' The dataset contains protein intensities gathered under two conditions (A and B).
#' Each condition contains a hybrid of proteome samples prepared in known ratios.
#' In each condition, four technical replicates of measurements were performed.
#'
#' @format A data.table with 3118 rows and 9 variables:
#' \describe{
#'   \item{entry}{The protein PDB entry}
#'   \item{A 1}{Intensities in condition A, first replicate}
#'   \item{A 2}{Intensities in condition A, second replicate}
#'   ...
#' }
"simple_protein_report"
