test_that("imf_ids works", {
    ids <- imf_ids()
    expect_warning(imf_ids(),"(.*deprecated.*)")
    expect_equal(nrow(ids) > 1, TRUE)
    expect_equal(all(names(ids) %in% c("database_id","description")), TRUE)
})

test_that("imf_codelist works", {
    df <- imf_codelist("BOP")
    li <- imf_codelist("BOP",return_raw=T)
    expect_equal(all(names(df) %in% c("codelist","description")), TRUE)
    expect_equal(nrow(df) > 1, TRUE)
    expect_equal(S3Class(li) == "list", TRUE)
    expect_error(imf_codelist(times=1))
})

test_that("imf_codes works", {
    df <- imf_codes(codelist="CL_AREA_BOP")
    li <- imf_codes(codelist="CL_AREA_BOP",return_raw=T)
    expect_equal(all(names(df) %in% c("codes","description")), TRUE)
    expect_equal(nrow(df) > 1, TRUE)
    expect_equal(S3Class(li) == "list", TRUE)
    expect_error(imf_codes(times=1))
})

test_that("imf_data works", {
    df <- imf_data("PCPS","PCOAL","all",start=2015,end=2020)
    li <- imf_data("PCPS","PCOAL","all",freq=c("A","M"),start=2020,end=2022,return_raw=T)
    expect_error(imf_data(times=1),"database_id is a required argument.",fixed=T)
    expect_warning(imf_data("PCPS","PCOAL","all",start=2020),"(.*deprecated.*)")
    expect_equal(nrow(df) > 1, TRUE)
    expect_equal("PCOAL" %in% names(df), TRUE)
    expect_equal(all(df$year >= 2015) & all(df$year <= 2020), TRUE)
    expect_equal("Obs" %in% names(li), TRUE)
})