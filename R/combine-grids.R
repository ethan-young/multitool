#' Combine grids of analysis decisions into a single \code{tibble}
#'
#' @param filter_grid a \code{tibble} created by
#'   \code{\link{create_filter_grid}}. This grid contains all observation (row)
#'   filtering decisions.
#' @param var_grid a \code{tibble} created by \code{\link{create_var_grid}}.
#'   This grid should contain different versions of variables or sets of
#'   different versions of variables.
#' @param post_filter_code a \code{tibble} created by
#'   \code{\link{post_filter_code}}. It should contain code you want to run just
#'   after filtering but before analysis
#' @param model_code a \code{tibble} created by \code{\link{create_model_grid}}.
#'   This grid contains the actual model syntax (with possible alternatives) to
#'   run over the specified grids.
#' @param post_hoc_code a \code{tibble} created by \code{\link{post_hoc_code}}.
#'   It should contain code that executes post hoc processing or analysis on the
#'   model object specified in the \code{model_grid}. This could be something
#'   like standardizing coefficients or running post hoc analysis (e.g., simple
#'   slopes).
#'
#' @return The output of this function will be a \code{tibble} of all
#'   combinations of analysis decisions. Each decision is denoted by the column
#'   \code{decision}. Filter and variable grids (if they were included) will
#'   become list columns. For example, when \code{filter_grid} is provided, the
#'   master grid will contain the list column \code{filters} containing all
#'   filter decisions. An analysis pipeline list column will also be created. In
#'   the simplest case this will just be the model you plan to run. In more
#'   complex cases, it will contain code to run after filters, the model,
#'   different summaries, and any post-hoc tests.
#' @export
#'
#' @examples
#' library(multitool)
combine_all_grids <-
  function(
    var_grid = NULL,
    filter_grid = NULL,
    model_grid = NULL,
    post_filter_code = NULL,
    model_summary_code = NULL,
    post_hoc_code = NULL)
  {

    all_grids <-
      list(
        variables          = NULL,
        filters            = NULL,
        model_code         = NULL,
        post_filter_code   = NULL,
        model_summary_code = NULL,
        post_hoc_code      = NULL
      )

    if(!is.null(var_grid)){
      all_grids$variables <-
        df_to_expand_prep(var_grid$summary, var_group, var)
    }

    if(!is.null(filter_grid)){
      all_grids$filters <-
        df_to_expand_prep(filter_grid$summary, filter_group, filter_expr)
    }

    if(!is.null(model_grid)) {
      all_grids$model_code <- df_to_expand_prep(model_grid$summary, model, code)
    }

    if(!is.null(post_filter_code)){
      all_grids$post_filter_code <- df_to_expand_prep(post_filter_code, post_filter_step, code)
    }

    if(!is.null(model_summary_code)){
      all_grids$model_summary_code <- df_to_expand_prep(model_summary_code, summary, code)
    }

    if(!is.null(post_hoc_code)){
      all_grids$post_hoc_code <- df_to_expand_prep(post_hoc_code, post_hoc_test, code)
    }

    combined_grid <-
      all_grids |>
      purrr::compact() |>
      purrr::flatten() |>
      df_to_expand() |>
      dplyr::mutate(decision = 1:dplyr::n()) |>
      dplyr::select(decision, dplyr::everything()) |>
      tidyr::nest(data = c(-decision, -matches("step|model|summary|test"))) |>
      dplyr::mutate(across(matches("step|model|summary|test"), ~purrr::map2_chr(data, .x, function(x, y) glue::glue_data(x, y)))) |>
      tidyr::unnest(data)

    if(!is.null(filter_grid)){
      combined_grid <-
        combined_grid |>
        tidyr::nest(filters = dplyr::any_of(names(filter_grid$grid)))
    }

    if(!is.null(var_grid)){
      combined_grid <-
        combined_grid |>
        tidyr::nest(variables = dplyr::any_of(names(var_grid$grid)))
    }

    if(!is.null(post_filter_code)){
      combined_grid <-
        combined_grid |>
        tidyr::nest(post_filter_code = dplyr::any_of(starts_with("post_filter")))
    }

    if(!is.null(model_summary_code)){
      combined_grid <-
        combined_grid |>
        tidyr::nest(model_summary_code = dplyr::any_of(starts_with("summary")))
    }

    if(!is.null(post_hoc_code)){
      combined_grid <-
        combined_grid |>
        tidyr::nest(post_hoc_code = dplyr::any_of(starts_with("post_hoc")))
    }

    all_combinations <-
      list(
        variable  = var_grid$combinations,
        filter    = filter_grid$combinations,
        model     = model_grid$combinations
      ) |>
      purrr::compact()

    all_combinations <-
      map2_df(all_combinations, names(all_combinations), function(x, y){
        combs <-
          x |>
          rename_with(~c("group", "n_alternatives")) |>
          mutate(
            category = paste0("(", y, ") "),
            category = ifelse(category != "(model) ", category, ""))
      })

    n_combinations <-
      all_combinations |>
      pull(n_alternatives) |>
      cumprod() |>
      max()

    combination_products <-
      all_combinations |>
      pull(n_alternatives) |>
      paste0(... = _, collapse = '*')

    message(glue::glue_data(all_combinations, "{group} {category}has {n_alternatives} alternatives\n", .trim = FALSE))
    message(glue::glue("{n_combinations} combinations ({combination_products} = {n_combinations})"))

    combined_grid |>
      dplyr::select(
        decision,
        any_of(c("variables", "filters", "post_filter_code", "model", "model_summary_code", "post_hoc_code"))
      )
  }

