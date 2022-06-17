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
run_universe <- function(my_grid, my_data, decision_num, save_model = FALSE){

  data_chr <- dplyr::enexpr(my_data) |> as.character()

  if(rlang::is_expression(my_data)){
    data_chr <- my_data |> as.character()
  }

  grid_elements <- paste(names(my_grid), collapse = " ")

  universe <-
    my_grid |>
    dplyr::filter(decision == decision_num)

  universe_pipeline <-
    list(
      original_data = data_chr,
      filters = NULL,
      post_filter_code = NULL,
      model = NULL,
      model_summary = NULL,
      post_hoc_code = NULL
    )

  universe_results <-
    list(
      filter_code = NULL,
      post_filter_code = NULL,
      model = NULL,
      summary = NULL,
      post_hoc = NULL
    )

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

  if(stringr::str_detect(grid_elements, "post_filter")){
    universe_pipeline$post_filter_code <-
      universe |>
      dplyr::pull(post_filter_code) |>
      unlist() |>
      paste0(collapse = " |> ")

    universe_results$post_filter_code <-
      tibble::tibble(
        post_filter_code = list_to_pipeline(universe_pipeline)
      )
  }

  universe_pipeline$model <-
    universe |>
    dplyr::pull(model) |>
    stringr::str_replace(string = _ ,"\\)$", ", data = _)")

  if(save_model | !stringr::str_detect(grid_elements, "summary")){
    universe_model <-
      list_to_pipeline(universe_pipeline) |>
      collect_quiet_results() |>
      dplyr::rename_with(~paste0("model_", .x))

    universe_results$model <- universe_model
  } else{
    universe_results$model <- tibble::tibble(model_code = list_to_pipeline(universe_pipeline))
  }

  if(stringr::str_detect(grid_elements, "summary")){
    universe_summaries <-
      universe |>
      dplyr::select(model_summary_code) |>
      tidyr::unnest(model_summary_code) |>
      dplyr::mutate(dplyr::across(dplyr::everything(), ~glue::glue(list_to_pipeline(universe_pipeline), " |> ", .x)))

    universe_results$summary <-
      purrr::map2_dfc(universe_summaries, names(universe_summaries), function(x, y){
        summaries <-
          collect_quiet_results(x) |>
          dplyr::rename_with(~paste0(y, "_", .x))
      })
  }

  if(stringr::str_detect(grid_elements, "post_hoc")){
    universe_post_hoc <-
      universe |>
      dplyr::select(post_hoc_code) |>
      tidyr::unnest(post_hoc_code) |>
      dplyr::mutate(dplyr::across(dplyr::everything(), ~glue::glue(list_to_pipeline(universe_pipeline), " |> ", .x)))

    universe_results$post_hoc <-
      purrr::map2_dfc(universe_post_hoc, names(universe_post_hoc), function(x, y){
        collect_quiet_results(x) |>
          dplyr::rename_with(~paste0(y, "_", .x))
      })
  }

  universe_results |>
    purrr::compact() |>
    purrr::reduce(dplyr::bind_cols) |>
    mutate(
      decision = decision_num,
      n_notes = across(matches("messages|warnings")) |> sum()
      ) |>
    tidyr::nest(code  = ends_with("code")) |>
    tidyr::nest(notes  = matches("messages|warnings")) |>
    select(decision, everything(), code, n_notes, notes)
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
