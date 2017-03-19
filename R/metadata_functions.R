#' Retreive metadata structure for of an individual IMF database.
#'
#' @param database_id character string of a \code{database_id} from
#' \code{\link{imf_ids}}.
#' @param return_raw logical. Whether to return the raw metadata
#' structure list or a data frame with codelist codes and descriptions.
#'
#' @return If \code{return_raw = FALSE} then a data frame with the codelist IDs
#' and descriptions is returned. If \code{return_raw = TRUE} then the raw
#' data strcuture list is returned.
#'
#' @examples
#' \dontrun{
#' # Find Balance of Payments database data structure
#' imf_metastructure(database_id = 'BOP')
#' }
#' @seealso \code{\link{imf_ids}}
#'
#' @export

imf_metastructure <- function(database_id, return_raw = FALSE) {
    if (missing(database_id))
        stop('Must supply database_id.\n\nUse imf_ids to find.',
             call. = FALSE)

    URL <- sprintf(
            'http://dataservices.imf.org/REST/SDMX_JSON.svc/MetadataStructure/%s',
            database_id)
    raw_dl <- download_parse(URL)

    if (!isTRUE(return_raw)) {
        codelist <- raw_dl$Structure$CodeLists$CodeList$`@id`
        codelist_description <- raw_dl$Structure$CodeLists$CodeList$Name$`#text`

        codelist_df <- data.frame(codelist = codelist,
                                  description = codelist_description)
        return(codelist_df)
    }
    else return(raw_dl)
}


#' Access meta data for specific country-series
#'
#' @param database_id character string database ID. Can be found using
#' \code{\link{imf_ids}}.
#' @param indicator character string of the indicator's ID.
#' These can be found using \code{\link{imf_codes}}.
#' @param country character string or character vector of ISO two letter
#' country codes identifying the countries for which you would like to
#' download the indicator metadata for.
#' See \url{https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2}. If
#' \code{country = 'all'} then all available countries will be downloaded.
#' @param start year for which you would like to start gathering the data.
#' @param end year for which you would like to end gathering the data.
#' @param return_raw logical. Whether to return the raw metadata
#' a data frame with just the requested data metadata.
#'
#' @examples
#' \dontrun{
#' imf_metadata(database_id = 'IFS', indicator = 'EREER_IX',
#'              start = 2012, end = 2013, country = c('GB', 'CN'))
#' }
#'
#' @export

imf_metadata <- function(database_id, indicator, country = 'all',
                     start = 2000, end = current_year(), return_raw = FALSE)
{
    if (length(indicator) > 1)
        stop('imf_metadata only work with one indicator at a time',
             call. = FALSE)

    if (length(country) == 1) {
        if (country == 'all') country <- all_iso2c()
    }

    # Download
    ## Address IMF download limit on individual call
    country <- split(country, ceiling(seq_along(country) / 60))
    comb_dl <- data.frame()
    for (u in 1:length(country)) {
        country_sub <- country[u] %>% unlist
        country_sub <- paste(country_sub, sep = '', collapse = '+')
        URL <- sprintf('http://dataservices.imf.org/REST/SDMX_JSON.svc/GenericMetadata/%s/%s.%s?startPeriod=%s&endPeriod=%s',
            database_id, country, indicator, start, end)
        raw_dl <- download_parse(URL)

        if (isTRUE(return_raw)) {
            if (length(country) > 1) message('Only returning data for the first 60 countries.')
        }
        return(raw_dl)
    }
}
