% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_functions.R
\name{imf_codes}
\alias{imf_codes}
\title{Retrieve individual database codes}
\usage{
imf_codes(codelist, return_raw = FALSE, times = 3)
}
\arguments{
\item{codelist}{character string of a \code{codelist} from
\code{\link{imf_codelist}}.}

\item{return_raw}{logical. Whether to return the raw codes list
list or a data frame with variable codes and descriptions.}

\item{times}{numeric. Maximum number of requests to attempt.}
}
\value{
If \code{return_raw = FALSE} then a data frame with the codes
and descriptions is returned. If \code{return_raw = TRUE} then the raw
code list is returned.
}
\description{
Retrieve individual database codes
}
\examples{
# Retrieve indicators from BOP database
test = imf_codes(codelist = 'CL_INDICATOR_BOP')

}
