% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data_functions.R
\name{imf_parameters}
\alias{imf_parameters}
\title{List parameters and parameter values for IMF API requests}
\usage{
imf_parameters(database_id, times = 3)
}
\arguments{
\item{database_id}{character string of a \code{database_id} from
\code{\link{imf_databases}}.}

\item{times}{numeric. Maximum number of API requests to attempt.}
}
\value{
Returns a named list of data frames. Each list item name corresponds
to an input parameter for API requests from the database. All list items are
data frames, with an \code{input_code} column and a \code{description}
column. The \code{input_code} column is a character vector of all possible
input codes for that parameter when making requests from the IMF API
endpoint. The \code{descriptions} column is a character vector of text
descriptions of what each input code represents.
}
\description{
List input parameters and available parameter values for use in
making API requests from a given IMF database.
}
\details{
Retrieves a list of data frames containing all possible input
parameters for requests from a given database available through the IMF API.
Each data frame in the returned list has an \code{input_code} column and a
\code{description} column. Retrieve the list, filter each data frame for the
parameters you want, and then supply the modified list object to the
\code{\link{imf_dataset}} function as its \code{parameters} argument.
Alternatively, individually supply \code{input_code} values from each data
frame as arguments to \code{imf_dataset}.
}
\examples{
# Fetch the full list of indicator codes and descriptions for the Primary
# Commodity Price System database
params <- imf_parameters(database_id = 'PCPS')

}
