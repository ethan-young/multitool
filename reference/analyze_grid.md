# Perform all analyses over a complete decision grid

Perform all analyses over a complete decision grid

## Usage

``` r
analyze_grid(
  .grid,
  save_model = FALSE,
  show_progress = TRUE,
  libraries = NULL,
  ...
)
```

## Arguments

- .grid:

  a `tibble` produced by
  [`expand_decisions`](https://ethan-young.github.io/multitool/reference/expand_decisions.md)

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

- libraries:

  a vector of character strings naming the packages you want to load
  when executing parallel processing. Internally, this will call
  `library` dynamically to ensure that any functions specific to a
  package you are using are available during execution on the individual
  workers. Only relevant if you have called
  [`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html).

- ...:

  this also reserved for parallel processing. Any custom functions you
  might use your pipeline (e.g., a custom post processing step), can be
  passed here in the form of `custom_func = custom_func`. This will be
  passed along to
  [`purrr::in_parallel`](https://purrr.tidyverse.org/reference/in_parallel.html)
  to make them available on the independent workers.

## Value

a single `tibble` containing tidied results for the model and any
post-processing tests/tasks. For each unique test (e.g., an `lm` or
`aov` called on an `lm`), a list column with the function name is
created with
[`parameters`](https://easystats.github.io/parameters/reference/model_parameters.html)
and
[`performance`](https://easystats.github.io/performance/reference/model_performance.html)
and any warnings or messages printed while fitting the models.

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
  add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
  add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
  add_model("no covariates",lm({dvs} ~ {ivs} * {mods})) |>
  add_model("covariate", lm({dvs} ~ {ivs} * {mods} + cov1)) |>
  add_postprocess("aov", aov())

pipeline_grid <- expand_decisions(full_pipeline)

# analyze the grid
analyzed_grid <- analyze_grid(pipeline_grid[1:10,])
#> Error in purrr::map(1:nrow(.grid), purrr::in_parallel(function(index,     ...) {    if (!is.null(libraries)) {        purrr::walk(rlang::parse_exprs(paste(glue::glue("library({c('multitool', 'dplyr', libraries)})"),             collapse = "; ")), rlang::eval_tidy)    }    if (!purrr::is_empty(custom_fns)) {        purrr::walk(rlang::parse_exprs(glue::glue("assign('{names(custom_fns)}', {custom_fns}, pos = .GlobalEnv)")),             rlang::eval_tidy)    }    start <- Sys.time()    analyzed_result <- execute_universe_model(.grid, decision_index = index,         save_model = save_model)    end <- Sys.time()    tidyr::nest(dplyr::mutate(analyzed_result, run_started = start,         run_ended = end, run_duration_seconds = end - start,         run_duration_minutes = (end - start)/60), timing_logs = dplyr::starts_with("run_"))}, .grid = .grid, execute_universe_model = execute_universe_model,     save_model = save_model, libraries = libraries, custom_fns = custom_fns),     .progress = show_progress): ℹ In index: 1.
#> Caused by error:
#> ! object 'the_data' not found
```
