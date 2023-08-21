#' Detect total number of analysis pipelines
#'
#'@param .grid a full decision grid created by \code{\link{expand_decisions}}
#' @param include_models Whether to count alternative models if you have more
#'   than one \code{add_model()} call.
#'
#' @return a numeric, the total number of unique analyis pipelines
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#'
#' # create some data
#' the_data <-
#'   data.frame(
#'     id  = 1:500,
#'     iv1 = rnorm(500),
#'     iv2 = rnorm(500),
#'     iv3 = rnorm(500),
#'     mod = rnorm(500),
#'     dv1 = rnorm(500),
#'     dv2 = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # create a pipeline blueprint
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' detect_multiverse_n(full_pipeline)
detect_multiverse_n <- function(.grid, include_models = TRUE){

  if(include_models){
    .grid |>
      dplyr::filter(type %in% c("filters","variables", "models")) |>
      dplyr::mutate(group = ifelse(type=="models", "model", group)) |>
      dplyr::group_by(group) |>
      dplyr::count() |>
      dplyr::pull(n) |>
      cumprod() |>
      max()
  } else{
    .grid |>
      dplyr::filter(type %in% c("filters","variables")) |>
      dplyr::group_by(group) |>
      dplyr::count() |>
      dplyr::pull(n) |>
      cumprod() |>
      max()
  }

}

#' Detect total number of variable sets in your pipelines
#'
#'@param .grid a full decision grid created by \code{\link{expand_decisions}}
#'
#' @return a numeric, the total number of unique variable sets
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#'
#' # create some data
#' the_data <-
#'   data.frame(
#'     id  = 1:500,
#'     iv1 = rnorm(500),
#'     iv2 = rnorm(500),
#'     iv3 = rnorm(500),
#'     mod = rnorm(500),
#'     dv1 = rnorm(500),
#'     dv2 = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # create a pipeline blueprint
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' detect_n_variables(full_pipeline)
detect_n_variables <- function(.grid){

  .grid |>
    dplyr::filter(type == "variables") |>
    dplyr::group_by(type, group) |>
    dplyr::count() |>
    dplyr::pull(n) |>
    cumprod() |>
    max()
}

#' Detect total number of filtering expressions your pipelines
#'
#'@param .grid a full decision grid created by \code{\link{expand_decisions}}
#'
#' @return a numeric, the total number of filtering expressions
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#'
#' # create some data
#' the_data <-
#'   data.frame(
#'     id  = 1:500,
#'     iv1 = rnorm(500),
#'     iv2 = rnorm(500),
#'     iv3 = rnorm(500),
#'     mod = rnorm(500),
#'     dv1 = rnorm(500),
#'     dv2 = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # create a pipeline blueprint
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' detect_n_filters(full_pipeline)
detect_n_filters <- function(.grid){

  .grid |>
    dplyr::filter(type == "filters") |>
    dplyr::group_by(type, group) |>
    dplyr::count() |>
    dplyr::pull(n) |>
    cumprod() |>
    max()
}

#' Detect total number of models in your pipelines
#'
#'@param .grid a full decision grid created by \code{\link{expand_decisions}}
#'
#' @return a numeric, the total number of unique models
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#'
#' # create some data
#' the_data <-
#'   data.frame(
#'     id  = 1:500,
#'     iv1 = rnorm(500),
#'     iv2 = rnorm(500),
#'     iv3 = rnorm(500),
#'     mod = rnorm(500),
#'     dv1 = rnorm(500),
#'     dv2 = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # create a pipeline blueprint
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' detect_n_models(full_pipeline)
detect_n_models <- function(.grid){
  .grid |>
    dplyr::filter(type == "models") |>
    dplyr::group_by(type, group) |>
    dplyr::count() |>
    dplyr::pull(n) |>
    cumsum() |>
    max()
}


#'Summarize samples sizes for each unique filtering expression
#'
#'@param .grid a full decision grid created by
#'  \code{\link{expand_decisions}}
#'
#'@return a \code{tibble} with each row representing a filtering expression and
#'  four columns: \code{filter_expression}, \code{variable}, \code{n_retained},
#'  and \code{n_excluded}.
#'
#'@export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#'
#' # create some data
#' the_data <-
#'   data.frame(
#'     id  = 1:500,
#'     iv1 = rnorm(500),
#'     iv2 = rnorm(500),
#'     iv3 = rnorm(500),
#'     mod = rnorm(500),
#'     dv1 = rnorm(500),
#'     dv2 = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # create a pipeline blueprint
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' summarize_filter_ns(full_pipeline)
summarize_filter_ns <- function(.grid){

  data_chr <- attr(.grid, "base_df")

  base_df <-
    rlang::parse_expr(data_chr) |>
    rlang::eval_tidy(env = parent.frame())

  filter_exprs <-
    .grid |>
    dplyr::filter(type == "filters") |>
    dplyr::pull(code)

  filter_vars <-
    .grid |>
    dplyr::filter(type == "filters") |>
    dplyr::pull(group)

  purrr::map2(filter_exprs, filter_vars, function(x, y){

    tibble::tibble(
      filter_expression = x,
      variable          = y,
      n_retained        = base_df |> dplyr::filter(rlang::parse_expr(x) |> rlang::eval_tidy()) |> nrow(),
      n_excluded        = nrow(base_df) - n_retained
    )

  }) |>
    dplyr::bind_rows()

}
