#' Simplify downloading and parsing JSON content
#'
#' @importFrom httr RETRY progress user_agent content
#' @importFrom jsonlite fromJSON
#' @importFrom dplyr %>%
#' @importFrom ratelimitr limit_rate rate
#'
#' @noRd

download_parse <- limit_rate(function(URL, times = 3) {
    raw_download <- RETRY('GET', URL, user_agent(''), times = times, pause_base = 2) %>%
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
}, rate(n = 9, period = 5))

#' Retrieve the list of codes for dimensions of an individual IMF database.
#'
#' @importFrom dplyr %>% left_join full_join
#'
#' @noRd

imf_dimensions <- function(database_id, times = 3, inputs_only=T) {
    URL <- paste0('http://dataservices.imf.org/REST/SDMX_JSON.svc/DataStructure/',
                  database_id)
    raw_dl <- download_parse(URL, times)

    code <- raw_dl$Structure$CodeLists$CodeList$`@id`
    description <- raw_dl$Structure$CodeLists$CodeList$Name$`#text`
    codelist_df <- data.frame(code,description)

    if (isTRUE(inputs_only)) {
        data.frame(parameter = tolower(raw_dl$Structure$KeyFamilies$KeyFamily$Components$Dimension$`@conceptRef`),
                   code = raw_dl$Structure$KeyFamilies$KeyFamily$Components$Dimension$`@codelist`) %>%
            left_join(codelist_df) %>%
            suppressMessages() %>%
            return()
    }else {data.frame(parameter = tolower(raw_dl$Structure$KeyFamilies$KeyFamily$Components$Dimension$`@conceptRef`),
                      code = raw_dl$Structure$KeyFamilies$KeyFamily$Components$Dimension$`@codelist`) %>%
            full_join(codelist_df) %>%
            suppressMessages() %>%
            return()}
}