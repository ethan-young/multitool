#' Unpack the decision grid of specifications for your modeling pipeline
#'
#' @param .multi a multiverse list-column \code{tibble} produced by
#'   \code{\link{analyze_grid}}.
#' @param .how character, options are \code{"no"}, \code{"wide"}, or
#'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#'   \code{wide} unnests specifications with each specification category as a
#'   column. \code{"long"} unnests specifications and stacks them into long
#'   format, which stacks specifications into a \code{decision_type},
#'   \code{decision_set} and \code{decision_choice} columns. This is mainly
#'   useful for plotting.
#'
#' @returns the unnested specifications of the analysis grid.
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
#' the_multiverse <- analyze_grid(pipeline_grid[1:10,])
#'
#' # Reveal results of the linear model
#' the_multiverse |> unpack_specs("wide")
unpack_specs <- function(.multi, .how = "wide"){

  if(.how == "wide"){
    unpacked <-
      .multi |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models"))) |>
      dplyr::select(-dplyr::matches("(model|fn)$")) |>
      dplyr::mutate(
        dplyr::across(
          dplyr::where(is.character),
          ~stringr::str_remove_all(.x, '\\\"')
        )
      )
  }else if(.how == "long"){
    unpacked <-
      .multi |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
      ) |>
      tidyr::unnest(
        dplyr::any_of(c("subgroups","variables","filters","models")),
        names_sep = "."
      ) |>
      dplyr::select(-dplyr::matches("(model|args|standardize|perform)$")) |>
      dplyr::mutate(
        dplyr::across(
          dplyr::where(is.character),
          ~stringr::str_remove_all(.x, '\\\"')
        )
      ) |>
      tidyr::pivot_longer(
        c(dplyr::where(is.character), -decision),
        names_to = "decision_set", values_to = "decision_choice"
      ) |>
      dplyr::relocate(decision_set, decision_choice, .after = decision) |>
      tidyr::separate(
        decision_set,
        into = c("decision_type", "decision_set"),
        sep = "\\."
      )
  } else{
    unpacked <- .multi
  }

  unpacked

}

#' Unpack a component of your analyzed grid
#'
#' @param .multi a multiverse list-column \code{tibble} produced by
#'   \code{\link{analyze_grid}}.
#' @param .what the name of a list-column you would like to unpack
#' @param .which any sub-list columns you would like to unpack
#' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#'   \code{wide} unnests specifications with each specification category as a
#'   column. \code{"long"} unnests specifications and stacks them into long
#'   format, which stacks specifications into a \code{decision_type},
#'   \code{decision_set} and \code{decision_choice} columns. This is mainly
#'   useful for plotting.
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
#' the_multiverse <- analyze_grid(pipeline_grid[1:10,])
#'
#' # Reveal results of the linear model
#' the_multiverse |> unpack_results(model_fitted, model_parameters)
unpack_results <- function(.multi, .what, .which = NULL, .unpack_specs = "wide"){

  unpacked <-
    .multi |>
    unpack_specs(.unpack_specs) |>
    tidyr::unnest({{.what}})

  if(!is.null(which)){
    unpacked <-
      unpacked |>
      tidyr::unnest({{.which}})
  }

  unpacked

}

#' @describeIn unpack_results Unpack the model parameters
#' @param effect_key character, if you added parameter keys to your pipeline,
#'   you can specify if you would like filter the parameters using one of your
#'   parameter keys. This is useful when different variables are being switched
#'   out across the multiverse but represent the same effect of interest.
#' @export
unpack_model_parameters <- function(.multi, effect_key = NULL, .unpack_specs = "wide"){

  revealed <-
    .multi |>
    unpack_results(model_fitted, model_parameters, .unpack_specs = .unpack_specs)

  if(!is.null(effect_key)){
    revealed <-
      revealed |>
      dplyr::filter(stringr::str_detect(parameter_key, effect_key))
  }

  revealed |>
    dplyr::select(dplyr::where(~!is.list(.x)))

}

#' @describeIn unpack_results Unpack the model performance
#' @export
unpack_model_performance <- function(.multi, .unpack_specs = "wide"){

  revealed <-
    .multi |>
    unpack_results(
      model_fitted,
      model_performance,
      .unpack_specs = .unpack_specs
    )

  revealed |>
    dplyr::select(dplyr::where(~!is.list(.x)))

}

#' @describeIn unpack_results Unpack the model warnings
#' @export
unpack_model_warnings <- function(.multi, .unpack_specs = "wide"){

  revealed <-
    .multi |>
    unpack_results(
      model_fitted,
      model_warnings,
      .unpack_specs = .unpack_specs
    )

  revealed |>
    dplyr::select(dplyr::where(~!is.list(.x)))

}

#' @describeIn unpack_results Unpack the model messages
#' @export
unpack_model_messages <- function(.multi, .unpack_specs = "wide"){

  revealed <-
    .multi |>
    unpack_results(
      model_fitted,
      model_messages,
      .unpack_specs = .unpack_specs
    )

  revealed |>
    dplyr::select(dplyr::where(~!is.list(.x)))

}

#' @describeIn unpack_results Unpack a post-processing result
#' @export
unpack_postprocess <- function(.multi, .which, .unpack_specs = "wide"){

  revealed <-
    .multi |>
    unpack_results(
      {{.which}},
      dplyr::ends_with("output"),
      .unpack_specs = .unpack_specs
    )

  revealed |>
    dplyr::select(dplyr::where(~!is.list(.x)))

}

#' Summarize multiverse parameters
#'
#' @param .unpacked an unpacked (with \code{\link{reveal}} or
#'   \code{tidyr::unnest}) multiverse dataset.
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
#' the_multiverse <- analyze_grid(pipeline_grid[1:10,])
#'
#' # Reveal and condense
#' the_multiverse |>
#'   unpack_model_parameters() |>
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

#' @describeIn condense Sort and organize results by size and sign.
#' @param .unpacked a set of results from \code{analyze_grid} using
#'   \code{unpack_results*}
#' @param .what the column from the unpacked results you'd like to organize
#' @param .group a grouping column, usually from the specifications, that you
#'   like to sort within. This will give you sorted output by the levels of the
#'   grouping variable.
#' @param focused logical, defaults to \code{TRUE}. Return only the variable,
#'   potential group, and a variable indicating rank. Set to \code{FALSE} to
#'   retain all other columns.
#' @export
organize <- function(.unpacked, .what, .group = NULL, focused = TRUE){

  organized <-
    .unpacked |>
    dplyr::mutate(
      rank = dplyr::dense_rank({{.what}}),
      .by = {{.group}}
    )

  if(focused){
    organized <-
      organized |>
      dplyr::select(
        {{.group}},
        rank,
        {{.what}}
      )

    if(ncol(organized) > 2){
      organized <-
        organized |>
        tidyr::unite("pasted_groups", {{.group}}, remove = FALSE) |>
        dplyr::arrange(pasted_groups, rank) |>
        dplyr::select(-dplyr::any_of("pasted_groups"))
    } else{
      organized <-
        organized |>
        dplyr::arrange(rank)
    }
  }

  organized

}
