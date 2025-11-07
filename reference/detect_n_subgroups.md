# Detect total number of subgroups in your pipelines

Detect total number of subgroups in your pipelines

## Usage

``` r
detect_n_subgroups(.pipeline)
```

## Arguments

- .pipeline:

  a `data.frame` produced by calling a series of add\_\* functions.

## Value

a numeric, the total number of unique subgroups, including subgroup
combinations

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
  add_subgroups(include2) |>
  add_filters(include1 == 0, include2 != 3, include3 > -2.5) |>
  add_variables(var_group = "ivs", iv1, iv2, iv3) |>
  add_variables(var_group = "dvs", dv1, dv2) |>
  add_model("linear model", lm({dvs} ~ {ivs} * mod))

detect_n_variables(full_pipeline)
#> [1] 6
```
