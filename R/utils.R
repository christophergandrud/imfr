#' Simplify downloading and parsing JSON content
#'
#' @importFrom httr GET content progress
#' @importFrom magrittr %>%
#' @importFrom jsonlite fromJSON
#' @noRd

download_parse <- function(URL) {
    raw_download <- GET(URL, progress()) %>%
        content(type = 'text', encoding = 'UTF-8')

    if (grepl('<!DOCTYPE html PUBLIC', raw_download)) {
        stop('data.imf.org appears to be down.', call. = FALSE)
    }

    if (grepl('<string xmlns="http://schemas.m', raw_download)) {
        stop("Unable to find what you're looking for.", call. = FALSE)
    }

    json_parsed <- fromJSON(raw_download)
    return(json_parsed)
}

#' Move variables to the beginning of a data frame.
#'
#' @source DataCombine package
#' @noRd

MoveFront <- function(data, Var, exact = TRUE, ignore.case = NULL, fixed = NULL)
{
    if (isTRUE(exact) & !is.null(ignore.case) | !is.null(fixed)){
        warning('When exact = TRUE ignore.case and fixed are ignored.')
    }
    OneMove <- function(data, Var){
        # Determine if Var exists in data
        DataNames <- names(data)
        TestExist <- Var %in% DataNames
        if (!isTRUE(TestExist)){
            stop(paste(Var, "was not found in the data frame."))
        }

        if (isTRUE(exact)){
            col_idx <- which(DataNames %in% Var, arr.ind = TRUE)
        }
        else if (!isTRUE(exact)){
            col_idx <- grep(Var, DataNames, ignore.case = ignore.case, fixed = fixed)
        }
        MovedData <- data[, c(col_idx, (1:ncol(data))[-col_idx])]
        return(MovedData)
    }

    RevVar <- rev(Var)

    for (i in RevVar){
        data <- OneMove(data, i)
    }
    return(data)
}
