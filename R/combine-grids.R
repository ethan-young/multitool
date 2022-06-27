#' Combine grids of analysis decisions into a single \code{tibble}
#'
#' @param .df a \code{data.frame} representing the the original data
#' @param filter_grid a \code{tibble} created by
#'   \code{\link{create_filter_grid}}. This grid contains all observation (row)
#'   filtering decisions.
#' @param var_grid a \code{tibble} created by \code{\link{create_var_grid}}.
#'   This grid should contain different versions of variables or sets of
#'   different versions of variables.
#' @param model_grid a \code{tibble} created by \code{\link{create_model_grid}}.
#'   This grid contains the actual model syntax (with possible alternatives) to
#'   run over the specified grids.
#' @param preprocessing a \code{tibble} created by
#'   \code{\link{create_preprocess}}. It should contain code you want to run
#'   just after filtering but before analysis
#' @param postprocessing a \code{tibble} created by
#'   \code{\link{create_postprocess}}. It should contain code that executes post
#'   hoc processing or analysis on the model object specified in the
#'   \code{model_grid}. This could be something like standardizing coefficients
#'   or running post hoc analysis (e.g., simple slopes).
#'
#' @return The output of this function will be a \code{tibble} of all
#'   combinations of analysis decisions. It contains the following columns:
#'
#'   \describe{ \item{\code{decision}}{a numeric column from 1 to n combinations
#'   of decisions} \item{\code{filters}}{Filters (if they were included) as a
#'   list column.} \item{\code{variables}}{Variable combinations as a list
#'   column} \item{\code{model}}{The model, based on the decisions, that will be
#'   fit.} \item{\code{preprocess}}{any pre-processing steps contained in a list
#'   column} \item{\code{postprocess}}{any post-processing tasks contained in a
#'   list column}}
#'
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#' ## Simulate some data
#' the_data <-
#'   data.frame(
#'     id   = 1:500,
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     iv3  = rnorm(500),
#'     mod1 = rnorm(500),
#'     mod2 = rnorm(500),
#'     mod3 = rnorm(500),
#'     cov1 = rnorm(500),
#'     cov2 = rnorm(500),
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' ## Create variable grid
#' my_var_grid <-
#'   create_var_grid(
#'     .df = the_data,
#'     iv  = c(iv1, iv2, iv3),
#'     mod = c(mod1, mod2, mod3),
#'     dv  = c(dv1, dv2),
#'     cov = c(cov1, cov2)
#'   )
#'
#' ## Create a filter grid
#' my_filter_grid <-
#'   create_filter_grid(
#'     .df = the_data,
#'     include1 == 0,
#'     include2 != 3,
#'     include2 != 2,
#'     scale(include3) > -2.5
#'   )
#'
#' ## Create model grid
#' my_model_grid <-
#'   create_model_grid(
#'     lm({dv} ~ {iv} * {mod}),
#'     lm({dv} ~ {iv} * {mod} + {cov})
#'   )
#'
#'
#' ## Add arbitrary code
#'
#' # Code to execute after filtering step
#' my_preprocess <-
#'   create_preprocess(
#'     mutate({iv} := scale({iv}) |> as.numeric())
#'   )
#'
#' # Code to execute after analysis is done
#' my_postprocess <-
#'   create_postprocess(
#'     aov()
#'   )
#'
#' ## Combine all grids together
#' my_full_grid <-
#'   combine_all_grids(
#'     the_data,
#'     my_var_grid,
#'     my_filter_grid,
#'     my_model_grid,
#'     my_preprocess,
#'     my_postprocess
#'   )
combine_all_grids <-
  function(
    .df,
    var_grid = NULL,
    filter_grid = NULL,
    model_grid = NULL,
    preprocessing = NULL,
    postprocessing = NULL
  )
  {

    base_df <- dplyr::enexpr(.df) |> as.character()

    all_grids <-list()

    if(!is.null(var_grid)){
      all_grids$variables <-
        df_to_expand_prep(var_grid$summary, var_group, var)
    }

    if(!is.null(filter_grid)){
      all_grids$filters <-
        df_to_expand_prep(filter_grid$summary, filter_group, filter_expr)
    }

    if(!is.null(model_grid)) {
      all_grids$model_code <-
        df_to_expand_prep(model_grid$summary, model, code)
    }

    if(!is.null(preprocessing)){
      all_grids$preprocessing_code <-
        df_to_expand_prep(preprocessing, preprocess, code)
    }

    if(!is.null(postprocessing)){
      all_grids$postprocessing_code <-
        df_to_expand_prep(postprocessing, postprocess, code)
    }

    combined_grid <-
      all_grids |>
      purrr::flatten() |>
      df_to_expand() |>
      dplyr::mutate(decision = 1:dplyr::n()) |>
      dplyr::select(decision, dplyr::everything()) |>
      tidyr::nest(data = c(-decision, -dplyr::matches("step|model|set"))) |>
      dplyr::mutate(
        dplyr::across(
          dplyr::matches("step|model|set"),
          ~purrr::map2_chr(data, .x, function(x, y) glue::glue_data(x, y))
        )
      ) |>
      tidyr::unnest(data)

    if(!is.null(var_grid)){
      combined_grid <-
        combined_grid |>
        tidyr::nest(variables = dplyr::any_of(names(var_grid$grid)))
    }

    if(!is.null(filter_grid)){
      combined_grid <-
        combined_grid |>
        tidyr::nest(filters = dplyr::any_of(names(filter_grid$grid)))
    }

    if(!is.null(preprocessing)){
      combined_grid <-
        combined_grid |>
        tidyr::nest(preprocess = dplyr::any_of(dplyr::starts_with("step")))
    }

    if(!is.null(postprocessing)){
      combined_grid <-
        combined_grid |>
        tidyr::nest(postprocess = dplyr::any_of(dplyr::starts_with("set")))
    }

    all_combinations <-
      list(
        variable  = var_grid$combinations,
        filter    = filter_grid$combinations,
        model     = model_grid$combinations
      ) |>
      purrr::compact()

    all_combinations <-
      purrr::map2_df(all_combinations, names(all_combinations), function(x, y){
        combs <-
          x |>
          dplyr::rename_with(~c("group", "n_alternatives")) |>
          dplyr::mutate(
            category = paste0("(", y, ") "),
            category = ifelse(category != "(model) ", category, ""))
      })

    n_combinations <-
      all_combinations |>
      dplyr::pull(n_alternatives) |>
      cumprod() |>
      max()

    combination_products <-
      all_combinations |>
      dplyr::pull(n_alternatives) |>
      paste0(... = _, collapse = '*')

    message(glue::glue_data(all_combinations, "{group} {category}has {n_alternatives} alternatives\n", .trim = FALSE))
    message(glue::glue("{n_combinations} combinations ({combination_products} = {n_combinations})"))

    combined_grid <-
      combined_grid |>
      dplyr::select(
        decision,
        dplyr::any_of(
          c("variables", "filters", "preprocess", "model", "postprocess")
        )
      )

    attr(combined_grid, "base_df") <- base_df

    combined_grid
  }
