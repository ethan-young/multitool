# Compose a single analysis-ready data frame from a results grid.

`compose_view()` assembles one tibble from selected components of a
results object. You name the result components you want (model
parameters, performance, post-processing output, pipeline code, timing
logs), and `compose_view()` unpacks each one and left-joins them by
`decision` into a single frame ready for plotting or tabling.

Its job is deliberately narrow: it reconciles components that live at
different grains into one frame and nothing else. It performs no
transformation, summarizing, or reshaping of the results. Any such work
is left to the caller, either with downstream `dplyr` on the returned
frame or with per-layer `data` transformations at plot time.

## Usage

``` r
compose_view(.multi, ...)
```

## Arguments

- .multi:

  a multiverse results object produced by
  [`analyze_grid`](https://ethan-young.github.io/multitool/reference/analyze_grid.md)
  (or
  [`analyze_grid_parallel`](https://ethan-young.github.io/multitool/reference/analyze_grid_parallel.md)).

- ...:

  result components to compose. Supply the bare column names of the
  components shipped by
  [`analyze_grid()`](https://ethan-young.github.io/multitool/reference/analyze_grid.md),
  for example `model_parameters`, `model_performance`, `pipeline_code`,
  `timing_logs`, or the name of a post-processing output column (e.g.
  `aov_fitted`). Arguments may be named to control the prefix applied to
  that component's columns (see Details); unnamed arguments receive an
  automatic prefix.

## Value

A single [`tibble`](https://tibble.tidyverse.org/reference/tibble.html)
containing the decision specifications and the requested components,
joined by `decision`. The row grain matches the finest component
requested, with coarser components broadcast across it.

## Details

The decision specifications are always included as the spine of the
returned frame, so you never need to request them explicitly.

**Column prefixing.** To keep columns from different components from
colliding, every value column is prefixed with its component's name; the
join key `decision` and the specification columns are left unprefixed so
they remain shared across components. When an argument is named, that
name is used as the prefix. When an argument is unnamed, a prefix is
assigned automatically:

- `model_parameters` becomes `params_`

- `model_performance` becomes `perform_`

- `pipeline_code` becomes `code_`

- `timing_logs` becomes `timing_`

- a post-processing column has its `_fitted` suffix removed (e.g.
  `aov_fitted` becomes `aov_`)

**Grain and broadcasting.** Components differ in granularity. Model
parameters have one row per model term, while performance, timing, and
pipeline code each have one row per decision. Because components are
joined by `decision`, coarser components are broadcast across the rows
of the finest component requested. For example, composing
`model_parameters` with `model_performance` repeats each decision's
performance values across that decision's term rows. This broadcasting
is intended: it produces a frame where, for instance, a model fit
statistic is available on every term row for annotation. Collapsing back
to a coarser grain (e.g. one label per decision) is left to the caller
at the point of use.

## See also

[`unpack_results`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
and the `unpack_model_*` functions for extracting a single component;
[`unpack_specs`](https://ethan-young.github.io/multitool/reference/unpack_specs.md)
for the specification grid.
