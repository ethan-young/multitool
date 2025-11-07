# Add correlations from the `correlation` package in `easystats`

Add correlations from the `correlation` package in `easystats`

## Usage

``` r
add_correlations(
  .df,
  var_set,
  variables,
  focus_set = NULL,
  method = "auto",
  redundant = TRUE,
  add_matrix = TRUE
)
```

## Arguments

- .df:

  the original `data.frame`(e.g., base data set). If part of set of
  add\_\* decision functions in a pipeline, the base data will be passed
  along as an attribute.

- var_set:

  character string. Should be a descriptive name of the correlation
  matrix.

- variables:

  the variables for which you would like to correlations. These
  variables will be passed to `link[correlation]{correlation}`. You can
  also use tidyselect to select variables.

- focus_set:

  variables to focus one in a table. This produces a table where rows
  are each focused variables and columns are all other variables

- method:

  a valid method of correlation supplied to
  `link[correlation]{correlation}` (e.g., 'pearson' or 'kendall').
  Defaults to `'auto'`. See `link[correlation]{correlation}` for more
  details.

- redundant:

  logical, should the result include repeated correlations? Defaults to
  `TRUE` See `link[correlation]{correlation}` for details.

- add_matrix:

  logical, add a traditional correlation matrix to the output. Defaults
  to `TRUE`.

## Value

a `data.frame`with three columns: type, group, and code. Type indicates
the decision type, group is a decision, and the code is the actual code
that will be executed. If part of a pipe, the current set of decisions
will be appended as new rows.

## Examples

``` r
library(tidyverse)
#> ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
#> ✔ dplyr     1.1.4     ✔ readr     2.1.5
#> ✔ forcats   1.0.1     ✔ stringr   1.6.0
#> ✔ ggplot2   4.0.0     ✔ tibble    3.3.0
#> ✔ lubridate 1.9.4     ✔ tidyr     1.3.1
#> ✔ purrr     1.2.0     
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
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
  add_correlations("predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2))
#> # A tibble: 18 × 3
#>    type      group             code                                             
#>    <chr>     <chr>             <chr>                                            
#>  1 filters   include1          "include1 == 0"                                  
#>  2 filters   include1          "include1 %in% unique(include1)"                 
#>  3 filters   include2          "include2 != 3"                                  
#>  4 filters   include2          "include2 != 2"                                  
#>  5 filters   include2          "include2 %in% unique(include2)"                 
#>  6 filters   include3          "include3 > -2.5"                                
#>  7 filters   include3          "include3 %in% unique(include3)"                 
#>  8 variables ivs               "iv1"                                            
#>  9 variables ivs               "iv2"                                            
#> 10 variables ivs               "iv3"                                            
#> 11 variables dvs               "dv1"                                            
#> 12 variables dvs               "dv2"                                            
#> 13 variables mods              "mod1"                                           
#> 14 variables mods              "mod2"                                           
#> 15 variables mods              "mod3"                                           
#> 16 corrs     predictors_rs     "select(matches(\"iv|mod|cov\")) |> correlation(…
#> 17 corrs     predictors_matrix "select(matches(\"iv|mod|cov\")) |> correlation(…
#> 18 corrs     predictors_focus  "select(matches(\"iv|mod|cov\")) |> correlation(…
```
