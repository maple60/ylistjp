#' Match scientific names against GBIF
#'
#' Thin helper around the GBIF species match API.
#'
#' @param scientific_name Character vector of scientific names.
#'
#' @return A data frame with selected GBIF match fields.
#' @export
#'
#' @examples
#' \dontrun{
#' gbif_match("Quercus serrata")
#' }
gbif_match <- function(scientific_name) {
  if (!is.character(scientific_name)) {
    stop("`scientific_name` must be a character vector.", call. = FALSE)
  }
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Package `jsonlite` is required for gbif_match().", call. = FALSE)
  }

  rows <- lapply(scientific_name, gbif_match_one)
  result <- do.call(rbind, rows)
  row.names(result) <- NULL
  result
}

gbif_match_one <- function(scientific_name) {
  if (is.na(scientific_name) || identical(scientific_name, "")) {
    return(empty_gbif_row(scientific_name))
  }

  url <- paste0(
    "https://api.gbif.org/v1/species/match?name=",
    utils::URLencode(scientific_name, reserved = TRUE)
  )

  json <- paste(readLines(url, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  parsed <- jsonlite::fromJSON(json, flatten = TRUE)

  data.frame(
    input = scientific_name,
    usageKey = gbif_field(parsed, "usageKey"),
    scientificName = gbif_field(parsed, "scientificName"),
    canonicalName = gbif_field(parsed, "canonicalName"),
    rank = gbif_field(parsed, "rank"),
    status = gbif_field(parsed, "status"),
    confidence = gbif_field(parsed, "confidence"),
    matchType = gbif_field(parsed, "matchType"),
    kingdom = gbif_field(parsed, "kingdom"),
    family = gbif_field(parsed, "family"),
    genus = gbif_field(parsed, "genus"),
    species = gbif_field(parsed, "species"),
    stringsAsFactors = FALSE
  )
}

empty_gbif_row <- function(scientific_name) {
  data.frame(
    input = scientific_name,
    usageKey = NA,
    scientificName = NA_character_,
    canonicalName = NA_character_,
    rank = NA_character_,
    status = NA_character_,
    confidence = NA,
    matchType = NA_character_,
    kingdom = NA_character_,
    family = NA_character_,
    genus = NA_character_,
    species = NA_character_,
    stringsAsFactors = FALSE
  )
}

gbif_field <- function(x, name) {
  value <- x[[name]]
  if (is.null(value) || length(value) == 0) {
    return(NA)
  }

  value
}
