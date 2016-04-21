imfr
====================================

[![CRAN Version](http://www.r-pkg.org/badges/version/imfr)](http://cran.r-project.org/package=imfr) [![Build Status](https://travis-ci.org/christophergandrud/imfr.svg?branch=master)](https://travis-ci.org/christophergandrud/imfr)

R package for interacting with the [International Monetary Funds's](http://data.imf.org/) [RESTful JSON API](http://datahelp.imf.org/knowledgebase/articles/667681-using-json-restful-web-service)

# How to download IMF data

You can use the `imf_data` function to download the data the IMF makes available via its API. To do this you will need at least the following information:

- `database_id`: the ID of the specific database you wish to download the data series from. You can find the list of IDs and their description using the `imf_ids` function.

- `indicator`: the IMF indicators of the variables you want to download. To find these by:

    1. Once you have the `database_id` for the database you want to access, you can use the `imf_codelist` function to find the code list of the database.

    2. Then using the indicator code (usually `CL_INDICATOR|database_id`) in `imf_codes`, you can find the data series indicator codes in that database.

    *Tip*: if you have a number of country identifiers that are not in ISO2C format, you can use the helpful [countrycode](https://cran.r-project.org/web/packages/countrycode/index.html) package to convert them.

- `country`: one or more [ISO two letter country codes](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) for the countries you would like to download the data for. If `country = 'all'` then all available countries will be downloaded.

- `start` and `end`: the start and end years for which you would like to download the data.

- `freq`: the frequency of the series you want to download. Often series are available annually, quarterly, and monthly.

## Example

Imagine that we want to download Effective Exchange Rate (CPI base) for China and the UK for 2013:


```r
library(imfr)

real_ex <- imf_data(database_id = 'IFS', indicator = 'EREER_IX',
                    country = c('CN', 'GB'), freq = 'A',
                    start = 2013, end = 2013)
```




```r
real_ex
```

```
##   iso2c year EREER_IX
## 2    CN 2013 115.4556
## 1    GB 2013 105.7741
```
