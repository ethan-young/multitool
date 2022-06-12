#' Create all combinations of filtering decisions for exploring exclusions
#'
#' @param my_data the actual data as a \code{data.frame} you want to create a
#'   filtering decisions for
#' @param ... logical expressions to be used with \code{\link[dplyr]{filter}}
#'   separated by commas. Expressions should not be quoted.
#' @param print logical, whether or not to show a summary of the resulting grid.
#'   Defaults to \code{TRUE}
#'
#' @return a list with two components. The first is a summary of your filters
#'   with the following columns: \code{expr}, \code{expr_var}, \code{expr_n},
#'   and \code{expr_typ}e:
#'
#'   \describe{ \item{\code{expr}}{the expression(s) passed to
#'   \code{create_filter_grid()}} \item{\code{expr_var}}{the variable involved
#'   in the filtering expression} \item{\code{expr_n}}{the total number of rows
#'   after the expression is applied} \item{\code{expr_type}}{whether or not the
#'   expression filters data} }
#'
#'   The summary is meant to help the user understand and evaluate different
#'   filters. The function automatically generates expressions that do nothing
#'   to complete a set of alternatives.
#'
#'   The second component of the list is a full grid of filtering decisions.
#'   This is created under the hood by \code{\link[tidyr]{expand_grid}}.
#'
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


#' Create a grid of all combinations of variables
#'
#' @param my_data the actual data as a \code{data.frame} with the variables to
#'   include in a grid
#' @param ... named vectors with the names indicating a category of variable.
#'   For example, you want to test if self esteem affects happiness but you may
#'   have two variables that measure self-esteem. You could add these variables
#'   to a multiverse to explore which variable matters (alongside other
#'   decisions). In this case, you could add \code{self_esteem = c(self_esteem1,
#'   self_esteem2)} to create a grid of these variables. In practice, you can
#'   add any kind of general variable categories e.g., ivs, dvs, covariates etc.
#' @param print logical, whether or not to show a summary of the resulting grid.
#'   Defaults to \code{TRUE}
#'
#' @return a \code{tibble} with all possible variable combinations.
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
#' my_var_grid <-
#'  create_var_grid(
#'    my_data = my_data,
#'    iv = c(iv1, iv2, iv3),
#'    dv = c(dv1, dv2),
#'    covariates = c(covariate1, covariate2)
#'  )
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


#' Create a modeling grid
#'
#' @param ... literal model syntax (no quotes) you would like to run. You can
#'   use \code{glue} inside formulas to dynamically generate variable names
#'   based on a variable grid. For example, if you make variable grid with two
#'   versions of your IVs (e.g., \code{iv1} and \code{iv2}), you can write your
#'   formula like so: \code{lm(happiness ~ {iv} + control_var)}. The only
#'   requirement is that the variables written in the formula actaully exist in
#'   the underlying data. You are also responsible for loading any packages that
#'   run a particular model (e.g., \code{lme4} for mixed-models)
#'
#' @return a \code{tibble} containing the models you wish to apply to your
#'   decision grid
#' @export
#'
#' @examples
#' library(multitool)
#'
#' my_model_grid <-
#'   create_model_grid(
#'     lm({dv} ~ {iv}),
#'     lm({dv} ~ {iv} + {covariates})
#'   )
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
