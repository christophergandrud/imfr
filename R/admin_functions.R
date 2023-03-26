#' Set the IMF Application Name
#'
#' @description Set a unique application name to be used in requests to the IMF
#' API as a hidden environment variable
#'
#' @details
#' The `imf_app_name` function sets the application name that will be used in
#' the request header when making API calls to the IMF API. The IMF API has an
#' application-based rate limit of 50 requests per second, with the application
#' identified by the "user_agent" variable in the request header. The function
#' sets the application name by changing the `IMF_APP_NAME` hidden variable in
#' `.Renviron`. If this variable doesn't exist, `imf_app_name` will create it.
#'
#' @param name A string representing the application name. Default is "imfr".
#'
#' @return Invisible NULL
#'
#' @examples
#' imf_app_name("my_custom_app_name")
#'
#' @export

imf_app_name <- function(name = "imfr") {

    if (missing(name) || is.null(name[1]) || is.na(name[1]) || !is.character(name[1]) || nchar(name[1]) > 255) {
        stop("Please provide a valid string as the application name (max length: 255 characters).")
    }

    if (length(name) > 1){
        warning("'name' argument should be a character string, not a vector. All but the first element will be ignored")
        name <- name[1]
    }

    if (name == "imfr" || name == "") {
        warning("Best practice is to choose a unique app name. Use of a default or empty app name may result in hitting API rate limits and being blocked by the API.")
    }

    forbidden_chars <- c(0:31, 127)
    if (any(charToRaw(name) %in% forbidden_chars)) {
        stop("The application name contains forbidden characters. Please remove control characters and non-printable ASCII characters.")
    }

    Sys.setenv(IMF_APP_NAME = name)

    return(invisible(NULL))
}