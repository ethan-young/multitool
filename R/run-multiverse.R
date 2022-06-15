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
run_universe <- function(my_grid, my_data, decision_num){

  data_chr <- dplyr::enexpr(my_data)|> as.character()
  grid_elements <- paste(names(my_grid), collapse = " ")

  universe <-
    my_grid |>
    filter(decision == decision_num)

  universe_pipeline <-
    list(
      universe_data = data_chr,
      filters = NULL,
      post_filter_code = NULL,
      model = NULL,
      model_summary = NULL,
      post_hoc_code = NULL
    )

  universe_data <- my_data

  if(stringr::str_detect(grid_elements, "filters")){
    universe_pipeline$filters <-
      universe |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")
  }

  if(stringr::str_detect(grid_elements, "post_filter")){
    universe_pipeline$post_filter_code <-
      universe |>
      dplyr::pull(post_filter_code) |>
      unlist() |>
      paste0(collapse = " |> ")
  }

  if(stringr::str_detect(grid_elements, "model")){
    universe_pipeline$model <-
      universe |>
      dplyr::pull(model) |>
      str_replace(string = _ ,"\\)$", ", data = _)")
  }

  if(stringr::str_detect(grid_elements, "summary")){
    universe_summaries <-
      universe |>
      dplyr::select(model_summary_code) |>
      tidyr::unnest(model_summary_code) |>
      mutate(across(everything(), ~glue::glue(list_to_pipeline(universe_pipeline), " |> ", .x)))

    universe_results <-
      map2_dfc(universe_summaries, names(universe_summaries), function(x, y){
        quiet_results <- run_universe_code_quietly(x) |> compact()
        universe_results <- quiet_results$result
        universe_results_notes <-
          quiet_results[3:length(quiet_results)] |>
          as_tibble()

        tibble(
          code           = x,
          results        = list(universe_results),
          results_notes  = list(universe_results_notes)
        ) |>
          rename_with(~paste0("model_", y, "_", .x))
      })
  }

  if(stringr::str_detect(grid_elements, "post_hoc")){
    universe_post_hoc <-
      universe |>
      dplyr::select(post_hoc_code) |>
      tidyr::unnest(post_hoc_code) |>
      mutate(across(everything(), ~glue::glue(list_to_pipeline(universe_pipeline), " |> ", .x)))

    post_hoc_results <-
      map2_dfc(universe_post_hoc, names(universe_post_hoc), function(x, y){
        quiet_results <- run_universe_code_quietly(x) |> compact()
        universe_results <- quiet_results$result
        universe_results_notes <-
          quiet_results[3:length(quiet_results)] |>
          as_tibble()

        tibble(
          code           = x,
          results        = list(universe_results),
          results_notes  = list(universe_results_notes)
        ) |>
          rename_with(~paste0(y, "_", .x))
      })
  }

  post_hoc_results

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
run_multiverse <- function(my_data, grid) {
  data_chr <- dplyr::enexpr(my_data)|> as.character()
  grid_elements <- paste(names(grid), collapse = " ")

  estimates <-
    grid |>
    dplyr::group_split(decision) |>
    purrr::map_df(function(universe){

      universe_pipeline <-
        list(
          universe_data = data_chr,
          filters = NULL,
          post_filter_code = NULL,
          model = NULL,
          post_hoc_code = NULL
        )

      universe_data <- my_data

      if(stringr::str_detect(grid_elements, "filters")){
        universe_pipeline$filters <-
          universe |>
          dplyr::pull(filters) |>
          unlist() |>
          paste0(collapse = ", ") |>
          paste0("dplyr::filter(", ... =  _, ")")

        universe_data <-
          list_to_pipeline(universe_pipeline, execute = TRUE)
      }

      if(stringr::str_detect(grid_elements, "post_filter")){
        universe_pipeline$post_filter_code <-
          universe |>
          dplyr::pull(post_filter_code) |>
          unlist() |>
          paste0(collapse = " |> ")

        universe_data <-
          list_to_pipeline(universe_pipeline, execute = TRUE)
      }

      if(stringr::str_detect(grid_elements, "models")){
        universe_pipeline$model <-
          universe |>
          select(models) |>
          str_replace(string = _ ,"\\)$", ", data = _)")
      }

      model_code <-
        universe_pipeline |>
        list_to_pipeline()

      universe_analysis <-
        universe_pipeline |>
        list_to_pipeline(execute = TRUE)

      if(stringr::str_detect(universe$models, "lmer")){
        universe_results <- broom.mixed::tidy(universe_analysis)
      } else{
        universe_results <- broom::tidy(universe_analysis)
      }

      if(stringr::str_detect(grid_elements, "post_hoc")){

        universe_pipeline$post_hoc_code <-
          universe |>
          dplyr::pull(post_hoc_code) |>
          unlist() |>
          paste0()

        post_hoc_code <-
          universe_pipeline |>
          list_to_pipeline()

        universe_post_hoc <-
          universe_pipeline |>
          list_to_pipeline(execute = TRUE)

        results <-
          tibble::tibble(
            decision            = universe$decision,
            data                = list(universe_data),
            model_code          = model_code,
            model_results       = list(universe_results),
            model_post_hoc      = list(universe_post_hoc),
            model_post_hoc_code = post_hoc_code
          )
      } else{
        results <-
          tibble::tibble(
            decision            = universe$decision,
            data                = list(universe_data),
            model_code          = model_code,
            model_results       = list(universe_results)
          )
      }

      message("decision ", universe$decision, " executed")

      results
    })

  dplyr::full_join(grid, estimates, by = "decision")
}
