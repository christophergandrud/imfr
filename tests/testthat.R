Sys.setenv("R_TESTS" = "")

library(testthat)
library(imfr)

test_check("imfr")
