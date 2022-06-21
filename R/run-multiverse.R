#' Run a single set of arbitrary decisions and save the result
#'
#' @param my_data a \code{data.frame} representing the the original data
#' @param grid a \code{tibble} produced by \code{\link{combine_all_grids}}
#' @param decision_num an single integer from 1 to \code{nrow(grid)} indicating
#'   which specific decision set to run
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
run_universe <- function(my_grid, my_data, decision_num, mixed = FALSE, save_model = FALSE){

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
      map(function(x) paste0(list_to_pipeline(universe_pipeline), " |> ", x))

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
    purrr::reduce(bind_cols) |>
    mutate(
      decision = decision_num,
    ) |>
    nest(data_pipeline = ends_with("code")) |>
    select(decision, data_pipeline, everything())
}

#' Run a multiverse based on a complete decision grid
#'
#' @param my_data a \code{data.frame} representing the the original data
#' @param grid a \code{tibble} produced by \code{\link{combine_all_grids}}
#'
#' @return various thing based on the grid, model, and post hoc analyses
#' @export
#'
#' @examples
#'
#' \dontrun{
#' run_multiverse(data, grid)
#' }
#'
run_multiverse <- function(my_grid, my_data, save_model = FALSE) {
  data_chr <- dplyr::enexpr(my_data)|> as.character()

  multiverse <-
    purrr::map_df(1:nrow(my_grid), function(x){
      universe <-
        run_universe(
          my_grid = my_grid,
          my_data = data_chr,
          decision_num = x,
          save_model = save_model
        )
      message("Decision set ", x, " analyzed")
      universe
    })

  dplyr::full_join(
    my_grid |> select(-contains("code")),
    multiverse,
    by = "decision"
  )

}
