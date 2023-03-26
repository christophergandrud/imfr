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
#' suppressWarnings(databases <- imf_ids())
#'
#' @rdname imfr-deprecated
#' @section \code{imf_ids}:
#' For \code{imf_ids}, use \code{\link{imf_databases}}.
#'
#' @export

imf_ids <- function(return_raw = FALSE, times = 3) {
    .Deprecated("imf_databases")
    URL <- 'http://dataservices.imf.org/REST/SDMX_JSON.svc/Dataflow'
    raw_dl <- download_parse(URL)

    if (!isTRUE(return_raw)) {
        data_id <- raw_dl$Structure$Dataflows$Dataflow$KeyFamilyRef$KeyFamilyID
        long_name <- raw_dl$Structure$Dataflows$Dataflow$Name$`#text`
        id_name <- data.frame(database_id = data_id, description = long_name)
        return(id_name)
    }
    else return(raw_dl)
}

#' Retrieve the list of codes (codelist) for dimensions of an individual IMF
#' database.
#'
#' @param database_id character string of a \code{database_id} from
#' \code{\link{imf_databases}}.
#' @param return_raw logical. Whether to return the raw data
#' structure list or a data frame with codelist codes and descriptions.
#' @param times numeric. Maximum number of requests to attempt.
#'
#' @return If \code{return_raw = FALSE} then a data frame with the codelist IDs
#' and descriptions is returned. If \code{return_raw = TRUE} then the raw
#' data structure list is returned.
#'
#' @examples
#' #' # Find Primary Commodity Price System database data structure
#' suppressWarnings(cl <- imf_codelist(database_id = 'PCPS'))
#'
#' @importFrom dplyr %>% left_join
#'
#' @rdname imfr-deprecated
#' @section \code{imf_codelist}:
#' For \code{imf_codelist}, use \code{\link{imf_parameters}}.
#'
#' @export
#'

imf_codelist <- function(database_id, return_raw = FALSE, times = 3) {
    .Deprecated("imf_parameters")
    if (missing(database_id))
        stop('Must supply database_id.\n\nUse imf_databases to find.',
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
#' suppressWarnings(codes <- imf_codes(codelist = 'CL_INDICATOR_BOP'))
#'
#' @rdname imfr-deprecated
#' @section \code{imf_codes}:
#' For \code{imf_codes}, use \code{\link{imf_parameters}}.
#'
#' @export

imf_codes <- function(codelist, return_raw = FALSE, times = 3) {
    .Deprecated("imf_parameters")
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

#' Download a dataset from the IMF
#'
#' @param database_id character string database ID. Can be found using
#' \code{\link{imf_databases}}.
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
#' # Download Real Effective Exchange Rate (CPI base) for China at an annual
#' # frequency since 2018
#' suppressWarnings(df <- imf_data(database_id = 'IFS', indicator = 'EREER_IX',
#'                  country = 'CN', freq = 'A',start = 2018))
#'
#' @importFrom dplyr %>% arrange bind_cols
#' @importFrom tidyr spread
#'
#' @rdname imfr-deprecated
#' @section \code{imf_data}:
#' For \code{imf_data}, use \code{\link{imf_dataset}}.
#'
#' @export

imf_data <- function(database_id, indicator, country = 'all',
                     start = 2000, end = format(Sys.Date(),"%Y"),
                     freq = 'A', return_raw = FALSE, print_url = FALSE,
                     times = 3) {
    .Deprecated("imf_dataset")
    if(missing(database_id)){
        stop("database_id is a required argument.",
             call. = FALSE)
    }
    param_defs <- imf_parameter_defs(database_id)
    geography_var <- param_defs$parameter[param_defs$description %in% c("Geographical Areas","Country")]
    indicator_var <- param_defs$parameter[param_defs$description == "Indicator"]
    if(!missing(indicator)){
        indicator_arg <- paste0(",",indicator_var,"=indicator")
    }else{
        indicator_arg <- ""
    }
    if(!all(country == "all")){
        geography_arg <- paste0(",",geography_var,"=country")
    }else{
        geography_arg <- ""
    }
    if(length(freq)>1){
        stop('imf_data only works with one frequency at a time.',
             call. = FALSE)
    }
    df <- eval(parse(text=paste0("imf_dataset(database_id=database_id",indicator_arg,geography_arg,
                                 ",start_year=start,end_year=end,freq=freq,return_raw=return_raw,print_url=print_url,times=times)")))
    if(return_raw==T){
        return(df)
    }else{
        if(geography_var %in% names(df)){
            names(df)[which(names(df) %in% geography_var)] <- "iso2c"
        }
        if(any(names(df)=="unit_measure")){
            df <- df %>%
                select(iso2c,date,unit_measure,value,indicator_var) %>%
                spread(key = indicator_var,value="value") %>%
                arrange(unit_measure)
            tmp <- data.frame(unit_measure = df$unit_measure)
            df <- df %>%
                select(-unit_measure)
            df <- bind_cols(df,tmp)
        }else{
            df <- df %>%
                select(iso2c,date,value,indicator_var) %>%
                spread(key = indicator_var,value="value")
        }
        if(freq == "A"){
            names(df)[which(names(df) == "date")] <- "year"
        }else if(freq=="Q"){
            names(df)[which(names(df) == "date")] <- "year_quarter"
        }else if(freq=="M"){
            names(df)[which(names(df) == "date")] <- "year_month"
        }
        return(df)
    }
}

#' Retrieve metadata structure for of an individual IMF database
#'
#' @param database_id character string of a \code{database_id} from
#' \code{\link{imf_ids}}.
#' @param return_raw logical. Whether to return the raw metadata
#' structure list or a data frame with codelist codes and descriptions.
#' @param times numeric. Maximum number of requests to attempt.
#'
#' @return If \code{return_raw = FALSE} then a data frame with the codelist IDs
#' and descriptions is returned. If \code{return_raw = TRUE} then the raw
#' data structure list is returned.
#'
#' @examples
#' # Find Primary Commodity Price System database data structure
#' suppressWarnings(metastruc <- imf_metastructure(database_id = 'PCPS'))
#'
#' @rdname imfr-deprecated
#' @section \code{imf_metastructure}:
#' Function \code{imf_metastructure} will be discontinued in a future version
#' for lack of evident use cases.
#'
#' @export

imf_metastructure <- function(database_id, return_raw = FALSE, times = 3) {
    .Deprecated()
    if (missing(database_id))
        stop('Must supply database_id.\n\nUse imf_ids to find.',
             call. = FALSE)

    URL <- sprintf(
        'http://dataservices.imf.org/REST/SDMX_JSON.svc/MetadataStructure/%s',
        database_id)
    raw_dl <- download_parse(URL, times=times)

    if (!isTRUE(return_raw)) {
        codelist <- raw_dl$Structure$CodeLists$CodeList$`@id`
        codelist_description <- raw_dl$Structure$CodeLists$CodeList$Name$`#text`

        codelist_df <- data.frame(codelist = codelist,
                                  description = codelist_description)
        return(codelist_df)
    }
    else return(raw_dl)
}

#' Access metadata for a dataset
#'
#' @param database_id character string. database_id to request the header for.
#' Can be found using \code{\link{imf_databases}}.
#' @param URL character string. Used internally by \code{imf_databases} to
#' request header by request URL rather than by database_id.
#' @param times numeric. Maximum number of requests to attempt.
#'
#' @examples
#' # Find Primary Commodity Price System database metadata
#' suppressWarnings(metadata <- imf_metadata(database_id = 'PCPS'))
#'
#' @rdname imfr-deprecated
#' @section \code{imf_metadata}:
#' Function \code{imf_metadata} is deprecated and will be discontinued in a
#' future version. Use \code{imf_dataset(include_metadata = TRUE)} instead.
#'
#' @export

imf_metadata <- function(database_id, URL, times = 3, ...)
{
    .Deprecated("imf_dataset(include_metadata = TRUE)")
    if(missing(database_id) & missing(URL)){
        stop('Must supply database_id.\n\nUse imf_ids to find.',
             call. = FALSE)
    }
    if(missing(URL)){
        URL <- sprintf('http://dataservices.imf.org/REST/SDMX_JSON.svc/GenericMetadata/%s/A..?start_year=2020',
                       database_id)
    }else{
        URL <- sub("CompactData","GenericMetadata",URL)
    }
    raw_dl <- download_parse(URL,times = times)

    output <- list(XMLschema = raw_dl[["GenericMetadata"]][["@xmlns:xsd"]],
                   message = raw_dl[["GenericMetadata"]][["@xsi:schemaLocation"]],
                   language = raw_dl[["GenericMetadata"]][["Header"]][["Sender"]][["Name"]][["@xml:lang"]],
                   timestamp = raw_dl[["GenericMetadata"]][["Header"]][["Prepared"]],
                   custodian = raw_dl[["GenericMetadata"]][["Header"]][["Sender"]][["Name"]][["#text"]],
                   custodian_url = raw_dl[["GenericMetadata"]][["Header"]][["Sender"]][["Contact"]][["URI"]],
                   custodian_telephone = raw_dl[["GenericMetadata"]][["Header"]][["Sender"]][["Contact"]][["Telephone"]]
    )
    return(output)
}
