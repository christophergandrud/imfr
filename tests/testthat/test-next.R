expect_error(
    imf_data(database_id = "IFS",
             indicator = "GG_GALM_G01_XDC",
             country = "all",
             freq = "A",
             start = 1900, end = 2020
    ),
    NA
)

expect_equal(
    ncol(imf_data(database_id = "WHDREO", indicator = "PCPI_PCH",
                       freq = "A", country = c("MX"))),
    3
)
