#' Simplify downloading and parsing JSON content
#'
#' @importFrom httr RETRY progress user_agent
#' @importFrom jsonlite fromJSON
#' @importFrom dplyr %>%
#' @noRd

download_parse <- function(url, times = 3) {
    raw_download <- RETRY('GET', url, user_agent(''), times = times) %>%
        content(as='text',econding='UTF-8')

    if (grepl('<!DOCTYPE html PUBLIC', raw_download)) {
        stop('data.imf.org appears to be down.', call. = FALSE)
    }

    if (grepl('<!DOCTYPE HTML PUBLIC', raw_download)) {
        stop('Unable to download series.', call. = FALSE)
    }

    if (grepl('<!DOCTYPE html>', raw_download)) {
        stop('Unable to download series.', call. = FALSE)
    }

    if (grepl('<string xmlns="http://schemas.m', raw_download)) {
        stop("Unable to find what you're looking for.", call. = FALSE)
    }

    json_parsed <- fromJSON(raw_download)
    return(json_parsed)
}

#' Retrieve the list of codes (codelist) for dimensions of an individual IMF
#' database.
#'
#' @importFrom dplyr %>% left_join
#'
#' @noRd

imf_codelist <- function(database_id, times = 3, inputs_only=T) {
    url <- paste0('http://dataservices.imf.org/REST/SDMX_JSON.svc/DataStructure/',
                  database_id)
    raw_dl <- download_parse(url, times)

    code <- raw_dl$Structure$CodeLists$CodeList$`@id`
    description <- raw_dl$Structure$CodeLists$CodeList$Name$`#text`
    codelist_df <- data.frame(code,description)

    if (isTRUE(inputs_only)) {
        data.frame(parameter = tolower(raw_dl$Structure$KeyFamilies$KeyFamily$Components$Dimension$`@conceptRef`),
                   code = raw_dl$Structure$KeyFamilies$KeyFamily$Components$Dimension$`@codelist`) %>%
            left_join(codelist_df) %>%
            suppressMessages() %>%
            return()
    }else {return(codelist_df)}
}