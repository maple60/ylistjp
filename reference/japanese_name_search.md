# Search cached checklist rows

Search cached checklist rows by Japanese name, scientific name, alias,
or all of those fields.

## Usage

``` r
japanese_name_search(
  query,
  field = c("japanese", "scientific", "alias", "all"),
  exact = FALSE
)

ylist_search(
  query,
  field = c("japanese", "scientific", "alias", "all"),
  exact = FALSE
)
```

## Arguments

- query:

  Character scalar to search for.

- field:

  Field to search: `japanese`, `scientific`, `alias`, or `all`.

- exact:

  Logical. If `TRUE`, use exact matching; otherwise use partial
  fixed-string matching.

## Value

A data frame of matching lookup rows.

## Details

`ylist_search()` is retained as a deprecated compatibility wrapper. Use
`japanese_name_search()` for new code.
