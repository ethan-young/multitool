# Detect total number of analysis pipelines

Detect total number of analysis pipelines

## Usage

``` r
detect_multiverse_n(.pipeline, include_models = TRUE)
```

## Arguments

- .pipeline:

  a `data.frame` produced by calling a series of add\_\* functions.

- include_models:

  Whether to count alternative models if you have more than one
  [`add_model()`](https://ethan-young.github.io/multitool/reference/add_model.md)
  call.

## Value

a numeric, the total number of unique analysis pipelines

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

detect_multiverse_n(full_pipeline)
#> [1] 48
```
