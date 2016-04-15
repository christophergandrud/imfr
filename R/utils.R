#' Simplify downloading and parsing JSON content
#'
#' @importFrom httr GET content progress
#' @importFrom dplyr %>%
#' @importFrom jsonlite fromJSON
#' @noRd

download_parse <- function(URL) {
    raw_data_list <- GET(URL, progress()) %>%
        content(type = 'text', encoding = 'UTF-8') %>%
        fromJSON
    return(raw_data_list)
}