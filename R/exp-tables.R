
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


multi_tab_interval <- function(x, range){
  tibble::tibble(stat = x) |>
    ggplot2::ggplot(ggplot2::aes(x = stat)) +
    ggdist::stat_pointinterval() +
    ggplot2::scale_x_continuous(limits = range) +
    ggplot2::theme_void()
}

multi_tab_dots <- function(x, range){
  tibble::tibble(stat = x) |>
    ggplot2::ggplot(ggplot2::aes(x = stat)) +
    ggdist::geom_dots() +
    ggplot2::scale_x_continuous(limits = range) +
    ggplot2::theme_void()
}

multi_tab_dotinterval <- function(x, range){
  tibble::tibble(stat = x) |>
    ggplot2::ggplot(ggplot2::aes(x = stat)) +
    ggdist::stat_dotsinterval() +
    ggplot2::scale_x_continuous(limits = range) +
    ggplot2::theme_void()
}

multi_tab_slab <- function(x, range){
  tibble::tibble(stat = x) |>
    ggplot2::ggplot(ggplot2::aes(x = stat)) +
    ggdist::stat_slab() +
    ggplot2::scale_x_continuous(limits = range) +
    ggplot2::theme_void()
}

multi_tab_slabinterval <- function(x, range){
  tibble::tibble(stat = x) |>
    ggplot2::ggplot(ggplot2::aes(x = stat)) +
    ggdist::stat_slabinterval() +
    ggplot2::scale_x_continuous(limits = range) +
    ggplot2::theme_void()
}

multi_tab_curve <- function(x, range){
  tibble(stat = sort(x), x = 1:length(x)) |>
    ggplot2::ggplot(ggplot2::aes(x = x, y = stat)) +
    ggplot2::geom_line() +
    ggplot2::scale_y_continuous(limits = range) +
    ggplot2::theme_void()
}

multi_tab_boxplot <- function(x, range){
  tibble::tibble(stat = x) |>
    ggplot2::ggplot(ggplot2::aes(x = stat)) +
    ggplot2::geom_boxplot() +
    ggplot2::scale_x_continuous(limits = range) +
    ggplot2::theme_void()
}
