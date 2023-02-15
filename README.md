
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

The imfr package introduces four core functions: `imf_databases`,
`imf_parameters`, `imf_parameter_defs`, and `imf_data`.

``` r
library(imfr)
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this. You could also
use GitHub Actions to re-render `README.Rmd` every time you push. An
example workflow can be found here:
<https://github.com/r-lib/actions/tree/v1/examples>.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
