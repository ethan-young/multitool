# Add a set of variable alternatives to a multiverse pipeline

Add a set of variable alternatives to a multiverse pipeline

## Usage

``` r
add_variables(.df, var_group, ...)
```

## Arguments

- .df:

  The original `data.frame`(e.g., base data set). If part of set of
  add\_\* decision functions in a pipeline, the base data will be passed
  along as an attribute.

- var_group:

  a character string. Indicates the name of the current set. For
  example, "primary_iv" could indicate this set are alternatives of the
  main predictor in an analysis.

- ...:

  the bare unquoted names of the variables to include as alternative
  options for this variable set. You can also use tidyselect to select
  variables.

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
 add_variables("mods", starts_with("mod"))
#> # A tibble: 8 × 3
#>   type      group code 
#>   <chr>     <chr> <chr>
#> 1 variables ivs   iv1  
#> 2 variables ivs   iv2  
#> 3 variables ivs   iv3  
#> 4 variables dvs   dv1  
#> 5 variables dvs   dv2  
#> 6 variables mods  mod1 
#> 7 variables mods  mod2 
#> 8 variables mods  mod3 
```
