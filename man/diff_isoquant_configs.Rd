% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/diff_configs.R
\name{diff_isoquant_configs}
\alias{diff_isoquant_configs}
\title{Show differences between config files in ISOQuant protein quantification reports.}
\usage{
diff_isoquant_configs(configs)
}
\arguments{
\item{configs}{Named list of configs.}
}
\value{
A data.table with parameters that differ.
}
\description{
Outputs a data.table with parameters in the first column and values
for particular configurations in the other.
}
