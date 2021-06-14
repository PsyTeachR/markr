# markr <img src="man/figures/logo.png" align="right" alt="" width="120" />

<!-- rmarkdown v1 -->
<!-- README.md is generated from README.Rmd. Please edit that file -->

<!-- badges: start -->
[![Lifecycle: experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

The goal of markr is to create individual feedback documents and marking summaries from flexibly organised spreadsheets and other types of input.

## Installation

You can install the development version of markr from GitHub with:

``` r
# you may need to install devtools first with
# install.packages("devtools")

devtools::install_github("psyteachr/markr")
```

Run the following code to create an `example` directory and then explore the code in `demo.Rmd`.

``` r
# an example using A-F marks
markr::markr_example()

# an example using the University of Glasgow marking scheme
markr::markr_example("glasgow")
```

See the [example vignette](https://psyteachr.github.io/markr/articles/example.html) for a demo.
