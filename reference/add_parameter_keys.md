# Add parameter keys names for later use in summarizing model effects

Add parameter keys names for later use in summarizing model effects

## Usage

``` r
add_parameter_keys(.df, parameter_group, parameter_name)
```

## Arguments

- .df:

  The original `data.frame`(e.g., base data set). If part of set of
  add\_\* decision functions in a pipeline, the base data will be passed
  along as an attribute.

- parameter_group:

  character, a name for the parameter of interest

- parameter_name:

  quoted or unquoted names of variables involved in a particular
  parameter of interest. Usually this is just a variable in your model
  (e.g., a main effect of your iv). However, it could also be an
  interaction term or some other term. You can use `glue` syntax to
  specify an effect that might use alternative versions of the same
  variable.

## Value

a `data.frame` with three columns: type, group, and code. Type indicates
the decision type, group is a decision, and the code is the actual code
that will be executed. If part of a pipe, the current set of decisions
will be appended as new rows.

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

the_data |>
  add_variables("ivs", iv1, iv2, iv3) |>
  add_variables("dvs", dv1, dv2) |>
  add_variables("mods", starts_with("mod")) |>
  add_model("linear model", lm({dvs} ~ {ivs} * {mods})) |>
  add_parameter_keys("my_interaction", "{ivs}:{mods}") |>
  add_parameter_keys("my_main_effect", {ivs})
#> # A tibble: 11 × 6
#>    type          group    code  additional_args add_standardized add_performance
#>    <chr>         <chr>    <chr> <lgl>           <lgl>            <lgl>          
#>  1 variables     ivs      iv1   NA              NA               NA             
#>  2 variables     ivs      iv2   NA              NA               NA             
#>  3 variables     ivs      iv3   NA              NA               NA             
#>  4 variables     dvs      dv1   NA              NA               NA             
#>  5 variables     dvs      dv2   NA              NA               NA             
#>  6 variables     mods     mod1  NA              NA               NA             
#>  7 variables     mods     mod2  NA              NA               NA             
#>  8 variables     mods     mod3  NA              NA               NA             
#>  9 models        linear … lm({… NA              TRUE             TRUE           
#> 10 parameter_key my_inte… {ivs… NA              NA               NA             
#> 11 parameter_key my_main… {ivs} NA              NA               NA             
```
