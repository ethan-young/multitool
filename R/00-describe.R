#' Detect total number of analysis pipelines
#'
#'@param .pipeline a \code{data.frame} produced by calling a series of add_*
#'   functions.
#' @param include_models Whether to count alternative models if you have more
#'   than one \code{add_model()} call.
#'
#' @return a numeric, the total number of unique analysis pipelines
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
#'   add_filters(include1 == 0, include2 != 3, include3 > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' detect_multiverse_n(full_pipeline)
detect_multiverse_n <- function(.pipeline, include_models = TRUE){

  if(include_models){
    .pipeline |>
      dplyr::filter(type %in% c("subgroups","filters","variables", "models")) |>
      dplyr::mutate(group = ifelse(type=="models", "model", group)) |>
      dplyr::group_by(group) |>
      dplyr::count() |>
      dplyr::pull(n) |>
      cumprod() |>
      max()
  } else{
    n_data <-
      .pipeline |>
      dplyr::filter(type %in% c("subgroups","filters","variables")) |>
      dplyr::group_by(group) |>
      dplyr::count()

    if(nrow(n_data) > 0){
      n_data |>
        dplyr::pull(n) |>
        cumprod() |>
        max()
    } else{
      1
    }
  }
}

#'Detect total number of subgroups in your pipelines
#'
#'@param .pipeline a \code{data.frame} produced by calling a series of add_*
#'  functions.
#'
#'@return a numeric, the total number of unique subgroups, including subgroup
#'  combinations
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
#'   add_subgroups(include2) |>
#'   add_filters(include1 == 0, include2 != 3, include3 > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' detect_n_variables(full_pipeline)
detect_n_subgroups <- function(.pipeline){

  n_subgroups <-
    .pipeline |>
    dplyr::filter(type == "subgroups") |>
    dplyr::group_by(type, group) |>
    dplyr::count()

  if(nrow(n_subgroups) > 0){
    n_subgroups |>
      dplyr::pull(n) |>
      cumprod() |>
      max()
  } else{
    0
  }
}

#' Detect total number of variable sets in your pipelines
#'
#'@param .pipeline a \code{data.frame} produced by calling a series of add_*
#'   functions.
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
#'   add_filters(include1 == 0, include2 != 3, include3 > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' detect_n_variables(full_pipeline)
detect_n_variables <- function(.pipeline){

  n_vars <-
    .pipeline |>
    dplyr::filter(type == "variables") |>
    dplyr::group_by(type, group) |>
    dplyr::count()

  if(nrow(n_vars) > 0){
    n_vars |>
      dplyr::pull(n) |>
      cumprod() |>
      max()
  } else{
    0
  }
}

#' Detect total number of filtering expressions your pipelines
#'
#'@param .pipeline a \code{data.frame} produced by calling a series of add_*
#'   functions.
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
#'   add_filters(include1 == 0, include2 != 3, include3 > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' detect_n_filters(full_pipeline)
detect_n_filters <- function(.pipeline){
  n_filters <-
    .pipeline |>
    dplyr::filter(type == "filters") |>
    dplyr::group_by(type, group) |>
    dplyr::count()

  if(nrow(n_filters) > 0){
    n_filters |>
      dplyr::pull(n) |>
      cumprod() |>
      max()
  } else{
    0
  }
}

#' Detect total number of models in your pipelines
#'
#'@param .pipeline a \code{data.frame} produced by calling a series of add_*
#'   functions.
#'
#'@return a numeric, the total number of unique models
#'@export
#'
#'@examples
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
#'   add_filters(include1 == 0, include2 != 3, include3 > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' detect_n_models(full_pipeline)
detect_n_models <- function(.pipeline){
  .pipeline |>
    dplyr::filter(type == "models") |>
    dplyr::group_by(type, group) |>
    dplyr::count() |>
    dplyr::pull(n) |>
    cumsum() |>
    max()
}


#'Summarize samples sizes for each unique filtering expression
#'
#'@param .pipeline a \code{data.frame} produced by calling a series of add_*
#'   functions.
#'
#'@return a \code{tibble} with each row representing a filtering expression and
#'  four columns: \code{filter_expression}, \code{variable}, \code{n_retained},
#'  and \code{n_excluded}.
#'
#'@export
#'
#'@examples
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
#'   add_filters(include1 == 0, include2 != 3, include3 > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' summarize_filter_ns(full_pipeline)
summarize_filter_ns <- function(.pipeline){

  data_chr <- attr(.pipeline, "base_df")

  base_df <-
    rlang::parse_expr(paste(data_chr, "|> collect()")) |>
    rlang::eval_tidy(env = parent.frame())

  filter_exprs <-
    .pipeline |>
    dplyr::filter(type == "filters") |>
    dplyr::pull(code)

  filter_vars <-
    .pipeline |>
    dplyr::filter(type == "filters") |>
    dplyr::pull(group)

  purrr::map2(filter_exprs, filter_vars, function(x, y){

    tibble::tibble(
      filter_expression = x,
      variable = y,
      n_retained = base_df |>
        dplyr::filter(rlang::parse_expr(x) |> rlang::eval_tidy()) |>
        nrow(),
      n_excluded = nrow(base_df) - n_retained
    )

  }) |>
    dplyr::bind_rows()

}

filter_overlap <- function(.pipeline, redundant = TRUE) {

  data_chr <- attr(.pipeline, "base_df")

  base_df <-
    rlang::parse_expr(paste(data_chr, "|> dplyr::collect()")) |>
    rlang::eval_tidy(env = parent.frame())

  all_rows <- base_df |> dplyr::mutate(.row_id = dplyr::row_number())

  filter_exprs <-
    .pipeline |>
    dplyr::filter(type == "filters") |>
    dplyr::filter(!stringr::str_detect(code, "%in% unique")) |>
    dplyr::pull(code)

  if (length(filter_exprs) < 2) {
    rlang::abort(
      "Need at least two non-trivial filters to compute pairwise overlap."
    )
  }

  # Each filter's excluded-row set: rows it removes (not retained).
  exclusion_sets <-
    filter_exprs |>
    rlang::set_names() |>
    purrr::map(function(expr) {
      retained <-
        all_rows |>
        dplyr::filter(rlang::parse_expr(expr) |> rlang::eval_tidy()) |>
        dplyr::pull(.row_id)

      setdiff(all_rows$.row_id, retained)
    })

  # All ordered pairs, diagonal removed. Ordered (not exp1 < exp2) so that
  # filter_1 is a complete anchor: every comparison a filter takes part in
  # appears in its own filter_1 rows.
  combos <-
    tidyr::expand_grid(
      filter_1 = names(exclusion_sets),
      filter_2 = names(exclusion_sets)
    ) |>
    dplyr::filter(filter_1 != filter_2)

  overlap <-
    purrr::pmap(
      combos,
      function(filter_1, filter_2) {
        set1 <- exclusion_sets[[filter_1]]
        set2 <- exclusion_sets[[filter_2]]

        n_shared <- length(intersect(set1, set2))
        n_union  <- length(union(set1, set2))

        tibble::tibble(
          base_df_n          = nrow(base_df),
          filter1            = filter_1,
          filter2            = filter_2,
          filter1_excluded   = length(set1),
          filter2_excluded   = length(set2),
          total_excluded     = n_union,
          filter1_unique     = length(setdiff(set1, set2)),
          filter2_unique     = length(setdiff(set2, set1)),
          overlap_n          = n_shared,
          overlap_pct_total  = if (n_union == 0) NA_real_ else n_shared / n_union,
          filter1_pct_shared = if (length(set1) == 0) NA_real_ else n_shared / length(set1),
          filter2_pct_shared = if (length(set1) == 0) NA_real_ else n_shared / length(set2),
        )
      }
    ) |>
    purrr::list_rbind()

  # Like correlation::correlation(redundant = ), keep every ordered pair by
  # default; when FALSE, collapse to one row per unordered pair.
  if (!redundant) {
    overlap <-
      overlap |>
      dplyr::filter(filter1 < filter2)
  }

  overlap
}
