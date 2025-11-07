# Reveal a set of multiverse cronbach's alpha statistics

Reveal a set of multiverse cronbach's alpha statistics

## Usage

``` r
reveal_reliabilities(.descriptives, .which, .unpack_specs = "no")
```

## Arguments

- .descriptives:

  a descriptive multiverse list-column `tibble` produced by
  [`run_descriptives`](https://ethan-young.github.io/multitool/reference/run_descriptives.md).

- .which:

  the specific name of the alphas

- .unpack_specs:

  character, options are `"no"`, `"wide"`, or `"long"`. `"no"` (default)
  keeps specifications in a list column, `wide` unnests specifications
  with each specification category as a column. `"long"` unnests
  specifications and stacks them into long format, which stacks
  specifications into a `decision_set` and `alternatives` columns. This
  is mainly useful for plotting.

## Value

an unnested set of correlations per decision from the multiverse.

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
  add_filters(
    include1 == 0,
    include2 != 3,
    include2 != 2,
    include3 > -2.5,
    include3 < 2.5,
    between(include3, -2.5, 2.5)
  ) |>
  add_variables(var_group = "ivs", iv1, iv2, iv3) |>
  add_variables(var_group = "dvs", dv1, dv2) |>
  add_correlations("predictor correlations", starts_with("iv")) |>
  add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
  add_reliabilities("vio_scale", starts_with("iv")) |>
  add_model("linear model", lm({dvs} ~ {ivs} * mod)) |>
  expand_decisions()

my_descriptives <- run_descriptives(full_pipeline)
#> Error in purrr::map(seq_len(nrow(filter_grid)), .progress = TRUE, function(x) {    multi_results <- list()    if ("corrs" %in% names(filter_grid)) {        multi_results$corrs <- run_universe_corrs(.grid = filter_grid,             decision_num = filter_grid$decision[x])    }    if ("summary_stats" %in% names(filter_grid)) {        multi_results$stats <- run_universe_summary_stats(.grid = filter_grid,             decision_num = filter_grid$decision[x])    }    if ("reliabilities" %in% names(filter_grid)) {        multi_results$reliabilities <- run_universe_reliabilities(.grid = filter_grid,             decision_num = filter_grid$decision[x])    }    purrr::reduce(multi_results, dplyr::left_join, by = "decision")}): ℹ In index: 1.
#> Caused by error in `map2()`:
#> ℹ In index: 1.
#> ℹ With name: predictor_correlations_rs.
#> Caused by error:
#> ! object 'the_data' not found

my_descriptives |>
  reveal_reliabilities(vio_scale_alpha)
#> Error: object 'my_descriptives' not found
```
