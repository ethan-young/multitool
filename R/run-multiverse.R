#' Run a single set of arbitrary decisions and save the result
#'
#' @param .grid a \code{tibble} produced by \code{\link{expand_decisions}}
#' @param decision_num an single integer from 1 to \code{nrow(grid)} indicating
#'   which specific decision set to run
#' @param save_model logical, indicates whether to save the model object in its
#'   entirety. The default is \code{FALSE} because model objects are usually
#'   large and under the hood, \code{\link[broom]{tidy}} and
#'   \code{\link[broom]{glance}} is used to summarize the most useful model
#'   information.
#'
#' @return a single row \code{tibble} containing the decision, code that was
#'   ran, the results, and any notes (e.g., warnings or messages).
#' @export
#'
#' @examples
#'
#' \dontrun{
#' run_universe(.grid, .df, decision_num)
#' }
run_universe_model <- function(.grid, decision_num, save_model = FALSE){

  data_chr <- attr(.grid, "base_df")

  grid_elements <- paste(names(.grid), collapse = " ")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  universe_pipeline <-list(original_data = data_chr)
  universe_analyses <- list()
  universe_results <- list()

  if(stringr::str_detect(grid_elements, "filters")){
    universe_pipeline$filters <-
      universe |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")

    universe_results$filter_code <-
      tibble::tibble(
        filter_code = list_to_pipeline(universe_pipeline)
      )
  }

  if(stringr::str_detect(grid_elements, "preprocess")){
    universe_pipeline$preprocess_code <-
      universe |>
      dplyr::pull(preprocess) |>
      unlist() |>
      paste0(collapse = " |> ")

    universe_results$pre_process_code <-
      tibble::tibble(
        preprocess_code = list_to_pipeline(universe_pipeline)
      )
  }

  universe_pipeline$model_code <-
    universe |>
    tidyr::unnest(models) |>
    dplyr::pull(model) |>
    stringr::str_replace(string = _ ,"\\)$", ", data = _)")

  universe_analyses$model <- list_to_pipeline(universe_pipeline)

  if(stringr::str_detect(grid_elements, "postprocess")){
    universe_postprocess <-
      universe |>
      dplyr::select(postprocess) |>
      tidyr::unnest(postprocess) |>
      as.list() |>
      purrr::map(
        function(x) paste0(list_to_pipeline(universe_pipeline), " |> ", x)
      )

    universe_analyses <-
      append(universe_analyses, universe_postprocess)
  }

  universe_results$model_results <-
    purrr::map2_dfc(
      universe_analyses, names(universe_analyses),
      function(x, y){
        results <- collect_quiet_results_easy(x, save_model = save_model)
        tibble("{y}_fitted" := list(results))
      })

  universe_results |>
    purrr::reduce(dplyr::bind_cols) |>
    dplyr::mutate(
      decision = decision_num |> as.character(),
    ) |>
    dplyr::select(decision, dplyr::everything())
}

run_universe_corrs <- function(.grid, decision_num){

  data_chr <- attr(.grid, "base_df")
  grid_elements <- paste(names(.grid), collapse = " ")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  universe_pipeline <-list(original_data = data_chr)
  universe_results <- list()

  if(stringr::str_detect(grid_elements, "filters")){
    universe_pipeline$filters <-
      universe |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")
  }

  corr_sets <-
    universe |>
    dplyr::select(corrs) |>
    tidyr::unnest(corrs) |>
    names() |>
    unique()

  universe_corrs <-
    universe |>
    dplyr::select(corrs) |>
    tidyr::unnest(corrs) |>
    as.list() |>
    purrr::map(
      function(x) paste0(list_to_pipeline(universe_pipeline), " |> ", x)
    )

  universe_results <-
    purrr::map2_dfc(
      universe_corrs, corr_sets,
      function(x, y){
        corr_results <- run_universe_code_quietly(x)
        corr_results <-
          tibble::tibble("{y}" := list(corr_results$result))
      })

  universe_results |>
    dplyr::mutate(
      decision = decision_num |> as.character(),
    ) |>
    tidyr::nest(corrs_computed = c(-decision)) |>
    dplyr::select(decision, dplyr::everything())

}

#' Compute summary statistics for a single decision set
#'
#' @param .grid the data.frame resulting from \code{\link{expand_decisions}}
#' @param decision_num the index of a particular decision set you want to run
#'
#' @return a single row \code{data.frame} with list columns containing the
#'   summary statistics specified in \code{.grid}
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
#' summary_stats_grid <-
#'   the_data |>
#'     add_variables("ivs", iv1, iv2, iv3) |>
#'     add_variables("dvs", dv1, dv2) |>
#'     add_variables("mods", starts_with("mod")) |>
#'     add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5) |>
#'     add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#'     add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis")) |>
#'     expand_decisions()
#'
#' run_universe_summary_stats(summary_stats_grid, decision_num  = 12)
run_universe_summary_stats <- function(.grid, decision_num){

  data_chr <- attr(.grid, "base_df")
  grid_elements <- paste(names(.grid), collapse = " ")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  universe_pipeline <-list(original_data = data_chr)
  universe_results <- list()

  if(stringr::str_detect(grid_elements, "filters")){
    universe_pipeline$filters <-
      universe |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")
  }

  var_sets <-
    universe |>
    dplyr::select(summary_stats) |>
    tidyr::unnest(summary_stats) |>
    names() |>
    unique()

  universe_summary_stats <-
    universe |>
    dplyr::select(summary_stats) |>
    tidyr::unnest(summary_stats) |>
    as.list() |>
    purrr::map(
      function(x) paste0(list_to_pipeline(universe_pipeline), " |> ", x)
    )

  universe_results <-
    purrr::map2_dfc(
      universe_summary_stats, var_sets,
      function(x, y){
        summary_stats_results <- run_universe_code_quietly(x)

        tidied_summary_stats <-
          summary_stats_results$result |>
          tidyr::pivot_longer(dplyr::everything(), names_to = "key", values_to = "value") |>
          tidyr::separate(key, c("variable", "stat")) |>
          tidyr::pivot_wider(names_from = stat, values_from = value)

        summary_stats_results <-
          tibble::tibble("{y}" := list(tidied_summary_stats))
      })

  universe_results |>
    dplyr::mutate(
      decision = decision_num |> as.character(),
    ) |>
    tidyr::nest(summary_stats_computed = c(-decision)) |>
    dplyr::select(decision, dplyr::everything())


}

run_universe_cron_alphas <- function(.grid, decision_num){

  data_chr <- attr(.grid, "base_df")
  grid_elements <- paste(names(.grid), collapse = " ")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  universe_pipeline <-list(original_data = data_chr)
  universe_results <- list()

  if(stringr::str_detect(grid_elements, "filters")){
    universe_pipeline$filters <-
      universe |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")
  }

  item_sets <-
    universe |>
    dplyr::select(cron_alphas) |>
    tidyr::unnest(cron_alphas) |>
    names() |>
    unique()

  universe_alphas <-
    universe |>
    dplyr::select(cron_alphas) |>
    tidyr::unnest(cron_alphas) |>
    as.list() |>
    purrr::map(
      function(x) paste0(list_to_pipeline(universe_pipeline), " |> ", x)
    )

  universe_results <-
    purrr::map2_dfc(
      universe_alphas, item_sets,
      function(x, y){
        alpha_results <- run_universe_code_quietly(x)
        suppressMessages({
          alpha_total <-
            alpha_results$result$total |>
            tibble(.name_repair = "universal") |>
            dplyr::rename_with(tolower)

          alpha_dropped <-
            alpha_results$result$alpha.drop |>
            tibble::tibble(.name_repair = "universal") |>
            dplyr::rename_with(tolower)
        })

        alpha_item_stats <-
          alpha_results$result$item.stats |>
          tibble::tibble() |>
          dplyr::rename_with(tolower)

        alpha_results <-
          tibble::tibble(
            "{y}_total"      := list(alpha_total),
            "{y}_dropped"    := list(alpha_dropped),
            "{y}_item_stats" := list(alpha_item_stats)
          )
      })

  universe_results |>
    dplyr::mutate(
      decision = decision_num |> as.character(),
    ) |>
    tidyr::nest(cron_alphas_computed = c(-decision)) |>
    dplyr::select(decision, dplyr::everything())


}

#' Run a multiverse based on a complete decision grid
#'
#' @param .grid a \code{tibble} produced by \code{\link{expand_decisions}}
#' @param save_model logical, indicates whether to save the model object in its
#'   entirety. The default is \code{FALSE} because model objects are usually
#'   large and under the hood, \code{\link[parameters]{parameters}} and
#'   \code{\link[performance]{performance}} is used to summarize the most useful
#'   model information.
#' @param ncores numeric. The number of cores you want to use for parallel
#'   processing.
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
#'
#' \dontrun{
#' run_multiverse(grid)
#' }
run_multiverse <- function(.grid, save_model = FALSE, ncores = 1, show_progress = FALSE){

  if(ncores > 1){
    future::plan(future::multisession, workers = ncores)
    multiverse <-
      furrr::future_map_dfr(
        seq_len(nrow(.grid)),
        function(x){
          multi_results <- list()

          if("models" %in% names(.grid)){
            multi_results$models <-
              run_universe_model(
                .grid = .grid,
                decision_num = x,
                save_model = save_model
              )
          }
          purrr::reduce(multi_results, left_join, by = "decision")
        },
        .options = furrr::furrr_options(seed = TRUE)
      )
    future::plan(future::sequential)
  } else{

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
                save_model = save_model
              )
          }
          purrr::reduce(multi_results, dplyr::left_join, by = "decision")
        }) |>
      purrr::list_rbind()
  }

  dplyr::full_join(
    .grid |>
      dplyr::select(-dplyr::contains("code")) |>
      mutate(decision = as.character(decision)),
    multiverse,
    by = "decision"
  ) |>
    tidyr::nest(specifications = c(-decision, -dplyr::matches("fitted$|computed$"))) |>
    dplyr::select(decision, specifications, dplyr::everything())
}


#' Run a multiverse-style descriptive analysis based on a complete decision grid
#'
#' @param .pipeline a \code{tibble} produced by a series of \code{add_*} calls.
#'   Importantly, this needs to be a pre-expanded pipeline because descriptive
#'   analyses only change when the underlying cases change. Thus, only filtering
#'   decisions will be used and internally expanded before calculating various
#'   descriptive analyses.
#' @param show_progress logical, whether to show a progress bar while running.
#'
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#' run_descriptives(pipeline)
#' }
run_descriptives <- function(.pipeline, show_progress = FALSE){

  filter_grid <-
    .pipeline |>
    dplyr::filter(stringr::str_detect(type, "filters|corrs|summary_stats|cron_alphas")) |>
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

        if("cron_alphas" %in% names(filter_grid)){
          multi_results$alphas <-
            run_universe_cron_alphas(
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
