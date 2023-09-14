#' Reveal the contents of a multiverse analysis
#'
#' @param .multi a multiverse list-column \code{tibble} produced by
#'   \code{\link{run_multiverse}}.
#' @param .what the name of a list-column you would like to unpack
#' @param .which any sub-list columns you would like to unpack
#' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#'   \code{wide} unnests specifications with each specification category as a
#'   column. \code{"long"} unnests specifications and stacks them into long
#'   format, which stacks specifications into a \code{decision_set} and
#'   \code{alternatives} columns. This is mainly useful for plotting.
#'
#' @return the unnested part of the multiverse requested. This usually contains
#'   the particular estimates or statistics you would like to analyze over the
#'   decision grid specified.
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
#' # Simulate some data
#' the_data <-
#'   data.frame(
#'     id   = 1:500,
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     iv3  = rnorm(500),
#'     mod1 = rnorm(500),
#'     mod2 = rnorm(500),
#'     mod3 = rnorm(500),
#'     cov1 = rnorm(500),
#'     cov2 = rnorm(500),
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # Decision pipeline
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_model("linear_model", lm({dvs} ~ {ivs} * {mods} + cov1))
#'
#' pipeline_grid <- expand_decisions(full_pipeline)
#'
#' # Run the whole multiverse
#' the_multiverse <- run_multiverse(pipeline_grid[1:10,])
#'
#' # Reveal results of the linear model
#' the_multiverse |> reveal(model_fitted, model_parameters)
reveal <- function(.multi, .what, .which = NULL, .unpack_specs = "no"){

  which_sublist <- dplyr::enexprs(.which) |> as.character()
  which_sublist <- which_sublist != "NULL"

  unpacked <-
    .multi |>
    tidyr::unnest({{.what}})

  if(which_sublist){
    unpacked <-
      unpacked |>
      tidyr::unnest({{.which}})
  }

  if(.unpack_specs == "wide"){
    unpacked <-
      unpacked |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("variables","filters","models")))
  }

  if(.unpack_specs == "long"){
    unpacked_and_stacked <-
      unpacked |>
      dplyr::select(decision, specifications) |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("variables","filters","models"))) |>
      dplyr::select(-dplyr::any_of("model")) |>
      dplyr::rename_with(~ stringr::str_remove(.x, "_.*"), dplyr::any_of("model_meta")) |>
      tidyr::pivot_longer(-decision, names_to = "decision_set", values_to = "alternatives")

    print(unpacked_and_stacked)

    unpacked <-
      dplyr::left_join(
        unpacked_and_stacked,
        unpacked |> dplyr::select(-specifications),
        dplyr::join_by(decision == decision)
      )

  }

  unpacked
}

#' Reveal the model parameters of a multiverse analysis
#'
#' @param .multi a multiverse list-column \code{tibble} produced by
#'   \code{\link{run_multiverse}}.
#' @param parameter_key character, if you added parameter keys to your pipeline,
#'   you can specify if you would like filter the parameters using one of your
#'   parameter keys. This is useful when different variables are being switched
#'   out across the multiverse but represent the same effect of interest.
#' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#'   \code{wide} unnests specifications with each specification category as a
#'   column. \code{"long"} unnests specifications and stacks them into long
#'   format, which stacks specifications into a \code{decision_set} and
#'   \code{alternatives} columns. This is mainly useful for plotting.
#'
#' @return the unnested model paramerters from the multiverse.
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
#' # Simulate some data
#' the_data <-
#'   data.frame(
#'     id   = 1:500,
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     iv3  = rnorm(500),
#'     mod1 = rnorm(500),
#'     mod2 = rnorm(500),
#'     mod3 = rnorm(500),
#'     cov1 = rnorm(500),
#'     cov2 = rnorm(500),
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # Decision pipeline
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_model("linear_model", lm({dvs} ~ {ivs} * {mods} + cov1))
#'
#' pipeline_grid <- expand_decisions(full_pipeline)
#'
#' # Run the whole multiverse
#' the_multiverse <- run_multiverse(pipeline_grid[1:10,])
#'
#' # Reveal results of the linear model
#' the_multiverse |>
#'   reveal_model_parameters()
reveal_model_parameters <- function(.multi, parameter_key = NULL, .unpack_specs = "no"){
  unpacked <-
    .multi |>
    tidyr::unnest(model_fitted) |>
    tidyr::unnest(model_parameters)

  if(!is.null(parameter_key)){
    unpacked <-
      unpacked |>
      dplyr::filter(parameter_key == parameter_key)
  }

  if(.unpack_specs == "wide"){
    unpacked <-
      unpacked |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("variables","filters","models")))
  }

  if(.unpack_specs == "long"){
    unpacked_and_stacked <-
      unpacked |>
      dplyr::select(decision, specifications) |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("variables","filters","models"))) |>
      dplyr::select(-model) |>
      dplyr::rename(model = model_meta) |>
      tidyr::pivot_longer(
        -decision,
        names_to = "decision_set",
        values_to = "alternatives"
      )

    unpacked <-
      dplyr::left_join(
        unpacked_and_stacked,
        unpacked |> dplyr::select(-specifications),
        dplyr::join_by(decision == decision)
      )

  }

  unpacked
}

#' Reveal the model performance/fit indices from a multiverse analysis
#'
#' @param .multi a multiverse list-column \code{tibble} produced by
#'   \code{\link{run_multiverse}}.
#' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#'   \code{wide} unnests specifications with each specification category as a
#'   column. \code{"long"} unnests specifications and stacks them into long
#'   format, which stacks specifications into a \code{decision_set} and
#'   \code{alternatives} columns. This is mainly useful for plotting.
#'
#' @return the unnested model performance/fit indices from a multiverse
#'   analysis.
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
#' # Simulate some data
#' the_data <-
#'   data.frame(
#'     id   = 1:500,
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     iv3  = rnorm(500),
#'     mod1 = rnorm(500),
#'     mod2 = rnorm(500),
#'     mod3 = rnorm(500),
#'     cov1 = rnorm(500),
#'     cov2 = rnorm(500),
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # Decision pipeline
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_model("linear_model", lm({dvs} ~ {ivs} * {mods} + cov1))
#'
#' pipeline_grid <- expand_decisions(full_pipeline)
#'
#' # Run the whole multiverse
#' the_multiverse <- run_multiverse(pipeline_grid[1:10,])
#'
#' # Reveal results of the linear model
#' the_multiverse |>
#'   reveal_model_performance()
reveal_model_performance <- function(.multi, .unpack_specs = "no"){
  unpacked <-
    .multi |>
    tidyr::unnest(model_fitted) |>
    tidyr::unnest(model_performance)

  if(.unpack_specs == "wide"){
    unpacked <-
      unpacked |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::everything())
  }

  if(.unpack_specs == "long"){
    unpacked_and_stacked <-
      unpacked |>
      dplyr::select(decision, specifications) |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("variables","filters","models"))) |>
      dplyr::select(-model) |>
      dplyr::rename(model = model_meta) |>
      tidyr::pivot_longer(
        -decision,
        names_to = "decision_set",
        values_to = "alternatives"
      )

    unpacked <-
      dplyr::left_join(
        unpacked_and_stacked,
        unpacked |> dplyr::select(-specifications),
        dplyr::join_by(decision == decision)
      )
  }

  unpacked
}

#' Reveal any warnings about your models during a multiverse analysis
#'
#' @param .multi a multiverse list-column \code{tibble} produced by
#'   \code{\link{run_multiverse}}.
#' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#'   \code{wide} unnests specifications with each specification category as a
#'   column. \code{"long"} unnests specifications and stacks them into long
#'   format, which stacks specifications into a \code{decision_set} and
#'   \code{alternatives} columns. This is mainly useful for plotting.
#'
#' @return the unnested model warnings captured during analysis
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
#' # Simulate some data
#' the_data <-
#'   data.frame(
#'     id   = 1:500,
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     iv3  = rnorm(500),
#'     mod1 = rnorm(500),
#'     mod2 = rnorm(500),
#'     mod3 = rnorm(500),
#'     cov1 = rnorm(500),
#'     cov2 = rnorm(500),
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # Decision pipeline
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_model("linear_model", lm({dvs} ~ {ivs} * {mods} + cov1))
#'
#' pipeline_grid <- expand_decisions(full_pipeline)
#'
#' # Run the whole multiverse
#' the_multiverse <- run_multiverse(pipeline_grid[1:10,])
#'
#' # Reveal results of the linear model
#' the_multiverse |>
#'   reveal_model_warnings()
reveal_model_warnings <- function(.multi, .unpack_specs = "no"){
  unpacked <-
    .multi |>
    tidyr::unnest(model_fitted) |>
    tidyr::unnest(model_warnings)

  if(.unpack_specs == "wide"){
    unpacked <-
      unpacked |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::everything())
  }

  if(.unpack_specs == "long"){
    unpacked_and_stacked <-
      unpacked |>
      dplyr::select(decision, specifications) |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("variables","filters","models"))) |>
      dplyr::select(-model) |>
      dplyr::rename(model = model_meta) |>
      tidyr::pivot_longer(
        -decision,
        names_to = "decision_set",
        values_to = "alternatives"
      )

    unpacked <-
      dplyr::left_join(
        unpacked_and_stacked,
        unpacked |> dplyr::select(-specifications),
        dplyr::join_by(decision == decision)
      )

  }

  unpacked
}

#' Reveal any messages about your models during a multiverse analysis
#'
#' @param .multi a multiverse list-column \code{tibble} produced by
#'   \code{\link{run_multiverse}}.
#' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#'   \code{wide} unnests specifications with each specification category as a
#'   column. \code{"long"} unnests specifications and stacks them into long
#'   format, which stacks specifications into a \code{decision_set} and
#'   \code{alternatives} columns. This is mainly useful for plotting.
#'
#' @return the unnested model messages captured during analysis.
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
#' # Simulate some data
#' the_data <-
#'   data.frame(
#'     id   = 1:500,
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     iv3  = rnorm(500),
#'     mod1 = rnorm(500),
#'     mod2 = rnorm(500),
#'     mod3 = rnorm(500),
#'     cov1 = rnorm(500),
#'     cov2 = rnorm(500),
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # Decision pipeline
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_model("linear_model", lm({dvs} ~ {ivs} * {mods} + cov1))
#'
#' pipeline_grid <- expand_decisions(full_pipeline)
#'
#' # Run the whole multiverse
#' the_multiverse <- run_multiverse(pipeline_grid[1:10,])
#'
#' # Reveal results of the linear model
#' the_multiverse |>
#'   reveal_model_messages()
reveal_model_messages <- function(.multi, .unpack_specs = "no"){
  unpacked <-
    .multi |>
    tidyr::unnest(model_fitted) |>
    tidyr::unnest(model_messages)

  if(.unpack_specs == "wide"){
    unpacked <-
      unpacked |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::everything())
  }

  if(.unpack_specs == "long"){
    unpacked_and_stacked <-
      unpacked |>
      dplyr::select(decision, specifications) |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("variables","filters","models"))) |>
      dplyr::select(-model) |>
      dplyr::rename(model = model_meta) |>
      tidyr::pivot_longer(
        -decision,
        names_to = "decision_set",
        values_to = "alternatives"
      )

    unpacked <-
      dplyr::left_join(
        unpacked_and_stacked,
        unpacked |> dplyr::select(-specifications),
        dplyr::join_by(decision == decision)
      )

  }

  unpacked
}

#' Reveal a set of summary statistics from a multiverse analysis
#'
#' @param .descriptives a descriptive multiverse list-column \code{tibble}
#'   produced by \code{\link{run_descriptives}}.
#' @param .which the specific name of the summary statistics
#' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#'   \code{wide} unnests specifications with each specification category as a
#'   column. \code{"long"} unnests specifications and stacks them into long
#'   format, which stacks specifications into a \code{decision_set} and
#'   \code{alternatives} columns. This is mainly useful for plotting.
#'
#' @return an unnested set of summary statistics per decision from the
#'   multiverse.
#'
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
#' # create some data
#' the_data <-
#'   data.frame(
#'     id  = 1:500,
#'     iv1 = rnorm(500),
#'     iv2 = rnorm(500),
#'     iv3 = rnorm(500),
#'     mod = rnorm(500),
#'     dv1 = rnorm(500),
#'     dv2 = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # create a pipeline blueprint
#' full_pipeline <-
#'   the_data |>
#'   add_filters(
#'     include1 == 0,
#'     include2 != 3,
#'     include2 != 2,
#'     include3 > -2.5,
#'     include3 < 2.5,
#'     between(include3, -2.5, 2.5)
#'   ) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_correlations("predictor correlations", starts_with("iv")) |>
#'   add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#'   add_reliabilities("vio_scale", starts_with("iv")) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' my_descriptives <- run_descriptives(full_pipeline)
#'
#' my_descriptives |>
#'   reveal_summary_stats(iv_stats)
reveal_summary_stats <- function(.descriptives, .which, .unpack_specs = "no"){
  which_sublist <- dplyr::enexprs(.which) |> as.character()
  which_sublist <- which_sublist != "NULL"

  unpacked <-
    .descriptives |>
    tidyr::unnest(summary_stats_computed) |>
    tidyr::unnest({{.which}})

  if(.unpack_specs == "wide"){
    unpacked <-
      unpacked |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("variables","filters","models")))
  }

  if(.unpack_specs == "long"){
    unpacked_and_stacked <-
      unpacked |>
      dplyr::select(decision, specifications) |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("variables","filters","models"))) |>
      dplyr::select(-dplyr::any_of("model")) |>
      dplyr::rename_with(~ stringr::str_remove(.x, "_.*"), dplyr::any_of("model_meta")) |>
      tidyr::pivot_longer(-decision, names_to = "decision_set", values_to = "alternatives")

    unpacked <-
      dplyr::left_join(
        unpacked_and_stacked,
        unpacked |> dplyr::select(-specifications),
        dplyr::join_by(decision == decision)
      )

  }

  unpacked
}

#' Reveal a set of multiverse correlations
#'
#' @param .descriptives a descriptive multiverse list-column \code{tibble}
#'   produced by \code{\link{run_descriptives}}.
#' @param .which the specific name of the correlations requested
#' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#'   \code{wide} unnests specifications with each specification category as a
#'   column. \code{"long"} unnests specifications and stacks them into long
#'   format, which stacks specifications into a \code{decision_set} and
#'   \code{alternatives} columns. This is mainly useful for plotting.
#'
#' @return an unnested set of correlations per decision from the
#'   multiverse.
#'
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
#' # create some data
#' the_data <-
#'   data.frame(
#'     id  = 1:500,
#'     iv1 = rnorm(500),
#'     iv2 = rnorm(500),
#'     iv3 = rnorm(500),
#'     mod = rnorm(500),
#'     dv1 = rnorm(500),
#'     dv2 = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # create a pipeline blueprint
#' full_pipeline <-
#'   the_data |>
#'   add_filters(
#'     include1 == 0,
#'     include2 != 3,
#'     include2 != 2,
#'     include3 > -2.5,
#'     include3 < 2.5,
#'     between(include3, -2.5, 2.5)
#'   ) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_correlations("predictors", starts_with("iv")) |>
#'   add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#'   add_reliabilities("vio_scale", starts_with("iv")) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' my_descriptives <- run_descriptives(full_pipeline)
#'
#' my_descriptives |>
#'   reveal_corrs(predictors_rs)
reveal_corrs <- function(.descriptives, .which, .unpack_specs = "no"){
  which_sublist <- dplyr::enexprs(.which) |> as.character()
  which_sublist <- which_sublist != "NULL"

  unpacked <-
    .descriptives |>
    tidyr::unnest(corrs_computed) |>
    tidyr::unnest({{.which}})

  if(.unpack_specs == "wide"){
    unpacked <-
      unpacked |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("variables","filters","models")))
  }

  if(.unpack_specs == "long"){
    unpacked_and_stacked <-
      unpacked |>
      dplyr::select(decision, specifications) |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("variables","filters","models"))) |>
      dplyr::select(-dplyr::any_of("model")) |>
      dplyr::rename_with(~ stringr::str_remove(.x, "_.*"), dplyr::any_of("model_meta")) |>
      tidyr::pivot_longer(-decision, names_to = "decision_set", values_to = "alternatives")

    unpacked <-
      dplyr::left_join(
        unpacked_and_stacked,
        unpacked |> dplyr::select(-specifications),
        dplyr::join_by(decision == decision)
      )

  }

  unpacked
}

#' Reveal a set of multiverse cronbach's alpha statistics
#'
#' @param .descriptives a descriptive multiverse list-column \code{tibble}
#'   produced by \code{\link{run_descriptives}}.
#' @param .which the specific name of the alphas
#' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#'   \code{wide} unnests specifications with each specification category as a
#'   column. \code{"long"} unnests specifications and stacks them into long
#'   format, which stacks specifications into a \code{decision_set} and
#'   \code{alternatives} columns. This is mainly useful for plotting.
#'
#' @return an unnested set of correlations per decision from the multiverse.
#'
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
#' # create some data
#' the_data <-
#'   data.frame(
#'     id  = 1:500,
#'     iv1 = rnorm(500),
#'     iv2 = rnorm(500),
#'     iv3 = rnorm(500),
#'     mod = rnorm(500),
#'     dv1 = rnorm(500),
#'     dv2 = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # create a pipeline blueprint
#' full_pipeline <-
#'   the_data |>
#'   add_filters(
#'     include1 == 0,
#'     include2 != 3,
#'     include2 != 2,
#'     include3 > -2.5,
#'     include3 < 2.5,
#'     between(include3, -2.5, 2.5)
#'   ) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_correlations("predictor correlations", starts_with("iv")) |>
#'   add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#'   add_reliabilities("vio_scale", starts_with("iv")) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' my_descriptives <- run_descriptives(full_pipeline)
#'
#' my_descriptives |>
#'   reveal_reliabilities(vio_scale_alpha)
reveal_reliabilities <- function(.descriptives, .which, .unpack_specs = "no"){
  which_sublist <- dplyr::enexprs(.which) |> as.character()
  which_sublist <- which_sublist != "NULL"

  unpacked <-
    .descriptives |>
    tidyr::unnest(reliabilities_computed) |>
    tidyr::unnest({{.which}})

  if(.unpack_specs == "wide"){
    unpacked <-
      unpacked |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("variables","filters","models")))
  }

  if(.unpack_specs == "long"){
    unpacked_and_stacked <-
      unpacked |>
      dplyr::select(decision, specifications) |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("variables","filters","models"))) |>
      dplyr::select(-dplyr::any_of("model")) |>
      dplyr::rename_with(~ stringr::str_remove(.x, "_.*"), dplyr::any_of("model_meta")) |>
      tidyr::pivot_longer(-decision, names_to = "decision_set", values_to = "alternatives")

    unpacked <-
      dplyr::left_join(
        unpacked_and_stacked,
        unpacked |> dplyr::select(-specifications),
        dplyr::join_by(decision == decision)
      )

  }

  unpacked
}

#' Summarize multiverse parameters
#'
#' @param .unpacked an unpacked (with \code{\link{reveal}} or
#'   \code{\link{unnest}}) multiverse dataset.
#' @param .what a specific column to summarize. This could be a model estimate,
#'   a summary statistic, correlation, or any other estimate computed over the
#'   multiverse.
#' @param .how a named list. The list should contain summary functions (e.g.,
#'   mean or median) the user would like to compute over the individual
#'   estimates from the multiverse
#' @param .group an optional variable to group the results. This argument is
#'   passed directly to the \code{.by} argument used in \code{dplyr::across}
#' @param list_cols logical, whether to create list columns for the raw values
#'   of any summarized columns. Useful for creating visualizations and tables.
#'   Default is TRUE.
#'
#' @return a summarized \code{tibble} containing a column for each summary
#'   method from \code{.how}
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
#' # Simulate some data
#' the_data <-
#'   data.frame(
#'     id   = 1:500,
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     iv3  = rnorm(500),
#'     mod1 = rnorm(500),
#'     mod2 = rnorm(500),
#'     mod3 = rnorm(500),
#'     cov1 = rnorm(500),
#'     cov2 = rnorm(500),
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # Decision pipeline
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_model("linear_model", lm({dvs} ~ {ivs} * {mods} + cov1))
#'
#' pipeline_grid <- expand_decisions(full_pipeline)
#'
#' # Run the whole multiverse
#' the_multiverse <- run_multiverse(pipeline_grid[1:10,])
#'
#' # Reveal and condense
#' the_multiverse |>
#'   reveal_model_parameters() |>
#'   filter(str_detect(parameter, "iv")) |>
#'   condense(coefficient, list(mean = mean, median = median))
condense <- function(.unpacked, .what, .how, .group = NULL, list_cols = TRUE){

  if(list_cols){
    .unpacked |>
      dplyr::summarize(
        dplyr::across(
          .cols = {{.what}},
          .fns = {{.how}},
          .names = "{.col}_{.fn}"
        ),
        dplyr::across(
          .cols = {{.what}},
          .fns = list,
          .names = "{.col}_list"
        ),
        .by = {{.group}}
      )
  } else{
    .unpacked |>
      dplyr::summarize(
        dplyr::across(
          .cols = {{.what}},
          .fns = {{.how}},
          .names = "{.col}_{.fn}"
        ),
        .by = {{.group}}
      )
  }
}

