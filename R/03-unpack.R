#' Unpack the decision grid of specifications for your modeling pipeline
#'
#' @param .multi a multiverse list-column \code{tibble} produced by
#'   \code{\link{analyze_grid}}.
#' @param .how how to present the specifications: \code{"wide"} (default)
#'   unnests them with one column per decision; \code{"long"} stacks them
#'   into \code{decision_type}, \code{decision_set}, and
#'   \code{decision_choice} columns, which is mainly useful for plotting;
#'   \code{"no"} keeps them in the nested \code{specifications} column;
#'   \code{"drop"} removes them.
#'
#' @returns the results with specifications presented as requested. Steps
#'   that are the same in every decision (preprocessing, conditions,
#'   postprocessing) are not specifications and are left out.
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
#' pipeline_grid <- expand_pipeline(full_pipeline)
#'
#' # Run the whole multiverse
#' the_multiverse <- analyze_grid(pipeline_grid[1:10,])
#'
#' # Reveal results of the linear model
#' the_multiverse |> unpack_specs("wide")
unpack_specs <- function(.multi, .how = c("wide", "long", "no", "drop")){
  .how <- rlang::arg_match(.how)

  if(.how == "no"){
    return(.multi)
  }

  if(.how == "drop"){
    return(dplyr::select(.multi, -specifications))
  }

  specs <-
    .multi |>
    tidyr::unnest(specifications) |>
    # steps that are the same in every decision aren't specifications
    dplyr::select(
      -dplyr::any_of(
        c("preprocess", "conditions", "postprocess", "corrs", "summary_stats", "reliabilities")
      )
    )

  # a missing subgroup value is stored as bare NA; keep it missing, not the text "NA"
  if("subgroups" %in% names(specs)){
    specs <-
      specs |>
      dplyr::mutate(
        subgroups = purrr::map(subgroups, \(subgroup_values){
          dplyr::mutate(
            subgroup_values,
            dplyr::across(dplyr::everything(), \(value) dplyr::na_if(value, "NA"))
          )
        })
      )
  }

  if(.how == "wide"){
    specs |>
      tidyr::unnest(dplyr::any_of(c("subgroups", "variables", "filters", "models"))) |>
      dplyr::select(-dplyr::matches("(model|fn)$")) |>
      dplyr::mutate(
        dplyr::across(dplyr::where(is.character), ~stringr::str_remove_all(.x, '\\\"'))
      )
  } else{
    specs |>
      tidyr::unnest(
        dplyr::any_of(c("subgroups", "variables", "filters", "models")),
        names_sep = "."
      ) |>
      dplyr::select(-dplyr::matches("(model|fn|args|standardize|perform)$")) |>
      dplyr::mutate(
        dplyr::across(dplyr::where(is.character), ~stringr::str_remove_all(.x, '\\\"'))
      ) |>
      tidyr::pivot_longer(
        c(dplyr::where(is.character), -decision, -dplyr::any_of("status")),
        names_to = "decision_set",
        values_to = "decision_choice"
      ) |>
      dplyr::relocate(decision_set, decision_choice, .after = decision) |>
      tidyr::separate(
        decision_set,
        into = c("decision_type", "decision_set"),
        sep = "\\."
      )
  }
}

#' Unpack a component of your analyzed grid
#'
#' @param .multi a multiverse list-column \code{tibble} produced by
#'   \code{\link{analyze_grid}}.
#' @param .what the results column to unpack, such as \code{model_fitted} or a
#'   postprocessing column such as \code{anova_fitted}.
#' @param .which for \code{unpack_results()}: an optional column inside
#'   \code{.what} to unpack further, such as \code{model_parameters}, or a
#'   tidyselect helper. For \code{unpack_postprocess()}: the postprocessing
#'   column to unpack, such as \code{anova_fitted} (the step's name without
#'   \code{_fitted} also works). If \code{NULL}, the first one is unpacked and
#'   the others are listed in a message.
#' @param .unpack_specs how to present the specifications: \code{"wide"}
#'   (default), \code{"long"}, \code{"no"}, or \code{"drop"}. See
#'   \code{\link{unpack_specs}}.
#' @param .include_unfinished logical, \code{FALSE} by default. Decisions that
#'   were skipped, halted, or errored before producing \code{.what} have no
#'   results to unpack. If \code{FALSE}, they are left out and a message reports
#'   how many, by status. If \code{TRUE}, they are kept as rows with missing
#'   results; summaries of such output should drop or handle the missing values.
#'
#' @return a \code{tibble} with \code{decision}, \code{status}, the
#'   specifications as requested by \code{.unpack_specs}, and the requested
#'   output. Nothing else is returned; use \code{\link{unpack_logs}} for
#'   information about how each decision ran and \code{\link{show_code}} for its
#'   code.
#'
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
#' pipeline_grid <- expand_pipeline(full_pipeline)
#'
#' # Run the whole multiverse
#' the_multiverse <- analyze_grid(pipeline_grid[1:10,])
#'
#' # Reveal results of the linear model
#' the_multiverse |> unpack_results(model_fitted, model_parameters)
unpack_results <-
  function(
    .multi,
    .what,
    .which = NULL,
    .unpack_specs = "wide",
    .include_unfinished = FALSE
  ){
    what_name <- rlang::as_name(rlang::enquo(.what))

    if(!what_name %in% names(.multi)){
      rlang::abort(
        c(
          glue::glue("No decision has `{what_name}`."),
          i = "Decisions that were skipped, halted, or errored have no results; check `status`."
        )
      )
    }

    # decisions with nothing to unpack (skipped, halted, or errored before this output)
    unfinished <-
      .multi |>
      dplyr::filter(purrr::map_lgl(.data[[what_name]], is.null))

    if(!.include_unfinished && nrow(unfinished) > 0){
      status_counts <-
        if("status" %in% names(unfinished)){
          unfinished |>
            dplyr::count(status) |>
            glue::glue_data("{n} {status}") |>
            stringr::str_flatten_comma()
        } else{
          "status not recorded"
        }

      rlang::inform(
        c(
          glue::glue(
            "{nrow(unfinished)} decision(s) have no `{what_name}` ",
            "and were left out ({status_counts})."
          ),
          i = "Keep them with `.include_unfinished = TRUE`; see why with `unpack_logs()`."
        )
      )
    }

    specs <- unpack_specs(.multi, .unpack_specs)

    # whatever unpack_specs() added or kept: wide or long columns, the nested column, or nothing
    spec_columns <- setdiff(names(specs), setdiff(names(.multi), "specifications"))

    unpacked <-
      specs |>
      tidyr::unnest({{ .what }}, keep_empty = .include_unfinished)

    output_columns <- setdiff(names(unpacked), names(specs))

    if(!rlang::quo_is_null(rlang::enquo(.which))){
      before_which <- names(unpacked)

      unpacked <-
        unpacked |>
        tidyr::unnest({{ .which }}, keep_empty = .include_unfinished)

      output_columns <- setdiff(names(unpacked), before_which)
    }

    unpacked |>
      dplyr::select(
        decision,
        dplyr::any_of("status"),
        dplyr::all_of(spec_columns),
        dplyr::all_of(output_columns)
      )
  }

#' @describeIn unpack_results Unpack the model parameters
#' @param effect_key character, optional. If your pipeline has parameter keys
#'   (see \code{\link{add_parameter_keys}}), keep only the parameters matching
#'   this key. This is useful when the variables change across decisions but
#'   represent the same effect of interest.
#' @export
unpack_model_parameters <-
  function(.multi, effect_key = NULL, .unpack_specs = "wide", .include_unfinished = FALSE){
    revealed <-
      unpack_results(
        .multi,
        model_fitted,
        model_parameters,
        .unpack_specs = .unpack_specs,
        .include_unfinished = .include_unfinished
      )

    if(!is.null(effect_key)){

      if(!"parameter_key" %in% names(revealed)){
        rlang::abort(
          c(
            "`effect_key` needs parameter keys, and these results have none.",
            i = "Add them to the pipeline with `add_parameter_keys()`."
          )
        )
      }

      revealed <-
        revealed |>
        dplyr::filter(stringr::str_detect(parameter_key, effect_key))
    }

    revealed

  }

#' @describeIn unpack_results Unpack the model performance
#' @export
unpack_model_performance <-
  function(.multi, .unpack_specs = "wide", .include_unfinished = FALSE){
    unpack_results(
      .multi,
      model_fitted,
      model_performance,
      .unpack_specs = .unpack_specs,
      .include_unfinished = .include_unfinished
    )
  }

#' @describeIn unpack_results Unpack the model warnings
#' @export
unpack_model_warnings <-
  function(.multi, .unpack_specs = "wide", .include_unfinished = FALSE){
    unpack_results(
      .multi,
      model_fitted,
      model_warnings,
      .unpack_specs = .unpack_specs,
      .include_unfinished = .include_unfinished
    )
  }

#' @describeIn unpack_results Unpack the model messages
#' @export
unpack_model_messages <-
  function(.multi, .unpack_specs = "wide", .include_unfinished = FALSE){
    unpack_results(
      .multi,
      model_fitted,
      model_messages,
      .unpack_specs = .unpack_specs,
      .include_unfinished = .include_unfinished
    )
  }

#' @describeIn unpack_results Unpack a postprocessing step's output. Choose
#'   the step with \code{.which}, using the name given in the pipeline.
#' @export
unpack_postprocess <-
  function(.multi, .which = NULL, .unpack_specs = "wide", .include_unfinished = FALSE){
    available <-
      names(.multi)[stringr::str_ends(names(.multi), "_fitted") & names(.multi) != "model_fitted"] |>
      stringr::str_remove("_fitted$")

    if(length(available) == 0){
      rlang::abort("These results have no postprocessing steps.")
    }

    available_columns <- paste0(available, "_fitted")

    chosen <-
      if(rlang::quo_is_null(rlang::enquo(.which))){
        available[1]
      } else{
        rlang::as_name(rlang::enquo(.which)) |> stringr::str_remove("_fitted$")
      }

    if(!chosen %in% available){

      rlang::abort(
        c(
          glue::glue("No postprocessing step `{chosen}`."),
          i = glue::glue("Available: {stringr::str_flatten_comma(available_columns)}")
        )
      )
    }

    if(rlang::quo_is_null(rlang::enquo(.which)) && length(available) > 1){
      rlang::inform(
        glue::glue(
          "Unpacking `{chosen}_fitted`. Also available: ",
          "{stringr::str_flatten_comma(available_columns[-1])}. ",
          "Choose one with `.which`."
        )
      )
    }

    .multi |>
      unpack_results(
        !!rlang::sym(paste0(chosen, "_fitted")),
        dplyr::ends_with("output"),
        .unpack_specs = .unpack_specs,
        .include_unfinished = .include_unfinished
      )
  }

#' Unpack the logs of how each decision ran
#'
#' Collects the record of every decision's run into one table with a row per
#' decision: its status, where and why it stopped, how long it took, how many
#' rows reached the model, and the warnings and messages from each step. Every
#' decision is included, whether it completed, was skipped, halted, or
#' errored, which makes this the table to check when validating or debugging
#' a run.
#'
#' @param .multi a results object produced by \code{\link{analyze_grid}}.
#' @param .which which logs to include: any of \code{"run"} (the failed step,
#'   its message, and timing), \code{"data"} (rows reaching the model and the
#'   data steps' warnings and messages), \code{"model"} (the model's warnings
#'   and messages), and \code{"postprocess"} (each postprocessing step's
#'   warnings and messages). Defaults to all four.
#' @param .unpack_specs how to present the specifications: \code{"wide"}
#'   (default), \code{"long"}, \code{"no"}, or \code{"drop"}. See
#'   \code{\link{unpack_specs}}.
#'
#' @return a \code{tibble} with \code{decision}, \code{status}, the
#'   specifications as requested, and the requested logs. Several warnings or
#'   messages from one step are joined into one value, separated by
#'   \code{"; "}. Steps that produced none, or never ran, are \code{NA}.
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#'
#' the_data <-
#'   data.frame(
#'     x  = rnorm(50),
#'     y1 = rnorm(50),
#'     y2 = 5
#'   )
#'
#' the_results <-
#'   the_data |>
#'   add_variables("dvs", y1, y2) |>
#'   add_condition("dv varies", with(var({dvs}) > 0), on_fail = "skip") |>
#'   add_model("linear", lm({dvs} ~ x)) |>
#'   expand_pipeline() |>
#'   analyze_grid()
#'
#' # one row per decision, including the skipped one
#' the_results |> unpack_logs()
#'
#' # only where and why each decision stopped
#' the_results |> unpack_logs(.which = "run", .unpack_specs = "drop")
unpack_logs <-
  function(
    .multi,
    .which = c("run", "data", "model", "postprocess"),
    .unpack_specs = "wide"
  ){
    .which <- rlang::arg_match(.which, multiple = TRUE)

    # several log entries become one value; none become NA
    collapse_log <- \(log){
      entries <- if(is.null(log)) character(0) else purrr::discard(log[[1]], is.na)
      if(length(entries) == 0) NA_character_ else stringr::str_flatten(entries, "; ")
    }

    log_frames <- list()

    if("run" %in% .which && "run_logs" %in% names(.multi)){
      log_frames$run <-
        .multi |>
        dplyr::select(decision, run_logs) |>
        tidyr::unnest(run_logs)
    }

    if("data" %in% .which && "data_logs" %in% names(.multi)){
      log_frames$data <-
        .multi |>
        dplyr::select(decision, data_logs) |>
        tidyr::unnest(data_logs, keep_empty = TRUE) |>
        dplyr::mutate(
          dplyr::across(
            c(data_warnings, data_messages),
            \(logs) purrr::map_chr(logs, collapse_log)
          )
        )
    }

    # the model and each postprocessing step store their logs the same way
    fitted_columns <- names(.multi)[stringr::str_ends(names(.multi), "_fitted")]

    if(!"model" %in% .which){
      fitted_columns <- setdiff(fitted_columns, "model_fitted")
    }

    if(!"postprocess" %in% .which){
      fitted_columns <- intersect(fitted_columns, "model_fitted")
    }

    fitted_logs <-
      purrr::map(fitted_columns, \(column){
        step <- stringr::str_remove(column, "_fitted$")
        type <- if(column == "model_fitted") "model" else "postprocess"

        warnings_column <- paste0(type, "_warnings")
        messages_column <- paste0(type, "_messages")

        tibble::tibble(
          decision = .multi$decision,
          "{step}_warnings" :=
            purrr::map_chr(.multi[[column]], \(fitted) collapse_log(fitted[[warnings_column]][[1]])),
          "{step}_messages" :=
            purrr::map_chr(.multi[[column]], \(fitted) collapse_log(fitted[[messages_column]][[1]]))
        )
      })

    specs <- unpack_specs(.multi, .unpack_specs)
    spec_columns <- setdiff(names(specs), setdiff(names(.multi), "specifications"))

    c(log_frames, fitted_logs) |>
      purrr::reduce(
        dplyr::left_join,
        by = "decision",
        .init =
          specs |>
          dplyr::select(decision, dplyr::any_of("status"), dplyr::all_of(spec_columns))
      )
  }

#' Compose a single analysis-ready data frame from a results grid.
#'
#' @description `compose_view()` assembles one tibble from selected components
#' of a results object. You name the result components you want (model
#' parameters, performance, post-processing output, pipeline code, timing logs),
#' and `compose_view()` unpacks each one and left-joins them by `decision` into
#' a single frame ready for plotting or tabling.
#'
#' Its job is deliberately narrow: it reconciles components that live at
#' different grains into one frame and nothing else. It performs no
#' transformation, summarizing, or reshaping of the results. Any such work is
#' left to the caller, either with downstream `dplyr` on the returned frame or
#' with per-layer `data` transformations at plot time.
#'
#' @param .multi a multiverse results object produced by
#'   \code{\link{analyze_grid}}.
#' @param ... result components to compose. Supply the bare column names of the
#'   components shipped by `analyze_grid()`, for example `model_parameters`,
#'   `model_performance`, `pipeline_code`, `timing_logs`, or the name of a
#'   post-processing output column (e.g. `aov_fitted`). Arguments may be named
#'   to control the prefix applied to that component's columns (see Details);
#'   unnamed arguments receive an automatic prefix.
#'
#' @details The specifications, including each decision's \code{status}, are
#' always included as the spine of the returned frame, so you never need to
#' request them. Decisions that were skipped, halted, or errored stay in the
#' frame: their specifications and status are present, and components they never
#' produced are missing.
#'
#' Requesting \code{pipeline_code} includes every step's code, along with each
#' condition (\code{condition_}), model summary (\code{summary_}), and
#' postprocessing step (\code{postprocess_}).
#'
#' \strong{Column prefixing.} To keep columns from different components from
#' colliding, every value column is prefixed with its component's name; the join
#' key `decision` and the specification columns are left unprefixed so they
#' remain shared across components. When an argument is named, that name is used
#' as the prefix. When an argument is unnamed, a prefix is assigned
#' automatically:
#' \itemize{
#'   \item `model_parameters` becomes `params_`
#'   \item `model_performance` becomes `perform_`
#'   \item `pipeline_code` becomes `code_`
#'   \item `run_logs` becomes `run_`
#'   \item a post-processing column has its `_fitted` suffix removed
#'     (e.g. `aov_fitted` becomes `aov_`)
#' }
#'
#' \strong{Grain and broadcasting.} Components differ in granularity. Model
#' parameters have one row per model term, while performance, timing, and
#' pipeline code each have one row per decision. Because components are joined
#' by `decision`, coarser components are broadcast across the rows of the finest
#' component requested. For example, composing `model_parameters` with
#' `model_performance` repeats each decision's performance values across that
#' decision's term rows. This broadcasting is intended: it produces a frame
#' where, for instance, a model fit statistic is available on every term row for
#' annotation. Collapsing back to a coarser grain (e.g. one label per decision)
#' is left to the caller at the point of use.
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
      else if(nm == '' & frame == "run_logs"){auto_nm <- "run"}
      else if(nm == ''){auto_nm <- stringr::str_remove(frame, "_fitted$")}
      else{auto_nm <- nm}

      auto_nm

    })

  repeated_names <- frame_names[duplicated(frame_names)]

  if(length(repeated_names) > 0){
    rlang::abort(
      c(
        "Each component in `compose_view()` needs its own prefix.",
        x = glue::glue("Used more than once: {stringr::str_flatten_comma(unique(repeated_names))}"),
        i = "Name the arguments to set prefixes, e.g. `compose_view(results, aov2 = anova_fitted)`."
      )
    )
  }

  unpacked_frames <-
    purrr::map2(frames, frame_names, function(frame, nm) {
      if(frame == "specs") {
        .multi |> unpack_specs() |> dplyr::select(-dplyr::where(is.list))
      } else if(frame == "model_parameters") {
        .multi |>
          unpack_model_parameters(
            .unpack_specs = "drop",
            .include_unfinished = TRUE
          ) |>
          dplyr::select(-dplyr::any_of("status")) |>
          dplyr::rename_with(~paste0(nm, "_", .x), -decision)
      } else if(frame == "model_performance") {
        .multi |>
          unpack_model_performance(
            .unpack_specs = "drop",
            .include_unfinished = TRUE
          ) |>
          dplyr::select(-dplyr::any_of("status")) |>
          dplyr::rename_with(~paste0(nm, "_", .x), -decision)
      } else if(frame %in% c("pipeline_code", "run_logs")){
        .multi |>
          dplyr::select(decision, dplyr::all_of(frame)) |>
          tidyr::unnest(dplyr::everything()) |>
          dplyr::rename_with(~paste0(nm, "_", .x), -decision)
      } else{
        .multi |>
          unpack_postprocess(
            !!frame,
            .unpack_specs = "drop",
            .include_unfinished = TRUE
          ) |>
          dplyr::select(-dplyr::any_of("status")) |>
          dplyr::rename_with(~paste0(nm, "_", .x), -decision)
      }
    })

  purrr::reduce(
    unpacked_frames,
    dplyr::left_join,
    by = "decision"
  )
}
