# Add a model and formula to a multiverse pipeline

Add a model and formula to a multiverse pipeline

## Usage

``` r
add_model(
  .df,
  model_desc,
  code,
  model_coefs = parameters::parameters(),
  model_fit = performance::performance(),
  model_standardize = parameters::standardize_parameters()
)
```

## Arguments

- .df:

  The original `data.frame`(e.g., base data set). If part of set of
  add\_\* decision functions in a pipeline, the base data will be passed
  along as an attribute.

- model_desc:

  a human readable name you would like to give the model.

- code:

  literal model syntax you would like to run. You can use `glue` inside
  formulas to dynamically generate variable names based on a variable
  grid. For example, if you make variable grid with two versions of your
  IVs (e.g., `iv1` and `iv2`), you can write your formula like so:
  `lm(happiness ~ {iv} + control_var)`. The only requirement is that the
  variables written in the formula actually exist in the underlying
  data. You are also responsible for loading any packages that run a
  particular model (e.g., `lme4` for mixed-models)

- model_coefs:

  a function to extract coefficients from the model object. The default
  is to use
  [`parameters::parameters()`](https://easystats.github.io/parameters/reference/model_parameters.html)
  but this could be also be
  [`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html) or
  any other function that summarizes model output. Whichever function
  you choose must take a model object as the first argument and return a
  `data.frame`.

- model_fit:

  a function to summarize model fit statistics. The default is to use
  [`performance::performance()`](https://easystats.github.io/performance/reference/model_performance.html)
  but this could be also be
  [`broom::glance()`](https://generics.r-lib.org/reference/glance.html)
  or any other function that summarizes model output. Whichever function
  you choose must take a model object as the first argument and return a
  `data.frame`.

- model_standardize:

  a function to calculate standardized coefficients from the model
  object. The default is to use
  [`parameters::standardize_parameters()`](https://easystats.github.io/parameters/reference/standardize_parameters.html)
  but this could be also be some other function that standardizes model
  output. Whichever function you choose must take a model object as the
  first argument and return a `data.frame`.

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
  add_model("linear model", lm({dvs} ~ {ivs} * {mods}))
#> # A tibble: 17 × 6
#>    type       group       code  model_coefs_fn model_fit_fn model_standardize_fn
#>    <chr>      <chr>       <chr> <chr>          <chr>        <chr>               
#>  1 filters    include1    incl… NA             NA           NA                  
#>  2 filters    include1    incl… NA             NA           NA                  
#>  3 filters    include2    incl… NA             NA           NA                  
#>  4 filters    include2    incl… NA             NA           NA                  
#>  5 filters    include2    incl… NA             NA           NA                  
#>  6 filters    include3    incl… NA             NA           NA                  
#>  7 filters    include3    incl… NA             NA           NA                  
#>  8 variables  ivs         iv1   NA             NA           NA                  
#>  9 variables  ivs         iv2   NA             NA           NA                  
#> 10 variables  ivs         iv3   NA             NA           NA                  
#> 11 variables  dvs         dv1   NA             NA           NA                  
#> 12 variables  dvs         dv2   NA             NA           NA                  
#> 13 variables  mods        mod1  NA             NA           NA                  
#> 14 variables  mods        mod2  NA             NA           NA                  
#> 15 variables  mods        mod3  NA             NA           NA                  
#> 16 preprocess scale_iv    muta… NA             NA           NA                  
#> 17 models     linear mod… lm({… parameters::p… performance… parameters::standar…
```
