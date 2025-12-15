# Package index

## Creating a Pipeline

Add your analysis pipeline steps

- [`add_subgroups()`](https://ethan-young.github.io/multitool/reference/add_subgroups.md)
  : Add sub groups to the multiverse pipeline

- [`add_filters()`](https://ethan-young.github.io/multitool/reference/add_filters.md)
  : Add filtering/exclusion criteria to a multiverse pipeline

- [`add_variables()`](https://ethan-young.github.io/multitool/reference/add_variables.md)
  : Add a set of variable alternatives to a multiverse pipeline

- [`add_model()`](https://ethan-young.github.io/multitool/reference/add_model.md)
  : Add a model and formula to a multiverse pipeline

- [`add_model_descriptives()`](https://ethan-young.github.io/multitool/reference/add_model_descriptives.md)
  : Add arbitrary summary statistics to a multiverse pipeline

- [`add_preprocess()`](https://ethan-young.github.io/multitool/reference/add_preprocess.md)
  : Add arbitrary preprocessing code to a multiverse analysis pipeline

- [`add_postprocess()`](https://ethan-young.github.io/multitool/reference/add_postprocess.md)
  : Add arbitrary postprocessing code to a multiverse pipeline

- [`add_summary_stats()`](https://ethan-young.github.io/multitool/reference/add_summary_stats.md)
  : Add a set of descriptive statistics to compute over a set of
  variables

- [`add_reliabilities()`](https://ethan-young.github.io/multitool/reference/add_reliabilities.md)
  : Add item reliabilities to a multiverse pipeline

- [`add_correlations()`](https://ethan-young.github.io/multitool/reference/add_correlations.md)
  :

  Add correlations from the `correlation` package in `easystats`

- [`add_parameter_keys()`](https://ethan-young.github.io/multitool/reference/add_parameter_keys.md)
  : Add parameter keys names for later use in summarizing model effects

- [`expand_decisions()`](https://ethan-young.github.io/multitool/reference/expand_decisions.md)
  : Expand a set of multiverse decisions into all possible combinations

## View, Check, and Test

View metadata, check the code, and test the pipeline

- [`create_blueprint_graph()`](https://ethan-young.github.io/multitool/reference/create_blueprint_graph.md)
  : Create a Analysis Pipeline diagram
- [`detect_multiverse_n()`](https://ethan-young.github.io/multitool/reference/detect_multiverse_n.md)
  : Detect total number of analysis pipelines
- [`detect_n_subgroups()`](https://ethan-young.github.io/multitool/reference/detect_n_subgroups.md)
  : Detect total number of subgroups in your pipelines
- [`detect_n_filters()`](https://ethan-young.github.io/multitool/reference/detect_n_filters.md)
  : Detect total number of filtering expressions your pipelines
- [`detect_n_variables()`](https://ethan-young.github.io/multitool/reference/detect_n_variables.md)
  : Detect total number of variable sets in your pipelines
- [`detect_n_models()`](https://ethan-young.github.io/multitool/reference/detect_n_models.md)
  : Detect total number of models in your pipelines
- [`summarize_filter_ns()`](https://ethan-young.github.io/multitool/reference/summarize_filter_ns.md)
  : Summarize samples sizes for each unique filtering expression
- [`show_code()`](https://ethan-young.github.io/multitool/reference/show_code.md)
  [`show_code_subgroups()`](https://ethan-young.github.io/multitool/reference/show_code.md)
  [`show_code_filters()`](https://ethan-young.github.io/multitool/reference/show_code.md)
  [`show_code_preprocess()`](https://ethan-young.github.io/multitool/reference/show_code.md)
  [`show_code_model()`](https://ethan-young.github.io/multitool/reference/show_code.md)
  [`show_code_postprocess()`](https://ethan-young.github.io/multitool/reference/show_code.md)
  [`show_code_summary_stats()`](https://ethan-young.github.io/multitool/reference/show_code.md)
  [`show_code_corrs()`](https://ethan-young.github.io/multitool/reference/show_code.md)
  [`show_code_reliabilities()`](https://ethan-young.github.io/multitool/reference/show_code.md)
  : Show multiverse data code pipelines

## Run your Pipeline

Execute the whole pipeline and all alternatives

- [`analyze_grid()`](https://ethan-young.github.io/multitool/reference/analyze_grid.md)
  : Perform all analyses over a complete decision grid
- [`analyze_grid_parallel()`](https://ethan-young.github.io/multitool/reference/analyze_grid_parallel.md)
  : Analyze a complete decision grid in parallel
- [`run_multiverse()`](https://ethan-young.github.io/multitool/reference/run_multiverse.md)
  : Run a multiverse based on a complete decision grid
- [`run_multiverse_furrr()`](https://ethan-young.github.io/multitool/reference/run_multiverse_furrr.md)
  : Run a multi-core, multiverse based on a complete decision grid
- [`run_descriptives()`](https://ethan-young.github.io/multitool/reference/run_descriptives.md)
  : Run a multiverse-style descriptive analysis based on a complete
  decision grid

## Unpack Results

Unpack your results for viewing, plotting, and understanding

- [`unpack_specs()`](https://ethan-young.github.io/multitool/reference/unpack_specs.md)
  : Unpack the decision grid of specifications for your modeling
  pipeline
- [`unpack_results()`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
  [`unpack_model_parameters()`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
  [`unpack_model_performance()`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
  [`unpack_model_warnings()`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
  [`unpack_model_messges()`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
  [`unpack_postprocess()`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
  : Unpack a component of your analyzed grid
- [`condense()`](https://ethan-young.github.io/multitool/reference/condense.md)
  [`organize()`](https://ethan-young.github.io/multitool/reference/condense.md)
  : Summarize multiverse parameters
- [`reveal()`](https://ethan-young.github.io/multitool/reference/reveal.md)
  : Reveal the contents of a multiverse analysis
- [`reveal_model_parameters()`](https://ethan-young.github.io/multitool/reference/reveal_model_parameters.md)
  : Reveal the model parameters of a multiverse analysis
- [`reveal_model_performance()`](https://ethan-young.github.io/multitool/reference/reveal_model_performance.md)
  : Reveal the model performance/fit indices from a multiverse analysis
- [`reveal_model_warnings()`](https://ethan-young.github.io/multitool/reference/reveal_model_warnings.md)
  : Reveal any warnings about your models during a multiverse analysis
- [`reveal_model_messages()`](https://ethan-young.github.io/multitool/reference/reveal_model_messages.md)
  : Reveal any messages about your models during a multiverse analysis
- [`reveal_reliabilities()`](https://ethan-young.github.io/multitool/reference/reveal_reliabilities.md)
  : Reveal a set of multiverse cronbach's alpha statistics
- [`reveal_corrs()`](https://ethan-young.github.io/multitool/reference/reveal_corrs.md)
  : Reveal a set of multiverse correlations
- [`reveal_summary_stats()`](https://ethan-young.github.io/multitool/reference/reveal_summary_stats.md)
  : Reveal a set of summary statistics from a multiverse analysis
