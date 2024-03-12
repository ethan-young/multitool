#' Run a multiverse based on a complete decision grid
#'
#' @param .grid a \code{tibble} produced by \code{\link{expand_decisions}}
#' @param add_standardized logical. Whether to add standardized coefficients to
#'   the model output. Defaults to \code{TRUE}.
#' @param save_model logical, indicates whether to save the model object in its
#'   entirety. The default is \code{FALSE} because model objects are usually
#'   large and under the hood, \code{\link[parameters]{parameters}} and
#'   \code{\link[performance]{performance}} is used to summarize the most useful
#'   model information.
#' @param show_progress logical, whether to show a progress bar while running.
#'
#' @return a single \code{tibble} containing tidied results for the model and
#'   any post-processing tests/tasks. For each unique test (e.g., an \code{lm}
#'   or \code{aov} called on an \code{lm}), a list column with the function name
#'   is created with \code{\link[parameters]{parameters}} and
#'   \code{\link[performance]{performance}} and any warnings or messages printed
#'   while fitting the models. Internally, modeling and post-processing
#'   functions are checked to see if there are tidy or glance methods available.
#'   If not, \code{summary} will be called instead.
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#'
#' # Simulate some data
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
#' # Decision pipeline
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#'   add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
#'   add_model("no covariates",lm({dvs} ~ {ivs} * {mods})) |>
#'   add_model("covariate", lm({dvs} ~ {ivs} * {mods} + cov1)) |>
#'   add_postprocess("aov", aov())
#'
#' pipeline_grid <- expand_decisions(full_pipeline)
#'
#' # Run the whole multiverse
#' the_multiverse <- run_multiverse(pipeline_grid[1:10,])
run_multiverse <- function(.grid, add_standardized = TRUE, save_model = FALSE, show_progress = TRUE){

    multiverse <-
      purrr::map(
        seq_len(nrow(.grid)),
        .progress = show_progress,
        function(x){
          multi_results <- list()

          if("models" %in% names(.grid)){
            multi_results$models <-
              run_universe_model(
                .grid = .grid,
                decision_num = .grid$decision[x],
                add_standardized = add_standardized,
                save_model = save_model
              )
          }
          purrr::reduce(multi_results, dplyr::left_join, by = "decision")
        }) |>
      purrr::list_rbind()

  dplyr::full_join(
    .grid |>
      dplyr::select(-dplyr::contains("code")) |>
      mutate(decision = as.character(decision)),
    multiverse,
    by = "decision"
  ) |>
    dplyr::select(-dplyr::matches("^parameter_keys$")) |>
    tidyr::nest(specifications = c(-decision, -dplyr::matches("fitted$|computed$|code$"))) |>
    dplyr::select(decision, specifications, dplyr::everything())
}

#' Run a multiverse-style descriptive analysis based on a complete decision grid
#'
#' @param .grid a \code{tibble} produced by \code{\link{expand_decisions}}
#'
#' @param show_progress logical, whether to show a progress bar while running.
#'
#' @return  single \code{tibble} containing tidied results for all descriptive
#'   analyses specified. Because descriptive analyses only change when the
#'   underlying cases change, only filtering and/or subgroup decisions will be
#'   used and will be internally re-expanded before performing various
#'   descriptive analyses.
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
#' # Simulate some data
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
#' # Decision pipeline
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#'   add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis")) |>
#'   add_correlations("predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2)) |>
#'   add_correlations("outcomes", matches("dv|mod"), focus_set = matches("dv")) |>
#'   add_reliabilities("unp_scale", c(iv1,iv2,iv3)) |>
#'   add_reliabilities("vio_scale", starts_with("mod")) |>
#'   expand_decisions()
#'
#' run_descriptives(full_pipeline)
run_descriptives <- function(.grid, show_progress = TRUE){

  pipeline <-
    attr(.grid, "pipeline") |>
    rlang::eval_tidy(env = parent.frame())

  filter_grid <-
    pipeline |>
    dplyr::filter(stringr::str_detect(type, "subgroups|filters|corrs|summary_stats|reliabilities")) |>
    expand_decisions()

  multi_descriptives <-
    purrr::map(
      seq_len(nrow(filter_grid)),
      .progress = TRUE,
      function(x){
        multi_results <- list()

        if("corrs" %in% names(filter_grid)){
          multi_results$corrs <-
            run_universe_corrs(
              .grid = filter_grid,
              decision_num =  filter_grid$decision[x]
            )
        }

        if("summary_stats" %in% names(filter_grid)){
          multi_results$stats <-
            run_universe_summary_stats(
              .grid = filter_grid,
              decision_num = filter_grid$decision[x]
            )
        }

        if("reliabilities" %in% names(filter_grid)){
          multi_results$reliabilities <-
            run_universe_reliabilities(
              .grid = filter_grid,
              decision_num = filter_grid$decision[x]
            )
        }

        purrr::reduce(multi_results, dplyr::left_join, by = "decision")

      }) |>
    purrr::list_rbind()

  dplyr::full_join(
    filter_grid |>
      dplyr::select(-dplyr::contains("code")) |>
      mutate(decision = as.character(decision)),
    multi_descriptives,
    by = "decision"
  ) |>
    tidyr::nest(specifications = c(-decision, -dplyr::matches("fitted$|computed$"))) |>
    dplyr::select(decision, specifications, dplyr::everything())

}
