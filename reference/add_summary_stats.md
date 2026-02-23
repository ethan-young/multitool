# Add a set of descriptive statistics to compute over a set of variables

**\[deprecated\]** This function has been deprecated; please use
[`add_model_descriptives()`](https://ethan-young.github.io/multitool/reference/add_model_descriptives.md)
instead.

## Usage

``` r
add_summary_stats(.df, var_set, variables, stats)
```

## Arguments

- .df:

  The original `data.frame`(e.g., base data set). If part of set of
  add\_\* decision functions in a pipeline, the base data will be passed
  along as an attribute.

- var_set:

  a character string. A name for the set of summary statistics

- variables:

  the variables for which you would like to compute summary statistics.
  You can also use tidyselect to select variables.

- stats:

  a character vector of stat names (e.g., `c("mean","sd")`). You are
  responsible for loading any packages that compute your preferred
  summary statistics. Summary statistic functions must work inside
  [`summarize`](https://dplyr.tidyverse.org/reference/summarise.html).

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
  add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
  add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
  add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
  add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis"))
#> # A tibble: 19 × 3
#>    type          group     code                                                 
#>    <chr>         <chr>     <chr>                                                
#>  1 filters       include1  "include1 == 0"                                      
#>  2 filters       include1  "include1 %in% unique(include1)"                     
#>  3 filters       include2  "include2 != 3"                                      
#>  4 filters       include2  "include2 != 2"                                      
#>  5 filters       include2  "include2 %in% unique(include2)"                     
#>  6 filters       include3  "include3 > -2.5"                                    
#>  7 filters       include3  "include3 %in% unique(include3)"                     
#>  8 variables     ivs       "iv1"                                                
#>  9 variables     ivs       "iv2"                                                
#> 10 variables     ivs       "iv3"                                                
#> 11 variables     dvs       "dv1"                                                
#> 12 variables     dvs       "dv2"                                                
#> 13 variables     mods      "mod1"                                               
#> 14 variables     mods      "mod2"                                               
#> 15 variables     mods      "mod3"                                               
#> 16 preprocess    scale_iv  "mutate({ivs} = scale({ivs}))"                       
#> 17 preprocess    scale_mod "mutate(`:=`({mods}, scale({mods})))"                
#> 18 summary_stats iv_stats  "select(c(starts_with(\"iv\"))) |> summarize(across(…
#> 19 summary_stats dv_stats  "select(c(starts_with(\"dv\"))) |> summarize(across(…
```
