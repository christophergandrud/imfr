#' Simplify downloading and parsing JSON content
#'
#' @importFrom httr GET content progress
#' @importFrom dplyr %>%
#' @importFrom jsonlite fromJSON
#' @noRd

download_parse <- function(URL) {
    raw_download <- GET(URL, progress()) %>%
        content(type = 'text', encoding = 'UTF-8')

    if (grepl('<!DOCTYPE html PUBLIC', raw_download)) {
        stop('data.imf.org appears to be down.', call. = FALSE)
    }

    json_parsed <- fromJSON(raw_download)
    return(json_parsed)
}
