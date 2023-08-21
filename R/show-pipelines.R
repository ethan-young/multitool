#'Show multiverse data code pipelines
#'
#'Each \code{show_code*} function should be self-explanatory - they indicate
#'where along the multiverse pipeline to extract code. The goal of these
#'functions is to create a window into each multiverse decision set
#'context/results and allow the user to inspect specific decisions straight from
#'the code that produced it.
#'
#'@param .grid a full decision grid created by \code{\link{expand_decisions}}
#'@param decision_num numeric. Indicates which 'universe' in the multiverse to
#'  show underlying code.
#'@param copy logical. Whether to copy the pipeline code to the clipboard using
#'  \code{\link[clipr]{write_clip}}.
#'@export
show_code_filter <- function(.grid, decision_num, copy = F){

  data_chr <- attr(.grid,  "base_df")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  code <- list(base_data = data_chr)

  if("filters" %in% names(universe)){
    code$filter_code <-
      universe |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")
  } else{
    rlang::warn("You don't have any filters specified in your pipeline...")
  }

  code <- list_to_pipeline(code, for_print = TRUE)

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Filter pipeline copied!")
  }

  cat(code, "\n")

}

#' @describeIn show_code_filter Show the code up to the preprocessing stage
#' @export
show_code_preprocess <- function(.grid, decision_num, copy = F){

  data_chr <- attr(.grid,  "base_df")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  code <- list(base_data = data_chr)

  if("filters" %in% names(universe)){
    code$filter_code <-
      universe |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")
  }

  if("preprocess" %in% names(universe)){
    code$preprocess_code <-
      universe |>
      dplyr::pull(preprocess) |>
      unlist() |>
      paste0(collapse = " |> \n  ")
  } else{
    rlang::warn("You don't have any pre-processing steps specified in your pipeline...")
  }

  code <- list_to_pipeline(code, for_print = TRUE)

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Pre-process pipeline copied!")
  }

  cat(code, "\n")
}

#' @describeIn show_code_filter Show the code up to the modeling stage
#' @export
show_code_model <- function(.grid, decision_num, copy = F){

  data_chr <- attr(.grid,  "base_df")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  code <- list(base_data = data_chr)

  if("filters" %in% names(universe)){
    code$filter_code <-
      universe |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")
  }

  if("preprocess" %in% names(universe)){
    code$preprocess_code <-
      universe |>
      dplyr::pull(preprocess) |>
      unlist() |>
      paste0(collapse = " |> \n  ")
  }

  if("models" %in% names(universe)){
    code$model <-
      universe |>
      tidyr::unnest(models) |>
      dplyr::pull(model) |>
      unlist() |>
      stringr::str_replace(string = _ ,"\\)$", ", data = _)")
  } else{
    rlang::warn("\nYou don't have any models specified in your pipeline...")
  }

  code <- list_to_pipeline(code, for_print = TRUE)

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Model pipeline copied!")
  }

  cat(code, "\n")
}

#' @describeIn show_code_filter Show the code up to the post-processing
#'   stage
#' @export
show_code_postprocess <- function(.grid, decision_num, copy = F){

  data_chr <- attr(.grid,  "base_df")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  code <- list(base_data = data_chr)

  if("filters" %in% names(universe)){
    code$filter_code <-
      universe |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")
  }

  if("preprocess" %in% names(universe)){
    code$preprocess_code <-
      universe |>
      dplyr::pull(preprocess) |>
      unlist() |>
      paste0(collapse = " |> \n  ")
  }

  if("models" %in% names(universe)){
    code$model <-
      universe |>
      tidyr::unnest(models) |>
      dplyr::pull(model) |>
      unlist() |>
      stringr::str_replace(string = _ ,"\\)$", ", data = _)")
  }

  if("postprocess" %in% names(universe)){
    post_processes <-
      universe |>
      dplyr::select(postprocess) |>
      tidyr::unnest(postprocess) |>
      as.list() |>
      purrr::map(
        function(x) paste0(list_to_pipeline(code, for_print = TRUE), " |> \n  ", x)
      )
  } else{
    rlang::warn("You don't have any post-processes in your pipeline...")
  }

  if("postprocess" %in% names(universe)){

    if(copy){
      suppressWarnings({clipr::write_clip(post_processes)})
      message("Pre-process pipeline copied!")
    }

    purrr::iwalk(post_processes,function(x,y){
      cat(glue::glue("---- Post process: {str_replace(y, 'set', 'set ')} ---- \n\n"))
      cat(x, "\n\n")
    })
  } else{
    code <- list_to_pipeline(code, for_print = TRUE)
    cat(code, "\n")
  }

}

#' @describeIn show_code_filter Show the code for computing summary statistics
#' @export
show_code_summary_stats <- function(.grid, decision_num, copy = F){

  data_chr <- attr(.grid,  "base_df")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  code <- list(base_data = data_chr)

  if("filters" %in% names(universe)){
    code$filter_code <-
      universe |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")
  }

  if("summary_stats" %in% names(universe)){
    summary_stats <-
      universe |>
      dplyr::select(summary_stats) |>
      tidyr::unnest(summary_stats) |>
      as.list() |>
      purrr::map(
        function(x) paste0(list_to_pipeline(code, for_print = TRUE), " |> \n  ", x |> str_replace_all(" \\|\\> ", " |> \n  "))
      )
  } else{
    rlang::warn("You don't have any summary statistics in your pipeline...")
  }

  if("summary_stats" %in% names(universe)){

    if(copy){
      suppressWarnings({clipr::write_clip(summary_stats)})
      message("Post-process pipeline copied!")
    }

    purrr::iwalk(summary_stats,function(x,y){
      cat(glue::glue("---- Summary Statistics: {str_replace(y, 'set', 'set ')} ---- \n\n"))
      cat(x, "\n\n")
    })

  } else{
    code <- list_to_pipeline(code, for_print = TRUE)
    cat(code,"\n")
  }

}

#' @describeIn show_code_filter Show the code for computing correlations
#' @export
show_code_corrs <- function(.grid, decision_num, copy = F){

  data_chr <- attr(.grid,  "base_df")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  code <- list(base_data = data_chr)

  if("filters" %in% names(universe)){
    code$filter_code <-
      universe |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")
  }

  if("corrs" %in% names(universe)){
    corrs <-
      universe |>
      dplyr::select(corrs) |>
      tidyr::unnest(corrs) |>
      as.list() |>
      purrr::map(
        function(x) paste0(list_to_pipeline(code, for_print = TRUE), " |> \n  ", x |> str_replace_all(" \\|\\> ", " |> \n  "))
      )
  } else{
    rlang::warn("You didn't specify any correlations in your pipeline...")
  }

  if("corrs" %in% names(universe)){

    if(copy){
      suppressWarnings({clipr::write_clip(corrs)})
      message("Correlation pipeline copied!")
    }

    purrr::iwalk(corrs,function(x,y){
      cat(glue::glue("---- Correlations: {str_replace(y, 'set', 'set ')} ---- \n\n"))
      cat(x, "\n\n")
    })

  } else{
    code <- list_to_pipeline(code, for_print = TRUE)
    cat(code,"\n")
  }

}

#' @describeIn show_code_filter Show the code for computing correlations
#' @export
show_code_cron_alpha <- function(.grid, decision_num, copy = F){

  data_chr <- attr(.grid,  "base_df")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  code <- list(base_data = data_chr)

  if("filters" %in% names(universe)){
    code$filter_code <-
      universe |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")
  }

  if("cron_alphas" %in% names(universe)){
    cron_alphas <-
      universe |>
      dplyr::select(cron_alphas) |>
      tidyr::unnest(cron_alphas) |>
      as.list() |>
      purrr::map(
        function(x) paste0(list_to_pipeline(code, for_print = TRUE), " |> \n  ", x |> str_replace_all(" \\|\\> ", " |> \n  "))
      )
  } else{
    rlang::warn("You didn't specify any cronbach alpha reports in your pipeline...")
  }

  if("cron_alphas" %in% names(universe)){

    if(copy){
      suppressWarnings({clipr::write_clip(corrs)})
      message("Cronbach's Alpha pipeline copied!")
    }

    purrr::iwalk(cron_alphas,function(x,y){
      cat(glue::glue("---- Cronbach's Alpha: {str_replace(y, 'set', 'set ')} ---- \n\n"))
      cat(x, "\n\n")
    })
  } else{
    code <- list_to_pipeline(code, for_print = TRUE)
    cat(code, "\n")
  }

}
