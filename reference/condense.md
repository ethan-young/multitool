# Summarize multiverse parameters

Summarize multiverse parameters

## Usage

``` r
condense(.unpacked, .what, .how, .group = NULL, list_cols = TRUE)

organize(.unpacked, .what, .group = NULL, focused = TRUE)
```

## Arguments

- .unpacked:

  a set of results from `analyze_grid` using `unpack_results*`

- .what:

  the column from the unpacked results you'd like to organize

- .how:

  a named list. The list should contain summary functions (e.g., mean or
  median) the user would like to compute over the individual estimates
  from the multiverse

- .group:

  a grouping column, usually from the specifications, that you like to
  sort within. This will give you sorted output by the levels of the
  grouping variable.

- list_cols:

  logical, whether to create list columns for the raw values of any
  summarized columns. Useful for creating visualizations and tables.
  Default is TRUE.

- focused:

  logical, defaults to `TRUE`. Return only the variable, potential
  group, and a variable indicating rank. Set to `FALSE` to retain all
  other columns.

## Value

a summarized `tibble` containing a column for each summary method from
`.how`

## Functions

- `organize()`: Sort and organize results by size and sign.

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

# Reveal and condense
the_multiverse |>
  reveal_model_parameters() |>
  filter(str_detect(parameter, "iv")) |>
  condense(unstd_coef, list(mean = mean, median = median))
#> Error: object 'the_multiverse' not found
```
