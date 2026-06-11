# Building ylistjp as an R package

This article explains how `ylistjp` is organized as a small R package.
It is a worked example for people who want to learn how an R package can
turn a useful public data source into a reproducible analysis tool.

For Japanese, see [日本語:
パッケージ開発チュートリアル](https://maple60.github.io/ylistjp/articles/ja-package-development.md).

## Start from a Small Problem

The original goal was simple:

``` r

academic_name("コナラ")
#> [1] "Quercus serrata"
```

That small API hides several important package-design decisions:

- the package is an unofficial wrapper around YList;
- YList data is not redistributed inside the package;
- the public YList tab-delimited file is downloaded only when needed;
- repeated lookup uses the user’s local cache;
- exact lookup is conservative, so ambiguous names are not silently
  guessed;
- international checking is optional and kept separate from the YList
  lookup.

This is a good package-sized problem because the public API is small,
but it still touches data access, encoding, caching, tests,
documentation, and GitHub Actions.

## Package Skeleton

`ylistjp` follows the standard structure used by many R packages.

| Path | Role in this package |
|----|----|
| `DESCRIPTION` | Package metadata, dependencies, URLs, and vignette settings. |
| `NAMESPACE` | Exported user-facing functions. |
| `R/` | Implementation code for cache, loading, lookup, and GBIF helpers. |
| `man/` | Function reference files generated from roxygen comments. |
| `tests/testthat/` | Unit tests and synthetic YList fixtures. |
| `vignettes/` | Longer pkgdown articles such as usage and maintenance guides. |
| `_pkgdown.yml` | Documentation-site navigation and reference grouping. |
| `.github/workflows/` | GitHub Actions for R package check and pkgdown deployment. |

For a small package, this structure is enough. The key is to keep each
directory responsible for one kind of work: code in `R/`, tests in
`tests/`, longer documentation in `vignettes/`, and automation in
`.github/`.

## Design the Public API First

The core user workflow is:

``` r

library(ylistjp)

academic_name("コナラ")
academic_name("コナラ", with_author = TRUE)
ylist_search("コナラ")
```

The package then exposes a few focused functions around that workflow:

| Function | Purpose |
|----|----|
| [`ylist_download()`](https://maple60.github.io/ylistjp/reference/ylist_download.md) | Download the public YList tab-delimited file into the user cache. |
| [`ylist_load()`](https://maple60.github.io/ylistjp/reference/ylist_load.md) | Read the cached file as a `data.frame`. |
| [`academic_name()`](https://maple60.github.io/ylistjp/reference/academic_name.md) | Return the standard scientific name for an exact Japanese-name match. |
| [`ylist_search()`](https://maple60.github.io/ylistjp/reference/ylist_search.md) | Return candidate rows for manual inspection. |
| [`gbif_match()`](https://maple60.github.io/ylistjp/reference/gbif_match.md) | Optionally check a scientific name against GBIF. |

This split keeps the simple use case simple, while still allowing
advanced users to inspect the underlying data.

## Keep YList Data Outside the Package

`ylistjp` does not bundle YList data. Instead, the data flow is:

1.  [`academic_name()`](https://maple60.github.io/ylistjp/reference/academic_name.md),
    [`ylist_search()`](https://maple60.github.io/ylistjp/reference/ylist_search.md),
    or
    [`ylist_load()`](https://maple60.github.io/ylistjp/reference/ylist_load.md)
    needs YList data.
2.  If no cached file exists,
    [`ylist_download()`](https://maple60.github.io/ylistjp/reference/ylist_download.md)
    downloads the public tab file.
3.  The file is saved under the user’s R cache directory.
4.  Later lookups read the cached file instead of contacting the YList
    server.

This design matters for two reasons. First, the package code can be MIT
licensed without redistributing YList data. Second, repeated analysis
does not send a request to YList for every lookup.

Users can refresh the local copy intentionally:

``` r

ylist_download(overwrite = TRUE)
ylist_load(refresh = TRUE)
```

## Handle Japanese Encoding Explicitly

YList’s public tab-delimited file is read with CP932 decoding:

``` r

utils::read.delim(
  file = path,
  sep = "\t",
  fileEncoding = "CP932",
  encoding = "UTF-8",
  stringsAsFactors = FALSE,
  check.names = FALSE
)
```

This is one of the most important implementation details. Japanese data
sources often use Shift-JIS or CP932. If the package guessed the
encoding implicitly, column names such as `和名`, `学名`, and
`ステータス` could become unreadable on some systems.

The package stores column names internally with Unicode escapes where
that makes the source code safer to edit across environments.

## Make Lookup Conservative

[`academic_name()`](https://maple60.github.io/ylistjp/reference/academic_name.md)
is designed for reproducible analysis, not fuzzy search. Its contract is
intentionally narrow:

- exact-match the YList `和名` column;
- use only rows where `ステータス == "標準"`;
- return `NA_character_` when no standard exact match exists;
- error when multiple standard exact matches exist.

That behavior prevents a script from silently choosing a questionable
name. When a name is ambiguous, the user should inspect candidates with
[`ylist_search()`](https://maple60.github.io/ylistjp/reference/ylist_search.md).

## Test with Synthetic Fixtures

Unit tests should not download the full YList file. Instead, `ylistjp`
uses a small synthetic fixture that contains just enough rows to test
behavior:

- CP932 tab parsing;
- standard versus synonym filtering;
- no-hit handling;
- ambiguity errors;
- cache reuse and refresh behavior.

Network tests are kept optional. GBIF and YList live checks are useful
as smoke tests, but they should not be required for every local test or
every pull request.

## Build Documentation with pkgdown

The documentation site is built with pkgdown:

- `README.md` becomes the English home page;
- `README.ja.md` provides the Japanese landing page;
- `vignettes/*.Rmd` become article pages;
- `_pkgdown.yml` controls navigation and reference grouping.

GitHub Actions runs pkgdown and publishes the generated site to GitHub
Pages. This keeps the package documentation close to the code and makes
every pushed change reproducible.

## Practical Extension Ideas

Good next features should preserve the conservative default behavior:

- add explicit hiragana-to-katakana or width normalization before
  searching;
- add richer candidate ranking to
  [`ylist_search()`](https://maple60.github.io/ylistjp/reference/ylist_search.md);
- add optional checks for WFO or Catalogue of Life;
- expose more metadata from YList when users need audit trails;
- add a small article showing how to join
  [`academic_name()`](https://maple60.github.io/ylistjp/reference/academic_name.md)
  results to a data frame.

The safest pattern is to make exploratory features explicit in search or
helper functions, while keeping
[`academic_name()`](https://maple60.github.io/ylistjp/reference/academic_name.md)
predictable for scripts.

## What to Read Next

- [Usage
  guide](https://maple60.github.io/ylistjp/articles/get-started.md)
  explains how to use the package.
- [Maintenance
  guide](https://maple60.github.io/ylistjp/articles/maintenance.md) maps
  common changes to the files to edit.
- [Function
  reference](https://maple60.github.io/ylistjp/reference/index.md)
  documents each exported function.
