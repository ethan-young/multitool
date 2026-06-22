# Unpack the decision grid of specifications for your modeling pipeline

Unpack the decision grid of specifications for your modeling pipeline

## Usage

``` r
unpack_specs(.multi, .how = "wide")
```

## Arguments

- .multi:

  a multiverse list-column `tibble` produced by
  [`analyze_grid`](https://ethan-young.github.io/multitool/reference/analyze_grid.md).

- .how:

  character, options are `"no"`, `"wide"`, or `"long"`. `"no"` (default)
  keeps specifications in a list column, `wide` unnests specifications
  with each specification category as a column. `"long"` unnests
  specifications and stacks them into long format, which stacks
  specifications into a `decision_type`, `decision_set` and
  `decision_choice` columns. This is mainly useful for plotting.

## Value

the unnested specifications of the analysis grid.

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
the_multiverse |> unpack_specs("wide")
#> # A tibble: 10 × 11
#>    decision ivs   dvs   mods  include1 include2 include3 model_meta model_fitted
#>       <dbl> <chr> <chr> <chr> <chr>    <chr>    <chr>    <chr>      <list>      
#>  1        1 iv1   dv1   mod1  include… include… scale(i… linear_mo… <tibble>    
#>  2        2 iv1   dv1   mod2  include… include… scale(i… linear_mo… <tibble>    
#>  3        3 iv1   dv1   mod3  include… include… scale(i… linear_mo… <tibble>    
#>  4        4 iv1   dv2   mod1  include… include… scale(i… linear_mo… <tibble>    
#>  5        5 iv1   dv2   mod2  include… include… scale(i… linear_mo… <tibble>    
#>  6        6 iv1   dv2   mod3  include… include… scale(i… linear_mo… <tibble>    
#>  7        7 iv2   dv1   mod1  include… include… scale(i… linear_mo… <tibble>    
#>  8        8 iv2   dv1   mod2  include… include… scale(i… linear_mo… <tibble>    
#>  9        9 iv2   dv1   mod3  include… include… scale(i… linear_mo… <tibble>    
#> 10       10 iv2   dv2   mod1  include… include… scale(i… linear_mo… <tibble>    
#> # ℹ 2 more variables: pipeline_code <list>, timing_logs <list>
```
