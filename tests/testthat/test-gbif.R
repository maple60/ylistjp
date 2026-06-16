test_that("gbif_match requires jsonlite", {
  skip_if(requireNamespace("jsonlite", quietly = TRUE))

  expect_error(gbif_match("Quercus serrata"), "jsonlite")
})

test_that("gbif_match can query GBIF when network tests are enabled", {
  skip_if_not(
    identical(Sys.getenv("JPPLANTNAMES_RUN_NETWORK_TESTS"), "true"),
    "Set JPPLANTNAMES_RUN_NETWORK_TESTS=true to run live GBIF tests."
  )
  skip_if_not(requireNamespace("jsonlite", quietly = TRUE), "jsonlite is not installed.")

  result <- gbif_match("Quercus serrata")

  expect_equal(result$canonicalName[[1]], "Quercus serrata")
  expect_equal(result$status[[1]], "ACCEPTED")
})
