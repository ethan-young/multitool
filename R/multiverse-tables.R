
column_plot <- function(.condensed, .col, type = "interval"){

  list_col_pre <-
    .condensed |>
    select({{.col}}) |>
    names() |>
    str_remove("_.*")

  interval_range <-
    .condensed |>
    unnest({{.col}}) |>
    pull({{.col}}) |>
    range()

  if(type == "interval"){
    tab_column_plot <-
      .condensed |>
      mutate(
        "{list_col_pre}_interval" :=
          map({{.col}}, multi_tab_interval, range = interval_range))
  }

  if(type == "dots"){
    tab_column_plot <-
      .condensed |>
      mutate(
        "{list_col_pre}_dots" :=
          map({{.col}}, multi_tab_dots, range = interval_range))
  }

  if(type == "boxplot"){
    tab_column_plot <-
      .condensed |>
      mutate(
        "{list_col_pre}_boxplot" :=
          map({{.col}}, multi_tab_boxplot, range = interval_range))
  }

  if(type == "dotinterval"){
    tab_column_plot <-
      .condensed |>
      mutate(
        "{list_col_pre}_dotinterval" :=
          map({{.col}}, multi_tab_dotinterval, range = interval_range))
  }

  if(type == "curve"){
    tab_column_plot <-
      .condensed |>
      mutate(
        "{list_col_pre}_curve" :=
          map({{.col}}, multi_tab_curve, range = interval_range))
  }

  if(type == "slab"){
    tab_column_plot <-
      .condensed |>
      mutate(
        "{list_col_pre}_slab" :=
          map({{.col}}, multi_tab_slab, range = interval_range))
  }

  if(type == "slabinterval"){
    tab_column_plot <-
      .condensed |>
      mutate(
        "{list_col_pre}_slabinterval" :=
          map({{.col}}, multi_tab_slabinterval, range = interval_range))
  }

  tab_column_plot

}

multi_tab_create <- function(.condensed, ...){
  gg_columns <-
    .condensed |>
    select(-ends_with("list")) |>
    select(where(is.list)) |>
    names()

  .condensed |>
    select(-ends_with("list")) |>
    flextable() |>
    mk_par(
      j = gg_columns,
      value =
        as_paragraph(
          gg_chunk(
            gg_columns |>
              paste0(collapse = ", ") |>
              paste0("c(", ... = _, ")") |>
              rlang::parse_expr() |>
              rlang::eval_tidy(),
            ...)
        )
    )
}
