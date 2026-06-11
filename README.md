# ylistjp

`ylistjp` is an unofficial R package for working with Japanese plant names from
[YList](http://www.ylist.info/), the "植物和名-学名インデックス".

The package does not redistribute YList data. Instead, it downloads the public
tab-delimited YList file into the user's local R cache and reads it from there.
YList data remains subject to its own source, terms, and citation requirements.

## Installation

```r
# After the GitHub repository is available:
# install.packages("pak")
pak::pak("maple60/ylistjp")
```

## Basic use

```r
library(ylistjp)

academic_name("コナラ")
#> [1] "Quercus serrata"

academic_name("コナラ", with_author = TRUE)
#> [1] "Quercus serrata Murray"

ylist_search("コナラ")
```

The first call that needs YList data downloads the public tab-delimited file to
the user cache. To refresh it explicitly:

```r
ylist_download(overwrite = TRUE)
ylist_load(refresh = TRUE)
```

## International name checks

`gbif_match()` is a small optional helper around the GBIF species match API.
It requires the suggested package `jsonlite`.

```r
gbif_match("Quercus serrata")
```

## Data Source and Citation

This package is not affiliated with or endorsed by YList.

When using YList data, cite the original source:

> 米倉浩司・梶田忠 (2003-)「BG Plants 和名－学名インデックス」（YList），http://ylist.info

The package code is MIT licensed. YList data is not included in the package and
is not covered by this package's license.
