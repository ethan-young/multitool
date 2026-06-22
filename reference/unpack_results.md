# Unpack a component of your analyzed grid

Unpack a component of your analyzed grid

## Usage

``` r
unpack_results(.multi, .what, .which = NULL, .unpack_specs = "wide")

unpack_model_parameters(.multi, effect_key = NULL, .unpack_specs = "wide")

unpack_model_performance(.multi, .unpack_specs = "wide")

unpack_model_warnings(.multi, .unpack_specs = "wide")

unpack_model_messages(.multi, .unpack_specs = "wide")

unpack_postprocess(.multi, .which, .unpack_specs = "wide")
```

## Arguments

- .multi:

  a multiverse list-column `tibble` produced by
  [`analyze_grid`](https://ethan-young.github.io/multitool/reference/analyze_grid.md).

- .what:

  the name of a list-column you would like to unpack

- .which:

  any sub-list columns you would like to unpack

- .unpack_specs:

  character, options are `"no"`, `"wide"`, or `"long"`. `"no"` (default)
  keeps specifications in a list column, `wide` unnests specifications
  with each specification category as a column. `"long"` unnests
  specifications and stacks them into long format, which stacks
  specifications into a `decision_type`, `decision_set` and
  `decision_choice` columns. This is mainly useful for plotting.

- effect_key:

  character, if you added parameter keys to your pipeline, you can
  specify if you would like filter the parameters using one of your
  parameter keys. This is useful when different variables are being
  switched out across the multiverse but represent the same effect of
  interest.

## Value

the unnested part of the multiverse requested. This usually contains the
particular estimates or statistics you would like to analyze over the
decision grid specified.

## Functions

- `unpack_model_parameters()`: Unpack the model parameters

- `unpack_model_performance()`: Unpack the model performance

- `unpack_model_warnings()`: Unpack the model warnings

- `unpack_model_messages()`: Unpack the model messages

- `unpack_postprocess()`: Unpack a post-processing result

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
the_multiverse <- analyze_grid(pipeline_grid[1:10,])

# Reveal results of the linear model
the_multiverse |> unpack_results(model_fitted, model_parameters)
#> # A tibble: 50 × 27
#>    decision ivs   dvs   mods  include1      include2      include3    model_meta
#>       <dbl> <chr> <chr> <chr> <chr>         <chr>         <chr>       <chr>     
#>  1        1 iv1   dv1   mod1  include1 == 0 include2 != 3 scale(incl… linear_mo…
#>  2        1 iv1   dv1   mod1  include1 == 0 include2 != 3 scale(incl… linear_mo…
#>  3        1 iv1   dv1   mod1  include1 == 0 include2 != 3 scale(incl… linear_mo…
#>  4        1 iv1   dv1   mod1  include1 == 0 include2 != 3 scale(incl… linear_mo…
#>  5        1 iv1   dv1   mod1  include1 == 0 include2 != 3 scale(incl… linear_mo…
#>  6        2 iv1   dv1   mod2  include1 == 0 include2 != 3 scale(incl… linear_mo…
#>  7        2 iv1   dv1   mod2  include1 == 0 include2 != 3 scale(incl… linear_mo…
#>  8        2 iv1   dv1   mod2  include1 == 0 include2 != 3 scale(incl… linear_mo…
#>  9        2 iv1   dv1   mod2  include1 == 0 include2 != 3 scale(incl… linear_mo…
#> 10        2 iv1   dv1   mod2  include1 == 0 include2 != 3 scale(incl… linear_mo…
#> # ℹ 40 more rows
#> # ℹ 19 more variables: model_function <chr>, parameter <chr>,
#> #   coefficient <dbl>, se <dbl>, ci <dbl>, ci_low <dbl>, ci_high <dbl>,
#> #   t <dbl>, df_error <int>, p <dbl>, std_coefficient <dbl>, std_ci <dbl>,
#> #   std_ci_low <dbl>, std_ci_high <dbl>, model_performance <list>,
#> #   model_warnings <list>, model_messages <list>, pipeline_code <list>,
#> #   timing_logs <list>
```
