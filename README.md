
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
devtools::install_github("ethan-young/multitool")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(tidyverse)
#> ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.1 ──
#> ✔ ggplot2 3.3.6     ✔ purrr   0.3.4
#> ✔ tibble  3.1.7     ✔ dplyr   1.0.9
#> ✔ tidyr   1.2.0     ✔ stringr 1.4.0
#> ✔ readr   2.1.2     ✔ forcats 0.5.1
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
library(multitool)
```

## Simulate some data

``` r
the_data <-
  data.frame(
    id   = 1:500,
    iv1  = rnorm(500),
    iv2  = rnorm(500),
    iv3  = rnorm(500),
    mod1 = rnorm(500),
    mod2 = rnorm(500),
    mod3 = rnorm(500),
    cov1 = rnorm(500),
    cov2 = rnorm(500),
    dv1  = rnorm(500),
    dv2  = rnorm(500),
    include1 = rbinom(500, size = 1, prob = .1),
    include2 = sample(1:3, size = 500, replace = TRUE),
    include3 = rnorm(500)
  )
```

## Create a variable grid

``` r
my_var_grid <-
  create_var_grid(
    .df = the_data,
    iv  = c(iv1, iv2, iv3),
    mod = c(mod1, mod2, mod3),
    dv  = c(dv1, dv2),
    cov = c(cov1, cov2)
  )
#> cov variable group has 2 alternative variables
#> dv variable group has 2 alternative variables
#> iv variable group has 3 alternative variables
#> mod variable group has 3 alternative variables
#> 36 combinations (2*2*3*3 = 36)
```

## Create filter grid

``` r
my_filter_grid <-
  create_filter_grid(
    .df = the_data,
    include1 == 0,
    include2 != 3,
    include2 != 2,
    scale(include3) > -2.5
  )
#> filters involving include1 has 2 alternative filtering criteria
#> filters involving include2 has 3 alternative filtering criteria
#> filters involving include3 has 2 alternative filtering criteria
#> 12 combinations (2*3*2 = 12)
```

## Create model grid

``` r
my_model_grid <-
  create_model_grid(
    lm({dv} ~ {iv} * {mod}),
    lm({dv} ~ {iv} * {mod} + {cov})
  )
#> Your model has 2 alternatives
```

## Add arbitrary code

``` r
#Add pre-processing code before model is fit (but after filtering)
my_preprocess <-
  create_preprocess(
    mutate({iv} := scale({iv}) |> as.numeric(), {mod} := scale({mod}) |> as.numeric())
  )
```

``` r
# Code to execute after analysis is fit
my_postprocess <-
  create_postprocess(
    aov()
  )
```

## Combine all grids together

``` r
my_full_grid <-
  combine_all_grids(
    my_var_grid,
    my_filter_grid,
    my_model_grid,
    my_preprocess,
    my_postprocess
  )
#> cov (variable) has 2 alternatives
#> dv (variable) has 2 alternatives
#> iv (variable) has 3 alternatives
#> mod (variable) has 3 alternatives
#> include1 (filter) has 2 alternatives
#> include2 (filter) has 3 alternatives
#> include3 (filter) has 2 alternatives
#> model has 2 alternatives
#> 864 combinations (2*2*3*3*2*3*2*2 = 864)
```

## Run a universe

``` r
run_universe(my_full_grid, the_data, 1)
#> # A tibble: 1 × 4
#>   decision data_pipeline    lm               aov             
#>      <dbl> <list>           <list>           <list>          
#> 1        1 <tibble [1 × 2]> <tibble [1 × 5]> <tibble [1 × 5]>
```

## Run a multiverse

``` r
run_multiverse(my_full_grid[1:10,], the_data)
#> # A tibble: 10 × 9
#>    decision variables        filters  preprocess model postprocess data_pipeline
#>       <int> <list>           <list>   <list>     <chr> <list>      <list>       
#>  1        1 <tibble [1 × 4]> <tibble> <tibble>   lm(d… <tibble>    <tibble>     
#>  2        2 <tibble [1 × 4]> <tibble> <tibble>   lm(d… <tibble>    <tibble>     
#>  3        3 <tibble [1 × 4]> <tibble> <tibble>   lm(d… <tibble>    <tibble>     
#>  4        4 <tibble [1 × 4]> <tibble> <tibble>   lm(d… <tibble>    <tibble>     
#>  5        5 <tibble [1 × 4]> <tibble> <tibble>   lm(d… <tibble>    <tibble>     
#>  6        6 <tibble [1 × 4]> <tibble> <tibble>   lm(d… <tibble>    <tibble>     
#>  7        7 <tibble [1 × 4]> <tibble> <tibble>   lm(d… <tibble>    <tibble>     
#>  8        8 <tibble [1 × 4]> <tibble> <tibble>   lm(d… <tibble>    <tibble>     
#>  9        9 <tibble [1 × 4]> <tibble> <tibble>   lm(d… <tibble>    <tibble>     
#> 10       10 <tibble [1 × 4]> <tibble> <tibble>   lm(d… <tibble>    <tibble>     
#> # … with 2 more variables: lm <list>, aov <list>
```
