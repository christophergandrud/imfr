
<!-- README.md is generated from README.Rmd. Please edit that file -->

# imfr

<!-- badges: start -->
<!-- badges: end -->

Originally created by Christopher Gandrud, imfr is an R package for
downloading data from the International Monetary Fund API endpoint.
Version 2.0.0, by Christopher C. Smith, is an extensive revision of the
package to make it both more powerful and more user-friendly.
Regrettably, Version 2.0.0 is *not* backward-compatible; you will need
to update old scripts if you update the package. The changes to the
functionality of the package in this version were extensive, and
adoption of the previous version was judged limited enough to make
backward compatibility unnecessary.

## Installation

To install the development version of imfr, use:

``` r
devtools::install_github("chriscarrollsmith/imfr", build_vignettes = TRUE)
```

## Usage

I recommend using imfr in combination with the tidyverse, stringr, and
knitr libraries, which introduces a powerful set of functions for
viewing and manipulating the data types returned by imfr functions. Each
of these packages can be installed from the CRAN repository using the
`install.packages` function. Once they are installed, load these
packages using the `library` function:

``` r
# Load libraries
library(imfr)
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.2 ──
#> ✔ ggplot2 3.4.0     ✔ purrr   1.0.1
#> ✔ tibble  3.1.8     ✔ dplyr   1.1.0
#> ✔ tidyr   1.3.0     ✔ stringr 1.5.0
#> ✔ readr   2.1.3     ✔ forcats 1.0.0
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
library(stringr)
library(knitr)
```

The imfr package introduces four core functions: `imf_databases`,
`imf_parameters`, `imf_parameter_defs`, and `imf_data`. The function for
downloading datasets is `imf_data`, but you will need the other
functions to determine what arguments to supply to `imf_data`. For
instance, all calls to `imf_data` require a database_id. This is because
the IMF serves many different databases through its API, and the API
needs to know which of these many databases you’re requesting data from.
To obtain a list of databases, use `imf_databases`, like so:

``` r
#Fetch the list of databases available through the IMF API
databases <- imf_databases()
```

This function returns the IMF’s listing of 259 databases available
through the API. (In reality, 11 of the listed databases are defunct and
not actually available: FAS_2015, GFS01, APDREO201610, BOP_2019M2,
BOP_2018M02, DOT_2020Q3, FM202010, APDREO202010, AFRREO202010,
WHDREO202010, BOPAGG_2020.)

To view and explore the database list, it’s possible to open a viewing
pane with `View(databases)` or to create an attractive table with
`kintr::kable(databases)`. Or, if you already know which database you
want, you can fetch the corresponding code by searching the description
column for the database name with `stringr::str_detect`. For instance,
here’s how to search for the Primary Commodity Price System:

``` r
# Filter the 'databases' data frame for descriptions matching `commodity price`
commodity_db <- databases[str_detect(tolower(databases$description),"commodity price"),]

# Display the result using knitr::kable
kable(commodity_db)
```

|     | database_id | description                           |
|:----|:------------|:--------------------------------------|
| 245 | PCPS        | Primary Commodity Price System (PCPS) |

Once you have a database_id, it’s possible to make a call to `imf_data`
to fetch the entire database: `imf_data(commodity_db$database_id)`.
However, while this will succeed for some small databases, it will fail
for many of the larger ones. And even when it succeeds, fetching an
entire database can take a long time. You’re much better off supplying
additional filter parameters to reduce the size of your request.

Requests to databases available through the IMF API are complicated by
the fact that each database uses a different set of parameters when
making a request, and you also have to have the list of valid input
codes for each parameter. You can obtain these using `imf_parameters`:

``` r
# Fetch list of valid parameters and input codes for commodity price database
params <- imf_parameters(commodity_db$database_id)
```

The `imf_parameters` function returns a named list of data frames. Each
named list item corresponds to a parameter used in making requests from
the database.

``` r
# Check class of `params` object
class(params)
#> [1] "list"

# Check names of `params` list items
names(params)
#> [1] "freq"         "ref_area"     "commodity"    "unit_measure"
```

In the event that a parameter name is not self-explanatory, the
`imf_parameter_defs` function can be used to fetch short text
descriptions of each parameter:

``` r
# Fetch and display parameter text descriptions for the commodity price database
param_descriptions <- imf_parameter_defs(commodity_db$database_id)
kable(param_descriptions)
```

| parameter    | description        |
|:-------------|:-------------------|
| freq         | Frequency          |
| ref_area     | Geographical Areas |
| commodity    | Indicator          |
| unit_measure | Unit               |

Each named list item is a data frame containing a vector of valid input
codes that can be used with the named parameter, and a vector of text
descriptions of what each code represents. The `$` operator can be used
to access the data frame for a given parameter, and the data frame can
be explored using `kable` or `View`:

``` r
# Display the data frame of valid input codes for the frequency parameter
kable(params$freq)
```

| input_code | description |
|:-----------|:------------|
| A          | Annual      |
| M          | Monthly     |
| Q          | Quarterly   |

There are two ways to supply parameters to `imf_data`: by supplying
vector arguments or by supplying a modified parameters list.

To supply vector arguments, just find the codes you want and supply them
to `imf_data` using the parameter name as the argument name. The example
below shows how to request 2000–2015 annual coal prices from the Primary
Commodity Price System database:

``` r
# Fetch the 'freq' input code for annual frequency
selected_freq <- params$freq$input_code[str_detect(tolower(params$freq$description),"annual")]

# Fetch the 'commodity' input code for coal
selected_commodity <- params$commodity$input_code[str_detect(tolower(params$commodity$description),"coal index")]

# Fetch the 'unit_measure' input code for index
selected_unit_measure <- params$unit_measure$input_code[str_detect(tolower(params$unit_measure$description),"index")]

# Request data from the API
df <- imf_data(database_id = commodity_db$database_id,
         freq = selected_freq, commodity = selected_commodity,
         unit_measure = selected_unit_measure,
         start_year = 2000, end_year = 2015)
#> Error in curl::curl_fetch_memory(url, handle = handle): Failure when receiving data from the peer
#> Request failed [ERROR]. Retrying in 1.6 seconds...
#> Error in curl::curl_fetch_memory(url, handle = handle): Failure when receiving data from the peer
#> Request failed [ERROR]. Retrying in 3 seconds...

# Display the first few entries in the retrieved data frame using knitr::kable
kable(head(df))
```

| date | value            | freq | ref_area | commodity | unit_measure |
|:-----|:-----------------|:-----|:---------|:----------|:-------------|
| 2000 | 39.3510230293202 | A    | W00      | PCOAL     | IX           |
| 2001 | 49.3378587284039 | A    | W00      | PCOAL     | IX           |
| 2002 | 39.4949091648006 | A    | W00      | PCOAL     | IX           |
| 2003 | 43.2878876950788 | A    | W00      | PCOAL     | IX           |
| 2004 | 82.9185858052862 | A    | W00      | PCOAL     | IX           |
| 2005 | 71.9223526096731 | A    | W00      | PCOAL     | IX           |

To supply a list object, modify each data frame in the `params` list
object to retain only the rows you want, and then supply the modified
list object to `imf_data` as its `parameters` argument. Here is how to
make the same request for annual coal price data using a parameters
list:

``` r
# Filter the frequency data frame for annual frequency
params$freq <- params$freq %>%
    filter(str_detect(tolower(.$description),"annual"))

# Filter the commodity data frame for the coal index
params$commodity <- params$commodity %>%
    filter(str_detect(tolower(.$description),"coal index"))

# Filter the unit_measure data frame for index
params$unit_measure <- params$unit_measure %>%
    filter(str_detect(tolower(.$description),"index"))

# Request data from the API
df <- imf_data(database_id = commodity_db$database_id,
               parameters = params,
         start_year = 2000, end_year = 2015)

# Display the first few entries in the retrieved data frame using knitr::kable
kable(head(df))
```

| date | value            | freq | ref_area | commodity | unit_measure |
|:-----|:-----------------|:-----|:---------|:----------|:-------------|
| 2000 | 39.3510230293202 | A    | W00      | PCOAL     | IX           |
| 2001 | 49.3378587284039 | A    | W00      | PCOAL     | IX           |
| 2002 | 39.4949091648006 | A    | W00      | PCOAL     | IX           |
| 2003 | 43.2878876950788 | A    | W00      | PCOAL     | IX           |
| 2004 | 82.9185858052862 | A    | W00      | PCOAL     | IX           |
| 2005 | 71.9223526096731 | A    | W00      | PCOAL     | IX           |

See also the vignettes, which can be accessed with
`vignette("ParametersList")` and `vignette("ParametersVectors")`.
