# Add arbitrary postprocessing code to a multiverse pipeline

Add arbitrary postprocessing code to a multiverse pipeline

## Usage

``` r
add_postprocess(.df, postprocess_name, code)
```

## Arguments

- .df:

  The original `data.frame`(e.g., base data set). If part of set of
  add\_\* decision functions in a pipeline, the base data will be passed
  along as an attribute.

- postprocess_name:

  a character string. A descriptive name for what the postprocessing
  step accomplishes.

- code:

  the literal code you would like to execute after each analysis.

  The code should be written to work with pipes (i.e., `|>` or `%>%`).
  Because the post-processing code comes last in each multiverse
  analysis step, the chosen model object will be passed to the
  post-processing code.

  For example, if you fit a simple linear model like: `lm(y ~ x1 + x2)`,
  and your post-processing code executes a call to `anova`, you would
  simply pass [`anova()`](https://rdrr.io/r/stats/anova.html) to
  `add_postprocess()`. The underlying code would be:

  `data |> filters |> lm(y ~ x1 + x2, data = _) |> anova()`

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
  add_postprocess("analysis of variance", aov())
#> # A tibble: 18 × 5
#>    type        group                code        additional_args add_standardized
#>    <chr>       <chr>                <chr>       <lgl>           <lgl>           
#>  1 filters     include1             include1 =… NA              NA              
#>  2 filters     include1             include1 %… NA              NA              
#>  3 filters     include2             include2 !… NA              NA              
#>  4 filters     include2             include2 !… NA              NA              
#>  5 filters     include2             include2 %… NA              NA              
#>  6 filters     include3             include3 >… NA              NA              
#>  7 filters     include3             include3 %… NA              NA              
#>  8 variables   ivs                  iv1         NA              NA              
#>  9 variables   ivs                  iv2         NA              NA              
#> 10 variables   ivs                  iv3         NA              NA              
#> 11 variables   dvs                  dv1         NA              NA              
#> 12 variables   dvs                  dv2         NA              NA              
#> 13 variables   mods                 mod1        NA              NA              
#> 14 variables   mods                 mod2        NA              NA              
#> 15 variables   mods                 mod3        NA              NA              
#> 16 preprocess  scale_iv             mutate({iv… NA              NA              
#> 17 models      linear model         lm({dvs} ~… NA              TRUE            
#> 18 postprocess analysis of variance aov()       NA              NA              
```
