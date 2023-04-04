#' Set the IMF Application Name
#'
#' @description Set a unique application name in R options to be used in
#' requests to the IMF API
#'
#' @details
#' The `set_imf_app_name` function sets the application name that will be used in
#' the request header when making API calls to the IMF API. The IMF API has an
#' application-based rate limit of 50 requests per second, with the application
#' identified by the "user_agent" variable in the request header. The function
#' sets the application name by changing the `imf_app_name` R option. This
#' option will not persist across sessions. To set a persistent app name, add
#' this function call to your .RProfile.
#'
#' @param name A string representing the application name. Default is "imfr".
#'
#' @return Invisible NULL
#'
#' @examples
#' set_imf_app_name("my_custom_app_name")
#'
#' @export

set_imf_app_name <- function(name = "imfr") {

    if (missing(name) || is.null(name[1]) || is.na(name[1]) ||
        !is.character(name[1]) || nchar(name[1]) > 255) {
        stop("Please provide a valid string as the application name (max length: 255 characters).")
    }

    if (length(name) > 1){
        warning("'name' argument should be a character string, not a vector. All but the first element will be ignored")
        name <- name[1]
    }

    if (name == "imfr" || name == "") {
        warning("Best practice is to choose a unique app name. Use of a
                default or empty app name may result in hitting API rate limits and being blocked by the API.")
    }

    forbidden_chars <- c(0:31, 127)
    if (any(charToRaw(name) %in% forbidden_chars)) {
        stop("The application name contains forbidden characters. Please remove control characters and non-printable ASCII characters.")
    }

    options(imf_app_name = name)

    return(invisible(NULL))
}

#' Set the IMF wait time
#'
#' This function allows you to modify the mandatory wait time between API calls with the imfr package.
#' Wait time should be a numeric value between 0 and 10 (in seconds). It is not recommended to use
#' wait times greater than 5 seconds, as they will significantly slow runtimes. Wait times greater
#' than 10 seconds are not allowed. The function sets the wait time by changing the `imf_wait time` R
#' option. This option will not persist across sessions. To set a persistent app name, add this
#' function call to your .RProfile.
#'
#' @param new_wait_time Numeric value representing the new wait time (in seconds) between API requests.
#'
#' @return None.
#' @export
#'
#' @examples
#' # Usage
#' library(imfr)
#' set_imf_wait_time(2.0)  # Change the wait time to 2 seconds

set_imf_wait_time <- function(new_wait_time) {
    if (!is.numeric(new_wait_time) || length(new_wait_time) != 1) {
        stop("new_wait_time must be a single numeric value.")
    }

    if (new_wait_time > 10) {
        stop("Wait times greater than 10 seconds are not allowed.")
    }

    if (new_wait_time > 5) {
        warning("Long wait times (>5 seconds) are not recommended because they will significantly slow runtimes.")
    }

    # Store the wait time in a hidden environment variable
    options(imf_wait_time = new_wait_time)

    invisible(NULL)
}

#' Set the IMF cache usage option
#'
#' This function allows users to set the `imf_use_cache` option, which determines
#' whether the cache should be used when fetching data from the International Monetary Fund (IMF).
#'
#' @param use_cache A boolean value indicating whether the cache should be used.
#' @return The updated `imf_use_cache` option value.
#' @examples
#' set_imf_use_cache(TRUE)
#' set_imf_use_cache(FALSE)
#' @export

set_imf_use_cache <- function(use_cache) {
    # Check that the use_cache argument is not missing
    if (missing(use_cache)) {
        stop("The 'use_cache' argument must be provided.")
    }

    # Check that the use_cache argument is a valid boolean value
    if (!is.logical(use_cache) || is.na(use_cache) || is.null(use_cache)) {
        stop("The 'use_cache' argument must be a valid, non-NA, non-null boolean value.")
    }

    # Update the imf_use_cache option
    options(imf_use_cache = use_cache)

    # Return the updated imf_use_cache option value
    return(getOption("imf_use_cache"))
}