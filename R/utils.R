#' Download one data series
#'
#' @importFrom magrittr %>%
#'
#' @noRd

imf_data_one <- function(database_id, indicator, country, start,
                         end, freq, return_raw)
{
    . <- NULL

    # Sanity check
    if (!(freq %in% c('A', 'Q', 'M'))) stop("freq must be 'A', 'Q', or 'M'.",
                                            call. = FALSE)

    # Download
    ## Address IMF download limit on individual call
    country <- split(country, ceiling(seq_along(country) / 60))
    comb_dl <- data.frame()
    for (u in 1:length(country)) {
        country_sub <- country[u] %>% unlist
        country_sub <- paste(country_sub, sep = '', collapse = '+')
        URL <- sprintf(
            'http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/%s/%s.%s?startPeriod=%s&endPeriod=%s',
            database_id, country_sub, indicator, start, end)
        raw_dl <- imfr:::download_parse(URL)

        if (isTRUE(return_raw)) {
            return(raw_dl)
        } else
            # Check if requested indicator and frequency is available
            overview <- raw_dl$CompactData$DataSet$Series
            if (is.null(overview)) stop(sprintf(
                '%s is not available for your query.', indicator),
                call. = FALSE)

            available_freq <- overview$`@FREQ`
            if (!(freq %in% available_freq)) stop(sprintf(
                    '%s is not available in the requested frequency', indicator),
                                              call. = FALSE)

        # Extract requested series
        observations <- raw_dl$CompactData$DataSet$Series$Obs

        series_pos <- grep(freq, available_freq)
        all <- 1:length(observations)
        not_null <- all[sapply(observations, isnt.null)]
        series_pos <- series_pos[series_pos %in% not_null]

        countries <- overview$`@REF_AREA`[series_pos]
        sub_data <- observations[series_pos]

        sub_data <- sub_data %>%
            lapply(as.data.frame, stringsAsFactors = FALSE) %>%
            Map(cbind, ., iso2c = countries) %>%
            do.call(rbind.data.frame, .) %>%
            MoveFront('iso2c')

        # Final clean up
        if (freq == 'A') {
            names(sub_data) <- c('iso2c', 'year', indicator)
        }
        else if (freq == 'Q') {
            names(sub_data) <- c('iso2c', 'year_quarter', indicator)
        }
        else if (freq == 'M') {
            names(sub_data) <- c('iso2c', 'year_month', indicator)
        }

        sub_data[, 'iso2c'] <- sub_data[, 'iso2c'] %>% as.character
        sub_data[, indicator] <- sub_data[, indicator] %>% as.numeric

        comb_dl <- rbind(comb_dl, sub_data)

        if (!isTRUE(last_element(u, 1:length(country)))) Sys.sleep(2)
    }
        if (nrow(comb_dl) >= 1) comb_dl <- comb_dl[order(comb_dl$iso2c), ]

        return(comb_dl)
}


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
            col_idx <- grep(Var, DataNames, ignore.case = ignore.case,
                            fixed = fixed)
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

#' Find last element of a vector
#'
#' @noRd

last_element <- function(x, v)
{
    x_position <- match(x, v)
    v_final <- length(v)
    if (x_position == v_final) return(TRUE)
    else return(FALSE)
}


#' All ISO2C codes
#'
#' @noRd

all_iso2c <- function() {
    all <- read.csv('data/all_iso.csv', stringsAsFactors = FALSE)
    return(all[, 1])
}

#' @noRd

isnt.null = function(x)!is.null(x)
