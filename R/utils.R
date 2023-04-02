#' Enforce a mandatory wait time between function calls
#'
#' @noRd

min_wait_time_limited <- function() {

    function(func) {
        force(func)

        function(...) {
            if (!is.null(getOption("imf_wait_time"))) {
                env_wait_time <- as.numeric(getOption("imf_wait_time"))
                if (!is.na(env_wait_time) && env_wait_time >= 0 && env_wait_time <= 10) {
                    min_wait_time <- env_wait_time
                } else {
                    min_wait_time <- 1.5
                }
            } else {
                min_wait_time <- 1.5
            }

            if(exists(".last_called", envir = .GlobalEnv)){
                elapsed <- as.numeric(Sys.time() - .last_called, units = "secs")
                left_to_wait <- min_wait_time - elapsed
                if (left_to_wait > 0) {
                    Sys.sleep(left_to_wait)
                }
            }

            ret <- func(...)
            assign(".last_called", Sys.time(), envir = .GlobalEnv)
            return(ret)
        }
    }
}

#' Replace GET with wrapped function with enforced wait time
#'
#' @importFrom httr GET
#'
#' @noRd

imf_get <- min_wait_time_limited()(GET)

#' Download and parse JSON content from a URL with rate limiting and retries
#'
#' This function is rate-limited and will perform a specified number of
#' retries in case of failure.
#'
#' @param URL A character string representing the URL to download and parse the JSON content from.
#' @param times An integer representing the number of times to retry the request in case of failure. Defaults to 3.
#'
#' @importFrom httr content user_agent add_headers accept_json status_code
#' @importFrom jsonlite fromJSON
#'
#' @return A list representing the parsed JSON content.
#' @noRd

download_parse <- function(URL, times = 3) {
    app_name <- getOption("imf_app_name")

    if (!is.null(app_name) && length(app_name) < 2 && is.character(app_name) &&
        nzchar(app_name) && app_name != "imfr") {
        app_name <- substr(app_name, 1, 255)
    } else {
        app_name <- paste0("imfr/", utils::packageVersion("imfr"))
    }

    for (i in 1:times) {
        response <- imf_get(url = URL, accept_json(), add_headers(Accept = "application/json"), user_agent(app_name))
        content <- content(response, "text")
        status <- status_code(response)

        if (grepl("<[^>]+>(.*?)</[^>]+>", content)) {
            inner_text <- regmatches(content, regexec("<[^>]+>(.*?)</[^>]+>", content))[[1]][2]
            output_string <- gsub(" GKey\\s*=\\s*[a-f0-9-]+", "", inner_text)

            if (i < times & (grepl("Rejected", content) | grepl("Bandwidth", content))) {
                Sys.sleep(5^(i + 1))
            } else {
                stop(sprintf("API request failed. URL: '%s' Status: '%d', Content: '%s'", URL, status, output_string))
            }
        } else {
            return(fromJSON(content))
        }
    }
}

#' Call download_parse only if there's no cached result for the API request
#'
#' @importFrom cachem cache_disk is.key_missing
#' @importFrom digest digest
#'
#' @noRd

download_parse_cached <- function(url, download_parse = download_parse, times = 3) {
    # Access and validate the imf_use_cache option
    use_cache <- getOption("imf_use_cache")
    if (is.null(use_cache) || !is.logical(use_cache) || is.na(use_cache)) {
        # Use the default value TRUE if the option is missing or invalid
        use_cache <- TRUE
    }

    # Check if the cache reference object exists in the global environment
    if (!exists(".global_cache", envir = .GlobalEnv)) {
        # If it doesn't exist, create a disk cache reference object with expiry time of 2 weeks
        assign(".global_cache", cachem::cache_disk(max_age = 60 * 60 * 24 * 14, dir = "/my_cache"), envir = .GlobalEnv)
    }

    # Get the cache key by hashing the input URL
    cache_key <- digest(url, algo = "md5")

    # Check if the result is already cached
    cached_result <- .global_cache$get(cache_key)

    if (is.key_missing(cached_result) | !use_cache) {
        # If the result is not cached, call download_parse and cache the result
        result <- download_parse(url, times)
        .global_cache$set(cache_key, result)
        return(result)
    } else {
        # If the result is cached, return it
        return(cached_result)
    }
}

#' Retrieve the list of codes for dimensions of an individual IMF database.
#'
#' @importFrom dplyr %>% left_join full_join
#'
#' @noRd

imf_dimensions <- function(database_id, times = 3, inputs_only=T) {
    URL <- paste0('http://dataservices.imf.org/REST/SDMX_JSON.svc/DataStructure/',
                  database_id)
    raw_dl <- download_parse_cached(URL, times)

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