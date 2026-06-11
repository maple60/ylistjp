test_that("ylist_download writes to and reuses the cache", {
  with_fixture_cache({
    path <- ylist_download()

    expect_true(file.exists(path))
    expect_match(path, "20210514YList_download_tab.txt", fixed = TRUE)

    first_mtime <- file.info(path)$mtime
    second_path <- ylist_download()

    expect_identical(path, second_path)
    expect_equal(file.info(path)$mtime, first_mtime)
  })
})

test_that("ylist_load reads CP932 tab-delimited YList data", {
  with_fixture_cache({
    data <- ylist_load()

    expect_s3_class(data, "data.frame")
    expect_true("和名" %in% names(data))
    expect_equal(data[["和名"]][[1]], "コナラ")
    expect_equal(data[["学名"]][[1]], "Quercus serrata")
  })
})

test_that("ylist_load refresh redownloads cached data", {
  with_fixture_cache({
    path <- ylist_download()
    writeLines("broken", path)

    data <- ylist_load(refresh = TRUE)

    expect_equal(data[["和名"]][[1]], "コナラ")
  })
})
