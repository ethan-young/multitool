#' Show multiverse data code pipelines
#'
#' \code{show_code} is the generic function. All \code{show_code*} functions are
#' simple wrappers of \code{show_code}.
#'
#' Each \code{show_code*} function should be self-explanatory - they indicate
#' where along the multiverse pipeline to extract code. The goal of these
#' functions is to create a window into each data/model combination and allow
#' the user to inspect specific decisions straight from the code that produced
#' it.
#'
#' @param .grid a full decision grid created by \code{\link{expand_decisions}}
#'   or a fully analyzed grid produced by \code{\link{analyze_grid}}.
#' @param decision_num numeric. Indicates which decision set in the grid to show
#'   underlying code.
#' @param .step a point along the pipeline for which you would like to show the
#'   underlying code. Defaults to the model.
#' @param .post_step Only relevant if you are exposing a postprocessing step. If
#'   you have more than one postprocess, you can specify which you would like to
#'   expose by index or by name.
#'
#' @returns the code that generated results up to the specified point in an
#'   analysis pipeline.
#' @export
show_code <-
  function(
    .grid,
    decision_num,
    .step = "model",
    .post_step = NULL
  ){
    if("specifications" %in% names(.grid)){
      grid_type <- "multi"
      grid_slice <-
        .grid |>
        dplyr::filter(decision == 1) |>
        dplyr::select(decision, pipeline_code) |>
        reveal(pipeline_code)

      grid_elements <- names(grid_slice)
    } else{
      grid_type <- "grid"
      grid_slice <- build_pipeline_code(.grid, decision_num)
      grid_elements <-
        .grid |>
        rename_with(
          ~stringr::str_replace(.x, "models", "model")
        ) |>
        names()
    }

    if(.step == "postprocess" & grid_type == "grid"){
      if(!is.null(.post_step)){
        grid_slice$pipeline$postprocess <-
          grid_slice$pipeline$postprocess[[.post_step]]
      } else{
        grid_slice$pipeline$postprocess <-
          grid_slice$pipeline$postprocess[[1]]
      }
    } else if(.step == "postprocess" & grid_type == "multi"){
      grid_slice <-
        grid_slice |>
        dplyr::select(
          -dplyr::any_of(
            c(
              "decision",
              "original_data",
              "collect",
              "subgroups",
              "filters",
              "preprocess",
              "model"
            )
          )
        )
      if(!is.null(.post_step)){
        grid_slice <-
          grid_slice |>
          dplyr::select(.post_step)

        .step <- names(grid_slice)

      } else{
        grid_slice <-
          grid_slice |>
          dplyr::select(1)

        .step <- names(grid_slice)
      }
    }

    if(!.step %in% grid_elements){
      rlang::abort(
        glue::glue(
          "You don't have a {.step} step specified in your pipeline..."
        )
      )
    }

    if(grid_type == "grid"){
      code <- get_code(grid_slice$pipeline, .step, for_print = TRUE)
    } else if(grid_type == "multi"){
      code <-
        grid_slice |>
        dplyr::pull(dplyr::any_of(c(.step))) |>
        stringr::str_replace_all("\\|\\>", " |> \n  ") |>
        glue::glue(.trim = FALSE)
    }
    code
  }

#' Show multiverse data code pipelines
#'
#' Each \code{show_code*} function should be self-explanatory - they indicate
#' where along the multiverse pipeline to extract code. The goal of these
#' functions is to create a window into each multiverse decision set
#' context/results and allow the user to inspect specific decisions straight
#' from the code that produced it.
#'
#' @param .grid a full decision grid created by \code{\link{expand_decisions}}.
#' @param decision_num numeric. Indicates which 'universe' in the multiverse to
#'   show underlying code.
#' @param copy logical. Whether to copy the pipeline code to the clipboard using
#'   \code{\link[clipr]{write_clip}}. Defaults to \code{FALSE}.
#' @param console logical. Whether to send the code to the console in RStudio.
#'   Defaults to \code{TRUE} but requires that the code be running in RStudio.
#' @param execute logical. If sending to the console, whether to immediately run
#'   the code in the console. Defaults to \code{FALSE}.
#' @param ... additional arguments passed to \code{rstudioapi::sendToConsole()}
#'
#' @returns the code that generated results up to the specified point in an
#'   analysis pipeline. The code is printed in the console and can be optionally
#'   copied to the clipboard.
#' @describeIn show_code Show the code up to the subgroups stage
#' @export
show_code_subgroups <- function(.grid, decision_num){
  show_code(.grid, decision_num, .step = "subgroups")
}

#' @describeIn show_code Show the code up to the filtering stage
#' @export
show_code_filters <- function(.grid, decision_num){
  show_code(.grid, decision_num, .step = "filters")
}

#' @describeIn show_code Show the code up to the preprocessing stage
#' @export
show_code_preprocess <- function(.grid, decision_num){
  show_code(.grid, decision_num, .step = "preprocess")
}

#' @describeIn show_code Show the code up to the modeling stage
#' @export
show_code_model <- function(.grid, decision_num){
  show_code(.grid, decision_num, .step = "model")
}

#' @describeIn show_code Show the code up to the post-processing stage
#' @export
show_code_postprocess <- function(.grid, decision_num){
  show_code(.grid, decision_num, .step = "postprocess")
}

#' @describeIn show_code Show the code for computing summary statistics
#' @param summary_set numeric. For \code{show_code_summary_stats}, Which set of
#'   summary statistics to print. Default is set to the \code{1}.
#' @export
show_code_summary_stats <- function(.grid, decision_num, summary_set = 1, copy = FALSE, console = TRUE, execute = FALSE, ...){

  code <-
    run_universe_summary_stats(.grid, decision_num, run = FALSE)

  if(is.null(code)){
    rlang::warn("You don't have any summary statistics specified in your pipeline...")
  } else{
    if(copy){
      suppressWarnings({clipr::write_clip(code[[summary_set]])})
      message("Summary stats pipeline copied!")
    }
    if(console){
      message("Showing summary stats set ", summary_set, " of ",  " labeled '", names(code)[[summary_set]], "'")
      message("Use the `summary_set` argument to see a different set of summary statistics")
      message("Hit enter to run the code:")
      rstudioapi::sendToConsole(code[[summary_set]], execute, ...)
    } else{
      message("Showing summary stats set ", summary_set, " of ",  " labeled '", names(code)[[summary_set]], "'")
      message("Use the `summary_set` argument to see a different set of summary statistics")
      cat(code[[summary_set]])
    }
  }
}

#' @describeIn show_code Show the code for computing correlations
#' @param corr_set numeric. For \code{show_code_corrs}, Which set of
#'   correlations to print. Default is set to the \code{1}.
#' @export
show_code_corrs <- function(.grid, decision_num, corr_set = 1, copy = FALSE, console = TRUE, execute = FALSE, ...){

  code <-
    run_universe_corrs(.grid, decision_num, run = FALSE)

  if(is.null(code)){
    rlang::warn("You don't have any correlations specified in your pipeline...")
  } else{
    if(copy){
      suppressWarnings({clipr::write_clip(code[[corr_set]])})
      message("Correlation pipeline copied!")
    }
    if(console){
      message("Showing correlation set ", corr_set, " of ", length(code),  " labeled '", names(code)[[corr_set]], "'")
      message("Use the `corr_set` argument to see a different set of correlations")
      message("Hit enter to run the code:")
      rstudioapi::sendToConsole(code[[corr_set]], execute, ...)
    } else{
      message("Showing correlation set ", corr_set, " of ", length(code),  " labeled '", names(code)[[corr_set]], "'")
      message("Use the `corr_set` argument to see a different set of correlations")
      cat(code[[corr_set]])
    }
  }
}

#' @describeIn show_code Show the code for computing scale reliability
#' @param rel_set numeric. For \code{show_code_reliabilities}, Which set of
#'   reliabilities to print. Default is set to the \code{1}.
#' @export
show_code_reliabilities <- function(.grid, decision_num, rel_set = 1, copy = FALSE, console = TRUE, execute = FALSE, ...){

  code <-
    run_universe_reliabilities(.grid, decision_num, run = FALSE)

  if(is.null(code)){
    rlang::warn("You don't have any reliabilities specified in your pipeline...")
  } else{
    if(copy){
      suppressWarnings({clipr::write_clip(code[[rel_set]])})
      message("Reliability pipeline copied!")
    }
    if(console){
      message("Showing reliability set ", rel_set, " of ", length(code),  " labeled '", names(code)[[rel_set]], "'")
      message("Use the `rel_set` argument to see a different set of reliabilities")
      message("Hit enter to run the code:")
      rstudioapi::sendToConsole(code[[rel_set]], execute, ...)
    } else{
      message("Showing reliability set ", rel_set, " of ", length(code),  " labeled '", names(code)[[rel_set]], "'")
      message("Use the `rel_set` argument to see a different set of reliabilities")
      cat(code[[rel_set]])
    }
  }
}
