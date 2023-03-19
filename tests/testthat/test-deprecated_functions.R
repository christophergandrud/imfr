test_that("imf_ids works", {
    ids <- imf_ids()
    expect_warning(imf_ids(),"(.*deprecated.*)")
    expect_equal(nrow(ids) > 1, TRUE)
    expect_equal(ncol(ids) == 2, TRUE)
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
    li <- imf_data("PCPS","PCOAL","all",freq="A",start=2020,end=2022,return_raw=T)
    expect_error(imf_data(),"database_id")
    expect_error(imf_data("PCPS","PCOAL","all",freq=c("A","M"),start=2020,end=2022,return_raw=T),"imf_data only works with one frequency at a time.",fixed=T)
    expect_warning(imf_data("PCPS","PCOAL","all",start=2020),"(.*deprecated.*)")
    expect_equal(nrow(df) == 18, TRUE)
    expect_equal(ncol(df) == 4, TRUE)
    expect_equal("PCOAL" %in% names(df), TRUE)
    expect_equal(all(df$year >= 2015) & all(df$year <= 2020), TRUE)
    expect_equal("Obs" %in% names(li), TRUE)
    expect_equal(!any(is.na(df)), TRUE)
})

test_that("imf_metastructure works", {
    df <- imf_metastructure("BOP")
    raw_data <- imf_metastructure("BOP",return_raw=T)
    expect_warning(imf_metastructure("PCPS"),"(.*deprecated.*)")
    expect_equal(nrow(df) == 1 & ncol(df) == 2, TRUE)
    expect_equal(all(names(df) %in% c("codelist","description")), TRUE)
    expect_equal(!any(is.na(df)), TRUE)
    expect_equal(S3Class(raw_data) == "list", TRUE)
    expect_equal(length(raw_data[[1]]) == 8, TRUE)
})

test_that("imf_metadata works", {
    output <- imfr::imf_metadata("PCPS")
    expect_warning(imf_metadata("PCPS"),"(.*deprecated.*)")
    expect_equal(S3Class(output) == "list", TRUE)
    expect_equal(!any(is.na(output)), TRUE)
})