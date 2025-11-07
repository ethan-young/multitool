# Run a multiverse-style descriptive analysis based on a complete decision grid

Run a multiverse-style descriptive analysis based on a complete decision
grid

## Usage

``` r
run_descriptives(.grid, show_progress = TRUE)
```

## Arguments

- .grid:

  a `tibble` produced by
  [`expand_decisions`](https://ethan-young.github.io/multitool/reference/expand_decisions.md)

- show_progress:

  logical, whether to show a progress bar while running.

## Value

single `tibble` containing tidied results for all descriptive analyses
specified. Because descriptive analyses only change when the underlying
cases change, only filtering and/or subgroup decisions will be used and
will be internally re-expanded before performing various descriptive
analyses.

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
  add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
  add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis")) |>
  add_correlations("predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2)) |>
  add_correlations("outcomes", matches("dv|mod"), focus_set = matches("dv")) |>
  add_reliabilities("unp_scale", c(iv1,iv2,iv3)) |>
  add_reliabilities("vio_scale", starts_with("mod")) |>
  expand_decisions()

run_descriptives(full_pipeline)
#> Error in purrr::map(seq_len(nrow(filter_grid)), .progress = TRUE, function(x) {    multi_results <- list()    if ("corrs" %in% names(filter_grid)) {        multi_results$corrs <- run_universe_corrs(.grid = filter_grid,             decision_num = filter_grid$decision[x])    }    if ("summary_stats" %in% names(filter_grid)) {        multi_results$stats <- run_universe_summary_stats(.grid = filter_grid,             decision_num = filter_grid$decision[x])    }    if ("reliabilities" %in% names(filter_grid)) {        multi_results$reliabilities <- run_universe_reliabilities(.grid = filter_grid,             decision_num = filter_grid$decision[x])    }    purrr::reduce(multi_results, dplyr::left_join, by = "decision")}): ℹ In index: 1.
#> Caused by error in `map2()`:
#> ℹ In index: 1.
#> ℹ With name: predictors_rs.
#> Caused by error:
#> ! object 'the_data' not found
```
