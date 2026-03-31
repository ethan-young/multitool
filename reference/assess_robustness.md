# Assess the robustness of multiverse analysis results

Summarizes the distribution of a particular model parameter, fit
statistics, or any other values returned by the focal modeling process
or a post-processing step. The summaries are computed over all
specifications in the analysis grid. This function helps evaluate
whether results are robust to analytical decisions by computing key
distributional properties and sign consistency metrics.

## Usage

``` r
assess_robustness(.multi, .estimand, zero_threshold = 0.01, .by = NULL)
```

## Arguments

- .multi:

  An object returned by
  [`analyze_grid`](https://ethan-young.github.io/multitool/reference/analyze_grid.md)
  containing results from a `multitool` pipeline.

- .estimand:

  The parameter or coefficient to assess. Defaults to `std_coef`
  (standardized coefficients). Can be any numeric column from the model
  parameters, performance, or a post-processing analysis (e.g.,
  `unstd_coef`, `r2`, `p_value`). Use unquoted column names with tidy
  evaluation.

- zero_threshold:

  Numeric value defining the threshold for "practically zero" effects.
  Effects between `-zero_threshold` and `+zero_threshold` are classified
  as zero. Defaults to `.01`. Used to compute sign entropy and
  proportion of positive/negative/zero effects.

- .by:

  Optional grouping variable(s) for stratified summaries. Useful for
  examining robustness within specific subsets of decisions (e.g.,
  different models or subgroups). Use unquoted column names.

## Value

A `data.frame` with the following columns:

- metric:

  Name of the summarized metric (e.g., "std_coef", "AIC")

- metric_type:

  Type of metric: "parameter" for model coefficients or "fit index" for
  model fit statistics

- reference:

  The parameter being summarized (e.g., variable name) or "full model"
  for fit indices

- n_decisions:

  Number of specifications contributing to the summary

- mean, median, iqr, q05, q95:

  Distributional summaries of the metric

- p_positive, p_negative, p_zero:

  Proportion of specifications with positive, negative, or practically
  zero effects

- sign_entropy:

  Shannon entropy of the sign distribution, measuring inconsistency in
  effect direction across specifications. Ranges from 0 (perfect
  consistency) to ~1.58 (maximum inconsistency)

All numeric values are rounded to 5 decimal places.

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
    dv1  = rnorm(500),
    dv2  = rnorm(500),
    include1 = rbinom(500, size = 1, prob = .1),
    include2 = sample(1:3, size = 500, replace = TRUE)
  )

# Run a multiverse analysis
results <-
  the_data |>
  add_filters(include1 == 0, include2 != 3) |>
  add_variables("ivs", iv1, iv2) |>
  add_variables("dvs", dv1, dv2) |>
  add_model("linear", lm({dvs} ~ {ivs})) |>
  expand_decisions() |>
  analyze_grid()
#> Error in purrr::map(1:nrow(.grid), purrr::in_parallel(function(index,     ...) {    if (!is.null(libraries)) {        purrr::walk(rlang::parse_exprs(paste(glue::glue("library({c('multitool', 'dplyr', libraries)})"),             collapse = "; ")), rlang::eval_tidy)    }    if (!purrr::is_empty(custom_fns)) {        purrr::walk(rlang::parse_exprs(glue::glue("assign('{names(custom_fns)}', {custom_fns}, pos = .GlobalEnv)")),             rlang::eval_tidy)    }    start <- Sys.time()    analyzed_result <- execute_universe_model(.grid, decision_index = index,         save_model = save_model)    end <- Sys.time()    tidyr::nest(dplyr::mutate(analyzed_result, run_started = start,         run_ended = end, run_duration_seconds = end - start,         run_duration_minutes = (end - start)/60), timing_logs = dplyr::starts_with("run_"))}, .grid = .grid, execute_universe_model = execute_universe_model,     save_model = save_model, libraries = libraries, custom_fns = custom_fns),     .progress = show_progress): ℹ In index: 1.
#> Caused by error:
#> ! object 'the_data' not found

# Assess robustness of standardized coefficients
assess_robustness(results, .estimand = std_coefficient)
#> Error: object 'results' not found

# Assess raw coefficients
assess_robustness(results, .estimand = coefficient)
#> Error: object 'results' not found

# Assess std_coef with custom zero threshold
assess_robustness(results, .estimand = std_coefficient, zero_threshold = .05)
#> Error: object 'results' not found

# Stratified assessment by model type
assess_robustness(results, .estimand = std_coefficient, .by = dvs)
#> Error: object 'results' not found
```
