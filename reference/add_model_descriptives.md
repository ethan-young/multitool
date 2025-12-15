# Add arbitrary summary statistics to a multiverse pipeline

Add arbitrary summary statistics to a multiverse pipeline

## Usage

``` r
add_model_descriptives(.df, desc_name, code)
```

## Arguments

- .df:

  The original `data.frame`(e.g., base data set). If part of set of
  add\_\* decision functions in a pipeline, the base data will be passed
  along as an attribute.

- desc_name:

  a character string. A descriptive name for what the summary statistics
  you want to compute over the data passed to your model.

- code:

  the literal code you would like to execute. For summary statistics,
  [`model.frame()`](https://rdrr.io/r/stats/model.frame.html) will be
  called on the model object fit in the prior step. Your code should
  thus work with the variables that are used in your model.

## Value

a `data.frame` with three columns: type, group, and code. Type indicates
the decision type, group is a decision, and the code is the actual code
that will be executed. If part of a pipe, the current set of decisions
will be appended as new rows.

## Examples

``` r
library(tidyverse)
library(multitool)

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
  add_filters(include1 == 0,include2 != 3,include2 != 2, include3 > -2.5) |>
  add_variables("ivs", iv1, iv2, iv3) |>
  add_variables("dvs", dv1, dv2) |>
  add_variables("mods", starts_with("mod")) |>
  add_preprocess("scale_iv", 'mutate({ivs} = scale({ivs}))') |>
  add_model("linear model", lm({dvs} ~ {ivs} * {mods})) |>
  add_model_descriptives(
    "descriptives",
    summarize(body_mass_mean = mean({dvs}), .by = c(include2))
  )
#> # A tibble: 18 × 6
#>    type        group      code  additional_args add_standardized add_performance
#>    <chr>       <chr>      <glu> <lgl>           <lgl>            <lgl>          
#>  1 filters     include1   incl… NA              NA               NA             
#>  2 filters     include1   incl… NA              NA               NA             
#>  3 filters     include2   incl… NA              NA               NA             
#>  4 filters     include2   incl… NA              NA               NA             
#>  5 filters     include2   incl… NA              NA               NA             
#>  6 filters     include3   incl… NA              NA               NA             
#>  7 filters     include3   incl… NA              NA               NA             
#>  8 variables   ivs        iv1   NA              NA               NA             
#>  9 variables   ivs        iv2   NA              NA               NA             
#> 10 variables   ivs        iv3   NA              NA               NA             
#> 11 variables   dvs        dv1   NA              NA               NA             
#> 12 variables   dvs        dv2   NA              NA               NA             
#> 13 variables   mods       mod1  NA              NA               NA             
#> 14 variables   mods       mod2  NA              NA               NA             
#> 15 variables   mods       mod3  NA              NA               NA             
#> 16 preprocess  scale_iv   muta… NA              NA               NA             
#> 17 models      linear mo… lm({… NA              TRUE             TRUE           
#> 18 postprocess descripti… mode… NA              NA               NA             
```
