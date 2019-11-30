#' List IMF database IDs
#'
#' @param return_raw logical. Whether to return the raw dataflow list or a
#' data frame with database IDs and names.
#' @param times numeric. Maximum number of requests to attempt.
#'
#' @return If \code{return_raw = FALSE} then a data frame with the database IDs
#' and descriptions is returned. If \code{return_raw = TRUE} then the raw
#' dataflow list is returned.
#'
#' @examples
#' imf_ids()
#'
#' @export

imf_ids <- function(return_raw = FALSE, times = 3) {
    URL <- 'http://dataservices.imf.org/REST/SDMX_JSON.svc/Dataflow?format=sdmx-json'
    raw_dl <- download_parse(URL)

    if (!isTRUE(return_raw)) {
        data_id <- raw_dl$Structure$Dataflows$Dataflow$`@id` %>%
            sub("^DS-", "", .) %>%
            sub("\n$", "", .)
        long_name <- raw_dl$Structure$Dataflows$Dataflow$Name$`#text`
        id_name <- data.frame(database_id = data_id, description = long_name)
        return(id_name)
    }
    else return(raw_dl)
}


#' Retreive the list of codes (codelist) for of an individual IMF database.
#'
#' @param database_id character string of a \code{database_id} from
#' \code{\link{imf_ids}}.
#' @param return_raw logical. Whether to return the raw data
#' structure list or a data frame with codelist codes and descriptions.
#' @param times numeric. Maximum number of requests to attempt.
#'
#' @return If \code{return_raw = FALSE} then a data frame with the codelist IDs
#' and descriptions is returned. If \code{return_raw = TRUE} then the raw
#' data strcuture list is returned.
#'
#' @examples
#' \dontrun{
#' # Find Balance of Payments database data structure
#' imf_codelist(database_id = 'BOP')
#' }
#' @seealso \code{\link{imf_ids}}
#'
#' @export

imf_codelist <- function(database_id, return_raw = FALSE, times = 3) {
    if (missing(database_id))
        stop('Must supply database_id.\n\nUse imf_ids to find.',
             call. = FALSE)

    URL <- sprintf(
            'http://dataservices.imf.org/REST/SDMX_JSON.svc/DataStructure/%s',
            database_id)
    raw_dl <- download_parse(URL, times = times)

    if (!isTRUE(return_raw)) {
        codelist <- raw_dl$Structure$CodeLists$CodeList$`@id`
        codelist_description <- raw_dl$Structure$CodeLists$CodeList$Name$`#text`

        codelist_df <- data.frame(codelist = codelist,
                                  description = codelist_description)
        return(codelist_df)
    }
    else return(raw_dl)
}

#' Retrieve individual database codes
#'
#' @param codelist character string of a \code{codelist} from
#' \code{\link{imf_codelist}}.
#' @param return_raw logical. Whether to return the raw codes list
#' list or a data frame with variable codes and descriptions.
#' @param times numeric. Maximum number of requests to attempt.
#'
#' @return If \code{return_raw = FALSE} then a data frame with the codes
#' and descriptions is returned. If \code{return_raw = TRUE} then the raw
#' code list is returned.
#'
#' @examples
#' # Retrieve indicators from BOP database
#' test = imf_codes(codelist = 'CL_INDICATOR_BOP')
#'
#' @export

imf_codes <- function(codelist, return_raw = FALSE, times = 3) {
    if (missing(codelist))
        stop('Must supply codelist\n\nUse imf_codelist to find.',
             call. = FALSE)

    URL <- sprintf('http://dataservices.imf.org/REST/SDMX_JSON.svc/CodeList/%s',
                   codelist)
    raw_dl <- download_parse(URL, times = times)

    if (!isTRUE(return_raw)) {
        codes <- raw_dl$Structure$CodeLists$CodeList$Code$`@value`
        codes_description <- raw_dl$Structure$CodeLists$CodeList$Code$Description$`#text`

        codes_df <- data.frame(codes = codes,
                                  description = codes_description)
        return(codes_df)
    }
    else return(raw_dl)
}

#' Download a data from the IMF
#'
#' @param database_id character string database ID. Can be found using
#' \code{\link{imf_ids}}.
#' @param indicator character string or character vector of indicator IDs.
#' These can be found using \code{\link{imf_codes}}.
#' @param country character string or character vector of ISO two letter
#' country codes identifying the countries for which you would like to
#' download the data.See \url{https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}.
#' If \code{country = 'all'} then \code{imf_data} will attempt to download
#' all available countries.
#' @param start year for which you would like to start gathering the data.
#' @param end year for which you would like to end gathering the data.
#' @param freq character string indicating the series frequency. With
#' \code{'A'} for annual, \code{'Q'} for quarterly, and \code{'M'} for monthly.
#' @param return_raw logical. Whether to return the data
#' as an unprocessed list.
#' @param print_url logical. Whether to print the URL used in the API call.
#' Can be useful for debugging.
#' @param times numeric. Maximum number of requests to attempt.
#'
#'
#' @return If \code{return_raw = FALSE} then a data frame with just the
#' requested data series are returned. If \code{return_raw = TRUE} then the raw
#' data list is returned. This can include additional information about the
#' series.
#'
#' @examples
#' # Download Real Effective Exchange Rate (CPI base) for the UK and China
#' # at an annual frequency
#' real_ex <- imf_data(database_id = 'IFS', indicator = 'EREER_IX',
#'                country = c('CN', 'GB'), freq = 'A')
#'
#' \dontrun{
#' # Also download Interest Rates, Lending Rate, Percent per annum
#' ex_interest <- imf_data(database_id = 'IFS',
#'                          indicator = c('FILR_PA', 'EREER_IX'),
#'                          freq = 'M')
#' }
#' @importFrom dplyr %>%
#'
#' @export

imf_data <- function(database_id, indicator, country = 'all',
                     start = 2000, end = current_year(),
                     freq = 'A', return_raw = FALSE, print_url = FALSE,
                     times = 3)
{
    if (length(indicator) > 1 & isTRUE(return_raw))
        stop('return_raw only works with one indicator at a time',
             call. = FALSE)

    if (!is.vector(country)) stop('country must be a vector of iso2c country codes.',
        call. = FALSE)

    country <- toupper(country)

    if (length(country) == 1) {
        if (country == 'ALL') country <- all_iso2c()
    }

    if (length(indicator) == 1) {
        one_series <- imf_data_one(database_id = database_id,
                                   indicator = indicator, country = country,
                                   start = start, end = end,
                                   freq = freq, return_raw = return_raw,
                                   print_url = print_url)
        if (is.data.frame(one_series)) {
            if (nrow(one_series) == 0) stop('No data found.', call. = FALSE)
            rownames(one_series) <- NULL
        }
        return(one_series)
    }
    else if (length(indicator) > 1) {
        for (i in indicator) {
            temp <- imf_data_one(database_id = database_id,
                                 indicator = i,
                                 country = country, start = start, end = end,
                                 freq = freq, return_raw = return_raw,
                                 print_url = print_url)

                if (grep(i, indicator) == 1) combined <- temp
                else {
                    by_id <- names(temp)[1:2]
                    combined <- merge(combined, temp, by = by_id, all = TRUE)
                }
            if (!isTRUE(last_element(i, indicator))) Sys.sleep(2)
        }
        if (nrow(combined) == 0) stop('No data found.', call. = FALSE)
        rownames(combined) <- NULL
        return(combined)
    }
}
