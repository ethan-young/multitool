# Perform all analyses over a complete decision grid

Executes the analysis pipeline for every row of an expanded decision
grid, returning tidied results for each. Execution is parallel-ready: if
[`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html)
have been provisioned, the rows are distributed across the daemons;
otherwise they run sequentially. `analyze_grid()` never sets up daemons
itself — you provision them, and the function uses them if present.

## Usage

``` r
analyze_grid(
  .grid,
  show_progress = TRUE,
  ship_base_df = TRUE,
  libraries = NULL,
  ...
)
```

## Arguments

- .grid:

  a `tibble` produced by
  [`expand_decisions`](https://ethan-young.github.io/multitool/reference/expand_decisions.md).

- show_progress:

  logical, whether to show a progress bar while running.

- ship_base_df:

  logical (default `TRUE`). Controls how the base data frame reaches the
  workers when running in parallel. When `TRUE`, the base data frame
  named in the grid's `"base_df"` attribute is resolved in the calling
  environment, shipped to each worker, and assigned there by name — the
  simplest option, suited to small-to-moderate in-memory data. When
  `FALSE`, the base data frame is not shipped; you are responsible for
  making it available on the workers under the name the pipeline code
  references, typically by establishing it on the daemons beforehand
  with
  [`mirai::everywhere()`](https://mirai.r-lib.org/reference/everywhere.html)
  (e.g. opening an Arrow dataset on each worker). Use `FALSE` for large
  or externally-stored data you do not want copied to every worker. Has
  no effect when running sequentially.

- libraries:

  a character vector naming packages to load on each worker. Internally
  this calls [`library()`](https://rdrr.io/r/base/library.html)
  dynamically so that functions from the packages your pipeline uses are
  available during execution on the workers. Relevant when running in
  parallel via
  [`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html);
  include here any package your pipeline code calls that is not attached
  by default.

- ...:

  Custom functions your pipeline references (e.g. a custom
  post-processing step), passed as `name = function` pairs (for example
  `my_step = my_step`). Each is made available on the workers under the
  given name, so pipeline code that calls it by name resolves. The name
  must match the name used in the pipeline.

## Value

a single `tibble` containing tidied results for the model and any
post-processing tests/tasks. For each unique test (e.g., an `lm` or
`aov` called on an `lm`), a list column with the function name is
created with
[`parameters`](https://easystats.github.io/parameters/reference/model_parameters.html)
and
[`performance`](https://easystats.github.io/performance/reference/model_performance.html)
and any warnings or messages printed while fitting the models. A
`timing_logs` list column records the start, end, and duration of each
row's run. The grid's `"pipeline"` attribute is carried through to the
result.

## Parallel execution

To run in parallel, provision daemons before calling, e.g.
`mirai::daemons(6)`. Each worker loads `multitool`, `dplyr`, and any
packages named in `libraries`; receives any custom functions passed
through `...`; and (when `ship_base_df = TRUE`) the base data frame.
With no daemons set, execution falls back to sequential and these
provisions still apply locally. For large data, prefer
`ship_base_df = FALSE` with the data established on the daemons via
[`mirai::everywhere()`](https://mirai.r-lib.org/reference/everywhere.html),
or an Arrow partition path baked into the pipeline so each worker reads
its own slice from storage.

## Establishing the data on workers yourself (`ship_base_df = FALSE`)

With `ship_base_df = FALSE`, `analyze_grid()` does not ship the base
data frame — you are responsible for making it available on each worker,
under the same name your pipeline references. This avoids copying large
data to every worker: instead each worker holds its own handle (for
example an Arrow dataset opened from storage), established once with
[`mirai::everywhere()`](https://mirai.r-lib.org/reference/everywhere.html).

Two rules make this work. First, the object must live in each worker's
global environment, because that is where the pipeline code is resolved;
the reliable way to put it there is `evalq(..., envir = .GlobalEnv)`
inside `everywhere()`. Second, the name must match the grid's
`"base_df"` attribute exactly — the pipeline code refers to the data by
that name, so the object you establish must carry it.


    # name must match attr(.grid, "base_df"), e.g. "coffee_analysis_df"
    mirai::daemons(6)
    mirai::everywhere(
      evalq(
        {
          library(arrow)
          coffee_analysis_df <- open_dataset("/absolute/path/to/data/")
        },
        envir = .GlobalEnv
      )
    )
    analyzed_grid <- analyze_grid(pipeline_grid, ship_base_df = FALSE)
    mirai::daemons(0)

If the object is missing or misnamed on the workers, the pipeline code
fails to find it; because the failure occurs inside worker evaluation it
may surface as an opaque error rather than a clear "object not found",
so check the name match first if a parallel run with
`ship_base_df = FALSE` fails.

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
  add_postprocess("ptp", predict())

pipeline_grid <- expand_decisions(full_pipeline)

# analyze the grid (sequential)
analyzed_grid <- analyze_grid(pipeline_grid[1:10,])

if (FALSE) { # \dontrun{
# analyze in parallel: provision daemons first
mirai::daemons(6)
analyzed_grid <- analyze_grid(pipeline_grid)
mirai::daemons(0)
} # }
```
