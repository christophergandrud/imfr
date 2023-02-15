#Instead of having an imf_codelist function that the user has to drop into
#the imf_codes function, just make imf_codelist a utility function on the back
#end and auto-pull the indicator code.

#imf_data function fails if you don't specify the right country code:
#imfr::imf_data("PCPS","PAGRI","W00")

# Load required libraries
library("tidyverse")
library("ggplot2")
library("httr")
library("jsonlite")
library("imfr")

#The following listed databases apparently are not actually accessible through the
#API: series_list[c(54,61,210:213,218),]

# Scrape economic dataset structure dictionary from IMF RESTful API
# (API Instructions: http://www.bd-econ.com/imfapi1.html)
url <- 'http://dataservices.imf.org/REST/SDMX_JSON.svc/'
database_list <- fromJSON(rawToChar(GET(paste0(url, 'Dataflow'))$content))$Structure$Dataflows$Dataflow

# Save dataset names and corresponding keys in a tibble
database_list <- tibble(series_name = database_list$Name$`#text`,
                      series_key = database_list$KeyFamilyRef$KeyFamilyID)

#Fetch data dimensions for all IMF databases
database_codes <- map_dfr(database_list$series_key,function(x){
    Sys.sleep(1)
    tryCatch({imf_codelist(x)},error=function(cond){return(data.frame(codelist = NA, description = NA))}) %>%
        mutate(database = x)
})

# Search series names to fetch the key for the Primary Commodity Price System series
search_term <- 'Primary Commodity'
series_key <- series_list$series_key[stringr::str_detect(series_list$series_name,search_term)]

# Use the Primary Commodity Price System key to get dimensions of that series
dimension_list <- fromJSON(rawToChar(GET(paste0(url, "DataStructure/",series_key))$content))$Structure$KeyFamilies$KeyFamily$Components$Dimension %>%
    mutate(`@isFrequencyDimension` = as.logical(`@isFrequencyDimension`)) %>%
    mutate(`@isFrequencyDimension` = case_when(is.na(`@isFrequencyDimension`)~F,
                                           T~`@isFrequencyDimension`))

# Get codes for all dimensions in the series and save in a tibble
dimension_list <- dimension_list %>%
    mutate(dimension_key = case_when(`@isFrequencyDimension`~NA_character_,
                                     T~paste0("CodeList/", `@codelist`)))

#For each dimension, save possible variable values and corresponding descriptions
code_list <- map(dimension_list$dimension_key[1:nrow(dimension_list)], function(k) {
    if(!is.na(k)){
        fromJSON(rawToChar(GET(paste(url, k, sep = ""))$content))$Structure$CodeLists$CodeList$Code
    }else{
        list(`@value` = c("A","M","Q"),Description = list(`#text` = c("Annual","Monthly","Quarterly")))
    }
})
names(code_list) <- dimension_list$`@codelist`
indicator_list <- map(1:length(code_list),function(x){
    tibble(indicator_code = code_list[[x]]$`@value`,
           indicator_description = code_list[[x]]$Description$`#text`)})
names(indicator_list) <- dimension_list$dimension_description
rm(code_list)

#Define url and key for API request
url <- 'http://dataservices.imf.org/REST/SDMX_JSON.svc/'
key <- 'CompactData/PCPS/...?startPeriod=2000&endPeriod=2023'
key <- 'CompactData/PCPS/A+Q...' # adjust codes here

# Download series JSON data from the API
data <- fromJSON(rawToChar(GET(paste0(url, key))$content))$CompactData$DataSet$Series

#Get dataframe of all observations in the dataset
df <- map_dfr(1:length(data$Obs),function(n){
    df <- data$Obs[[n]] %>%
        select(date = `@TIME_PERIOD`,
               value = `@OBS_VALUE`) %>%
        mutate(commodity = rep(data$`@COMMODITY`[n]),
               unit = rep(data$`@UNIT_MEASURE`[n]),
               frequency = rep(data$`@FREQ`[n]))
    return(df)
})

# Join dataframes to map codes to series and measure names
df <- df %>%
    left_join(indicator_list$COMMODITY, join_by(commodity == indicator_code)) %>%
    select(date,value,commodity,unit,frequency,commodity_description = indicator_description) %>%
    left_join(indicator_list$UNIT_MEASURE, join_by(unit == indicator_code)) %>%
    select(date,value,commodity,unit,frequency,commodity_description,unit_description = indicator_description) %>%
    left_join(indicator_list$FREQ, join_by(frequency == indicator_code)) %>%
    select(date,value,commodity,unit,frequency,commodity_description,unit_description,frequency_description = indicator_description) %>%
    mutate(value = as.numeric(value))

# Plot the data
df %>%
    filter(commodity == "PAGRI",
           frequency == "M",
           unit == "IX") %>%
    mutate(date = as.Date(paste0(date,"-01"),format="%Y-%m-%d")) %>%
    ggplot(aes(x = date, y = value)) +
    geom_line(colour = "blue") +
    ggtitle("Agricultural Raw Materials Prices")
