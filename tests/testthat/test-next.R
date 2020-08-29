expect_error(
    imf_data(database_id = "IFS",
             indicator = "GG_GALM_G01_XDC",
             country = "all",
             freq = "A",
             start = 1900, end = 2020
    ),
    NA
)
