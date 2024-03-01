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
#' @export
show_code_subgroups <- function(.grid, decision_num, copy = FALSE, console = TRUE, execute = FALSE, ...){

  decision_pipeline <-
    run_universe_model(.grid, decision_num, run = FALSE)

  code <-
    decision_pipeline$subgroups

  if(is.null(code)){
    rlang::warn("You don't have any subgroups specified in your pipeline...")
  } else{
    if(copy){
      suppressWarnings({clipr::write_clip(code)})
      message("Subgroup pipeline copied!")
    }
    if(console){
      message("Hit enter to run the code:")
      rstudioapi::sendToConsole(code, execute = FALSE, ...)
    } else{
      cat(code)
    }
  }
}

#' @describeIn show_code_subgroups Show the code up to the filtering stage
#' @export
show_code_filter <- function(.grid, decision_num, copy = FALSE, console = TRUE, execute = FALSE, ...){

  decision_pipeline <-
    run_universe_model(.grid, decision_num, run = FALSE)

  code <-
    decision_pipeline$filters

  if(is.null(code)){
    rlang::warn("You don't have any filters specified in your pipeline...")
  } else{
    if(copy){
      suppressWarnings({clipr::write_clip(code)})
      message("Filter pipeline copied!")
    }
    if(console){
      message("Hit enter to run the code:")
      rstudioapi::sendToConsole(code, execute = FALSE, ...)
    } else{
      cat(code)
    }
  }
}

#' @describeIn show_code_subgroups Show the code up to the preprocessing stage
#' @export
show_code_preprocess <- function(.grid, decision_num, copy = FALSE, console = TRUE, execute = FALSE, ...){

  decision_pipeline <-
    run_universe_model(.grid, decision_num, run = FALSE)

  code <-
    decision_pipeline$preprocess

  if(is.null(code)){
    rlang::warn("You don't have any pre-processing specified in your pipeline...")
  } else{
    if(copy){
      suppressWarnings({clipr::write_clip(code)})
      message("Pre-processing pipeline copied!")
    }
    if(console){
      message("Hit enter to run the code:")
      rstudioapi::sendToConsole(code, execute = FALSE, ...)
    } else{
      cat(code)
    }
  }
}

#' @describeIn show_code_subgroups Show the code up to the modeling stage
#' @export
show_code_model <- function(.grid, decision_num, copy = FALSE, console = TRUE, execute = FALSE, ...){

  decision_pipeline <-
    run_universe_model(.grid, decision_num, run = FALSE)

  code <-
    decision_pipeline$model

  if(is.null(code)){
    rlang::warn("You don't have any models specified in your pipeline...")
  } else{
    if(copy){
      suppressWarnings({clipr::write_clip(code)})
      message("Model pipeline copied!")
    }
    if(console){
      message("Hit enter to run the code:")
      rstudioapi::sendToConsole(code, execute = FALSE, ...)
    } else{
      cat(code)
    }
  }
}

#' @describeIn show_code_subgroups Show the code up to the post-processing stage
#' @param post_step numeric. For \code{show_code_postprocess}, Which post-processing
#'   step to print. Default is set to the \code{1}.
#' @export
show_code_postprocess <- function(.grid, decision_num, post_step = 1, copy = FALSE, console = TRUE, execute = FALSE, ...){

  decision_pipeline <-
    run_universe_model(.grid, decision_num, run = FALSE)

  code <-
    decision_pipeline$postprocess

  if(is.null(code)){
    rlang::warn("You don't have any post-processing specified in your pipeline...")
  } else{
    if(copy){
      suppressWarnings({clipr::write_clip(code[[post_step]])})
      message("Post-processing pipeline copied!")
    }
    if(console){
      message("Showing post process ", post_step, " of ", length(code),  " labeled '", names(code)[[post_step]], "'")
      message("Use the `post_step` argument to see a different post processing pipeline")
      message("Hit enter to run the code:")
      rstudioapi::sendToConsole(code[[post_step]], execute, ...)
    } else{
      message("Showing post process ", post_step, " of ", length(code),  " labeled '", names(code)[[post_step]], "'")
      message("Use the `post_step` argument to see a different post processing pipeline")
      cat(code[[post_step]])
    }
  }
}

#' @describeIn show_code_subgroups Show the code for computing summary statistics
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

#' @describeIn show_code_subgroups Show the code for computing correlations
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

#' @describeIn show_code_subgroups Show the code for computing scale reliability
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
