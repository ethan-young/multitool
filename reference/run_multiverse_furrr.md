# Run a multi-core, multiverse based on a complete decision grid

Run a multi-core, multiverse based on a complete decision grid

## Usage

``` r
run_multiverse_furrr(
  .grid,
  add_standardized = TRUE,
  save_model = FALSE,
  show_progress = TRUE,
  furrr_globals = NULL,
  furrr_packages = c("multitool", "dplyr", "tidyr")
)
```

## Arguments

- .grid:

  a `tibble` produced by
  [`expand_decisions`](https://ethan-young.github.io/multitool/reference/expand_decisions.md)

- add_standardized:

  logical. Whether to add standardized coefficients to the model output.
  Defaults to `TRUE`.

- save_model:

  logical, indicates whether to save the model object in its entirety.
  The default is `FALSE` because model objects are usually large and
  under the hood,
  [`parameters`](https://easystats.github.io/parameters/reference/model_parameters.html)
  and
  [`performance`](https://easystats.github.io/performance/reference/model_performance.html)
  is used to summarize the most useful model information.

- show_progress:

  logical, whether to show a progress bar while running.

- furrr_globals:

  any global objects to pass to `furrr_options`

- furrr_packages:

  character vector, any packages to load inside parallel environments

## Value

a single `tibble` containing tidied results for the model and any
post-processing tests/tasks. For each unique test (e.g., an `lm` or
`aov` called on an `lm`), a list column with the function name is
created with
[`parameters`](https://easystats.github.io/parameters/reference/model_parameters.html)
and
[`performance`](https://easystats.github.io/performance/reference/model_performance.html)
and any warnings or messages printed while fitting the models.
Internally, modeling and post-processing functions are checked to see if
there are tidy or glance methods available. If not, `summary` will be
called instead.

## Examples

``` r
library(tidyverse)
library(multitool)
library(furrr)

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
  add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
  add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
  add_model("no covariates",lm({dvs} ~ {ivs} * {mods})) |>
  add_model("covariate", lm({dvs} ~ {ivs} * {mods} + cov1)) |>
  add_postprocess("aov", aov())

pipeline_grid <- expand_decisions(full_pipeline)

# Run the whole multiverse
plan(multisession, workers = 4)
the_multiverse <- run_multiverse_furrr(pipeline_grid[4,])
#> Error in (function (.x, .f, ..., .progress = FALSE) {    map_("list", .x, .f, ..., .progress = .progress)})(.x = 1L, .f = function (...) {    NULL    {        if (...furrr_progress) {            try(expr = {                cat("+", file = ...furrr_progress_con, sep = "")            }, silent = TRUE)        }    }    ...furrr_out <- ...furrr_fn(...)    ...furrr_out}): ℹ In index: 1.
#> Caused by error in `map2()`:
#> ℹ In index: 1.
#> ℹ With name: model.
#> Caused by error:
#> ! object 'the_data' not found
plan(sequential)
```
