
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
library(multitool)
```

## Simulate some data

``` r
my_data <-
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

## Create a filter grid

``` r
my_filter_grid <-
  create_filter_grid(
    my_data = my_data,
    filter1 == 1,
    filter1 == 2,
    filter2 == 0,
    filter3 == 0,
    filter4 == 0
  )
#> # A tibble: 9 × 4
#>   expr                         expr_var expr_n expr_type 
#>   <chr>                        <chr>     <int> <chr>     
#> 1 filter1 == 1                 filter1     167 filter    
#> 2 filter1 == 2                 filter1     158 filter    
#> 3 filter1 %in% unique(filter1) filter1     500 do nothing
#> 4 filter2 == 0                 filter2       0 filter    
#> 5 filter2 %in% unique(filter2) filter2     500 do nothing
#> 6 filter3 == 0                 filter3     450 filter    
#> 7 filter3 %in% unique(filter3) filter3     500 do nothing
#> 8 filter4 == 0                 filter4     456 filter    
#> 9 filter4 %in% unique(filter4) filter4     500 do nothing
```

## Create variable grid

``` r
my_var_grid <-
  create_var_grid(
    my_data = my_data,
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

## Combine all grids together

``` r
combine_all_grids(my_filter_grid, my_var_grid, my_model_grid)
```
