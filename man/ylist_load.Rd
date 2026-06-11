\name{ylist_load}
\alias{ylist_load}
\title{Load cached YList data}
\usage{
ylist_load(refresh = FALSE)
}
\arguments{
\item{refresh}{Logical. If \code{TRUE}, redownload the YList data before loading.}
}
\value{
A data frame containing YList rows.
}
\description{
Loads the cached YList tab-delimited data as a data frame. If the cache does
not exist, the public data file is downloaded first.
}
