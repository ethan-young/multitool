#'Show multiverse data code pipelines
#'
#'Each \code{show_pipeline*} function should be self-explanatory - they indicate
#'where along the multiverse pipeline to extract code. The goal of these
#'functions is to create a window into each multiverse decision set
#'context/results and allow the user to inspect specific decisions straight from
#'the code that produced it.
#'
#'@param multiverse a \code{tibble} created by \code{\link{run_multiverse}}
#'@param decision_num numeric. Indicates which 'universe' in the multiverse to
#'  show underlying code.
#'@param copy logical. Whether to copy the pipeline code to the clipboard using
#'  \code{\link[clipr]{write_clip}}.
#'@param mod the name of the model (e.g., \code{lm}) or post-processing task
#'@export
show_pipe_filter <- function(multiverse, decision_num, copy = F){

  code <-
    multiverse |>
    dplyr::filter(decision == decision_num) |>
    tidyr::unnest(data_pipeline) |>
    dplyr::pull(filter_code) |>
    stringr::str_replace_all("\\|\\>", " |>\n  ") |>
    glue::glue(.trim = FALSE)

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Filter pipeline copied!")
  }

  cli::cli_code(code)

}

#' @describeIn show_pipe_filter Show the code up to the preprocessing stage
show_pipe_preprocess <- function(multiverse, decision_num, copy = F){

  code <-
    multiverse |>
    dplyr::filter(decision == decision_num) |>
    tidyr::unnest(data_pipeline) |>
    dplyr::pull(preprocess_code) |>
    stringr::str_replace_all("\\|\\>", " |>\n  ") |>
    glue::glue(.trim = FALSE)

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Post filter pipeline copied!")
  }

  cli::cli_code(code)

}

#' @describeIn show_pipe_filter Show the code up to the modeling stage
show_pipe_model <- function(multiverse, decision_num, mod, copy = F){

  code <-
    multiverse |>
    dplyr::filter(decision == decision_num) |>
    dplyr::select({{mod}}) |>
    tidyr::unnest({{mod}}) |>
    dplyr::select(dplyr::ends_with("code")) |>
    dplyr::pull() |>
    stringr::str_replace_all("\\|\\>", " |>\n  ") |>
    glue::glue(.trim = FALSE)

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Model pipeline copied!")
  }

  cli::cli_code(code)

}

#' @describeIn show_pipe_filter Show the code up to the post_processing
#'   stage
show_pipe_postprocess <- function(multiverse, decision_num, mod, copy = F){

  code <-
    multiverse |>
    dplyr::filter(decision == decision_num) |>
    dplyr::select({{mod}}) |>
    tidyr::unnest({{mod}}) |>
    dplyr::select(dplyr::ends_with("code")) |>
    dplyr::pull() |>
    stringr::str_replace_all("\\|\\>", " |>\n  ") |>
    glue::glue(.trim = FALSE)

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Post process pipeline copied!")
  }

  cli::cli_code(code)

}
