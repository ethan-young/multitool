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
#>  ■■■■■■■■■■■■■■■■■■■■■■■■■■■       88% |  ETA:  0s

# Assess robustness of standardized coefficients
assess_robustness(results, .estimand = std_coefficient)
#> # A tibble: 10 × 13
#>    metric   metric_type reference n_decisions     mean   median     iqr      q05
#>    <chr>    <chr>       <chr>           <dbl>    <dbl>    <dbl>   <dbl>    <dbl>
#>  1 std_coe… parameter   (Interce…          16  0        0       0        0      
#>  2 std_coe… parameter   iv1                 8 -1.44e-2 -6.78e-3 7.79e-2 -9.34e-2
#>  3 std_coe… parameter   iv2                 8  1.62e-2  1.2 e-2 3.38e-2 -1.26e-2
#>  4 aic      fit index   full mod…          16  1.11e+3  1.09e+3 3.86e+2  8.15e+2
#>  5 aicc     fit index   full mod…          16  1.11e+3  1.09e+3 3.86e+2  8.15e+2
#>  6 bic      fit index   full mod…          16  1.12e+3  1.10e+3 3.87e+2  8.26e+2
#>  7 r2       fit index   full mod…          16  1.92e-3  8.10e-4 2.34e-3  1   e-5
#>  8 r2_adju… fit index   full mod…          16 -7.2 e-4 -1.76e-3 2.02e-3 -2.45e-3
#>  9 rmse     fit index   full mod…          16  9.71e-1  9.78e-1 2.82e-2  9.39e-1
#> 10 sigma    fit index   full mod…          16  9.74e-1  9.81e-1 2.79e-2  9.41e-1
#> # ℹ 5 more variables: q95 <dbl>, p_positive <dbl>, p_negative <dbl>,
#> #   p_zero <dbl>, sign_entropy <dbl>

# Assess raw coefficients
assess_robustness(results, .estimand = coefficient)
#> # A tibble: 10 × 13
#>    metric   metric_type reference n_decisions     mean   median     iqr      q05
#>    <chr>    <chr>       <chr>           <dbl>    <dbl>    <dbl>   <dbl>    <dbl>
#>  1 coeffic… parameter   (Interce…          16 -1.26e-2 -1.67e-2 9.05e-2 -1.04e-1
#>  2 coeffic… parameter   iv1                 8 -1.48e-2 -6.65e-3 7.51e-2 -9.20e-2
#>  3 coeffic… parameter   iv2                 8  1.67e-2  1.20e-2 3.40e-2 -1.25e-2
#>  4 aic      fit index   full mod…          16  1.11e+3  1.09e+3 3.86e+2  8.15e+2
#>  5 aicc     fit index   full mod…          16  1.11e+3  1.09e+3 3.86e+2  8.15e+2
#>  6 bic      fit index   full mod…          16  1.12e+3  1.10e+3 3.87e+2  8.26e+2
#>  7 r2       fit index   full mod…          16  1.92e-3  8.10e-4 2.34e-3  1   e-5
#>  8 r2_adju… fit index   full mod…          16 -7.2 e-4 -1.76e-3 2.02e-3 -2.45e-3
#>  9 rmse     fit index   full mod…          16  9.71e-1  9.78e-1 2.82e-2  9.39e-1
#> 10 sigma    fit index   full mod…          16  9.74e-1  9.81e-1 2.79e-2  9.41e-1
#> # ℹ 5 more variables: q95 <dbl>, p_positive <dbl>, p_negative <dbl>,
#> #   p_zero <dbl>, sign_entropy <dbl>

# Assess std_coef with custom zero threshold
assess_robustness(results, .estimand = std_coefficient, zero_threshold = .05)
#> # A tibble: 10 × 13
#>    metric   metric_type reference n_decisions     mean   median     iqr      q05
#>    <chr>    <chr>       <chr>           <dbl>    <dbl>    <dbl>   <dbl>    <dbl>
#>  1 std_coe… parameter   (Interce…          16  0        0       0        0      
#>  2 std_coe… parameter   iv1                 8 -1.44e-2 -6.78e-3 7.79e-2 -9.34e-2
#>  3 std_coe… parameter   iv2                 8  1.62e-2  1.2 e-2 3.38e-2 -1.26e-2
#>  4 aic      fit index   full mod…          16  1.11e+3  1.09e+3 3.86e+2  8.15e+2
#>  5 aicc     fit index   full mod…          16  1.11e+3  1.09e+3 3.86e+2  8.15e+2
#>  6 bic      fit index   full mod…          16  1.12e+3  1.10e+3 3.87e+2  8.26e+2
#>  7 r2       fit index   full mod…          16  1.92e-3  8.10e-4 2.34e-3  1   e-5
#>  8 r2_adju… fit index   full mod…          16 -7.2 e-4 -1.76e-3 2.02e-3 -2.45e-3
#>  9 rmse     fit index   full mod…          16  9.71e-1  9.78e-1 2.82e-2  9.39e-1
#> 10 sigma    fit index   full mod…          16  9.74e-1  9.81e-1 2.79e-2  9.41e-1
#> # ℹ 5 more variables: q95 <dbl>, p_positive <dbl>, p_negative <dbl>,
#> #   p_zero <dbl>, sign_entropy <dbl>

# Stratified assessment by model type
assess_robustness(results, .estimand = std_coefficient, .by = dvs)
#> # A tibble: 20 × 14
#>    metric      metric_type reference dvs   n_decisions     mean   median     iqr
#>    <chr>       <chr>       <chr>     <chr>       <dbl>    <dbl>    <dbl>   <dbl>
#>  1 std_coeffi… parameter   (Interce… dv1             8  0        0       0      
#>  2 std_coeffi… parameter   iv1       dv1             4 -5.95e-2 -5.72e-2 3.79e-2
#>  3 std_coeffi… parameter   (Interce… dv2             8  0        0       0      
#>  4 std_coeffi… parameter   iv1       dv2             4  3.07e-2  2.80e-2 2.24e-2
#>  5 std_coeffi… parameter   iv2       dv1             4  2.94e-2  2.78e-2 2.47e-2
#>  6 std_coeffi… parameter   iv2       dv2             4  3   e-3 -2.84e-3 1.95e-2
#>  7 aic         fit index   full mod… dv1             8  1.12e+3  1.12e+3 3.86e+2
#>  8 aicc        fit index   full mod… dv1             8  1.12e+3  1.12e+3 3.86e+2
#>  9 bic         fit index   full mod… dv1             8  1.13e+3  1.13e+3 3.87e+2
#> 10 r2          fit index   full mod… dv1             8  2.96e-3  1.72e-3 3.34e-3
#> 11 r2_adjusted fit index   full mod… dv1             8  3.2 e-4 -8.7 e-4 2.21e-3
#> 12 rmse        fit index   full mod… dv1             8  9.88e-1  9.88e-1 4.75e-3
#> 13 sigma       fit index   full mod… dv1             8  9.91e-1  9.90e-1 4.58e-3
#> 14 aic         fit index   full mod… dv2             8  1.10e+3  1.09e+3 3.56e+2
#> 15 aicc        fit index   full mod… dv2             8  1.10e+3  1.09e+3 3.56e+2
#> 16 bic         fit index   full mod… dv2             8  1.11e+3  1.10e+3 3.57e+2
#> 17 r2          fit index   full mod… dv2             8  8.9 e-4  3.9 e-4 1.03e-3
#> 18 r2_adjusted fit index   full mod… dv2             8 -1.76e-3 -1.95e-3 4.9 e-4
#> 19 rmse        fit index   full mod… dv2             8  9.54e-1  9.53e-1 2.89e-2
#> 20 sigma       fit index   full mod… dv2             8  9.57e-1  9.56e-1 2.84e-2
#> # ℹ 6 more variables: q05 <dbl>, q95 <dbl>, p_positive <dbl>, p_negative <dbl>,
#> #   p_zero <dbl>, sign_entropy <dbl>
```
