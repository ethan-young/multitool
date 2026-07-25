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
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■       88% |  ETA:  0s

# Decompose variance in standardized coefficients
unpacked <- unpack_model_parameters(results)
assess_decisions(unpacked, .estimand = std_coefficient)
#> Joining with `by = join_by(decision_set, total_variance)`
#> Joining with `by = join_by(decision_set)`
#> # A tibble: 4 × 5
#>   decision_set main_effect total_effect interaction_effect variance_reduction
#>   <chr>              <dbl>        <dbl>              <dbl>              <dbl>
#> 1 ivs            0.0000343        0.836              0.836          0.0000343
#> 2 dvs            0.0478           0.952              0.904          0.0478   
#> 3 include1       0.000840         0.810              0.809          0.000840 
#> 4 include2       0.0438           0.917              0.874          0.0438   

# Which decisions matter most for p-values?
assess_decisions(unpacked, .estimand = p)
#> Joining with `by = join_by(decision_set, total_variance)`
#> Joining with `by = join_by(decision_set)`
#> # A tibble: 4 × 5
#>   decision_set main_effect total_effect interaction_effect variance_reduction
#>   <chr>              <dbl>        <dbl>              <dbl>              <dbl>
#> 1 ivs            0.0000804        0.615              0.615          0.0000804
#> 2 dvs            0.00815          0.934              0.926          0.00815  
#> 3 include1       0.0478           0.619              0.571          0.0478   
#> 4 include2       0.0170           0.909              0.892          0.0170   

# Decompose separately for each parameter
assess_decisions(unpacked, .estimand = p, .by = dvs)
#> Joining with `by = join_by(decision_set, dvs, total_variance)`
#> Joining with `by = join_by(dvs, decision_set)`
#> # A tibble: 6 × 6
#>   dvs   decision_set main_effect total_effect interaction_effect
#>   <chr> <chr>              <dbl>        <dbl>              <dbl>
#> 1 dv1   ivs               0.0324        0.411              0.379
#> 2 dv1   include1          0.0593        0.430              0.370
#> 3 dv1   include2          0.512         0.908              0.396
#> 4 dv2   ivs               0.0322        0.791              0.759
#> 5 dv2   include1          0.0393        0.782              0.743
#> 6 dv2   include2          0.157         0.924              0.767
#> # ℹ 1 more variable: variance_reduction <dbl>
```
