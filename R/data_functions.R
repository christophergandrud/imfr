#' List IMF database IDs and descriptions
#'
#' @description List IMF database IDs and descriptions
#'
#' @param times numeric. Maximum number of API requests to attempt.
#'
#' @return Returns a data frame with \code{database_id} and text
#' \code{description} for each database available through the IMF API endpoint.
#'
#' @examples
#' # Return first 6 IMF database IDs and descriptions
#' head(imf_databases())
#'\dontrun{
#' # Open a viewing pane with the full list of IMF database IDs and descriptions
#' View(imf_databases())
#' }
#'
#' @export

imf_databases <- function(times = 3) {
    url <- 'http://dataservices.imf.org/REST/SDMX_JSON.svc/Dataflow'
    raw_dl <- download_parse(url, times)

    database_id <- raw_dl$Structure$Dataflows$Dataflow$KeyFamilyRef$KeyFamilyID
    description <- raw_dl$Structure$Dataflows$Dataflow$Name$`#text`
    database_list <- data.frame(database_id, description)
    return(database_list)
}

#' List parameters and parameter values for IMF API requests
#'
#' @description List input parameters and available parameter values for use in
#' making API requests from a given IMF database.
#'
#' @details
#' Retrieves a list of data frames containing all possible input
#' parameters for requests from a given database available through the IMF API.
#' Each data frame in the returned list has an \code{input_code} column and a
#' \code{description} column. Retrieve the list, filter each data frame for the
#' parameters you want, and then supply the modified list object to the
#' \code{\link{imf_data}} function as its \code{parameters} argument.
#' Alternatively, individually supply \code{input_code} values from each data
#' frame as arguments to \code{imf_data}.
#'
#' @param database_id character string of a \code{database_id} from
#' \code{\link{imf_databases}}.
#' @param times numeric. Maximum number of API requests to attempt.
#'
#' @return Returns a named list of data frames. Each list item name corresponds
#' to an input parameter for API requests from the database. All list items are
#' data frames, with an \code{input_value} column and a \code{description}
#' column. The \code{input_code} column is a character vector of all possible
#' input codes for that parameter when making requests from the IMF API
#' endpoint. The \code{descriptions} column is a character vector of text
#' descriptions of what each input code represents.
#'
#' @examples
#' # Open a viewing pane with the full list of indicator codes and descriptions
#' from the Balance of Payments database
#' params <- imf_parameters(database_id = 'BOP')
#' # Print names of parameters in the list
#' names(params)
#' # Display data frame of all possible inputs for the frequency parameter
#' params$freq
#'
#' @importFrom dplyr %>%
#' @importFrom purrr map map_dfr
#'
#' @export

imf_parameters <- function(database_id, times = 3) {
    if (missing(database_id)){
        stop('Must supply database_id.\nUse imf_databases to find.',
             call. = FALSE)
    }

    url <- 'http://dataservices.imf.org/REST/SDMX_JSON.svc/CodeList/'
    codelist <- imf_codelist(database_id)
    parameterlist <- map(1:nrow(codelist), function(k) {
        if(codelist$parameter[k] == "freq"){
            data.frame(input_code = c("A","M","Q"),
                       description = c("Annual","Monthly","Quarterly"))
        }else{
            raw <- download_parse(paste0(url,codelist$code[k]), times = times)$Structure$CodeLists$CodeList$Code
            data.frame(input_code = raw$`@value`,
                       description = raw$Description$`#text`)
        }
    })
    names(parameterlist) <- codelist$parameter
    return(parameterlist)
}

#' Get definitions of IMF API parameters
#'
#' @description Get text descriptions of input parameters used in making API
#' requests from a given IMF database
#'
#' @param database_id character string of a \code{database_id} from
#' \code{\link{imf_databases}}.
#' @param times numeric. Maximum number of API requests to attempt.
#'
#' @return Returns a data frame of input parameters used in making API requests
#' from a given IMF database, along with text descriptions or definitions of
#' those parameters. Useful in cases when parameter names returned by
#' \code{\link{imf_databases}} are not self-explanatory. (Note that the
#' usefulness of text descriptions can be uneven, depending on the database
#' design.)
#'
#' @examples
#' # Get names and text descriptions of parameters used in IMF API calls to the
#' Balance of Payments database
#' imf_parameter_defs(database_id = 'BOP'))
#'
#' @importFrom dplyr %>% select
#' @importFrom purrr map
#'
#' @export

imf_parameter_defs <- function(database_id, times = 3) {
    if (missing(database_id)){
        stop('Must supply database_id.\nUse imf_databases to find.',
             call. = FALSE)
    }

    url <- 'http://dataservices.imf.org/REST/SDMX_JSON.svc/CodeList/'
    parameterlist <- imf_codelist(database_id) %>%
        select(parameter,description)
    return(parameterlist)
}

#' Download a data series from the IMF
#'
#' @description Function to request data from a database through the IMF API endpoint.
#'
#' @usage
#' imf_data(database_id, parameters, start_year, end_year)
#'
#' @details Only the \code{database_id} argument is strictly required; all other
#' arguments are optional. If you provide a \code{database_id} without any other
#' arguments, the function will attempt to download the entire database.
#' However, many databases available through the API are too large to download
#' in their entirety, and your request will fail. Additional arguments to the
#' function act as filter parameters to reduce the size of the returned dataset.
#' For instance, supplying \code{c("A","M")} as the \code{freq} argument will
#' return all database observations of annual or monthly frequency, while
#' excluding all observations of quarterly frequency.
#'
#' There are two ways to supply parameters for your API request. The optimal way
#' is to retrieve a list of data frames using \code{\link{imf_parameters}},
#' filter each data frame to retain only the parameters you want, and then
#' supply the modified list object to \code{imf_data} as its \code{parameters}
#' argument. However, users who are not comfortable modifying data frames in a
#' nested list may find it easier to instead supply one or more character
#' vectors as arguments, as in the example in the previous paragraph. (There are
#' a total of 44 possible parameters for making request from various databases
#' through the API, and each parameter uses unique input codes, which is why the
#' \code{parameters} list method simplifies things!) These two methods for
#' specifying parameters may not be combined. Only  \code{database_id},
#' \code{start_year}, \code{end_year}, \code{print_url}, and \code{times}
#' arguments may be used in combination with a \code{parameters} list object;
#' any other arguments will be ignored (and a warning thrown).
#'
#' @param database_id character string. Database ID for database from which
#' you would like to request data. Can be found using
#' \code{\link{imf_databases}}.
#' @param parameters list of data frames providing input parameters for your
#' API request. Retrieve list of all possible input parameters using
#' \code{\link{imf_parameters}} and filter each data frame in the list to
#' reduce it to the inputs you want.
#' @param start_year integer four-digit year. Earliest year for which you would like
#' to request data.
#' @param end_year integer four-digit year. Latest year for which you would like to
#' request data.
#' @param print_url logical. Whether to print the URL used in the API call.
#' Can be useful for debugging.
#' @param times numeric. Maximum number of requests to attempt.
#' @param accounting_entry,activity,adjustment,age,classification,cofog_function,commodity,comp_method,composite_breakdown,counterpart_area,counterpart_sector,currency_denom,cust_breakdown,disability_status,education_lev,expenditure,financial_institution,flow_stock_entry,freq,functional_cat,gfs_sto,income_wealth_quantile,indicator,instr_asset,instrument_and_assets_classification,int_acc_item,maturity,occupation,prices,product,ref_area,ref_sector,reporting_type,series,sex,sto,summary_statistics,survey,transformation,type,unit_measure,urbanisation,valuation
#' character vector. Use \code{imf_parameters} to identify which parameters to
#' use for requests from a given database and to see all valid input codes for
#' each parameter.
#'
#' @return Returns a tidy data frame with the data series.
#'
#' @examples
#' # Retrieve "Assets (with Fund Record), National Currency" series from the
#' # Balance of Payments database using the list object method
#' params <- imf_parameters(database_id = 'BOP')
#' params$indicator <- filter(params$indicator,
#'                            description == 'Assets (with Fund Record), National Currency')
#' df <- imf_data(database_id = 'BOP', parameters = params)
#'
#' # Retrieve "Assets (with Fund Record), National Currency" series from the
#' # Balance of Payments database using the character vector method
#' params <- imf_parameters(database_id = 'BOP')
#' indicator_code <- filter(params$indicator,
#'                            description == 'Assets (with Fund Record), National Currency')$input_code
#' df <- imf_data(database_id = 'BOP', indicator = indicator_code)
#'
#' @importFrom dplyr %>% filter bind_cols select
#' @importFrom purrr map walk
#'
#' @export

imf_data <- function(database_id, parameters, start_year, end_year,
                     print_url = FALSE, times = 3,
                     accounting_entry, activity, adjustment, age,
                     classification, cofog_function, commodity, comp_method,
                     composite_breakdown, counterpart_area, counterpart_sector,
                     currency_denom, cust_breakdown, disability_status,
                     education_lev, expenditure, financial_institution,
                     flow_stock_entry, freq, functional_cat, gfs_sto,
                     income_wealth_quantile, indicator, instr_asset,
                     instrument_and_assets_classification, int_acc_item,
                     maturity, occupation, prices, product, ref_area,
                     ref_sector, reporting_type, series, sex, sto,
                     summary_statistics, survey, transformation, type,
                     unit_measure, urbanisation, valuation) {
    if (!(inherits(database_id, "character"))){
        stop("database_id must be a character string.",
             call. = FALSE)
    }
    if (!(length(database_id) == 1L)){
        stop("database_id must be a character string, not a vector.",
             call. = FALSE)
    }

    if(!missing(start_year) & !missing(end_year)){
        suppressWarnings(start <- as.integer(start_year))
        suppressWarnings(end <- as.integer(end_year))
        years <- c(start_year = start_year,end_year = end_year)
    }else if(!missing(start_year)){
        suppressWarnings(start <- as.integer(start_year))
        years <- c(start_year = start_year)
    }else if(!missing(end_year)){
        suppressWarnings(end <- as.integer(end_year))
        years <- c(end_year = end_year)
    }else{
        years <- c()
    }
    walk(years,function(x){
        if(!(length(x) == 1L)){
            stop(paste(names(x),"must be a four-digit year, not a vector."),
                 call. = FALSE)
        }else if(is.na(x)){
            stop(paste("Failed to coerce",names(x),"to a four-digit integer."),
                 call. = FALSE)
        }else if(!(nchar(x) == 4L)){
            stop(paste("Failed to coerce",names(x),"to a four-digit integer."),
                 call. = FALSE)
        }
    })

    vector_vars <- c("accounting_entry", "activity", "adjustment", "age",
    "classification", "cofog_function", "commodity", "comp_method",
    "composite_breakdown", "counterpart_area", "counterpart_sector",
    "currency_denom", "cust_breakdown", "disability_status",
    "education_lev", "expenditure", "financial_institution",
    "flow_stock_entry", "freq", "functional_cat", "gfs_sto",
    "income_wealth_quantile", "indicator", "instr_asset",
    "instrument_and_assets_classification", "int_acc_item",
    "maturity", "occupation", "prices", "product", "ref_area",
    "ref_sector", "reporting_type", "series", "sex", "sto",
    "summary_statistics", "survey", "transformation", "type",
    "unit_measure", "urbanisation", "valuation")
    supplied_list <- !missing(parameters)
    supplied_vectors <- !c(missing(accounting_entry), missing(activity), missing(adjustment),
                           missing(age), missing(classification), missing(cofog_function),
                           missing(commodity), missing(comp_method), missing(composite_breakdown),
                           missing(counterpart_area), missing(counterpart_sector), missing(currency_denom),
                           missing(cust_breakdown), missing(disability_status), missing(education_lev),
                           missing(expenditure), missing(financial_institution), missing(flow_stock_entry),
                           missing(freq), missing(functional_cat), missing(gfs_sto),
                           missing(income_wealth_quantile), missing(indicator), missing(instr_asset),
                           missing(instrument_and_assets_classification), missing(int_acc_item),
                           missing(maturity), missing(occupation), missing(prices), missing(product),
                           missing(ref_area), missing(ref_sector), missing(reporting_type), missing(series),
                           missing(sex), missing(sto), missing(summary_statistics), missing(survey),
                           missing(transformation), missing(type), missing(unit_measure),
                           missing(urbanisation), missing(valuation))
    if(supplied_list & any(supplied_vectors)){
        warning("Parameters list argument cannot be combined with character vector parameters arguments.
Character vector parameters arguments will be ignored.",immediate.=T)
    }
    if(!missing(parameters)){
        if(class(parameters) != "list" | any(is.null(names(parameters))) |
           class(parameters[[1]]) != "data.frame" |
           !all(names(parameters[[1]]) == c("input_code","description"))){
            stop("parameters argument must be a named list of data frames, each with columns \'input_code\' and \'description\'.",
                 call. = FALSE)
        }
    }

    data_dimensions <- imf_parameters(database_id)
    if(supplied_list){
        if(any(!(names(parameters) %in% names(data_dimensions)))){
            stop(paste0(paste(names(parameters)[which(!(names(parameters) %in% names(data_dimensions)))],collapse = ", ")," not valid parameter(s) for the ",database_id," database.
                        Use imf_parameters(\'",database_id,"\') to get valid parameters."),
                 call. = FALSE)
        }
        name_vector <- names(data_dimensions)
        data_dimensions <- map(1:length(name_vector),function(x){
            if(name_vector[x] %in% names(parameters)){
                df <- filter(data_dimensions[[x]],input_code %in% parameters[[name_vector[x]]]$input_code)
                if(any(!(parameters$input_code %in% df$input_code))){
                    warning(paste(sum(!(parameters$input_code %in% df$input_code)),
" invalid user-supplied input code(s) for",name_vector[x],"parameter will be ignored.
Use imf_parameters(\'",database_id,"\')$",name_vector[x],"to see all valid input codes for this parameter.
Note that codes are case sensitive.",immediate.=T))
                }
                df <- if(nrow(df) == nrow(data_dimensions[[x]])){
                    data.frame(input_code = c(),description = c())
                }else{df}
                return(df)
            }else{
                return(data.frame(input_code = c(),description = c()))
            }
        })
        names(data_dimensions) <- name_vector
    }else if(any(supplied_vectors)){
        if(any(!(vector_vars[supplied_vectors] %in% names(data_dimensions)))){
            stop(paste0(paste(vector_vars[supplied_vectors][which(!(vector_vars[supplied_vectors] %in% names(data_dimensions)))],collapse = ", ")," not valid parameter(s) for the ",database_id," database.
Use imf_parameters(\'",database_id,"\') to get valid parameters."),
                 call. = FALSE)
        }
        name_vector <- names(data_dimensions)
        data_dimensions <- map(1:length(name_vector),function(x){
            if(name_vector[x] %in% vector_vars[supplied_vectors]){
                df <- filter(data_dimensions[[x]],input_code %in% eval(parse(text = name_vector[x])))
                if(any(!(eval(parse(text = name_vector[x])) %in% df$input_code))){
                    warning(paste0(sum(!(eval(parse(text = name_vector[x])) %in% df$input_code)),
" invalid user-supplied input code(s) for ",name_vector[x]," parameter will be ignored.
Use imf_parameters(\'",database_id,"\')$",name_vector[x]," to see all valid input codes for this parameter.
Note that codes are case sensitive.",immediate.=T))
                }
                df <- if(nrow(df) == nrow(data_dimensions[[x]])){
                    data.frame(input_code = c(),description = c())
                }else{df}
                return(df)
            }else{
                return(data.frame(input_code = c(),description = c()))
            }
        })
        names(data_dimensions) <- name_vector
    }else{
        warning("User supplied no filter parameters for the API request.
imf_data will attempt to request the entire database.",immediate.=T)
        name_vector <- names(data_dimensions)
        data_dimensions <- map(1:length(data_dimensions),function(x){
            data.frame(input_code = c(),description = c())
        })
        names(data_dimensions) <- name_vector
    }

    parameter_string <- paste(unlist(map(1:length(data_dimensions),function(x){
        paste(data_dimensions[[x]]$input_code,collapse="+")
    })),collapse=".")
    url <- paste0('http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/',database_id,'/',
                  parameter_string,
                  if(!missing(start_year) | !missing(end_year)){'?'}else{''},
                  if(!missing(start_year)){paste0('startPeriod=',start)}else{''},
                  if(!missing(start_year) & !missing(end_year)){paste0('&endPeriod=',end)}
                  else if(missing(start_year) & !missing(end_year)){paste0('endPeriod=',end)}
                  else{''})
    if(print_url){print(url)}

    raw_dl <- download_parse(url)$CompactData$DataSet$Series
    if(!is.data.frame(raw_dl$Obs)){
        df <- map_dfr(1:length(raw_dl$Obs),function(n){
            df <- raw_dl$Obs[[n]] %>%
                select(date = `@TIME_PERIOD`,
                       value = `@OBS_VALUE`)
            tmp <- as.data.frame(
                map(.x = name_vector,.f = function(variable_name){
                    vec <- rep(raw_dl[[paste0("@",toupper(variable_name))]][n],times=nrow(df))
                    return(vec)
                })
            )
            names(tmp) <- name_vector
            df <- bind_cols(df,tmp)
            return(df)
        })
    }else{
        df <- raw_dl$Obs %>%
            select(date = `@TIME_PERIOD`,
                   value = `@OBS_VALUE`)
        tmp <- as.data.frame(
            map(.x = name_vector,.f = function(variable_name){
                vec <- rep(raw_dl[[paste0("@",toupper(variable_name))]],times=nrow(df))
                return(vec)
            })
        )
        names(tmp) <- name_vector
        df <- bind_cols(df,tmp)
    }
    return(df)
}
