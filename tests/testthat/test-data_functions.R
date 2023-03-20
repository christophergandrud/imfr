test_that("imf_databases works", {
    expect_equal(nrow(imf_databases()) > 1, TRUE)
})

test_that("imf_parameters works", {
    params <- imf_parameters("BOP")
    expect_equal(all(params$input_code == c("A","M","Q")), TRUE)
    expect_error(imf_parameters(times=1))
    expect_error(imf_parameters(database_id="not_a_real_database",times=1))
})

test_that("imf_parameter_defs works",{
    expect_equal(nrow(imf_parameter_defs("BOP_2017M08")) > 1, TRUE)
    expect_error(imf_parameter_defs(times=1),"database_id")
    expect_error(imf_parameters("not_a_real_database",times=1),"database_id")
})

test_that("imf_dataset error handling works",{
    params <- imf_parameters("FISCALDECENTRALIZATION")
    params$freq <- params$freq[1,]
    params$ref_area <- params$ref_area[1,]
    params$indicator <- params$indicator[params$indicator == "edu",]
    params$ref_sector <- params$ref_sector[1,]
    expect_error(imf_dataset(database_id = "APDREO201904",counterpart_area = "X",counterpart_sector = "X",times=1))
    expect_warning(imf_dataset(database_id = "APDREO201904",ref_area="AU",indicator=c("BCA_BP6_USD","XYZ")))
    expect_error(imf_dataset(times=1),"Missing required database_id argument.",fixed=T)
    expect_error(imf_dataset(database_id=2,times=1),"database_id must be a character string.",fixed=T)
    expect_error(imf_dataset(database_id=c(),times=1),"database_id must be a character string.",fixed=T)
    expect_error(imf_dataset(database_id=c("a","b"),times=1),"database_id must be a character string, not a vector.",fixed=T)
    expect_error(imf_dataset(database_id="not_a_real_database",times=1))
    expect_error(imf_dataset(database_id="PCPS",start_year=1,times=1),"Failed to coerce start_year and/or end_year to a four-digit integer.",fixed=T)
    expect_error(imf_dataset(database_id="PCPS",end_year="a",times=1),"Failed to coerce start_year and/or end_year to a four-digit integer.",fixed=T)
    expect_error(imf_dataset(database_id="PCPS",end_year=c(1999,2004),times=1),"start_year and/or end_year must be a four-digit year, not a vector.",fixed=T)
    expect_error(imf_dataset(database_id = "WHDREO201910",freq="M",ref_area="US",indicator=c("PPPSH","NGDPD"),start_year=2010,end_year=2011,times=3),
                 "No data found for that combination of parameters. Try making your request less restrictive.",fixed=T)
    expect_warning(imf_dataset(database_id="FISCALDECENTRALIZATION",parameters=params,ref_sector=c("1C_CG","1C_LG")))
})

test_that("imf_dataset params list request works",{
    params <- list(freq = data.frame(input_code="A",description="blah"),
                   ref_area = data.frame(input_code="US",description="blah"),
                   ref_sector = data.frame(input_code="S13",description="blah"),
                   classification = data.frame(input_code=c("W0_S1_G1151","W0_S1_G1412"),description=c("blah")))
    df <- imf_dataset(database_id = "GFSR2019",parameters = params,start_year=2001,end_year=2002,times=5)
    expect_equal(nrow(df) > 1, TRUE)
    expect_equal(all(as.integer(df$date) >= 2001) & all(as.integer(df$date) <= 2002),TRUE)
    expect_equal(all(df$ref_sector == "S13"), TRUE)
})

test_that("imf_dataset vector parameters request works",{
    df <- imf_dataset(database_id = "AFRREO",indicator = c("TTT_IX","GGX_G01_GDP_PT"),ref_area="7A",start_year=2021)
    expect_equal(nrow(df) > 1, TRUE)
    expect_equal(all(as.integer(df$date) >= 2021), TRUE)
    expect_equal(all(df$indicator %in% c("TTT_IX","GGX_G01_GDP_PT")), TRUE)
})

test_that("imf_dataset data frame prep works under all three conditions",{
    if_condition <- imf_dataset(database_id = "WHDREO201910",freq="A",ref_area="US",indicator=c("PPPSH","NGDPD"),start_year=2010,end_year=2012)
    else_if_condition <- imf_dataset(database_id = "WHDREO201910",freq="A",ref_area="US",indicator=c("PPPSH","NGDPD"),start_year=2010,end_year=2011)
    else_condition <- imf_dataset(database_id = "WHDREO201910",freq="A",ref_area="US",indicator=c("NGDPD"),start_year=2011,end_year=2012)
    desired_names <- c("date","value","freq","ref_area","indicator","unit_mult","time_format")
    expect_equal(nrow(if_condition) == 4L & nrow(else_if_condition) == 2 & nrow(else_condition) == 2, TRUE)
    expect_equal(length(if_condition) == 7 & length(else_if_condition) == 7 & length(else_condition) == 7, TRUE)
    expect_equal(all(names(if_condition) %in% desired_names) & all(names(else_if_condition)  %in% desired_names) & all(names(else_condition)  %in% desired_names), TRUE)
})

test_that("imf_dataset include_metadata works",{
    output <- imf_dataset(database_id = "WHDREO201910",freq="A",ref_area="US",indicator=c("PPPSH","NGDPD"),start_year=2010,end_year=2012,include_metadata=T)
    expect_equal(S3Class(output) == "list", TRUE)
    expect_equal(length(output) == 2, TRUE)
    expect_equal(S3Class(output[[1]]) == "list", TRUE)
    expect_equal(S3Class(output[[1]]) == "list", TRUE)
    expect_equal(!any(is.na(output[[1]])), TRUE)
})