# Load cached Japanese-name checklist data

Loads the cached Vascular Plant Japanese Name Checklist ver. 1.10 as a
data frame normalized for the package lookup helpers. If the cache does
not exist, the checklist file is downloaded first.

## Usage

``` r
japanese_name_load(refresh = FALSE)

ylist_load(refresh = FALSE)
```

## Arguments

- refresh:

  Logical. If `TRUE`, redownload the checklist data before loading.

## Value

A data frame containing normalized checklist rows.

## Details

`ylist_load()` is retained as a deprecated compatibility wrapper. Use
`japanese_name_load()` for new code.
