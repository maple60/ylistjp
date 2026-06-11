YLIST_PUBLIC_TAB_URL <- "http://www.ylist.info/20210514YList_download_tab.txt"
YLIST_CACHE_FILE <- "20210514YList_download_tab.txt"

ylist_source_url <- function() {
  getOption("ylistjp.source_url", YLIST_PUBLIC_TAB_URL)
}

ylist_cache_dir <- function() {
  cache_dir <- getOption("ylistjp.cache_dir", NULL)
  if (!is.null(cache_dir)) {
    return(cache_dir)
  }

  tools::R_user_dir("ylistjp", which = "cache")
}

ylist_cache_path <- function() {
  file.path(ylist_cache_dir(), YLIST_CACHE_FILE)
}

is_probably_url <- function(x) {
  grepl("^[A-Za-z][A-Za-z0-9+.-]*://", x)
}

#' Download the public YList tab-delimited data file
#'
#' Downloads the public YList tab-delimited data file into the user's R cache.
#' The file is not bundled with the package.
#'
#' @param overwrite Logical. If `FALSE`, an existing cached file is reused.
#'
#' @return The path to the cached file, invisibly.
#' @export
ylist_download <- function(overwrite = FALSE) {
  if (!isTRUE(overwrite) && !identical(overwrite, FALSE)) {
    stop("`overwrite` must be TRUE or FALSE.", call. = FALSE)
  }

  path <- ylist_cache_path()
  if (file.exists(path) && !overwrite) {
    return(invisible(path))
  }

  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)

  source <- ylist_source_url()
  tmp <- tempfile(fileext = ".txt")
  on.exit(unlink(tmp), add = TRUE)

  if (!is_probably_url(source) && file.exists(source)) {
    ok <- file.copy(source, tmp, overwrite = TRUE)
    if (!ok) {
      stop("Failed to copy local YList source file.", call. = FALSE)
    }
  } else {
    status <- utils::download.file(
      url = source,
      destfile = tmp,
      mode = "wb",
      quiet = TRUE
    )
    if (!identical(status, 0L)) {
      stop("Failed to download YList data from ", source, call. = FALSE)
    }
  }

  ok <- file.copy(tmp, path, overwrite = TRUE)
  if (!ok) {
    stop("Failed to write YList data to cache: ", path, call. = FALSE)
  }

  invisible(path)
}
