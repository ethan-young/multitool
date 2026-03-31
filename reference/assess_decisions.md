# Decompose decision variance using Sobol sensitivity indices and variance dispersal

Quantifies how much each decision type (e.g., filters, variables,
models) contributes to the total variance in a focal estimand across all
decision specifications. Uses variance-based sensitivity analysis to
partition variance into main effects, interaction effects, and total
effects for each decision set.

## Usage

``` r
assess_decisions(.unpacked, .estimand, .by = NULL)
```

## Arguments

- .unpacked:

  A `data.frame` with unpacked multiverse results, typically produced by
  [`unpack_model_parameters`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
  or
  [`unpack_model_performance`](https://ethan-young.github.io/multitool/reference/unpack_results.md).
  Must contain columns for each decision type (filters, variables,
  models, etc.) and the focal estimand.

- .estimand:

  The numeric outcome variable to decompose. Defaults to `std_coef`
  (standardized coefficients). Use unquoted column names with tidy
  evaluation.

- .by:

  Optional grouping variable(s) for stratified decomposition. The
  variance decomposition will be computed separately for each group.
  Useful for examining whether decision importance varies across
  different model variables or subgroups. Use unquoted column names.

## Value

A `data.frame` with one row per decision set, containing:

- decision_set:

  Name of the decision type (e.g., "filters", "variables", "model")

- main_effect:

  First-order Sobol index. Proportion of total variance explained by
  this decision set alone, averaging over all other decisions. Ranges
  from 0 (no effect) to 1 (explains all variance)

- total_effect:

  Total Sobol index. Proportion of total variance explained by this
  decision set including all its interactions with other decisions.
  Always ≥ main_effect

- interaction_effect:

  Total effect minus main effect. Proportion of variance due to
  interactions between this decision and others

- variance_reduction:

  Proportion of variance eliminated by fixing this decision to a single
  option. Also called "expected reduction in variance" or EVPPI
  (Expected Value of Perfect Parameter Information)

If `.by` is specified, grouping columns appear first.

## Details

This function implements a Sobol-style decomposition where "decision
sets" (e.g., all filter decisions) are treated as factors whose
combinations produce different specifications. The decomposition reveals
which analytical choices have the strongest influence on results.

The function computes four complementary variance measures:

**Main effect (first-order Sobol):** How much does this decision matter
on average, ignoring interactions? Computed by averaging the estimand
over all combinations of other decisions, then computing the variance of
those conditional means.

**Total effect (total-order Sobol):** How much variance remains when we
fix all decisions *except* this one? Includes the decision's main effect
plus all interactions involving it.

**Interaction effect:** The gap between total and main effects, showing
how much the decision's impact depends on other choices.

**Variance reduction:** How much would total variance decrease if we
picked one option for this decision? Useful for prioritizing which
decisions to "fix" to reduce result instability.

Interpretation: A decision with high main effect drives results
independently. A decision with high interaction effect matters, but
differently depending on other choices. A decision with low total effect
is relatively inconsequential.

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

# Decompose variance in standardized coefficients
unpacked <- unpack_model_parameters(results)
#> Error: object 'results' not found
assess_decisions(unpacked, .estimand = std_coefficient)
#> Error: object 'unpacked' not found

# Which decisions matter most for p-values?
assess_decisions(unpacked, .estimand = p)
#> Error: object 'unpacked' not found

# Decompose separately for each parameter
assess_decisions(unpacked, .estimand = p, .by = dvs)
#> Error: object 'unpacked' not found
```
