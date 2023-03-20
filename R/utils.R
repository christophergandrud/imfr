#' Simplify downloading and parsing JSON content
#'
#' @importFrom httr RETRY progress user_agent content
#' @importFrom jsonlite fromJSON
#' @importFrom dplyr %>%
#' @importFrom ratelimitr limit_rate rate
#'
#' @noRd

download_parse <- limit_rate(function(URL, times = 3) {
    raw_download <- RETRY('GET', URL, user_agent(''), times = times, pause_base = 2)
    cont <- raw_download %>% content(as='text',econding='UTF-8')
    status <- raw_download$status_code

    if (grepl('<!DOCTYPE html PUBLIC', cont)) {
        stop(sprintf("data.imf.org appears to be down. URL: %s, Status: %s, Content: %s",
                     URL, status, substr(cont, 1, 200)), call. = FALSE)
    }

    if (grepl('<!DOCTYPE HTML PUBLIC', cont)) {
        stop(sprintf("Unable to download series. URL: %s, Status: %s, Content: %s",
                     URL, status, substr(cont, 1, 200)), call. = FALSE)
    }

    if (grepl('<!DOCTYPE html>', cont)) {
        stop(sprintf("Unable to download series. URL: %s, Status: %s, Content: %s",
                     URL, status, substr(cont, 1, 200)), call. = FALSE)
    }

    if (grepl('<string xmlns="http://schemas.m', cont)) {
        stop(sprintf("Unable to find what you're looking for. URL: %s, Status: %s, Content: %s",
                     URL, status, substr(cont, 1, 200)), call. = FALSE)
    }

    json_parsed <- fromJSON(cont)
    return(json_parsed)
}, rate(n = 8, period = 5))

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