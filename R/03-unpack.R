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

  if (!rlang::quo_is_null(rlang::enquo(.which))) {
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
      .unpack_specs = .unpack_specs
    )

  if (any(stringr::str_detect(names(revealed), "output$"))) {
    revealed <-
      revealed |>
      tidyr::unnest(dplyr::ends_with("output"))
  }

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

#' Compose a single analysis-ready data frame from a results grid.
#'
#' @description
#' `compose_view()` assembles one tibble from selected components of a
#' results object. You name the result components you want (model
#' parameters, performance, post-processing output, pipeline code, timing
#' logs), and `compose_view()` unpacks each one and left-joins them by
#' `decision` into a single frame ready for plotting or tabling.
#'
#' Its job is deliberately narrow: it reconciles components that live at
#' different grains into one frame and nothing else. It performs no
#' transformation, summarizing, or reshaping of the results. Any such work is
#' left to the caller, either with downstream `dplyr` on the returned frame or
#' with per-layer `data` transformations at plot time.
#'
#' @param .multi a multiverse results object produced by
#'   \code{\link{analyze_grid}} (or \code{\link{analyze_grid_parallel}}).
#' @param ... result components to compose. Supply the bare column names of the
#'   components shipped by `analyze_grid()`, for example `model_parameters`,
#'   `model_performance`, `pipeline_code`, `timing_logs`, or the name of a
#'   post-processing output column (e.g. `aov_fitted`). Arguments may be named
#'   to control the prefix applied to that component's columns (see Details);
#'   unnamed arguments receive an automatic prefix.
#'
#' @details
#' The decision specifications are always included as the spine of the returned
#' frame, so you never need to request them explicitly.
#'
#' \strong{Column prefixing.} To keep columns from different components from
#' colliding, every value column is prefixed with its component's name; the
#' join key `decision` and the specification columns are left unprefixed so
#' they remain shared across components. When an argument is named, that name
#' is used as the prefix. When an argument is unnamed, a prefix is assigned
#' automatically:
#' \itemize{
#'   \item `model_parameters` becomes `params_`
#'   \item `model_performance` becomes `perform_`
#'   \item `pipeline_code` becomes `code_`
#'   \item `timing_logs` becomes `timing_`
#'   \item a post-processing column has its `_fitted` suffix removed
#'     (e.g. `aov_fitted` becomes `aov_`)
#' }
#'
#' \strong{Grain and broadcasting.} Components differ in granularity. Model
#' parameters have one row per model term, while performance, timing, and
#' pipeline code each have one row per decision. Because components are joined
#' by `decision`, coarser components are broadcast across the rows of the
#' finest component requested. For example, composing `model_parameters` with
#' `model_performance` repeats each decision's performance values across that
#' decision's term rows. This broadcasting is intended: it produces a frame
#' where, for instance, a model fit statistic is available on every term row
#' for annotation. Collapsing back to a coarser grain (e.g. one label per
#' decision) is left to the caller at the point of use.
#'
#' @return A single \code{\link[tibble]{tibble}} containing the decision
#'   specifications and the requested components, joined by `decision`. The row
#'   grain matches the finest component requested, with coarser components
#'   broadcast across it.
#'
#' @seealso \code{\link{unpack_results}} and the `unpack_model_*` functions for
#'   extracting a single component; \code{\link{unpack_specs}} for the
#'   specification grid.
#'
#' @export
compose_view <- function(.multi, ...) {

  requested_frames <- purrr::map_chr(rlang::enquos(...), rlang::as_name)
  frames <- c("specs", requested_frames)
  frame_names <- c("specs", names(requested_frames))

  frame_names <-
    purrr::map2_chr(frames, frame_names, function(frame, nm){

      if(nm == "specs"){auto_nm <- "specs"}
      else if(nm == '' & frame == "model_parameters"){auto_nm <- "params"}
      else if(nm == '' & frame == "model_performance"){auto_nm <- "perform"}
      else if(nm == '' & frame == "pipeline_code"){auto_nm <- "code"}
      else if(nm == '' & frame == "timing_logs"){auto_nm <- "timing"}
      else if(nm == ''){auto_nm <- stringr::str_remove(frame, "_fitted$")}
      else{auto_nm <- nm}

      auto_nm

    })

  unpacked_frames <-
    purrr::map2(frames, frame_names, function(frame, nm) {
      if (frame == "specs") {
        .multi |> unpack_specs() |> dplyr::select(-dplyr::where(is.list))
      } else if (frame == "model_parameters") {
        .multi |>
          unpack_model_parameters(.unpack_specs = "no") |>
          dplyr::rename_with(~paste0(nm, "_", .x), -decision)
      } else if (frame == "model_performance") {
        .multi |>
          unpack_model_performance(.unpack_specs = "no") |>
          dplyr::rename_with(~paste0(nm, "_", .x), -decision)
      } else if(frame %in% c("pipeline_code", "timing_logs")){
        .multi |>
          dplyr::select(decision, dplyr::all_of(frame)) |>
          tidyr::unnest(dplyr::everything()) |>
          dplyr::rename_with(~paste0(nm, "_", .x), -decision)
      } else {
        .multi |>
          unpack_postprocess({{frame}}, .unpack_specs = "no") |>
          dplyr::rename_with(~paste0(nm, "_", .x), -decision)
      }
    })

  purrr::reduce(
    unpacked_frames,
    dplyr::left_join,
    by = "decision"
  )
}
