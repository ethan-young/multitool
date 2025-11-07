# Unpack the decision grid of specifications for your modeling pipeline

Unpack the decision grid of specifications for your modeling pipeline

## Usage

``` r
unpack_specs(.multi, .how = "wide")
```

## Arguments

- .multi:

  a multiverse list-column `tibble` produced by
  [`analyze_grid`](https://ethan-young.github.io/multitool/reference/analyze_grid.md).

- .how:

  character, options are `"no"`, `"wide"`, or `"long"`. `"no"` (default)
  keeps specifications in a list column, `wide` unnests specifications
  with each specification category as a column. `"long"` unnests
  specifications and stacks them into long format, which stacks
  specifications into a `decision_type`, `decision_set` and
  `decision_choice` columns. This is mainly useful for plotting.

## Value

the unnested specifications of the analysis grid.

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

# Decision pipeline
full_pipeline <-
  the_data |>
  add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
  add_variables("ivs", iv1, iv2, iv3) |>
  add_variables("dvs", dv1, dv2) |>
  add_variables("mods", starts_with("mod")) |>
  add_model("linear_model", lm({dvs} ~ {ivs} * {mods} + cov1))

pipeline_grid <- expand_decisions(full_pipeline)

# Run the whole multiverse
the_multiverse <- analyze_grid(pipeline_grid[1:10,])
#> Error in parallel_pkgs_installed(): The packages "carrier" (>= 0.3.0) and "mirai" (>= 2.5.1) are required
#> for parallel map.

# Reveal results of the linear model
the_multiverse |> unpack_specs("wide")
#> Error: object 'the_multiverse' not found
```
