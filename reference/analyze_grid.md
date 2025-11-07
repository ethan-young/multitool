# Perform all analyses over a complete decision grid

Perform all analyses over a complete decision grid

## Usage

``` r
analyze_grid(
  .grid,
  save_model = FALSE,
  show_progress = TRUE,
  libraries = NULL,
  ...
)
```

## Arguments

- .grid:

  a `tibble` produced by
  [`expand_decisions`](https://ethan-young.github.io/multitool/reference/expand_decisions.md)

- save_model:

  logical, indicates whether to save the model object in its entirety.
  The default is `FALSE` because model objects are usually large and
  under the hood,
  [`parameters`](https://easystats.github.io/parameters/reference/model_parameters.html)
  and
  [`performance`](https://easystats.github.io/performance/reference/model_performance.html)
  is used to summarize the most useful model information.

- show_progress:

  logical, whether to show a progress bar while running.

- libraries:

  a vector of character strings naming the packages you want to load
  when executing parallel processing. Internally, this will call
  `library` dynamically to ensure that any functions specific to a
  package you are using are available during execution on the individual
  workers. Only relevant if you have called `mirai::daemons()`.

- ...:

  this also reserved for parallel processing. Any custom functions you
  might use your pipeline (e.g., a custom post processin step), can be
  passed here in the form of `custom_func = custom_func`. This will be
  passed along to
  [`purrr::in_parallel`](https://purrr.tidyverse.org/reference/in_parallel.html)
  to make them available on the independent workers.

## Value

a single `tibble` containing tidied results for the model and any
post-processing tests/tasks. For each unique test (e.g., an `lm` or
`aov` called on an `lm`), a list column with the function name is
created with
[`parameters`](https://easystats.github.io/parameters/reference/model_parameters.html)
and
[`performance`](https://easystats.github.io/performance/reference/model_performance.html)
and any warnings or messages printed while fitting the models.
Internally, modeling and post-processing functions are checked to see if
there are tidy or glance methods available. If not, `summary` will be
called instead.

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
  add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
  add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
  add_model("no covariates",lm({dvs} ~ {ivs} * {mods})) |>
  add_model("covariate", lm({dvs} ~ {ivs} * {mods} + cov1)) |>
  add_postprocess("aov", aov())

pipeline_grid <- expand_decisions(full_pipeline)

# analyze the grid
analyzed_grid <- analyze_grid(pipeline_grid[1:10,])
#> Error in parallel_pkgs_installed(): The packages "carrier" (>= 0.3.0) and "mirai" (>= 2.5.1) are required
#> for parallel map.
```
