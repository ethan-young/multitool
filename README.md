
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
#> 1 filter1 == 1                 filter1     182 filter    
#> 2 filter1 == 2                 filter1     168 filter    
#> 3 filter1 %in% unique(filter1) filter1     500 do nothing
#> 4 scale(filter2) > -2          filter2     488 filter    
#> 5 filter2 %in% unique(filter2) filter2     500 do nothing
#> 6 filter3 == 0                 filter3     454 filter    
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
#>   model code                          
#>   <chr> <chr>                         
#> 1 model lm({dv} ~ {iv})               
#> 2 model lm({dv} ~ {iv} + {covariates})
```

## Add arbitrary code

``` r
# Code to execute after filtering step
my_post_filter_code <- 
  post_filter_code(
    mutate({iv} := scale({iv})), 
    mutate({dv} := log({dv}))
  )
```

``` r
# Code to summarize the model
my_model_summary_code <- 
  model_summary_code(
    summary(),
    broom::tidy()
  )

my_model_summary_code
#> # A tibble: 2 × 2
#>   summary  code         
#>   <chr>    <chr>        
#> 1 summary1 summary()    
#> 2 summary2 broom::tidy()
```

``` r
# Code to execute after analysis is donoe
my_post_hoc_code <- 
  post_hoc_code(
    anova(),
    aov()
  )
```

## Combine all grids together

``` r
my_full_grid <- 
  combine_all_grids(
    my_filter_grid, 
    my_var_grid, 
    my_post_filter_code,
    my_model_grid,
    my_model_summary_code,
    my_post_hoc_code
  )

my_full_grid |> glimpse()
#> Rows: 288
#> Columns: 7
#> $ decision           <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, …
#> $ variables          <list> [<tbl_df[1 x 3]>], [<tbl_df[1 x 3]>], [<tbl_df[1 x…
#> $ filters            <list> [<tbl_df[1 x 3]>], [<tbl_df[1 x 3]>], [<tbl_df[1 x…
#> $ post_filter_code   <list> [<tbl_df[1 x 2]>], [<tbl_df[1 x 2]>], [<tbl_df[1 x…
#> $ model              <chr> "lm(dv1 ~ iv1)", "lm(dv1 ~ iv1 + covariate1)", "lm(…
#> $ model_summary_code <list> [<tbl_df[1 x 2]>], [<tbl_df[1 x 2]>], [<tbl_df[1 x…
#> $ post_hoc_code      <list> [<tbl_df[1 x 2]>], [<tbl_df[1 x 2]>], [<tbl_df[1 x…
```

## Run a universe

``` r
run_universe(my_full_grid, the_data, 1)
#> # A tibble: 1 × 6
#>   post_hoc_test1_code         post_hoc_test1_… post_hoc_test1_… post_hoc_test2_…
#>   <glue>                      <list>           <list>           <glue>          
#> 1 the_data |> filter(filter1… <anova [2 × 5]>  <tibble [1 × 1]> the_data |> fil…
#> # … with 2 more variables: post_hoc_test2_results <list>,
#> #   post_hoc_test2_results_notes <list>
```

## Run multiverse

``` r
# my_multi_results <- run_multiverse(the_data, my_full_grid[1:10,])
# 
# my_multi_results |> filter(decision == 1) |> pull(model_code) |> str_replace_all(" \\|> ", " |> \n") |> glue::glue()
# my_multi_results |> filter(decision == 1) |> pull(model_post_hoc_code) |> str_replace_all(" \\|> ", " |> \n") |> glue::glue()
# my_multi_results |> filter(decision == 1) |> unnest(data) |> summarize(mean = mean(iv1), sd = sd(iv1))
# my_multi_results |> filter(decision == 1) |> unnest(model_results)
```
