#' Run a single set of arbitrary decisions and save the result
#'
#' @param my_grid a \code{tibble} produced by \code{\link{combine_all_grids}}
#' @param my_data a \code{data.frame} representing the the original data
#' @param decision_num an single integer from 1 to \code{nrow(grid)} indicating
#'   which specific decision set to run
#' @param save_model logical, indicates whether to save the model object in its
#'   entirety. The default is \code{FALSE} because model objects are usually
#'   large and under the hood, \code{\link[broom]{tidy}} and
#'   \code{\link[broom]{glance}} is used to summarize the most useful model
#'   information.
#'
#' @return a single row \code{tibble} containing the decision, code that was
#'   ran, the results, and any notes (e.g., warnings or messages).
#' @export
#'
#' @examples
#'
#' \dontrun{
#' run_universe(my_grid, my_data, decision_num)
#' }
run_universe <- function(my_grid, my_data, decision_num, save_model = FALSE){

  data_chr <- dplyr::enexpr(my_data) |> as.character()

  if(rlang::is_expression(my_data)){
    data_chr <- my_data |> as.character()
  }

  grid_elements <- paste(names(my_grid), collapse = " ")

  universe <-
    my_grid |>
    dplyr::filter(decision == decision_num)

  universe_pipeline <-list(original_data = data_chr)
  universe_analyses <- list()
  universe_results <- list()

  if(stringr::str_detect(grid_elements, "filters")){
    universe_pipeline$filters <-
      universe |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")

    universe_results$filter_code <-
      tibble::tibble(
        filter_code = list_to_pipeline(universe_pipeline)
      )
  }

  if(stringr::str_detect(grid_elements, "preprocess")){
    universe_pipeline$preprocess_code <-
      universe |>
      dplyr::pull(preprocess) |>
      unlist() |>
      paste0(collapse = " |> ")

    universe_results$pre_process_code <-
      tibble::tibble(
        preprocess_code = list_to_pipeline(universe_pipeline)
      )
  }

  universe_pipeline$model_code <-
    universe |>
    dplyr::pull(model) |>
    stringr::str_replace(string = _ ,"\\)$", ", data = _)")

  universe_analyses$model <- list_to_pipeline(universe_pipeline)

  if(stringr::str_detect(grid_elements, "postprocess")){
    universe_postprocess <-
      universe |>
      dplyr::select(postprocess) |>
      tidyr::unnest(postprocess) |>
      as.list() |>
      purrr::map(
        function(x) paste0(list_to_pipeline(universe_pipeline), " |> ", x)
      )

    universe_analyses <-
      append(universe_analyses, universe_postprocess)
  }

  universe_results$model_results <-
    purrr::map_dfc(
      universe_analyses,
      function(x){
        collect_quiet_results(x, save_model = save_model)
      })

  universe_results |>
    purrr::reduce(dplyr::bind_cols) |>
    dplyr::mutate(
      decision = decision_num,
    ) |>
    tidyr::nest(data_pipeline = dplyr::ends_with("code")) |>
    dplyr::select(decision, data_pipeline, dplyr::everything())
}

#' Run a multiverse based on a complete decision grid
#'
#' @param my_grid a \code{tibble} produced by \code{\link{combine_all_grids}}
#' @param my_data a \code{data.frame} representing the the original data
#' @param save_model logical, indicates whether to save the model object in its
#'   entirety. The default is \code{FALSE} because model objects are usually
#'   large and under the hood, \code{\link[broom]{tidy}} and
#'   \code{\link[broom]{glance}} is used to summarize the most useful model
#'   information.
#' @param ncores numeric. The number of cores you want to use for parallel
#'   processing.
#'
#' @return a single \code{tibble} containing tidied results for the model and
#'   any post-processing tests/tasks. For each unique test (e.g., an \code{lm}
#'   or \code{aov} called on an \code{lm}), a list column with the function name
#'   is created with \code{\link[broom]{tidy}} and \code{\link[broom]{glance}}
#'   and any warnings or messages printed while fitting the models. Internally,
#'   modeling and post-processing functions are checked to see if there are tidy
#'   or glance methods available. If not, \code{summary} will be called instead.
#' @export
#'
#' @examples
#'
#' \dontrun{
#' run_multiverse(data, grid)
#' }
run_multiverse <- function(my_grid, my_data, save_model = FALSE, ncores = 1) {
  data_chr <- dplyr::enexpr(my_data)|> as.character()

  if(ncores > 1){
    future::plan(future::multisession, workers = ncores)

    multiverse <-
      furrr::future_map_dfr(
        1:nrow(my_grid),
        function(x){
          run_universe(
            my_grid = my_grid,
            my_data = data_chr,
            decision_num = x,
            save_model = save_model
          )
        },
        .options = furrr::furrr_options(seed = T))

    future::plan(future::sequential)
  } else{

    multiverse <-
      purrr::map_df(
        cli::cli_progress_along(1:nrow(my_grid)),
        function(x){
          run_universe(
            my_grid = my_grid,
            my_data = data_chr,
            decision_num = x,
            save_model = save_model
          )
        })

  }

  dplyr::full_join(
    my_grid |> dplyr::select(-dplyr::contains("code")),
    multiverse,
    by = "decision"
  )
}


