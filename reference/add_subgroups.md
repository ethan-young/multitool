# Add sub groups to the multiverse pipeline

Add sub groups to the multiverse pipeline

## Usage

``` r
add_subgroups(.df, ..., .only = NULL)
```

## Arguments

- .df:

  The original `data.frame`(e.g., base data set). If part of set of
  add\_\* decision functions in a pipeline, the base data will be passed
  along as an attribute.

- ...:

  sub group variable(s) in your data whose values specify groupings.

- .only:

  a character vector of sub group values to include. The default
  includes all sub group values for each sub group variable.

## Value

a `data.frame` with three columns: type, group, and code. Type indicates
the decision type, group is a decision, and the code is the actual code
that will be executed. If part of a pipe, the current set of decisions
will be appended as new rows.

## Examples

``` r
library(tidyverse)
library(multitool)

# Simulate some data
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
    include3 = rnorm(500),
    group    = sample(1:3, size = 500, replace = TRUE)
  )

the_data |>
  add_subgroups(group)
#> # A tibble: 3 × 3
#>   type      group code 
#>   <chr>     <chr> <chr>
#> 1 subgroups group 1    
#> 2 subgroups group 3    
#> 3 subgroups group 2    

the_data |>
  add_subgroups(group, .only = c(1,3))
#> # A tibble: 2 × 3
#>   type      group code 
#>   <chr>     <chr> <chr>
#> 1 subgroups group 1    
#> 2 subgroups group 3    
```
