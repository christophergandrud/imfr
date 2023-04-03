test_that("set_imf_app_name sets the application name correctly", {
    expect_equal(getOption("imf_app_name"),NULL)
    expect_warning(set_imf_app_name(""))
    expect_warning(set_imf_app_name("imfr"))
    expect_warning(set_imf_app_name(rep("z",2)))
    expect_error(set_imf_app_name(NULL))
    expect_error(set_imf_app_name(NA_character_))
    expect_error(set_imf_app_name(paste(rep("z",256),collapse="")))
    set_imf_app_name("imfr_tester")
    expect_equal(getOption("imf_app_name"), "imfr_tester", TRUE)
})

test_that("set_imf_wait_time works correctly", {
    # Test for valid input
    set_imf_wait_time(2.0)
    expect_equal(as.numeric(getOption("imf_wait_time")), 2.0)

    # Test for non-numeric input
    expect_error(set_imf_wait_time("invalid"), "single numeric value")

    # Test for vector input
    expect_error(set_imf_wait_time(c(2, 3)), "single numeric value")

    # Test for wait time greater than 10 seconds
    expect_error(set_imf_wait_time(11), "not allowed")

    # Test for wait time greater than 5 seconds (with warning)
    expect_warning(set_imf_wait_time(6), "not recommended")
    expect_equal(as.numeric(getOption("imf_wait_time")), 6.0)
    set_imf_wait_time(1.5)
})

test_that("set_imf_use_cache sets the option correctly and handles errors", {
    # Test that the option is set correctly when use_cache is TRUE
    set_imf_use_cache(TRUE)
    expect_equal(getOption("imf_use_cache"), TRUE)

    # Test that the option is set correctly when use_cache is FALSE
    set_imf_use_cache(FALSE)
    expect_equal(getOption("imf_use_cache"), FALSE)

    # Test that an error is thrown if use_cache is missing
    expect_error(set_imf_use_cache(), "The 'use_cache' argument must be provided.")

    # Test that an error is thrown if use_cache is not a valid boolean value
    expect_error(set_imf_use_cache("not_a_boolean"), "The 'use_cache' argument must be a valid, non-NA, non-null boolean value.")
    expect_error(set_imf_use_cache(NA), "The 'use_cache' argument must be a valid, non-NA, non-null boolean value.")
    expect_error(set_imf_use_cache(NULL), "The 'use_cache' argument must be a valid, non-NA, non-null boolean value.")
})