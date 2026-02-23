# Reveal any warnings about your models during a multiverse analysis

**\[deprecated\]** This function has been deprecated; please use
[`unpack_model_warnings()`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
instead.

## Usage

``` r
reveal_model_warnings(.multi, .unpack_specs = "no")
```

## Arguments

- .multi:

  a multiverse list-column `tibble` produced by
  [`run_multiverse`](https://ethan-young.github.io/multitool/reference/run_multiverse.md).

- .unpack_specs:

  character, options are `"no"`, `"wide"`, or `"long"`. `"no"` (default)
  keeps specifications in a list column, `wide` unnests specifications
  with each specification category as a column. `"long"` unnests
  specifications and stacks them into long format, which stacks
  specifications into a `decision_set` and `alternatives` columns. This
  is mainly useful for plotting.

## Value

the unnested model warnings captured during analysis

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
the_multiverse <- run_multiverse(pipeline_grid[1:10,])
#> Error in purrr::map(seq_len(nrow(.grid)), .progress = show_progress, function(x) {    multi_results <- list()    if ("models" %in% names(.grid)) {        multi_results$models <- run_universe_model(.grid = .grid,             decision_num = .grid$decision[x], add_standardized = add_standardized,             save_model = save_model)    }    purrr::reduce(multi_results, dplyr::left_join, by = "decision")}): ℹ In index: 1.
#> Caused by error in `map2()`:
#> ℹ In index: 1.
#> ℹ With name: model.
#> Caused by error:
#> ! object 'the_data' not found

# Reveal results of the linear model
the_multiverse |>
  reveal_model_warnings()
#> Error: object 'the_multiverse' not found
```
