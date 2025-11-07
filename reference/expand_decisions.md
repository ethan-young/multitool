# Expand a set of multiverse decisions into all possible combinations

Expand a set of multiverse decisions into all possible combinations

## Usage

``` r
expand_decisions(
  .pipeline,
  .collect_after = NULL,
  .pointer_path = NULL,
  .subgroup_in_path = FALSE
)
```

## Arguments

- .pipeline:

  a `data.frame` produced by calling a series of add\_\* functions.

- .collect_after:

  default is NULL. Most of the time you will not use this argument.
  However, if your data come from a database, you can use this argument
  to call
  [`dplyr::collect()`](https://dplyr.tidyverse.org/reference/compute.html)
  from `dbplyr` after a simple filter statements to speed up
  computations. Valid options are `"subgroups"`, `"filters"`, or
  `"preprocess"`. Note that `dbplyr` does not support all expressions.

- .pointer_path:

  a string specifying a path to create a external pointer object. This
  is only necessary if you are using data from an external source.
  Defaults to NULL.

- .subgroup_in_path:

  logical, whether to place the subgroup filters in a file path. This is
  only relevant if you are using an external pointer (e.g., an Arrow
  filesystem database). Placing the subgroup filter in the path itself
  might provide a performance boost over reading the entire filesystem
  and then performing subgoup filtering.

## Value

a nested `data.frame` containing all combinations of arbitrary decisions
for a multiverse analysis. Decision types will become list columns
matching the type of decisions called along the pipeline (e.g., filters,
variables, etc.). Any decisions containing
[`glue`](https://glue.tidyverse.org/reference/glue.html) syntax will be
populated with the relevant information.

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

full_pipeline <-
  the_data |>
  add_filters(include1 == 0,include2 != 3,include2 != 2, include3 > -2.5) |>
  add_variables("ivs", iv1, iv2, iv3) |>
  add_variables("dvs", dv1, dv2) |>
  add_variables("mods", starts_with("mod")) |>
  add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
  add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
  add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
  add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis")) |>
  add_correlations("predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2)) |>
  add_correlations("outcomes", matches("dv|mod"), focus_set = matches("dv")) |>
  add_reliabilities("unp_scale", c(iv1,iv2,iv3)) |>
  add_model("no covariates", lm({dvs} ~ {ivs} * {mods})) |>
  add_model("with covariates", lm({dvs} ~ {ivs} * {mods} + cov1)) |>
  add_postprocess("aov", aov())

pipeline_expanded <- expand_decisions(full_pipeline)
```
