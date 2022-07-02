add_filters <- function(.df, ...){
  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <- rlang::parse_expr(data_chr) |> rlang::eval_tidy()

  filter_exprs <- dplyr::enexprs(...)
  filter_exprs_chr <- as.character(filter_exprs)
  filter_vars <-
    stringr::str_extract(
      filter_exprs_chr,
      paste(
        base_df|> names(),
        collapse = "|"
      )
    )

  grid_prep1 <-
    purrr::map2_df(filter_exprs_chr, filter_vars, function(x, y){

      tibble::tibble(
        type  = "filter",
        group = y,
        code  = x
      )

    })

  grid_prep2 <-
    grid_prep1 |>
    dplyr::pull(group) |>
    unique() |>
    purrr::map_df(function(x){

      grid_prep1 |>
        dplyr::filter(group == x) |>
        tibble::add_row(
          type  = "filter",
          group = x,
          code  = glue::glue("{x} %in% unique({x})") |> as.character()
        )

    })

  if(!is.null(data_attr)){
    grid_prep <- bind_rows(.df, grid_prep2)
  } else{
    grid_prep <- grid_prep2
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep

}

add_variables <- function(.df, var_group, ...){
  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <- rlang::parse_expr(data_chr) |> rlang::eval_tidy()

  grid_prep <-
    tibble::tibble(
      type  = "variable",
      group = var_group,
      code  = base_df |> dplyr::select(...) |> names()
    )

  if(!is.null(data_attr)){
    grid_prep <- bind_rows(.df, grid_prep)
  } else{
    grid_prep <- grid_prep
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep

}

add_preprocess <- function(.df, process_name, code){
  code <- dplyr::enexprs(code)
  code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <- rlang::parse_expr(data_chr) |> rlang::eval_tidy()

  grid_prep <-
    tibble::tibble(
      type  = "preprocess",
      group = process_name,
      code  = code_chr
    )

  if(!is.null(data_attr)){
    grid_prep <- bind_rows(.df, grid_prep)
  } else{
    grid_prep <- grid_prep
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep

}

add_model <- function(.df, model_name, code){
  code <- dplyr::enexprs(code)
  code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <- rlang::parse_expr(data_chr) |> rlang::eval_tidy()

  grid_prep <-
    tibble::tibble(
      type  = "model",
      group = model_name,
      code  = code_chr
    )

  if(!is.null(data_attr)){
    grid_prep <- bind_rows(.df, grid_prep)
  } else{
    grid_prep <- grid_prep
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep

}

add_postprocess <- function(.df, postprocess_name, code){

  code <- dplyr::enexprs(code)
  code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <- rlang::parse_expr(data_chr) |> rlang::eval_tidy()

  grid_prep <-
    tibble::tibble(
      type  = "postprocess",
      group = postprocess_name,
      code  = code_chr
    )

  if(!is.null(data_attr)){
    grid_prep <- bind_rows(.df, grid_prep)
  } else{
    grid_prep <- grid_prep
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep


}

add_descriptives <- function(.df, var_set, variables, stats){

  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <- rlang::parse_expr(data_chr) |> rlang::eval_tidy()

  variables <- enexprs(variables) |> as.character()

  stats_list <-
    map_chr(stats, function(x) glue::glue("{x} = {x}")) |>
    paste(collapse = ", ") |> paste0("list(", ... = _, ")")

  descriptives <-
    glue::glue(
      'summarize(
        across(
          c([variables]),
          [stats_list],
          na.rm = TRUE,
          .names = "{.col}_{.fn}"
        )
      )',
      .open = "[",
      .close = "]"
    ) |>
    as.character() |>
    stringr::str_remove_all("\n|  ")

  grid_prep <-
    tibble::tibble(
      type  = "descriptive_stats",
      group = var_set,
      code  = descriptives
    )

  if(!is.null(data_attr)){
    grid_prep <- bind_rows(.df, grid_prep)
  } else{
    grid_prep <- grid_prep
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep

}

add_corrs <-
  function(
    .df,
    var_set,
    variables,
    focus = NULL,
    stretch = FALSE,
    pair_ns = TRUE,
    use = 'pairwise.complete.obs',
    method = 'pearson'
  ){

    data_chr <- dplyr::enexpr(.df) |> as.character()
    data_attr <- attr(.df, "base_df")

    if(!is.null(data_attr)){
      data_chr <- attr(.df, "base_df")
    }

    base_df <- rlang::parse_expr(data_chr) |> rlang::eval_tidy()

    variables <- enexprs(variables) |> as.character()
    focus_set <- enexprs(focus) |> as.character()

    if(is.null(focus)){
      correlations <-
        glue::glue(
          'select(c({variables})) |> correlate(use = "{use}", method = "{method}")'
        ) |>
        as.character() |>
        stringr::str_remove_all("\n|  ")
    } else{
      correlations <-
        glue::glue(
          'select(c({variables})) |> correlate(use = "{use}", method = "{method}") |> focus({focus_set})'
        ) |>
        as.character() |>
        stringr::str_remove_all("\n|  ")
    }

    if(stretch){
      correlations <-
        glue::glue(
          'select(c({variables})) |> correlate(use = "{use}", method = "{method}") |> stretch(na.rm = TRUE, remove.dups = TRUE)'
        ) |>
        as.character() |>
        stringr::str_remove_all("\n|  ")
    }

    grid_prep_corrs <-
      tibble::tibble(
        type  = "correlations",
        group = var_set,
        code  = correlations
      )

    if(pair_ns){
      corr_pair_ns <-
        glue::glue(
          'select(c({variables})) |> pair_n()'
        ) |>
        as.character() |>
        stringr::str_remove_all("\n|  ")

      grid_prep_ns <-
        tibble(
          type = "correlation_ns",
          group = var_set,
          code = corr_pair_ns
        )

      grid_prep <- bind_rows(grid_prep_corrs, grid_prep_ns)
    } else{
      grid_prep <- grid_prep_corrs
    }

    if(!is.null(data_attr)){
      grid_prep <- bind_rows(.df, grid_prep)
    } else{
      grid_prep <- grid_prep
    }

    attr(grid_prep, "base_df") <- data_chr
    grid_prep
  }

add_cronalpha <- function(.df, scale_name, items, keys = NULL){}
