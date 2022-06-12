#' Combine grids of analysis decisions into a single \code{tibble}
#'
#' @param filter_grid a data.frame created using
#'   \code{\link{create_filter_grid()}}. This grid contains all observation
#'   (row) filtering decisions.
#' @param var_grid a data.frame created using \code{\link{create_var_grid()}}.
#'   This grid should contain different versions of variables or sets of
#'   different versions of variables.
#' @param model_grid a data.frame created using
#'   \code{\link{create_model_grid()}}. This grid contains the actual model
#'   syntax (with possible alternatives) to run over the specified grids.
#'
#' @return The output of this function will be a \code{tibble} of all
#'   combinations of analysis decisions. Each decision is denoted by the column
#'   \code{decision}. Ecah type of decision grid will create a list column. For
#'   example, when \code{filter_grid} is provided, the master grid will contain
#'   the list column \code{filters} containing all filter deicions.
#' @export
#'
#' @examples
#'
#' library(multitool)
#'
#' data <-
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
#'     data,
#'     filter1 == 1,
#'     filter1 == 2,
#'     filter2 == 0,
#'     filter3 == 0,
#'     filter4 == 0
#'   )
#'
#' my_var_grid <-
#'   create_var_grid(
#'     my_data = sim_data,
#'     iv       = c(iv1, iv2, iv3),
#'     dv       = c(dv1, dv2),
#'     covariates = c(covariate1, covariate2)
#'   )
#'
#' my_model_grid <-
#' create_model_grid(
#'   lm({dv} ~ {iv}),
#'   lm({dv} ~ {iv} + {covariates})
#' )
#'
#' combine_all_grids(my_filter_grid, my_var_grid, my_model_grid)
#'
combine_all_grids <- function(filter_grid = NULL, var_grid = NULL, model_grid = NULL){

  all_grids <-
    list(
      filters    = NULL,
      variables  = NULL,
      models     = NULL
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

  all_grids <-
    all_grids |>
    purrr::discard(is.null) |>
    purrr::flatten() |>
    df_to_expand() |>
    dplyr::mutate(decision = 1:dplyr::n()) |>
    dplyr::select(decision, dplyr::everything()) |>
    tidyr::nest(data = c(-decision)) |>
    dplyr::mutate(
      model_syntax = purrr::map_chr(data, function(x) glue::glue_data(x, x$models))) |>
    tidyr::unnest(data) |>
    dplyr::select(-models) |>
    tidyr::nest(filters   = dplyr::any_of(names(filter_grid$grid))) |>
    tidyr::nest(variables = dplyr::any_of(names(var_grid$grid))) |>
    dplyr::select(decision, filters, variables, model_syntax)
}

