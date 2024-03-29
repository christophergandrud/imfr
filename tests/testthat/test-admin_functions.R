test_that("imf_app_name sets the application name correctly", {
    expect_warning(imf_app_name(""))
    expect_warning(imf_app_name("imfr"))
    expect_warning(imf_app_name(rep("z",2)))
    expect_error(imf_app_name(NULL))
    expect_error(imf_app_name(NA_character_))
    expect_error(imf_app_name(paste(rep("z",256),collapse="")))
    imf_app_name("imfr_admin_functions_tester")
    expect_equal(Sys.getenv("IMF_APP_NAME"), "imfr_admin_functions_tester", TRUE)
})