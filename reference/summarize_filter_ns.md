# Summarize samples sizes for each unique filtering expression

Summarize samples sizes for each unique filtering expression

## Usage

``` r
summarize_filter_ns(.pipeline)
```

## Arguments

- .pipeline:

  a `data.frame` produced by calling a series of add\_\* functions.

## Value

a `tibble` with each row representing a filtering expression and four
columns: `filter_expression`, `variable`, `n_retained`, and
`n_excluded`.

## Examples

``` r
library(tidyverse)
library(multitool)

# create some data
the_data <-
  data.frame(
    id  = 1:500,
    iv1 = rnorm(500),
    iv2 = rnorm(500),
    iv3 = rnorm(500),
    mod = rnorm(500),
    dv1 = rnorm(500),
    dv2 = rnorm(500),
    include1 = rbinom(500, size = 1, prob = .1),
    include2 = sample(1:3, size = 500, replace = TRUE),
    include3 = rnorm(500)
  )

# create a pipeline blueprint
full_pipeline <-
  the_data |>
  add_filters(include1 == 0, include2 != 3, include3 > -2.5) |>
  add_variables(var_group = "ivs", iv1, iv2, iv3) |>
  add_variables(var_group = "dvs", dv1, dv2) |>
  add_model("linear model", lm({dvs} ~ {ivs} * mod))

summarize_filter_ns(full_pipeline)
#> # A tibble: 6 × 4
#>   filter_expression              variable n_retained n_excluded
#>   <chr>                          <chr>         <int>      <int>
#> 1 include1 == 0                  include1        448         52
#> 2 include1 %in% unique(include1) include1        500          0
#> 3 include2 != 3                  include2        346        154
#> 4 include2 %in% unique(include2) include2        500          0
#> 5 include3 > -2.5                include3        493          7
#> 6 include3 %in% unique(include3) include3        500          0
```
