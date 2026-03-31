#' Perform all analyses over a complete decision grid
#'
#' @param .grid a \code{tibble} produced by \code{\link{expand_decisions}}
#' @param save_model logical, indicates whether to save the model object in its
#'   entirety. The default is \code{FALSE} because model objects are usually
#'   large and under the hood, \code{\link[parameters]{parameters}} and
#'   \code{\link[performance]{performance}} is used to summarize the most useful
#'   model information.
#' @param show_progress logical, whether to show a progress bar while running.
#' @param libraries a vector of character strings naming the packages you want
#'   to load when executing parallel processing. Internally, this will call
#'   \code{library} dynamically to ensure that any functions specific to a
#'   package you are using are available during execution on the individual
#'   workers. Only relevant if you have called \code{mirai::daemons()}.
#' @param ... this also reserved for parallel processing. Any custom functions
#'   you might use your pipeline (e.g., a custom post processing step), can be
#'   passed here in the form of \code{custom_func = custom_func}. This will be
#'   passed along to \code{purrr::in_parallel} to make them available on the
#'   independent workers.
#'
#' @return a single \code{tibble} containing tidied results for the model and
#'   any post-processing tests/tasks. For each unique test (e.g., an \code{lm}
#'   or \code{aov} called on an \code{lm}), a list column with the function name
#'   is created with \code{\link[parameters]{parameters}} and
#'   \code{\link[performance]{performance}} and any warnings or messages printed
#'   while fitting the models.
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
#' # analyze the grid
#' analyzed_grid <- analyze_grid(pipeline_grid[1:10,])
analyze_grid <-
  function(
    .grid,
    save_model = FALSE,
    show_progress = TRUE,
    libraries = NULL,
    ...
  ){

    custom_fns <- list(...)

    analyzed_grid <-
      purrr::map(
        1:nrow(.grid),
        purrr::in_parallel(
          function(index, ...){

            if(!is.null(libraries)){
              glue::glue("library({c('multitool', 'dplyr', libraries)})") |>
                paste(collapse = "; ") |>
                rlang::parse_exprs() |>
                purrr::walk(rlang::eval_tidy)
            }

            if(!purrr::is_empty(custom_fns)){
              glue::glue(
                "assign('{names(custom_fns)}', {custom_fns}, pos = .GlobalEnv)"
              ) |>
                rlang::parse_exprs() |>
                purrr::walk(rlang::eval_tidy)
            }

            start <- Sys.time()
            analyzed_result <-
              execute_universe_model(
                .grid,
                decision_index = index,
                save_model = save_model
              )
            end <- Sys.time()

            analyzed_result |>
              dplyr::mutate(
                run_started = start,
                run_ended = end,
                run_duration_seconds = end-start,
                run_duration_minutes = (end-start)/60
              ) |>
              tidyr::nest(timing_logs = dplyr::starts_with("run_"))
          },
          .grid = .grid,
          execute_universe_model = execute_universe_model,
          save_model = save_model,
          libraries = libraries,
          custom_fns = custom_fns
        ),
        .progress = show_progress
      )

    results <- purrr::list_rbind(analyzed_grid)

    attr(results, "pipeline") <- attr(.grid, "pipeline")

    results

  }

#' Analyze a complete decision grid in parallel
#'
#' @param .grid a \code{tibble} produced by \code{\link{expand_decisions}}
#' @param save_model logical, indicates whether to save the model object in its
#'   entirety. The default is \code{FALSE} because model objects are usually
#'   large and under the hood, \code{\link[parameters]{parameters}} and
#'   \code{\link[performance]{performance}} is used to summarize the most useful
#'   model information.
#' @param show_progress logical, whether to show a progress bar while running.
#' @param furrr_globals any global objects to pass to \code{furrr_options}
#' @param furrr_packages character vector, any packages to load inside parallel
#'   environments
#'
#' @return a single \code{tibble} containing tidied results for the model and
#'   any post-processing tests/tasks. For each unique test (e.g., an \code{lm}
#'   or \code{aov} called on an \code{lm}), a list column with the function name
#'   is created with \code{\link[parameters]{parameters}} and
#'   \code{\link[performance]{performance}} and any warnings or messages printed
#'   while fitting the models.
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#' library(furrr)
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
#' plan(multisession, workers = 4)
#' the_multiverse <- analyze_grid_parallel(pipeline_grid[4,])
#' plan(sequential)
analyze_grid_parallel <-
  function(
    .grid,
    save_model = FALSE,
    show_progress = TRUE,
    furrr_globals = NULL,
    furrr_packages = c("multitool", "dplyr", "tidyr")
  ){

    data_chr <- attr(.grid, "base_df")
    grid_chr <- dplyr::enexpr(.grid) |> as.character()

    opts <-
      furrr::furrr_options(
        globals = c(data_chr, furrr_globals),
        packages = furrr_packages
      )

    decision_vec <- .grid |> dplyr::pull(decision)

    analyzed_grid <-
      furrr::future_map(
        .options = opts,
        decision_vec,
        function(index){
          start <- Sys.time()
          analyzed_result <-
            execute_universe_model(
              .grid,
              decision_index = index,
              save_model = save_model
            )
          end <- Sys.time()

          analyzed_result |>
            dplyr::mutate(
              run_started = start,
              run_ended = end,
              run_duration_seconds = end-start,
              run_duration_minutes = (end-start)/60
            ) |>
            tidyr::nest(timing_logs = dplyr::starts_with("run_"))
        },
        .progress = show_progress
      )

    purrr::list_rbind(analyzed_grid)

  }
