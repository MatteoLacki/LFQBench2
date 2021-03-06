% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/wide2long.R
\name{wide2long}
\alias{wide2long}
\title{Reshape a wide report into a long format.}
\usage{
wide2long(wide_report, I_col_pattern)
}
\arguments{
\item{wide_report}{A report in a wide format.}

\item{I_col_pattern}{A pattern selecting columns with intensities; consult the `stringr` package. Additionally, you can specify the group name by including it between the colons.}
}
\value{
A report in a long format.
}
\description{
Data in wide format has one peptide/protein per row, and multple columns with intensities.
Data in long format has one intensity per row and more than one row corresponds to the same molecule.
The long format is convenient for merging multiple reports and for plotting with ggplot2.
}
\examples{
data(simple_protein_report)
# Columns 'A 1', 'A 2', 'A 3'. 'A 4', 'B 1', 'B 2', 'B 3', 'B 4'.
# wide2long(simple_protein_report, '(:condition:.) (:technical_replicate:.)')
}
