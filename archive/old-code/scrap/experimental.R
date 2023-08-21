# Combine variable grids --------------------------------------------------
exp_combine_var_grids <- function(grid1, grid2){

  grid1 |>
    tibble::rownames_to_column(var = "row_split") |>
    dplyr::group_by(row_split) |>
    dplyr::group_split() |>
    purrr::map_df(function(x) dplyr::bind_cols(x, grid2)) |>
    dplyr::select(-row_split)

}

exp1_combine_all_grids <- function(filter_grid = NULL, iv_grids = NULL, dv_grid = NULL, covariate_grids = NULL, model_grid = NULL){

  all_grids <-
    list(
      filters    = NULL,
      ivs        = NULL,
      dvs        = NULL,
      covariates = NULL,
      models     = NULL
    )

  if(!is.null(filter_grid)){
    all_grids$filters <- filter_grid$grid
  }

  if(!is.null(iv_grids)){

    iv_grids_prep <-
      purrr::map2(seq_along(iv_grids), iv_grids, function(x, y){

        y |> dplyr::rename_with(~stringr::str_replace(.x, "iv", paste0("iv", x)))

      })

    iv_grid <- purrr::reduce(iv_grids_prep, combine_var_grids)

    all_grids$ivs <-  iv_grid

  }

  if(!is.null(dv_grid)){
    all_grids$dvs <-  dv_grid
  }

  if(!is.null(covariate_grids)){

    covariate_grids_prep <-
      purrr::map2(seq_along(covariate_grids), covariate_grids, function(x, y){

        y |> dplyr::rename_with(~str_replace(.x, "covariate", paste0("covariate", x)))

      })

    covariate_grid <- purrr::reduce(covariate_grids_prep, combine_var_grids)

    all_grids$covariates <-  covariate_grids
  }

  if(!is.null(model_grid)) {

    all_grids$models <- model_grid
  }

  all_grids <- all_grids |>
    purrr::discard(is.null) |>
    purrr::reduce(combine_var_grids) |>
    dplyr::mutate(
      decision = 1:n()
    ) |>
    dplyr::select(
      decision,
      dplyr::starts_with("dv"),
      dplyr::starts_with("iv"),
      dplyr::starts_with("covari"),
      dplyr::starts_with("filter"),
      dplyr::starts_with("mod")
    )


  if("mod_formula" %in% names(all_grids)) {
    all_grids <- all_grids |>
      tidyr::nest(
        data = c(
          dplyr::starts_with("dv"),
          dplyr::starts_with("iv"),
          dplyr::starts_with("covari"),
          mod_formula)
      ) |>
      dplyr::mutate(
        dynamic_formula = purrr::map_chr(data, function(x) glue::glue_data(x, x$mod_formula))
      ) |>
      tidyr::unnest(data) |>
      dplyr::select(-mod_formula) |>
      dplyr::rename(mod_formula = dynamic_formula) |>
      dplyr::select(
        decision,
        dplyr::starts_with("dv"),
        dplyr::starts_with("iv"),
        dplyr::starts_with("covari"),
        dplyr::starts_with("filter"),
        dplyr::starts_with("mod")
      )
  }

  all_grids
}

exp2_combine_all_grids <- function(filter_grid = NULL, var_grid = NULL, model_grid = NULL, nest = T){

  all_grids <-
    list(
      filters    = NULL,
      variables  = NULL,
      models     = NULL
    )

  if(!is.null(filter_grid)){
    all_grids$filters <- df_to_expand_prep(filter_grid$grid_summary, expr_var, expr)
  }

  if(!is.null(var_grid)){
    all_grids$variables <- df_to_expand_prep(var_grid$grid_summary, var_group, var)
  }

  if(!is.null(model_grid)) {
    all_grids$models <- df_to_expand_prep(model_grid, mod_group, mod_formula)
  }

  all_grids <-
    all_grids |>
    purrr::discard(is.null) |>
    purrr::flatten() |>
    df_to_expand() |>
    dplyr::mutate(decision = 1:n()) |>
    dplyr::select(decision, everything()) |>
    tidyr::nest(data = c(-decision)) |>
    dplyr::mutate(model_syntax = map_chr(data, function(x) glue::glue_data(x, x$models))) |>
    tidyr::unnest(data) |>
    dplyr::select(-models) |>
    dplyr::rename_with(~paste0("var_", .x), dplyr::any_of(names(var_grid$grid))) |>
    dplyr::rename_with(~paste0("filter_", .x), dplyr::any_of(names(filter_grid$grid)))


  if(nest){
    all_grids |>
      tidyr::nest(filters = starts_with("filter_")) |>
      tidyr::nest(variables = starts_with("var_")) |>
      dplyr::select(decision, filters, variables, model_syntax)
  }
}

# Create Variable Grids ---------------------------------------------------
exp_create_iv_grid <- function(my_data, ...){
  vars <- enquos(..., .named = TRUE)
  var_groups <- names(vars)

  map2_df(vars, var_groups, function(x,y){
    tibble(
      iv_group = y,
      iv       = my_data %>% select(!!x) %>% names
    )
  })
}

exp_create_dv_grid <- function(my_data, ...){
  vars <- enquos(..., .named = TRUE)
  var_groups <- names(vars)

  map2_df(vars, var_groups, function(x,y){
    tibble(
      dv_group = y,
      dv       = my_data %>% select(!!x) %>% names
    )
  })
}

exp_create_covariate_grid <- function(my_data, ...){
  vars <- enquos(..., .named = TRUE)
  var_groups <- names(vars)

  map2_df(vars, var_groups, function(x,y){
    tibble(
      covariate_group = y,
      covariate       = my_data %>% select(!!x) %>% names
    )
  })
}

# Create Model Grids ------------------------------------------------------
exp_create_model_grid <- function(formulas, models) {

  stopifnot("The list of formulas must be of the same length as the list of models."= length(formulas)==length(models))

  map2_df(formulas, models, function(f, m) {

    tibble(
      mod_formula = f,
      mod_type    = m[[1]],
      mod_args    = ifelse(length(m) == 2, list(m[[2]]), NA)
    )
  }) %>%
    mutate(mod_group = names(formulas)) %>%
    select(mod_group, everything())
}

# Run multiverse ----------------------------------------------------------
exp_run_multiverse <- function(data, grid) {

  model_output <- grid %>%
    dplyr::select(dplyr::matches("^filter_"), model_syntax) %>%
    grid_to_list() %>%
    map_df(function(universe){

      # Filter data
      filtered_data <- data %>%
        filter(rlang::parse_expr(universe[str_detect(names(universe), "^filter_")] %>% str_c(collapse = " & ")) %>% rlang::eval_tidy())

      # Fit model
      mod <- universe[str_detect(names(universe), "^model_syntax")] %>%
        str_replace_all("\\)$", ", data = data_filtered)") %>%
        rlang::parse_expr() %>%
        rlang::eval_tidy()


      # Return results
      tibble(
        data = list(filtered_data),
        model = list(mod)
      )
    })

  grid %>%
    bind_cols(model_output)
}
