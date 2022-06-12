
<!-- README.md is generated from README.Rmd. Please edit that file -->

# multitool

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/multitool)](https://CRAN.R-project.org/package=multitool)
<!-- badges: end -->

The goal of multitool is to …

## Installation

You can install the development version of multitool from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ethan-young/multiverse_tools")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
#library(multitool)

data <-
  data.frame(
    id   = 1:500,
    iv1  = rnorm(500),
    iv2  = rnorm(500),
    iv3  = rnorm(500),
    covariate1 = rnorm(500),
    covariate2 = rnorm(500),
    dv1 = rnorm(500),
    dv2 = rnorm(500),
    filter1   = sample(1:3, size = 500, replace = TRUE),
    filter2   = rnorm(500),
    filter3   = rbinom(500, size = 1, prob = .1),
    filter4   = rbinom(500, size = 1, prob = .1)
  )
```

``` r
# my_filter_grid <-
#   create_filter_grid(
#     data,
#     filter1 == 1,
#     filter1 == 2,
#     filter2 == 0,
#     filter3 == 0,
#     filter4 == 0
#   )
```

``` r
# my_var_grid <-
#   create_var_grid(
#     my_data = sim_data,
#     iv       = c(iv1, iv2, iv3),
#     dv       = c(dv1, dv2),
#     covariates = c(covariate1, covariate2)
#   )
```

``` r
# my_model_grid <-
#   create_model_grid(
#     lm({dv} ~ {iv}),
#     lm({dv} ~ {iv} + {covariates})
#   )
```

``` r
#combine_all_grids(my_filter_grid, my_var_grid, my_model_grid)
```
