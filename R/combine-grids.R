#' Combine grids of analysis decisions into a single \code{tibble}
#'
#' @param filter_grid a \code{tibble} created by
#'   \code{\link{create_filter_grid}}. This grid contains all observation (row)
#'   filtering decisions.
#' @param var_grid a \code{tibble} created by \code{\link{create_var_grid}}.
#'   This grid should contain different versions of variables or sets of
#'   different versions of variables.
#' @param model_grid a \code{tibble} created by \code{\link{create_model_grid}}.
#'   This grid contains the actual model syntax (with possible alternatives) to
#'   run over the specified grids.
#' @param post_filter_code a \code{tibble} created by
#'   \code{\link{post_filter_code}}. It should contain code you want to run just
#'   after filtering but before analysis
#' @param post_hoc_code a \code{tibble} created by \code{\link{post_hoc_code}}.
#'   It should contain code that executes post hoc processing or analysis on the
#'   model object specified in the \code{model_grid}. This could be something
#'   like standardizing coefficients or running post hoc analysis (e.g., simple
#'   slopes).
#'
#' @return The output of this function will be a \code{tibble} of all
#'   combinations of analysis decisions. Each decision is denoted by the column
#'   \code{decision}. Ecah type of decision grid will create a list column. For
#'   example, when \code{filter_grid} is provided, the master grid will contain
#'   the list column \code{filters} containing all filter deicions.
#' @export
#'
#' @examples
#' library(multitool)
#'
#' my_data <-
#'   data.frame(
#'    id   = 1:500,
#'    iv1  = rnorm(500),
#'    iv2  = rnorm(500),
#'    iv3  = rnorm(500),
#'    covariate1 = rnorm(500),
#'    covariate2 = rnorm(500),
#'    dv1 = rnorm(500),
#'    dv2 = rnorm(500),
#'    filter1   = sample(1:3, size = 500, replace = TRUE),
#'    filter2   = rnorm(500),
#'    filter3   = rbinom(500, size = 1, prob = .1),
#'    filter4   = rbinom(500, size = 1, prob = .1)
#'   )
#'
#' my_filter_grid <-
#'   create_filter_grid(
#'     my_data,
#'     filter1 == 1,
#'     filter1 == 2,
#'     filter2 == 0,
#'     filter3 == 0,
#'     filter4 == 0
#'   )
#'
#' my_var_grid <-
#'   create_var_grid(
#'     my_data = my_data,
#'     iv       = c(iv1, iv2, iv3),
#'     dv       = c(dv1, dv2),
#'     covariates = c(covariate1, covariate2)
#'   )
#'
#' my_model_grid <-
#'  create_model_grid(
#'    lm({dv} ~ {iv}),
#'    lm({dv} ~ {iv} + {covariates})
#'  )
#'
#' my_post_filter_code <-
#'   post_filter_code(
#'     mutate({iv} := scale({iv})),
#'     mutate({dv} := log({dv}))
#'   )
#'
#' combine_all_grids(
#'   my_filter_grid,
#'   my_var_grid,
#'   my_model_grid,
#'   my_post_filter_code,
#'
#' )
#'
combine_all_grids <- function(filter_grid = NULL, var_grid = NULL, model_grid = NULL, post_filter_code = NULL, post_hoc_code = NULL){

  all_grids <-
    list(
      filters          = NULL,
      variables        = NULL,
      models           = NULL,
      post_filter_code = NULL,
      post_hoc_code    = NULL
    )

  if(!is.null(filter_grid)){
    all_grids$filters <-
      df_to_expand_prep(filter_grid$grid_summary, expr_var, expr)
  }

  if(!is.null(var_grid)){
    all_grids$variables <-
      df_to_expand_prep(var_grid$grid_summary, var_group, var)
  }

  if(!is.null(model_grid)) {
    all_grids$models <- df_to_expand_prep(model_grid, mod_group, mod_formula)
  }

  if(!is.null(post_filter_code)){
    all_grids$post_filter_code <- df_to_expand_prep(post_filter_code, step, code)
  }

  if(!is.null(post_hoc_code)){
    all_grids$post_hoc_code <- df_to_expand_prep(post_hoc_code, post_hoc_test, code)
  }

  all_grids <-
    all_grids |>
    purrr::compact() |>
    purrr::flatten() |>
    df_to_expand() |>
    dplyr::mutate(decision = 1:dplyr::n()) |>
    dplyr::select(decision, dplyr::everything()) |>
    tidyr::nest(data = c(-decision, -matches("step|post_hoc_test|models"))) |>
    dplyr::mutate(across(matches("step|post_hoc_test|models"), ~purrr::map2_chr(data, .x, function(x, y) glue::glue_data(x, y)))) |>
    #dplyr::mutate(model_syntax = purrr::map_chr(data, function(x) glue::glue_data(x, x$models))) |>
    tidyr::unnest(data)
    #select(-models)

  if(!is.null(filter_grid)){
    all_grids <-
      all_grids |>
      tidyr::nest(filters   = dplyr::any_of(names(filter_grid$grid)))
  }

  if(!is.null(var_grid)){
    all_grids <-
      all_grids |>
      tidyr::nest(variables = dplyr::any_of(names(var_grid$grid)))
  }

  if(!is.null(post_filter_code)){
    all_grids <-
      all_grids |>
      tidyr::nest(post_filter_code = dplyr::any_of(starts_with("step")))
  }

  if(!is.null(post_hoc_code)){
    all_grids <-
      all_grids |>
      tidyr::nest(post_hoc_code = dplyr::any_of(starts_with("post_hoc_test")))
  }

  all_grids |>
    dplyr::select(
      decision,
      any_of(c("filters","variables", "post_filter_code", "post_hoc_code")),
      models
    )
}

