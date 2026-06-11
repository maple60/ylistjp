col_japanese_name <- "\u548c\u540d"
col_alias_name <- "\u5225\u540d"
col_scientific_name <- "\u5b66\u540d"
col_scientific_name_author <- "\u5b66\u540d withAuthor"
col_status <- "\u30b9\u30c6\u30fc\u30bf\u30b9"
status_standard <- "\u6a19\u6e96"

required_ylist_columns <- c(
  col_japanese_name,
  col_alias_name,
  col_scientific_name,
  col_scientific_name_author,
  col_status
)

check_ylist_columns <- function(data, required = required_ylist_columns) {
  missing <- setdiff(required, names(data))
  if (length(missing) > 0) {
    stop(
      "YList data is missing required column(s): ",
      paste(missing, collapse = ", "),
      call. = FALSE
    )
  }

  invisible(data)
}

#' Look up scientific names from Japanese plant names
#'
#' Exact-matches Japanese names in YList and returns the standard scientific
#' name.
#'
#' @param name Character vector of Japanese plant names.
#' @param with_author Logical. If `TRUE`, include the name author.
#'
#' @return A character vector with one result per input name. Missing names
#'   return `NA_character_`.
#' @export
#'
#' @examples
#' \dontrun{
#' academic_name("\u30b3\u30ca\u30e9")
#' academic_name("\u30b3\u30ca\u30e9", with_author = TRUE)
#' }
academic_name <- function(name, with_author = FALSE) {
  if (!is.character(name)) {
    stop("`name` must be a character vector.", call. = FALSE)
  }
  if (!isTRUE(with_author) && !identical(with_author, FALSE)) {
    stop("`with_author` must be TRUE or FALSE.", call. = FALSE)
  }

  data <- ylist_data()
  check_ylist_columns(
    data,
    required = c(
      col_japanese_name,
      col_scientific_name,
      col_scientific_name_author,
      col_status
    )
  )

  column <- if (with_author) col_scientific_name_author else col_scientific_name

  vapply(
    name,
    lookup_one_academic_name,
    data = data,
    column = column,
    FUN.VALUE = character(1),
    USE.NAMES = FALSE
  )
}

lookup_one_academic_name <- function(name, data, column) {
  if (is.na(name)) {
    return(NA_character_)
  }

  hits <- data[
    data[[col_japanese_name]] == name & data[[col_status]] == status_standard,
    ,
    drop = FALSE
  ]

  if (nrow(hits) == 0) {
    return(NA_character_)
  }

  if (nrow(hits) > 1) {
    stop(
      "Multiple standard YList matches found for `",
      name,
      "`. Use ylist_search(\"",
      name,
      "\") to inspect candidates.",
      call. = FALSE
    )
  }

  value <- hits[[column]][[1]]
  if (is.na(value) || identical(value, "")) {
    return(NA_character_)
  }

  value
}

#' Search YList rows
#'
#' Search YList rows by Japanese name, scientific name, alias, or all of those
#' fields.
#'
#' @param query Character scalar to search for.
#' @param field Field to search: `japanese`, `scientific`, `alias`, or `all`.
#' @param exact Logical. If `TRUE`, use exact matching; otherwise use partial
#'   fixed-string matching.
#'
#' @return A data frame of matching YList rows.
#' @export
ylist_search <- function(query, field = c("japanese", "scientific", "alias", "all"), exact = FALSE) {
  if (!is.character(query) || length(query) != 1 || is.na(query)) {
    stop("`query` must be a non-missing character scalar.", call. = FALSE)
  }
  if (!isTRUE(exact) && !identical(exact, FALSE)) {
    stop("`exact` must be TRUE or FALSE.", call. = FALSE)
  }

  field <- match.arg(field)
  data <- ylist_data()
  check_ylist_columns(data)

  columns <- switch(
    field,
    japanese = col_japanese_name,
    scientific = c(col_scientific_name, col_scientific_name_author),
    alias = col_alias_name,
    all = c(
      col_japanese_name,
      col_alias_name,
      col_scientific_name,
      col_scientific_name_author
    )
  )

  mask <- Reduce(
    `|`,
    lapply(columns, function(column) match_ylist_column(data[[column]], query, exact = exact))
  )

  result <- data[mask, , drop = FALSE]
  row.names(result) <- NULL
  result
}

match_ylist_column <- function(values, query, exact) {
  values[is.na(values)] <- ""
  if (exact) {
    return(values == query)
  }

  grepl(tolower(query), tolower(values), fixed = TRUE)
}
