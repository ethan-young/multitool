
column_plot <- function(.condensed, .col, type = "interval"){

  list_col_pre <-
    .condensed |>
    dplyr::select({{.col}}) |>
    names() |>
    stringr::str_remove("_.*")

  interval_range <-
    .condensed |>
    tidyr::unnest({{.col}}) |>
    dplyr::pull({{.col}}) |>
    range()

  if(type == "interval"){
    tab_column_plot <-
      .condensed |>
      dplyr::mutate(
        "{list_col_pre}_interval" :=
          purrr::map({{.col}}, multi_tab_interval, range = interval_range))
  }

  if(type == "dots"){
    tab_column_plot <-
      .condensed |>
      dplyr::mutate(
        "{list_col_pre}_dots" :=
          purrr::map({{.col}}, multi_tab_dots, range = interval_range))
  }

  if(type == "boxplot"){
    tab_column_plot <-
      .condensed |>
      dplyr::mutate(
        "{list_col_pre}_boxplot" :=
          purrr::map({{.col}}, multi_tab_boxplot, range = interval_range))
  }

  if(type == "dotinterval"){
    tab_column_plot <-
      .condensed |>
      dplyr::mutate(
        "{list_col_pre}_dotinterval" :=
          purrr::map({{.col}}, multi_tab_dotinterval, range = interval_range))
  }

  if(type == "curve"){
    tab_column_plot <-
      .condensed |>
      dplyr::mutate(
        "{list_col_pre}_curve" :=
          purrr::map({{.col}}, multi_tab_curve, range = interval_range))
  }

  if(type == "slab"){
    tab_column_plot <-
      .condensed |>
      dplyr::mutate(
        "{list_col_pre}_slab" :=
          purrr::map({{.col}}, multi_tab_slab, range = interval_range))
  }

  if(type == "slabinterval"){
    tab_column_plot <-
      .condensed |>
      dplyr::mutate(
        "{list_col_pre}_slabinterval" :=
          purrr::map({{.col}}, multi_tab_slabinterval, range = interval_range))
  }

  tab_column_plot

}

multi_tab_create <- function(.condensed, ...){
  gg_columns <-
    .condensed |>
    dplyr::select(-dplyr::ends_with("list")) |>
    dplyr::select(dplyr::where(is.list)) |>
    names()

  .condensed |>
    dplyr::select(-dplyr::ends_with("list")) |>
    flextable::flextable() |>
    flextable::mk_par(
      j = gg_columns,
      value =
        flextable::as_paragraph(
          flextable::gg_chunk(
            gg_columns |>
              paste0(collapse = ", ") |>
              paste0("c(", ... = _, ")") |>
              rlang::parse_expr() |>
              rlang::eval_tidy(),
            ...
          )
        )
    )
}
