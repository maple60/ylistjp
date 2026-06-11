write_ylist_fixture <- function(path) {
  lines <- c(
    paste(
      c(
        "学名 withAuthor",
        "和名",
        "別名",
        "ステータス",
        "LAPG 科名",
        "LAPG Family",
        "学名",
        "修正日",
        "ID"
      ),
      collapse = "\t"
    ),
    paste(
      c(
        "Quercus serrata Murray",
        "コナラ",
        "ナラ",
        "標準",
        "ブナ科",
        "Fagaceae",
        "Quercus serrata",
        "2021.01.31",
        "2632"
      ),
      collapse = "\t"
    ),
    paste(
      c(
        "Quercus serrata Thunb.",
        "コナラ",
        "",
        "synonym",
        "ブナ科",
        "Fagaceae",
        "Quercus serrata",
        "2012.05.12",
        "21129"
      ),
      collapse = "\t"
    ),
    paste(
      c(
        "Quercus crispula Blume",
        "ミズナラ",
        "オオナラ コナラ",
        "標準",
        "ブナ科",
        "Fagaceae",
        "Quercus crispula",
        "2021.01.31",
        "2627"
      ),
      collapse = "\t"
    )
  )

  encoded <- iconv(lines, from = "UTF-8", to = "CP932")
  writeLines(encoded, con = path, useBytes = TRUE)
}

with_fixture_cache <- function(code) {
  source <- tempfile(fileext = ".txt")
  cache_dir <- tempfile("ylistjp-cache-")
  write_ylist_fixture(source)

  old_options <- options(
    ylistjp.source_url = source,
    ylistjp.cache_dir = cache_dir,
    ylistjp.data = NULL
  )
  on.exit(options(old_options), add = TRUE)
  on.exit(unlink(c(source, cache_dir), recursive = TRUE, force = TRUE), add = TRUE)

  force(code)
}
