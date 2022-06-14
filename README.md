
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
    covariate1 = rnorm(500),
    covariate2 = rnorm(500),
    dv1 = rnorm(500),
    dv2 = rnorm(500),
    filter1   = sample(1:3, size = 500, replace = TRUE),
    filter2   = rnorm(500),
    filter3   = rbinom(500, size = 1, prob = .1)
  )
```

## Create a filter grid

``` r
my_filter_grid <-
  create_filter_grid(
    my_data = the_data,
    filter1 == 1,
    filter1 == 2,
    scale(filter2) > -2,
    filter3 == 0,
  )
#> # A tibble: 7 × 4
#>   expr                         expr_var expr_n expr_type 
#>   <chr>                        <chr>     <int> <chr>     
#> 1 filter1 == 1                 filter1     175 filter    
#> 2 filter1 == 2                 filter1     162 filter    
#> 3 filter1 %in% unique(filter1) filter1     500 do nothing
#> 4 scale(filter2) > -2          filter2     485 filter    
#> 5 filter2 %in% unique(filter2) filter2     500 do nothing
#> 6 filter3 == 0                 filter3     451 filter    
#> 7 filter3 %in% unique(filter3) filter3     500 do nothing
```

## Create variable grid

``` r
my_var_grid <-
  create_var_grid(
    my_data = the_data,
    iv = c(iv1, iv2, iv3),
    dv = c(dv1, dv2),
    covariates = c(covariate1, covariate2)
  )
#> # A tibble: 7 × 2
#>   var_group  var       
#>   <chr>      <chr>     
#> 1 iv         iv1       
#> 2 iv         iv2       
#> 3 iv         iv3       
#> 4 dv         dv1       
#> 5 dv         dv2       
#> 6 covariates covariate1
#> 7 covariates covariate2
```

## Create model grid

``` r
my_model_grid <-
  create_model_grid(
    lm({dv} ~ {iv}),
    lm({dv} ~ {iv} + {covariates})
  )

my_model_grid
#> # A tibble: 2 × 2
#>   mod_group mod_formula                   
#>   <chr>     <chr>                         
#> 1 models    lm({dv} ~ {iv})               
#> 2 models    lm({dv} ~ {iv} + {covariates})
```

## Add arbitrary code

``` r
# Code to execute after filtering step
my_post_filter_code <- 
  post_filter_code(
    mutate({iv} := scale({iv})), 
    mutate({dv} := log({dv}))
  )

# Code to execute after analysis is donoe
my_post_hoc_code <- post_hoc_code(predict())
```

## Combine all grids together

``` r
my_full_grid <- 
  combine_all_grids(
    my_filter_grid, 
    my_var_grid, 
    my_model_grid,
    my_post_filter_code,
    my_post_hoc_code
  )
```

## Run multiverse

``` r
my_multi_results <- run_multiverse(the_data, my_full_grid[1:10,])
#> Warning in log(dv1): NaNs produced

#> Warning in log(dv1): NaNs produced

#> Warning in log(dv1): NaNs produced
#> decision 1 executed
#> Warning in log(dv1): NaNs produced

#> Warning in log(dv1): NaNs produced

#> Warning in log(dv1): NaNs produced
#> decision 2 executed
#> Warning in log(dv1): NaNs produced

#> Warning in log(dv1): NaNs produced

#> Warning in log(dv1): NaNs produced
#> decision 3 executed
#> Warning in log(dv1): NaNs produced

#> Warning in log(dv1): NaNs produced

#> Warning in log(dv1): NaNs produced
#> decision 4 executed
#> Warning in log(dv2): NaNs produced
#> Warning in log(dv2): NaNs produced

#> Warning in log(dv2): NaNs produced
#> decision 5 executed
#> Warning in log(dv2): NaNs produced

#> Warning in log(dv2): NaNs produced

#> Warning in log(dv2): NaNs produced
#> decision 6 executed
#> Warning in log(dv2): NaNs produced

#> Warning in log(dv2): NaNs produced

#> Warning in log(dv2): NaNs produced
#> decision 7 executed
#> Warning in log(dv2): NaNs produced

#> Warning in log(dv2): NaNs produced

#> Warning in log(dv2): NaNs produced
#> decision 8 executed
#> Warning in log(dv1): NaNs produced
#> Warning in log(dv1): NaNs produced

#> Warning in log(dv1): NaNs produced
#> decision 9 executed
#> Warning in log(dv1): NaNs produced

#> Warning in log(dv1): NaNs produced

#> Warning in log(dv1): NaNs produced
#> decision 10 executed

my_multi_results |> filter(decision == 1) |> pull(model_code) |> str_replace_all(" \\|> ", " |> \n") |> glue::glue()
#> the_data |> 
#> dplyr::filter(filter1 == 1, scale(filter2) > -2, filter3 == 0) |> 
#> mutate(`:=`(iv1, scale(iv1))) |> 
#> mutate(`:=`(dv1, log(dv1))) |> 
#> lm(dv1 ~ iv1, data = _)
my_multi_results |> filter(decision == 1) |> pull(model_post_hoc_code) |> str_replace_all(" \\|> ", " |> \n") |> glue::glue()
#> the_data |> 
#> dplyr::filter(filter1 == 1, scale(filter2) > -2, filter3 == 0) |> 
#> mutate(`:=`(iv1, scale(iv1))) |> 
#> mutate(`:=`(dv1, log(dv1))) |> 
#> lm(dv1 ~ iv1, data = _) |> 
#> predict()
my_multi_results |> filter(decision == 1) |> unnest(data) |> summarize(mean = mean(iv1), sd = sd(iv1))
#> # A tibble: 1 × 2
#>       mean    sd
#>      <dbl> <dbl>
#> 1 6.21e-19     1
my_multi_results |> filter(decision == 1) |> unnest(model_results)
#> # A tibble: 2 × 15
#>   decision filters  variables        post_filter_code post_hoc_code models data 
#>      <int> <list>   <list>           <list>           <list>        <chr>  <lis>
#> 1        1 <tibble> <tibble [1 × 3]> <tibble [1 × 2]> <tibble>      lm(dv… <df> 
#> 2        1 <tibble> <tibble [1 × 3]> <tibble [1 × 2]> <tibble>      lm(dv… <df> 
#> # … with 8 more variables: model_code <glue>, term <chr>, estimate <dbl>,
#> #   std.error <dbl>, statistic <dbl>, p.value <dbl>, model_post_hoc <list>,
#> #   model_post_hoc_code <glue>
```
