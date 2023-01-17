#' Add correlations from the {corrr} package in {tidymodels}
#'
#' @param .df the original data.frame (e.g., base data set). If part of set of
#'   add_* decision functions in a pipeline, the base data will be passed along
#'   as an attribute.
#' @param var_set character string. Should be a descriptive name of the
#'   correlation matrix.
#' @param variables the variables for which you would like to correlations.
#'   These variables will be passed to \code{link[corrr]{correlate}}. You can
#'   also use tidyselect to select variables.
#' @param focus the any variables for which you would like to run
#'   \code{link[corrr]{focus}}.
#' @param stretch logical. Whether or not you would like to add a long form
#'   correlation list computed by \code{link[corrr]{stretch}}.
#' @param pair_ns logical. Whether or not you would like to add sample sizes
#'   table for each correlation computed by \code{link[corrr]{pair_n}}.
#' @param use an optional character string indicating how to handle missing
#'   values. Should be one of "everything", "all.obs", "complete.obs",
#'   "na.or.complete", or "pairwise.complete.obs".
#' @param method character string indicating the correlation method used in
#'   \code{link[corrr]{correlate}}. The default is "peasron".
#'
#' @return a data.frame with three columns: type, group, and code. Type
#'   indicates the decision type, group is a decision, and the code is the
#'   actual code that will be executed. If part of a pipe, the current set of
#'   decisions will be appended as new rows.
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
#' the_data |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#'   add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
#'   add_model(lm({dvs} ~ {ivs} * {mods})) |>
#'   add_model(lm({dvs} ~ {ivs} * {mods} + cov1)) |>
#'   add_postprocess("aov", aov()) |>
#'   add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#'   add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis")) |>
#'   add_corrrs("predictors", matches("iv|mod|cov"), focus = c(cov1,cov2)) |>
#'   add_corrrs("outcomes", matches("dv"))
add_corrrs <-
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
    focus <- focus_set != "NULL"

    full_matrix <-
      glue::glue(
        'select({variables}) |> correlate(use = "{use}", method = "{method}")'
      ) |>
      as.character() |>
      stringr::str_remove_all("\n|  ")

    grid_prep <-
      tibble::tibble(
        type  = "corrs",
        group = paste0(var_set,"_rs"),
        code  = full_matrix
      )

    if(focus){
      focus_corrs <-
        glue::glue(
          'select({variables}) |> correlate(use = "{use}", method = "{method}") |> focus({focus_set})'
        ) |>
        as.character() |>
        stringr::str_remove_all("\n|  ")

      grid_prep <-
        grid_prep |>
        add_row(type = "corrs", group = paste0(var_set, "_focus"), code = focus_corrs)
    }

    if(stretch){
      stretched_corrs <-
        glue::glue(
          'select({variables}) |> correlate(use = "{use}", method = "{method}") |> stretch(na.rm = TRUE, remove.dups = TRUE)'
        ) |>
        as.character() |>
        stringr::str_remove_all("\n|  ")

      grid_prep <-
        grid_prep |>
        add_row(type = "corrs", group = paste0(var_set, "_stretch"), code = stretched_corrs)
    }

    if(pair_ns){
      corr_pair_ns <-
        glue::glue(
          'select(c({variables})) |> pair_n()'
        ) |>
        as.character() |>
        stringr::str_remove_all("\n|  ")

      grid_prep <-
        grid_prep |>
        add_row(type = "corrs", group = paste0(var_set, "_ns"), code = corr_pair_ns)
    }

    if(!is.null(data_attr)){
      grid_prep <- bind_rows(.df, grid_prep)
    } else{
      grid_prep <- grid_prep
    }

    attr(grid_prep, "base_df") <- data_chr
    grid_prep
  }
