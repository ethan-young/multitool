run_multiverse <- function(data, grid) {

  estimates <-
    grid |>
    dplyr::group_split(decision) |>
    purrr::map_df(function(x){

      filters <-
        x |>
        dplyr::pull(filters) |>
        unlist() |>
        paste0(collapse = ", ")

      universe_data <-
        glue::glue("dplyr::filter(sim_data, {filters})") |>
        rlang::parse_expr() |>
        rlang::eval_tidy()

      if("post_filter_code" %in% names(x)){
        universe_data <-
          glue::glue("universe_data |> {x$post_filter_code}") |>
          rlang::parse_expr() |>
          rlang::eval_tidy()
      }

      universe_analysis <-
        x$model_syntax |>
        stringr::str_replace_all("\\)$", ", data = universe_data)") |>
        rlang::parse_expr() |>
        rlang::eval_tidy()

      if(stringr::str_detect(x$model_syntax, "lmer")){
        results <- broom.mixed::tidy(universe_analysis)
      } else{
        results <- broom::tidy(universe_analysis)
      }

      if("post_analysis_code" %in% names(x)){
        post_analysis_results <-
          glue::glue("{x$post_analysis_code}") |>
          rlang::parse_expr() |>
          rlang::eval_tidy()

        results <-
          tibble::tibble(
            decision              = x$decision,
            data                  = list(universe_data),
            results               = list(results),
            post_analysis_results = list(post_analysis_results)
          )
      } else{

        results <-
          tibble::tibble(
            decision              = x$decision,
            data                  = list(universe_data),
            results               = list(results)
          )
      }

      message("decision ", x$decision, " executed")

      results
    })


  dplyr::full_join(grid, estimates, by = "decision")

}
