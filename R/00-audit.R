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
#' @param .execute logical, whether or not to run the code as well as print it.
#'
#' @returns the code that generated results up to the specified point in an
#'   analysis pipeline.
#' @export
show_code <-
  function(
    .grid,
    decision_num,
    .step = "model",
    .post_step = NULL,
    .execute = FALSE
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

    print(code)

    if(.execute){
      rlang::parse_expr(code) |>
        rlang::eval_tidy() |>
        print()
    }
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

#' @describeIn show_code Show the code up to the modeling stage
#' @param ... additional arguments passed to \code{show_code()}
#' @export
show_code_model <- function(.grid, decision_num, ...){
  show_code(.grid, decision_num, .step = "model", ...)
}

#' @describeIn show_code Show the code up to the post-processing stage
#' @param ... additional arguments passed to \code{show_code()}
#' @export
show_code_postprocess <- function(.grid, decision_num, ...){
  show_code(.grid, decision_num, .step = "postprocess", ...)
}

show_result <-
  function(
    .multi,
    decision_num,
    type = "parameters",
    ...,
    .print_specs = TRUE
  ){
    results_slice <-
      .multi |>
      dplyr::filter(decision == decision_num)

    if(type == "parameters"){
      result <-
        results_slice |>
        unpack_model_parameters(..., .unpack_specs = "no")
    }

    if(type == "performance"){
      result <-
        results_slice |>
        unpack_model_performance(..., .unpack_specs = "no")
    }

    if(type == "post_process"){
      result <-
        results_slice |>
        unpack_postprocess(..., .unpack_specs = "no")
    }

    specs <-
      .multi |>
      unpack_specs(.how = "long") |>
      dplyr::select(dplyr::where(~!is.list(.x))) |>
      dplyr::mutate(
        n_dis = dplyr::n_distinct(decision_choice),
        .by = decision_set
      ) |>
      dplyr::filter(decision == 1, n_dis > 1) |>
      dplyr::transmute(
        decision,
        print_out = glue::glue("{decision_set}: {decision_choice} ({decision_type})")
      ) |>
      tidyr::pivot_longer(
        dplyr::everything(),
        values_transform = as.character
      ) |>
      dplyr::distinct() |>
      glue::glue_data(
        "{ifelse(name == 'decision', 'Decision: ', '')}{value}",
        .trim = FALSE
      )

    print(specs)
    result

  }
