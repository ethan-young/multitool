#' Show the code behind one decision
#'
#' \code{show_code} is the generic function. All \code{show_code_*} functions
#' are simple wrappers of \code{show_code}.
#'
#' Each \code{show_code_*} function indicates where along the pipeline to
#' extract code. The goal of these functions is to open a window into each
#' decision and let you inspect it straight from the code that produced it.
#' The code is the same whether it comes from a grid (built on the fly) or from
#' analyzed results (stored when the decision ran).
#'
#' @param .grid a decision grid created by \code{\link{expand_pipeline}}, or
#'   analyzed results produced by \code{\link{analyze_grid}}.
#' @param decision_num numeric. The decision whose code to show.
#' @param .step the point along the pipeline to show code for: one of the
#'   main steps (\code{"original_data"}, \code{"collect"}, \code{"subgroups"},
#'   \code{"filters"}, \code{"preprocess"}, \code{"model"}), or one of the
#'   steps that can have several parts (\code{"conditions"},
#'   \code{"model_summary"}, \code{"postprocess"}). Defaults to
#'   \code{"model"}.
#' @param .which for \code{"conditions"}, \code{"model_summary"}, and
#'   \code{"postprocess"}: which part to show, by name or by position. If
#'   \code{NULL} (the default), the first is shown and the others are listed
#'   in a message. Model summaries are named \code{"coefs"}, \code{"fit"}, and
#'   \code{"standardize"}; conditions and postprocessing steps use the names
#'   given in the pipeline.
#' @param .execute logical, whether to run the code as well as print it.
#'
#' @returns the code, invisibly, after printing it. The code for main steps
#'   runs from the base data through that step; conditions run on the data as
#'   it reaches the model; model summaries and postprocessing run on the fitted
#'   model.
#' @export
show_code <-
  function(
    .grid,
    decision_num,
    .step = "model",
    .which = NULL,
    .execute = FALSE
  ){

    if(!decision_num %in% .grid$decision){
      rlang::abort(
        glue::glue("There is no decision {decision_num} in this grid.")
      )
    }

    # this decision's code: stored in analyzed results, built from a grid
    if("pipeline_code" %in% names(.grid)){
      step_code <-
        .grid |>
        dplyr::filter(decision == decision_num) |>
        dplyr::pull(pipeline_code) |>
        purrr::pluck(1)
    } else{
      step_code <-
        build_pipeline_code(.grid, decision_num) |>
        build_step_code()
    }

    # steps with several parts: show one, by name, position, or the first
    substep_prefixes <-
      c(
        conditions    = "condition_",
        model_summary = "summary_",
        postprocess   = "postprocess_"
      )

    if(.step %in% names(substep_prefixes)){
      prefix <- substep_prefixes[[.step]]

      available <-
        names(step_code)[stringr::str_starts(names(step_code), prefix)] |>
        stringr::str_remove(paste0("^", prefix))

      if(length(available) == 0){
        rlang::abort(
          glue::glue("Decision {decision_num} has no {.step} steps.")
        )
      }

      chosen <-
        if(is.null(.which)){
          available[1]
        } else if(is.numeric(.which)){
          available[.which]
        } else{
          .which
        }

      chosen <- stringr::str_remove(chosen, "_fitted$")

      if(is.na(chosen) || !chosen %in% available){
        rlang::abort(
          c(
            glue::glue("No {.step} step `{.which}`."),
            i = glue::glue(
              "Available: {stringr::str_flatten_comma(available)}"
            )
          )
        )
      }

      if(is.null(.which) && length(available) > 1){
        rlang::inform(
          glue::glue(
            "Showing `{chosen}`. ",
            "Also available: {stringr::str_flatten_comma(available[-1])}. ",
            "Choose one with `.which`."
          )
        )
      }

      code_column <- paste0(prefix, chosen)
    } else{
      main_steps <-
        names(step_code)[
          !stringr::str_detect(
            names(step_code),
            "^(condition|summary|postprocess)_"
          )
        ]

      if(!.step %in% main_steps){
        rlang::abort(
          c(
            glue::glue("This decision's code has no `{.step}` step."),
            i = glue::glue(
              "Steps available: ",
              "{stringr::str_flatten_comma(
                c(main_steps, names(substep_prefixes))
              )}"
            )
          )
        )
      }

      code_column <- .step
    }

    code <-
      step_code[[code_column]] |>
      stringr::str_replace_all(" \\|> ", " |> \n  ") |>
      glue::as_glue()

    print(styler::style_text(code))

    if(.execute){
      code |>
        rlang::parse_expr() |>
        rlang::eval_tidy() |>
        print()
    }

    invisible(code)
  }

#' @describeIn show_code Show the code up to the subgroups stage
#' @param ... additional arguments passed to \code{show_code()}
#' @export
show_code_subgroups <- function(.grid, decision_num, ...){
  show_code(.grid, decision_num, .step = "subgroups", ...)
}

#' @describeIn show_code Show the code up to the filtering stage
#' @param ... additional arguments passed to \code{show_code()}
#' @export
show_code_filters <- function(.grid, decision_num, ...){
  show_code(.grid, decision_num, .step = "filters", ...)
}

#' @describeIn show_code Show the code up to the preprocessing stage
#' @param ... additional arguments passed to \code{show_code()}
#' @export
show_code_preprocess <- function(.grid, decision_num, ...){
  show_code(.grid, decision_num, .step = "preprocess", ...)
}

#' @describeIn show_code Show the code for a condition: the data as it
#'   reaches the model, followed by the condition's test
#' @param ... additional arguments passed to \code{show_code()}
#' @export
show_code_conditions <- function(.grid, decision_num, ...){
  show_code(.grid, decision_num, .step = "conditions", ...)
}

#' @describeIn show_code Show the code up to the modeling stage
#' @param ... additional arguments passed to \code{show_code()}
#' @export
show_code_model <- function(.grid, decision_num, ...){
  show_code(.grid, decision_num, .step = "model", ...)
}

#' @describeIn show_code Show the code for a model summary, such as the
#'   model's coefficients or fit statistics
#' @param ... additional arguments passed to \code{show_code()}
#' @export
show_code_model_summary <- function(.grid, decision_num, ...){
  show_code(.grid, decision_num, .step = "model_summary", ...)
}

#' @describeIn show_code Show the code for a postprocessing step
#' @param ... additional arguments passed to \code{show_code()}
#' @export
show_code_postprocess <- function(.grid, decision_num, ...){
  show_code(.grid, decision_num, .step = "postprocess", ...)
}
