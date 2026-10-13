# Add sub groups to the multiverse pipeline

Add sub groups to the multiverse pipeline

## Usage

``` r
add_subgroups(.df, ..., .use_partitions = FALSE)
```

## Arguments

- .df:

  The original `data.frame`(e.g., base data set). If part of set of
  add\_\* decision functions in a pipeline, the base data will be passed
  along as an attribute.

- ...:

  sub group variable(s) in your data whose values specify groupings.

- .use_partitions:

  whether or not to search an arrow pointer table's partitioning for
  subgroup names and values. Defaults to `FALSE`.

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
#> 1 subgroups group 2    
#> 2 subgroups group 1    
#> 3 subgroups group 3    

the_data |>
  add_subgroups(group, .only = c(1,3))
#> # A tibble: 1,003 × 3
#>    type      group  code              
#>    <chr>     <chr>  <chr>             
#>  1 subgroups group  2                 
#>  2 subgroups .only1 1                 
#>  3 subgroups .only2 0.430849126351421 
#>  4 subgroups group  1                 
#>  5 subgroups .only1 2                 
#>  6 subgroups .only2 1.60863536001445  
#>  7 subgroups .only1 3                 
#>  8 subgroups .only2 -0.749096299794574
#>  9 subgroups group  3                 
#> 10 subgroups .only1 4                 
#> # ℹ 993 more rows
```
