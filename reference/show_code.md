# Show multiverse data code pipelines

`show_code` is the generic function. All `show_code*` functions are
simple wrappers of `show_code`.

## Usage

``` r
show_code(
  .grid,
  decision_num,
  .step = "model",
  .post_step = NULL,
  .execute = FALSE
)

show_code_subgroups(.grid, decision_num, ...)

show_code_filters(.grid, decision_num, ...)

show_code_preprocess(.grid, decision_num, ...)

show_code_model(.grid, decision_num, ...)

show_code_postprocess(.grid, decision_num, ...)

show_code_summary_stats(
  .grid,
  decision_num,
  summary_set = 1,
  copy = FALSE,
  console = TRUE,
  execute = FALSE,
  ...
)

show_code_corrs(
  .grid,
  decision_num,
  corr_set = 1,
  copy = FALSE,
  console = TRUE,
  execute = FALSE,
  ...
)

show_code_reliabilities(
  .grid,
  decision_num,
  rel_set = 1,
  copy = FALSE,
  console = TRUE,
  execute = FALSE,
  ...
)
```

## Arguments

- .grid:

  a full decision grid created by
  [`expand_decisions`](https://ethan-young.github.io/multitool/reference/expand_decisions.md)
  or a fully analyzed grid produced by
  [`analyze_grid`](https://ethan-young.github.io/multitool/reference/analyze_grid.md).

- decision_num:

  numeric. Indicates which decision set in the grid to show underlying
  code.

- .step:

  a point along the pipeline for which you would like to show the
  underlying code. Defaults to the model.

- .post_step:

  Only relevant if you are exposing a postprocessing step. If you have
  more than one postprocess, you can specify which you would like to
  expose by index or by name.

- .execute:

  logical, whether or not to run the code as well as print it.

- ...:

  additional arguments passed to `show_code()`

- summary_set:

  numeric. For `show_code_summary_stats`, Which set of summary
  statistics to print. Default is set to the `1`.

- copy:

  logical, whether to copy code to clipboard

- console:

  logical, whether to paste code into the console

- execute:

  logical, whether to run the code

- corr_set:

  numeric. For `show_code_corrs`, Which set of correlations to print.
  Default is set to the `1`.

- rel_set:

  numeric. For `show_code_reliabilities`, Which set of reliabilities to
  print. Default is set to the `1`.

## Value

the code that generated results up to the specified point in an analysis
pipeline.

## Details

Each `show_code*` function should be self-explanatory - they indicate
where along the multiverse pipeline to extract code. The goal of these
functions is to create a window into each data/model combination and
allow the user to inspect specific decisions straight from the code that
produced it.

## Functions

- `show_code_subgroups()`: Show the code up to the subgroups stage

- `show_code_filters()`: Show the code up to the filtering stage

- `show_code_preprocess()`: Show the code up to the preprocessing stage

- `show_code_model()`: Show the code up to the modeling stage

- `show_code_postprocess()`: Show the code up to the post-processing
  stage

- `show_code_summary_stats()`: Show the code for computing summary
  statistics

- `show_code_corrs()`: Show the code for computing correlations

- `show_code_reliabilities()`: Show the code for computing scale
  reliability
