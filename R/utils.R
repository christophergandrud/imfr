#' Simplify downloading and parsing JSON content
#'
#' @importFrom httr RETRY progress content user_agent add_headers
#' @importFrom jsonlite fromJSON
#' @importFrom dplyr %>%
#' @importFrom ratelimitr limit_rate rate
#'
#' @noRd

download_parse <- limit_rate(function(URL, times = 3) {
    if (nzchar(Sys.getenv("IMF_APP_NAME"))) {
        app_name <- Sys.getenv("IMF_APP_NAME")
        if(nchar(app_name) > 255){
            app_name <- substr(app_name, 1, 255)
            }
    } else {
        app_name <- paste0("imfr/",packageVersion("imfr"))
    }

    raw_download <- RETRY('GET', URL, add_headers(Accept = "application/json"), user_agent(app_name),times = 2, pause_base = 5) %>%
        suppressWarnings()
    cont <- raw_download %>% content(as='text',encoding='UTF-8')
    status <- raw_download$status_code
    header <- raw_download$request$headers[[1]]

    if (grepl('<!DOCTYPE HTML PUBLIC', cont) |
        grepl('<!DOCTYPE html', cont) |
        grepl('<string xmlns="http://schemas.m', cont) |
        grepl('<html xmlns=', cont) |
        grepl('<html><head>', cont)) {
        matches <- regexec("<[^>]+>(.*?)<\\/[^>]+>", cont)
        inner_text <- regmatches(cont, matches)[[1]][2]
        output_string <- gsub(" GKey\\s*=\\s*[a-f0-9-]+", "", inner_text)
        if(grepl('Rejected', cont) & as.character(status) == "200"){
            err_message <- paste0("API request failed. Status: '",status,
                                  "', Content: '",output_string,"'",
                                  "\n\nToo many requests. Take a break and try again.")
        }else{
            err_message <- paste0("API request failed. Status: '",status,
                                  "', Content: '",output_string,"'")
        }
        stop(err_message)
    }

    json_parsed <- fromJSON(cont)
    return(json_parsed)
}, rate(n = 3, period = 5))

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