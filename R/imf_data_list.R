#' List imf database IDs
#'
#' @param return_raw logical. Whether to return the raw dataflow list or a
#' data frame with database IDs and names.
#'
#' @return If \code{return_raw = FALSE} then a data frame with the database IDs
#' and descriptions is returned. If \code{return_raw = TRUE} then the raw
#' dataflow list is returned.
#'
#' @examples
#' imf_ids()
#'
#' @export

imf_ids <- function(return_raw = FALSE) {
    URL <- 'http://dataservices.imf.org/REST/SDMX_JSON.svc/Dataflow/'
    raw_dl <- download_parse(URL)

    if (!isTRUE(return_raw)) {
        data_id <- raw_dl$Structure$KeyFamilies$KeyFamily$`@id`
        long_name = raw_dl$Structure$KeyFamilies$KeyFamily$Name$`#text`

        id_name <- data.frame(database_id = data_id, description = long_name)
        return(id_name)
    }
    else return(raw_dl)
}


#' Retreive the list of codes (codelist) for of an individual IMF database.
#'
#' @param database_id character string of a \code{database_id} from
#' \code{\link{imf_ids}}.
#' #' @param return_raw logical. Whether to return the raw data
#' structure list or a data frame with codelist codes and descriptions.
#'
#' @return If \code{return_raw = FALSE} then a data frame with the codelist IDs
#' and descriptions is returned. If \code{return_raw = TRUE} then the raw
#' data strcuture list is returned.
#'
#' @examples
#' #' \dontrun{
#' # Find Balance of Payments database data structure
#' imf_codelist(database_id = 'BOP')
#' }
#' @seealso \code{\link{imf_ids}}
#'
#' @export

imf_codelist <- function(database_id, return_raw = FALSE) {
    if (missing(database_id))
        stop('Must supply database_id.\n\nUse imf_ids to find.',
             call. = FALSE)

    URL <- sprintf('http://dataservices.imf.org/REST/SDMX_JSON.svc/DataStructure/%s',
                    database_id)
    raw_dl <- imfr:::download_parse(URL)

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
#' #' @param return_raw logical. Whether to return the raw codes list
#' list or a data frame with variable codes and descriptions.
#'
#' @return If \code{return_raw = FALSE} then a data frame with the codes
#' and descriptions is returned. If \code{return_raw = TRUE} then the raw
#' code list is returned.
#'
#' @examples
#' # Retrieve indicators from BOP database
#' imf_codes(codelist = 'CL_INDICATOR|BOP')
#'
#' @export

imf_codes <- function(codelist, return_raw = FALSE) {
    if (missing(codelist))
        stop('Must supply codelist\n\nUse imf_codelist to find.',
             call. = FALSE)

    URL <- sprintf('http://dataservices.imf.org/REST/SDMX_JSON.svc/CodeList/%s',
                   codelist)
    raw_dl <- imfr:::download_parse(URL)

    if (!isTRUE(return_raw)) {
        codes <- raw_dl$Structure$CodeLists$CodeList$Code$`@value`
        codes_description <- raw_dl$Structure$CodeLists$CodeList$Code$Description$`#text`

        codes_df <- data.frame(codes = codes,
                                  description = codes_description)
        return(codes_df)
    }
    else return(raw_dl)
}