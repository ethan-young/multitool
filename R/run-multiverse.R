#' Run a multiverse based on a complete decision grid
#'
#' @param my_data a \code{data.frame} representing the the original data
#' @param grid a \code{data.frame} produced by \link{\code{combine_all_grids}}
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

  grid_elements <- paste(names(grid), collapse = " ")

  estimates <-
    grid |>
    dplyr::group_split(decision) |>
    purrr::map_df(function(universe){

      universe_pipeline <-
        list(
          universe_data = "my_data",
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
          select(starts_with("post_filter_code")) |>
          paste0(collapse = " |> ")

        universe_data <-
          list_to_pipeline(universe_pipeline, execute = TRUE)
      }

      if(stringr::str_detect(grid_elements, "model_syntax")){
        universe_pipeline$model <-
          universe |>
          select(model_syntax) |>
          str_replace(string = _ ,"\\)$", ", data = _)")
      }

      model_code <-
        universe_pipeline |>
        list_to_pipeline()

      universe_analysis <-
        universe_pipeline |>
        list_to_pipeline(execute = TRUE)

      if(stringr::str_detect(universe$model_syntax, "lmer")){
        universe_results <- broom.mixed::tidy(universe_analysis)
      } else{
        universe_results <- broom::tidy(universe_analysis)
      }

      if(stringr::str_detect(grid_elements, "post_hoc")){

        universe_pipeline$post_hoc_code <-
          universe |>
          select(starts_with("post_hoc")) |>
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
