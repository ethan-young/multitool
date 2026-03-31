# Show multiverse data code pipelines

`show_code` is the generic function. All `show_code*` functions are
simple wrappers of `show_code`.

## Usage

``` r
show_code(
  .grid,
  decision_num,
  .step = "model",
  .model_summary = NULL,
  .post_step = NULL,
  .execute = FALSE
)

show_code_subgroups(.grid, decision_num, ...)

show_code_filters(.grid, decision_num, ...)

show_code_preprocess(.grid, decision_num, ...)

show_code_model(.grid, decision_num, ...)

show_code_postprocess(.grid, decision_num, ...)
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

- .model_summary:

  a model summary function such as
  [`parameters::parameters()`](https://easystats.github.io/parameters/reference/model_parameters.html)
  or [`broom::tidy()`](https://generics.r-lib.org/reference/tidy.html)

- .post_step:

  Only relevant if you are exposing a postprocessing step. If you have
  more than one postprocess, you can specify which you would like to
  expose by index or by name.

- .execute:

  logical, whether or not to run the code as well as print it.

- ...:

  additional arguments passed to `show_code()`

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
