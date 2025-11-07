# Add filtering/exclusion criteria to a multiverse pipeline

Add filtering/exclusion criteria to a multiverse pipeline

## Usage

``` r
add_filters(.df, ..., remove_do_nothing = FALSE)
```

## Arguments

- .df:

  The original `data.frame`(e.g., base data set). If part of set of
  add\_\* decision functions in a pipeline, the base data will be passed
  along as an attribute.

- ...:

  logical expressions to be used with
  [`filter`](https://dplyr.tidyverse.org/reference/filter.html)
  separated by commas. Expressions should not be quoted.

- remove_do_nothing:

  logical, `FALSE` by default. Indicates whether to include an
  specification where no filters are applied to the data. Typically this
  is desirable, but on a occasion you may wan to turn this functionally
  off.

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
    include3 = rnorm(500)
  )

the_data |>
  add_filters(include1 == 0,include2 != 3,include2 != 2, include3 > -2.5)
#> # A tibble: 7 × 3
#>   type    group    code                          
#>   <chr>   <chr>    <chr>                         
#> 1 filters include1 include1 == 0                 
#> 2 filters include1 include1 %in% unique(include1)
#> 3 filters include2 include2 != 3                 
#> 4 filters include2 include2 != 2                 
#> 5 filters include2 include2 %in% unique(include2)
#> 6 filters include3 include3 > -2.5               
#> 7 filters include3 include3 %in% unique(include3)
```
