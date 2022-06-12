grid_to_list <- function(my_grid){

  purrr::map(1:nrow(my_grid), function(x){

    my_grid <- my_grid |> dplyr::select(-dplyr::matches("filter_decision|decision"))

    grid_list <-
      my_grid |>
      dplyr::filter(dplyr::row_number() == x) |>
      tidyr::pivot_longer(dplyr::everything()) |>
      dplyr::pull(value)

    names(grid_list) <- names(my_grid)

    grid_list

  }) |>
    purrr::set_names(paste0("decision_", 1:nrow(my_grid)))

}

list_to_grid <- function(list_grid){

  if(!is.list(list_grid)){
    list_grid <- list(list_grid)
  }

  list_grid |>
    purrr::map_df(function(x) x |> as.list() |> tibble::as_tibble())

}

grid_to_formulas <- function(grid, glue_string){
  grid |>
    glue::glue_data(glue_string)
}

generate_multi_data <- function(my_data, filter_grid){

  filter_list <- grid_to_list(filter_grid$grid)

  multi_data_list <-
    purrr::map(filter_list, function(x){

      filter_expr <- glue::glue("filter(my_data, {paste(x, collapse = ', ')})") |> as.character()
      data <- rlang::parse_expr(filter_expr) |> rlang::eval_tidy()

      list(
        decisions = x,
        data      = my_data
      )
    })

  multi_data_list
}

df_to_expand_prep <- function(df, grouping_var, values_var){

  grid_prep <-
    df |>
    dplyr::distinct({{grouping_var}}) |>
    dplyr::pull() |>
    purrr::map(function(x){
      vect <-
        df |>
        dplyr::filter({{grouping_var}} == x) |>
        dplyr::pull({{values_var}})

      vect_chr <- paste0("'", vect, "'", collapse=",")

      new_vect <- glue::glue("{x} = c({paste0(vect_chr)})") |> as.character()
    })

  grid_prep
}



df_to_expand <- function(prep){

  glue::glue("tidyr::expand_grid({paste(prep, collapse = ', ')})") |>
    rlang::parse_expr() |>
    rlang::eval_tidy()

}
