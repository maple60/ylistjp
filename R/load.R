#' Load cached YList data
#'
#' Loads the cached YList tab-delimited data as a data frame. If the cache does
#' not exist, the public data file is downloaded first.
#'
#' @param refresh Logical. If `TRUE`, redownload the YList data before loading.
#'
#' @return A data frame containing YList rows.
#' @export
ylist_load <- function(refresh = FALSE) {
  if (!isTRUE(refresh) && !identical(refresh, FALSE)) {
    stop("`refresh` must be TRUE or FALSE.", call. = FALSE)
  }

  path <- ylist_cache_path()
  if (refresh || !file.exists(path)) {
    ylist_download(overwrite = refresh)
  }

  read_ylist_tab(path)
}

read_ylist_tab <- function(path) {
  data <- utils::read.delim(
    file = path,
    sep = "\t",
    header = TRUE,
    fileEncoding = "CP932",
    encoding = "UTF-8",
    stringsAsFactors = FALSE,
    check.names = FALSE,
    quote = "",
    comment.char = "",
    fill = TRUE
  )

  names(data) <- sub("\ufeff", "", names(data), fixed = TRUE)
  data
}

ylist_data <- function() {
  data <- getOption("ylistjp.data", NULL)
  if (!is.null(data)) {
    return(data)
  }

  ylist_load()
}
