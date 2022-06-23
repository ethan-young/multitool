# Create Grids ------------------------------------------------------------
#' Create all combinations of filtering decisions for exploring exclusion criteria
#'
#' @param my_data the actual data as a \code{data.frame} you want to create a
#'   filtering decisions for
#' @param ... logical expressions to be used with \code{\link[dplyr]{filter}}
#'   separated by commas. Expressions should not be quoted.
#'
#' @return a list with four components:
#'
#'   \describe{
#'     \item{summary}{a summary \code{tibble} of your filters with the following
#'     columns: \code{filter_expr} (the filtering code), \code{filter_group}
#'     (which variable does the filter apply to), \code{filtered_n}
#'     (how many observations are there after the filter), and  \code{filter_type}
#'     (does the expression filter or do nothing, which is auto-generated).}
#'     \item{combinations}{a summary of the number of alternatives per filtering
#'     decision}
#'     \item{n_combinations}{the total number of filtering combinations}
#'     \item{grid}{the actual filtering grid, the number of rows = n_combinations.
#'     }
#'   }
#'
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#'
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
#' my_filter_grid <-
#'   create_filter_grid(
#'     my_data = the_data,
#'     include1 == 0,
#'     include2 != 3,
#'     include2 != 2,
#'     scale(include3) > -2.5
#'   )
#'
#' my_filter_grid
create_filter_grid <- function(my_data, ...){
  filter_exprs <- dplyr::enexprs(...)
  filter_exprs_chr <- as.character(filter_exprs)
  filter_vars <-
    stringr::str_extract(filter_exprs_chr, paste(names(my_data), collapse = "|"))

  grid_summary1 <-
    purrr::map2_df(filter_exprs_chr, filter_vars, function(x, y){

      tibble::tibble(
        filter_expr  = x,
        filter_group = y,
        filtered_n   = my_data |> dplyr::filter(rlang::parse_expr(x) |> rlang::eval_tidy()) |> nrow(),
        filter_type  = "filter"
      )

    })

  grid_summary2 <-
    grid_summary1 |>
    dplyr::pull(filter_group) |>
    unique() |>
    purrr::map_df(function(x){

      grid_summary1 |>
        dplyr::filter(filter_group == x) |>
        tibble::add_row(
          filter_expr  = glue::glue("{x} %in% unique({x})") |> as.character(),
          filter_group = x,
          filtered_n   = my_data |> dplyr::filter(rlang::parse_expr(filter_expr) |> rlang::eval_tidy()) |> nrow(),
          filter_type  = "do nothing"
        )

    })

  combinations <-
    grid_summary2 |>
    dplyr::group_by(filter_group) |>
    dplyr::summarize(
      n_alternatives = dplyr::n()
    )

  n_combinations <-
    combinations |>
    dplyr::pull(n_alternatives) |>
    cumprod() |>
    max()

  combination_products <-
    combinations |>
    dplyr::pull(n_alternatives) |>
    paste0(... = _, collapse = '*')

  grid_expanded <-
    grid_summary2 |>
    df_to_expand_prep(filter_group, filter_expr) |>
    df_to_expand()

  message(glue::glue_data(combinations, "filters involving {filter_group} has {n_alternatives} alternative filtering criteria\n",.trim = FALSE))
  message(glue::glue("{n_combinations} combinations ({combination_products} = {n_combinations})"))

  list(
    summary        = grid_summary2,
    combinations   = combinations,
    n_combinations = n_combinations,
    grid           = grid_expanded
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
#'
#' @return\ a list with four components:
#'
#'   \describe{
#'     \item{summary}{a summary \code{tibble} of the variables chosen.}
#'     \item{combinations}{a summary of the number of alternatives variables for
#'     each variable group}
#'     \item{n_combinations}{the total number of variable combinations}
#'     \item{grid}{the actual variable grid, the number of rows = n_combinations.
#'     }
#'   }
#'
#' @export
#'
#' @examples
#' library(tidyverse)
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
create_var_grid <- function(my_data, ...){
  vars_raw <- dplyr::enquos(..., .named = TRUE)
  var_groups <- names(vars_raw)

  grid_summary <-
    purrr::map2_df(vars_raw, var_groups, function(x,y){
      tibble::tibble(
        var_group = y,
        var       = my_data |> dplyr::select(!!x) |> names()
      )
    })

  grid_expanded <-
    grid_summary |>
    df_to_expand_prep(var_group, var) |>
    df_to_expand()

  combinations <-
    grid_summary |>
    dplyr::group_by(var_group) |>
    dplyr::summarize(
      n_alternatives = dplyr::n()
    )

  n_combinations <-
    combinations |>
    dplyr::pull(n_alternatives) |>
    cumprod() |>
    max()

  combination_products <-
    combinations |>
    dplyr::pull(n_alternatives) |>
    paste0(... = _, collapse = '*')

  message(glue::glue_data(combinations, "{var_group} variable group has {n_alternatives} alternative variables\n",.trim = FALSE))
  message(glue::glue("{n_combinations} combinations ({combination_products} = {n_combinations})"))

  list(
    summary        = grid_summary,
    combinations   = combinations,
    n_combinations = n_combinations,
    grid           = grid_expanded
  )

}

#' Create a modeling grid
#'
#' @param ... literal model syntax (no quotes) you would like to run. You can
#'   use \code{glue} inside formulas to dynamically generate variable names
#'   based on a variable grid. For example, if you make variable grid with two
#'   versions of your IVs (e.g., \code{iv1} and \code{iv2}), you can write your
#'   formula like so: \code{lm(happiness ~ {iv} + control_var)}. The only
#'   requirement is that the variables written in the formula actually exist in
#'   the underlying data. You are also responsible for loading any packages that
#'   run a particular model (e.g., \code{lme4} for mixed-models)
#'
#' @return\ a list with four components:
#'
#'   \describe{
#'     \item{summary}{a summary \code{tibble} of the models chosen.}
#'     \item{combinations}{a summary of the number of alternatives models}
#'     \item{n_combinations}{the total number of model combinations}
#'     \item{grid}{the actual modeling grid, the number of rows = n_combinations.
#'     }
#'   }
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#'
#' my_model_grid <-
#'   create_model_grid(
#'     lm({dv} ~ {iv} * {mod}),
#'     lm({dv} ~ {iv} * {mod} + {cov})
#'   )
create_model_grid <- function(...){
  code <- dplyr::enexprs(..., .named = T)
  code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

  grid_summary <-
    purrr::imap_dfr(code_chr, function(x, y){
      tibble::tibble(
        model   = "model",
        code    = x
      )
    })

  grid_expanded <-
    grid_summary |>
    df_to_expand_prep(model, code) |>
    df_to_expand()

  combinations <-
    grid_summary |>
    dplyr::group_by(model) |>
    dplyr::summarize(
      n_alternatives = dplyr::n()
    )

  n_combinations <-
    combinations |>
    dplyr::pull(n_alternatives) |>
    cumprod() |>
    max()

  combination_products <-
    combinations |>
    dplyr::pull(n_alternatives) |>
    paste0(... = _, collapse = '*')

  message(glue::glue_data(combinations, "Your {model} has {n_combinations} alternatives",.trim = FALSE))

  list(
    summary        = grid_summary,
    combinations   = combinations,
    n_combinations = n_combinations,
    grid           = grid_expanded
  )

}

# Pre and Post processing -------------------------------------------------

#'Add arbitrary pre-processing code to execute after data are filtered (but
#'before analysis)
#'
#'@param ... the literal code you would like to execute after data are filtered.
#'  \code{\link[glue]{glue}} syntax is allowed. An example might be centering or
#'  scaling a predictor after the appropriate filters are applied to the data.
#'
#'@return a \code{tibble} with  two columns, "preprocess" and "code". Each row
#'  representing a pre-processing step to execute.
#'
#'  The values in the "preprocess" column indicate the order (e.g., step1,
#'  step2, etc.) and the "code" column is the literal code to be ran. The code
#'  must be written in \code{|>} (pipe) format. Assume that the original data
#'  and filtering decisions (if any), will be passed directly to your
#'  pre-processing code.
#'
#'  If you want to manipulate a variable that is part of a variable grid created
#'  by \code{\link{create_var_grid}}, you can use \code{\link[glue]{glue}}
#'  syntax to indicate the variable group (e.g., ivs). When all grids are
#'  combined with \code{\link{combine_all_grids}}, the variables corresponding
#'  to a particular decisions set will  be evaluated with
#'  \code{\link[glue]{glue}} syntax.
#'
#'@export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#'
#'# All in one step
#' my_preprocess_v1 <-
#'   create_preprocess(
#'     mutate(
#'       {iv} := as.numeric(scale({iv})), {mod} := as.numeric(scale({mod}))
#'     )
#'   )
#'
#'# In two steps
#' my_preprocess_v2 <-
#'   create_preprocess(
#'     mutate({iv} := scale({iv}) |> as.numeric()),
#'     mutate({mod} := scale({mod}) |> as.numeric())
#'   )
create_preprocess <- function(...){
  code <- dplyr::enexprs(..., .named = T)
  code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

  pre_processing_code <-
    purrr::imap_dfr(code_chr, function(x, y){
      tibble::tibble(
        preprocess = paste0("step",y),
        code        = x
      )
    })

  pre_processing_code

}

#' Add arbitrary post hoc code to execute after each analysis
#'
#' @param ... the literal code block (unquoted) you would like to execute after
#'   each analysis. If you have multiple post processing tasks, separate each
#'   distinct code chunk by a comma.
#'
#'   The code should be written to work with pipes (i.e., \code{|>} or
#'   \code{\%>\%}). Because the post hoc code comes last in each multiverse
#'   analysis step, the chosen model object will be passed to the
#'   post-processing code.
#'
#'   For example, if you fit a simple linear model like: \code{lm(y ~ x1 + x2)},
#'   and your post hoc code executes a call to \code{anova}, you would simply
#'   pass \code{anova()} to \code{create_postprocess()}. The underlying code
#'   would be:
#'
#'   \code{data |> filters |> lm(y ~ x1 + x2, data = _) |> anova()}
#'
#' @return a \code{tibble} with  two columns, "postprocess" and "code". Each row
#'   representing a post processing task to execute. The "postprocess" column
#'   indicates the order (although its arbitrary) and the "code" column is the
#'   literal code to be ran.
#'
#'   You can add arguments to the code as you would normally. Always assume that
#'   the model you fit will passed as the first argument. However, for example,
#'   if you wanted to fit a simple slopes test with
#'   \code{\link[interactions]{sim_slopes}}, you use \code{\link[glue]{glue}}
#'   syntax. For example:
#'
#'   \code{sim_slopes(pred = {iv}, modx = {mod})}
#'
#'   The \code{\link{combine_all_grids}} will populate with the variables from
#'   your variable grid.
#'
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
create_postprocess <- function(...){
  code <- dplyr::enexprs(..., .named = T)
  code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

  post_processing_code <-
    purrr::imap_dfr(code_chr, function(x, y){
      tibble::tibble(
        postprocess = paste0("set",y),
        code         = x
      )
    })

  post_processing_code

}
