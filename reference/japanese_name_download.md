# Download the Japanese-name checklist data file

Downloads the Vascular Plant Japanese Name Checklist ver. 1.10 Excel
file into the user's R cache. The file is not bundled with the package.

## Usage

``` r
japanese_name_download(overwrite = FALSE)

ylist_download(overwrite = FALSE)
```

## Arguments

- overwrite:

  Logical. If `FALSE`, an existing cached file is reused.

## Value

The path to the cached file, invisibly.

## Details

`ylist_download()` is retained as a deprecated compatibility wrapper.
Use `japanese_name_download()` for new code.
