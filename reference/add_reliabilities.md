# Add item reliabilities to a multiverse pipeline

Add item reliabilities to a multiverse pipeline

## Usage

``` r
add_reliabilities(.df, scale_name, items)
```

## Arguments

- .df:

  the original `data.frame`(e.g., base data set). If part of set of
  add\_\* decision functions in a pipeline, the base data will be passed
  along as an attribute.

- scale_name:

  a character string. Indicates the name of the scale or measure
  measured by the items or indicators in `items`.

- items:

  the items (variables) that comprise a scale or measure. These
  variables will be passed to `link[performance]{cronbachs_alpha}`,
  `link[performance]{item_intercor}`, and
  `link[performance]{item_reliability}`. You can also use tidyselect to
  select variables.

## Value

a `data.frame`with three columns: type, group, and code. Type indicates
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
  add_reliabilities("unp_scale", c(iv1,iv2,iv3))
#> # A tibble: 18 × 3
#>    type          group                code                                      
#>    <chr>         <chr>                <chr>                                     
#>  1 filters       include1             include1 == 0                             
#>  2 filters       include1             include1 %in% unique(include1)            
#>  3 filters       include2             include2 != 3                             
#>  4 filters       include2             include2 != 2                             
#>  5 filters       include2             include2 %in% unique(include2)            
#>  6 filters       include3             include3 > -2.5                           
#>  7 filters       include3             include3 %in% unique(include3)            
#>  8 variables     ivs                  iv1                                       
#>  9 variables     ivs                  iv2                                       
#> 10 variables     ivs                  iv3                                       
#> 11 variables     dvs                  dv1                                       
#> 12 variables     dvs                  dv2                                       
#> 13 variables     mods                 mod1                                      
#> 14 variables     mods                 mod2                                      
#> 15 variables     mods                 mod3                                      
#> 16 reliabilities unp_scale_alpha      select(c(iv1, iv2, iv3)) |> cronbachs_alp…
#> 17 reliabilities unp_scale_inter_corr select(c(iv1, iv2, iv3)) |> item_intercor…
#> 18 reliabilities unp_scale_if_dropped select(c(iv1, iv2, iv3)) |> item_reliabil…
```
