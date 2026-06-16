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
- [`add_parameter_keys()`](https://ethan-young.github.io/multitool/reference/add_parameter_keys.md)
  : Add parameter keys names for later use in summarizing model effects
- [`expand_decisions()`](https://ethan-young.github.io/multitool/reference/expand_decisions.md)
  : Expand a set of multiverse decisions into all possible combinations

## View, Check, and Test

View metadata, check the code, and test the pipeline

- [`visualize_pipeline()`](https://ethan-young.github.io/multitool/reference/visualize_pipeline.md)
  : Visualize an analysis pipeline workflow
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
  : Show multiverse data code pipelines

## Run your Pipeline

Execute the whole pipeline and all alternatives

- [`analyze_grid()`](https://ethan-young.github.io/multitool/reference/analyze_grid.md)
  : Perform all analyses over a complete decision grid
- [`analyze_grid_parallel()`](https://ethan-young.github.io/multitool/reference/analyze_grid_parallel.md)
  : Analyze a complete decision grid in parallel

## Unpack Results

Unpack your results for viewing, plotting, and understanding

- [`unpack_specs()`](https://ethan-young.github.io/multitool/reference/unpack_specs.md)
  : Unpack the decision grid of specifications for your modeling
  pipeline
- [`unpack_results()`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
  [`unpack_model_parameters()`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
  [`unpack_model_performance()`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
  [`unpack_model_warnings()`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
  [`unpack_model_messages()`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
  [`unpack_postprocess()`](https://ethan-young.github.io/multitool/reference/unpack_results.md)
  : Unpack a component of your analyzed grid
- [`condense()`](https://ethan-young.github.io/multitool/reference/condense.md)
  [`organize()`](https://ethan-young.github.io/multitool/reference/condense.md)
  : Summarize multiverse parameters
- [`compose_view()`](https://ethan-young.github.io/multitool/reference/compose_view.md)
  : Compose a single analysis-ready data frame from a results grid.

## Assess Decision Sensitivity/Robustness

Evaluate the robustness of a model output over the whole decision space,
by decision alternatives, or assess the impact of making specific
decisions.

- [`assess_robustness()`](https://ethan-young.github.io/multitool/reference/assess_robustness.md)
  : Assess the robustness of multiverse analysis results
- [`assess_decisions()`](https://ethan-young.github.io/multitool/reference/assess_decisions.md)
  : Decompose decision variance using Sobol sensitivity indices and
  variance dispersal

## Build a report

Given a set of anlzyed results, incrementally build a polished report

- [`configure_labels()`](https://ethan-young.github.io/multitool/reference/configure_labels.md)
  : Configure human-readable labels for pipeline decisions
- [`show_labels()`](https://ethan-young.github.io/multitool/reference/show_labels.md)
  : Inspect or scaffold pipeline labels
- [`add_section()`](https://ethan-young.github.io/multitool/reference/add_section.md)
  : Add a content section to a report
- [`show_section_content()`](https://ethan-young.github.io/multitool/reference/show_section_content.md)
  : Inspect one section's content and code
- [`view_real_size()`](https://ethan-young.github.io/multitool/reference/view_real_size.md)
  : Preview a figure at its true output size
- [`preview_section()`](https://ethan-young.github.io/multitool/reference/preview_section.md)
  : Preview a report section's composed layout
- [`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md)
  : Begin assembling a report document
- [`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
  : Record a section's layout for assembly
- [`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md)
  : Render an assembled document

## Data

- [`coffee_quality`](https://ethan-young.github.io/multitool/reference/coffee_quality.md)
  : Professional coffee quality ratings

## Superseded

Functions that have been replaced by new approaches that are better.
These functions still work and will stick around for awhile.

- [`create_blueprint_graph()`](https://ethan-young.github.io/multitool/reference/create_blueprint_graph.md)
  **\[superseded\]** : Create a Analysis Pipeline diagram

## Deprecated

Functions that are no longer supported and will be removed in a future
version.
