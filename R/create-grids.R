# Filter Grid -------------------------------------------------------------
create_filter_grid <- function(my_data, ..., print = TRUE){
  filter_exprs <- dplyr::enexprs(...)
  filter_exprs_chr <- as.character(filter_exprs)
  filter_vars <-
    stringr::str_extract(filter_exprs_chr, paste(names(my_data), collapse = "|"))

  filter_grid_summary1 <-
    purrr::map2_df(filter_exprs_chr, filter_vars, function(x, y){

      tibble::tibble(
        expr        = x,
        expr_var    = y,
        expr_n      = my_data |> dplyr::filter(rlang::parse_expr(x) |> rlang::eval_tidy()) |> nrow(),
        expr_type   = "filter"
      )

    })

  filter_grid_summary2 <-
    filter_grid_summary1 |>
    dplyr::pull(expr_var) |>
    unique() |>
    purrr::map_df(function(x){

      filter_grid_summary1 |>
        dplyr::filter(expr_var == x) |>
        tibble::add_row(
          expr        = glue::glue("{x} %in% unique({x})") |> as.character(),
          expr_var    = x,
          expr_n      = my_data |> dplyr::filter(rlang::parse_expr(expr) |> rlang::eval_tidy()) |> nrow(),
          expr_type   = "do nothing"
        )

    })

  filter_grid_expand <-
    df_to_expand_prep(filter_grid_summary2, expr_var, expr) |>
    df_to_expand()

  if(print){
    print(filter_grid_summary2)
  }

  list(
    grid_summary  = filter_grid_summary2,
    grid          = filter_grid_expand
  )
}

# Variable Grids ----------------------------------------------------------
create_var_grid <- function(my_data, ..., print = TRUE){
  vars_raw <- dplyr::enquos(..., .named = TRUE)
  var_groups <- names(vars_raw)

  var_grid_summary <-
    purrr::map2_df(vars_raw, var_groups, function(x,y){
      tibble::tibble(
        var_group = y,
        var       = my_data |> dplyr::select(!!x) |> names()
      )
    })

  var_grid <-
    df_to_expand_prep(var_grid_summary, var_group, var) |>
    df_to_expand()

  if(print){
    print(var_grid_summary)
  }

  list(
    grid_summary = var_grid_summary,
    grid         = var_grid
  )

}

# Model Grid --------------------------------------------------------------
create_model_grid <- function(...){
  model_formulas <- dplyr::enexprs(..., .named = T)
  model_formulas_chr <-
    as.character(model_formulas) |> stringr::str_remove_all("\n|    ")

  tibble::tibble(
    mod_group   = "models",
    mod_formula = model_formulas_chr
  )

}

# Pre and Post analysis code ----------------------------------------------
post_filter_code <- function(grid, ...){
  code <- dplyr::enexprs(..., .named = T)
  code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

  post_filter_code <-
    grid |>
    tidyr::unnest(dplyr::everything()) |>
    glue::glue_data(code_chr)

  dplyr::bind_cols(
    grid,
    post_filter_code = post_filter_code |> as.character()
  )

}

post_analysis_code <- function(grid, ...){
  code <- dplyr::enexprs(..., .named = T)
  code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

  post_analysis_code <-
    grid |>
    tidyr::unnest(dplyr::everything()) |>
    glue::glue_data(code_chr)

  dplyr::bind_cols(
    grid, post_analysis_code = post_analysis_code |> as.character()
  )

}
