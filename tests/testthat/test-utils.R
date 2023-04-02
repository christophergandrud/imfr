test_that("download_parse_cached works correctly", {
    # Define helper function to remove cache items for a list of urls
    remove_cache_items <- function(urls) {
            # Create a disk cache reference object
            cache <- cachem::cache_disk(max_age = 60 * 60 * 24 * 14, dir = "/my_cache")
            for (url in urls) {
                cache_key <- digest::digest(url, algo = "md5")
                cache$remove(cache_key)
            }
    }

    # Mock the download_parse function to avoid making real API requests during testing
    mock_download_parse <- function(url, times = 1) {
        return(list(result = paste("Result for", url, "with", times, "retries")))
    }

    url1 <- "https://api.example.com/data1"
    url2 <- "https://api.example.com/data2"

    # Remove cache items for the test URLs before starting the test
    remove_cache_items(c(url1, url2))

    # Test both TRUE and FALSE conditions for use_cache
    for (use_cache in c(TRUE, FALSE)) {
        # Set the imf_use_cache option
        set_imf_use_cache(use_cache)

        # Call the function for the first time and save the results
        result1_first <- download_parse_cached(url1, mock_download_parse, times = 2)
        result2_first <- download_parse_cached(url2, mock_download_parse, times = 3)

        # Call the function again for the same URLs with different 'times' values
        result1_second <- download_parse_cached(url1, mock_download_parse, times = 4)
        result2_second <- download_parse_cached(url2, mock_download_parse, times = 5)

        if (use_cache) {
            # Check if the 'result' elements of the results are equal, indicating that the cache was used
            expect_equal(result1_first$result, result1_second$result)
            expect_equal(result2_first$result, result2_second$result)
        } else {
            # Check if the 'result' elements of the results are not equal, indicating that the cache was not used
            expect_equal(result1_first$result != result1_second$result, TRUE)
            expect_equal(result2_first$result != result2_second$result, TRUE)
        }

        # Check if the 'result' elements of the first results are as expected
        expected_result1 <- paste("Result for", url1, "with", 2, "retries")
        expected_result2 <- paste("Result for", url2, "with", 3, "retries")
        expect_equal(result1_first$result, expected_result1)
        expect_equal(result2_first$result, expected_result2)
    }
})

test_that("_download_parse works correctly", {
    # Test with a valid URL
    valid_url <- "http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/BOP/A.US.BXSTVPO_BP6_USD?startPeriod=2020"
    valid_result <- download_parse(valid_url)

    expect_true(is.list(valid_result))
    expect_equal(length(valid_result), 1)
    expect_true("CompactData" %in% names(valid_result))
    expect_equal(length(valid_result$CompactData), 6)

    # Test with an invalid URL
    invalid_url <- "http://dataservices.imf.org/REST/SDMX_JSON.svc/CompactData/not_a_real_database/"
    expect_error(download_parse(invalid_url), "API request failed")
})

test_that("Enforced wait time between imf_get calls works correctly", {
    # Set the imf_wait_time to 2.5 seconds
    set_imf_wait_time(2.5)

    # Call imf_get for the first time
    start_time <- Sys.time()
    response1 <- imf_get("https://example.com/")

    # Call imf_get for the second time
    response2 <- imf_get("https://example.com/")
    end_time <- Sys.time()

    # Calculate the time difference between the two calls
    time_diff <- as.numeric(difftime(end_time, start_time, units = "secs"))

    # Test if the time difference is greater than or equal to 2.5 seconds
    expect_true(time_diff >= 2.5)

    # Additional tests to check if the response status codes are 200 (successful)
    expect_equal(status_code(response1), 200)
    expect_equal(status_code(response2), 200)
})