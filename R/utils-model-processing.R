# Model Processing Utilities
# Internal functions for processing fitted models, extracting parameters,
# and handling post-processing steps.

# Execute code ------------------------------------------------------------
#' @noRd
run_universe_code <-
  function(code, ...){
    rlang::parse_expr(code) |>
      rlang::eval_tidy(...)
  }

#' @noRd
run_universe_code_quietly <-
  purrr::quietly(
    function(code, ...){
      rlang::parse_expr(code) |>
        rlang::eval_tidy(...)
    }
  )

# Model Processing --------------------------------------------------------
#' Process run conditions
#' @noRd
process_conditions <- function(.df, conditions){

  # each test runs with the data piped into its front
  test_results <-
    purrr::map(conditions$test, \(test_code){
      glue::glue(".df |> {test_code}") |>
        rlang::parse_expr() |>
        rlang::eval_tidy(env = rlang::current_env())
    })

  not_single_logical <- !purrr::map_lgl(test_results, rlang::is_scalar_logical)

  if(any(not_single_logical)){
    rlang::abort(
      c(
        "Each condition test must return a single TRUE or FALSE.",
        x = glue::glue("Check: {stringr::str_flatten_comma(conditions$condition[not_single_logical])}")
      )
    )
  }

  condition_results <-
    conditions |>
    dplyr::mutate(
      result = purrr::list_c(test_results),
      # a test that can't be evaluated to TRUE (NA) counts as failed
      implied_action = dplyr::if_else(dplyr::coalesce(result, FALSE), "proceed", on_fail)
    )

  # halt takes priority over skip, and skip over proceed
  action <-
    if(any(condition_results$implied_action == "halt")){
      "halt"
    } else if(any(condition_results$implied_action == "skip")){
      "skip"
    } else{
      "proceed"
    }

  list(
    data              = .df,
    condition_results = condition_results,
    action            = action
  )
}

# Run and Process a model
#' @noRd
process_model <-
  function(
    code,
    .model_coefs = NULL,
    .model_fit = NULL,
    .model_standardize = NULL,
    param_keys = NULL,
    env = rlang::caller_env()
  ){

    model_results <- list()

    model_func <-
      code |>
      stringr::str_extract("\\|\\>[^\\|\\>].*$") |>
      stringr::str_remove(".*\\|\\> ") |>
      stringr::str_remove("\\(.*\\)")

    model_obj <- run_universe_code_quietly(code, env = env)

    if(.model_coefs != ""){
      model_coefs <-
        glue::glue("model_obj$result |> {.model_coefs} |> suppressMessages()") |>
        run_universe_code(env = rlang::current_env()) |>
        tibble::as_tibble() |>
        dplyr::rename_with(tolower)

      if(.model_standardize != ""){
        model_std <-
          glue::glue("model_obj$result |> {.model_standardize} |> suppressMessages()") |>
          run_universe_code(env = rlang::current_env()) |>
          tibble::as_tibble() |>
          dplyr::rename_with(tolower) |>
          dplyr::rename_with(
            ~paste0("std_", .x),
            -dplyr::matches("^std_")
          )

        term_col_coefs <- intersect(c("parameter", "term"), names(model_coefs))
        term_col_std    <- intersect(c("std_parameter", "std_term"), names(model_std))

        model_coefs <-
          model_coefs |>
          dplyr::left_join(
            model_std,
            dplyr::join_by({{term_col_coefs}} == {{term_col_std}})
          )
      }

      if(!is.null(param_keys)){
        term_col <- intersect(c("parameter", "term"), names(model_coefs))

        if(length(term_col) > 0){
          model_coefs <-
            model_coefs |>
            dplyr::left_join(
              param_keys,
              dplyr::join_by({{term_col}} == parameter)
            ) |>
            dplyr::relocate(parameter_key, .before = {{term_col}})
        }
      }

      model_coefs <- list(model_coefs)

    } else{
      # fallback: coef(summary()) coerced to tidy data.frame
      clean_summary_names <- function(x){
        x |>
          stringr::str_replace_all("\\s+", "_") |>
          stringr::str_replace_all("pr\\(>\\|[tz]\\|\\)", "p_value") |>
          stringr::str_replace_all("std\\._error|std\\. error", "std_error") |>
          stringr::str_replace_all("[^a-z0-9_]", "")
      }

      model_coefs <-
        coef(summary(model_obj$result)) |>
        as.data.frame() |>
        dplyr::rename_with(tolower) |>
        dplyr::rename_with(clean_summary_names) |>
        tibble::rownames_to_column("term") |>
        tibble::as_tibble()

      model_coefs <- list(model_coefs)

    }

    if(.model_fit != ""){
      model_fit <-
        glue::glue("model_obj$result |> {.model_fit} |> suppressMessages()") |>
        run_universe_code(env = rlang::current_env()) |>
        tibble::as_tibble() |>
        dplyr::rename_with(tolower)

      model_fit <- list(model_fit)

    } else{
      model_fit <- NULL
    }

    # Messages & Warnings
    model_messages <-
      tibble::tibble(
        model_messages = if(purrr::is_empty(model_obj$messages)) NA_character_ else model_obj$messages
      )

    model_warnings <-
      tibble::tibble(
        model_warnings = if(purrr::is_empty(model_obj$warnings)) NA_character_ else model_obj$warnings
      )

    output_full <-
      tibble::tibble(
        "model_function" := model_func,
        "model_parameters" := model_coefs,
        "model_performance" := model_fit,
        "model_warnings" := list(model_warnings),
        "model_messages" := list(model_messages)
      ) |>
      dplyr::select(-dplyr::where(is.null))

    list(
      results = output_full,
      model = model_obj$result
    )
  }


#' Strip problematic attributes
#' @noRd
strip_attributes <- function(x, keep = c("names", "class", "row.names")) {
  attributes(x) <- attributes(x)[keep]
  as.data.frame(x)
}

#' Post-process a fitted model
#' @noRd
postprocess_model <-
  function(
    model,
    code,
    additional_args = ""
  ){

    postmodel_func <-
      code |>
      stringr::str_remove("\\(.*\\)")

    postmodel_obj <-
      glue::glue("model |> {code} |> strip_attributes()") |>
      run_universe_code_quietly(env = rlang::current_env())

    # Messages & Warnings
    postmodel_messages <-
      tibble::tibble(
        postprocess_messages =
          if(purrr::is_empty(postmodel_obj$messages)) NA_character_ else postmodel_obj$messages
      )

    postmodel_warnings <-
      tibble::tibble(
        postprocess_warnings = if(purrr::is_empty(postmodel_obj$warnings)) NA_character_ else postmodel_obj$warnings
      )

    postmodel_output_full <-
      tibble::tibble(
        postprocess_function = postmodel_func,
        postprocess_output   = list(postmodel_obj$result),
        postprocess_warnings = list(postmodel_warnings),
        postprocess_messages = list(postmodel_messages)
      )

    postmodel_output_full
  }



# Model execution ---------------------------------------------------------
# Execute a single universe specification
#' @noRd
execute_universe_model <-
  function(
    .grid,
    decision_index,
    .on_break = "stop"
  ){
    stopifnot("models" %in% names(.grid))

    # set up the universe
    grid_slice <-
      .grid |>
      dplyr::filter(decision == decision_index)

    pipeline_code <- build_pipeline_code(.grid, decision_num = decision_index)

    pipeline_elements <- names(pipeline_code$pipeline)

    # data creation code, it creates model_data later
    data_step <- pipeline_elements[match("model", pipeline_elements) - 1]

    # modeling code, model_data is created later
    model_code <-
      glue::glue(
        "model_data |> {pipeline_code$pipeline$model}"
      ) |>
      as.character()

    if("parameter_keys" %in% names(.grid)){
      parameter_keys <-
        grid_slice |>
        dplyr::select(parameter_keys) |>
        tidyr::unnest(dplyr::everything())
    } else{
      parameter_keys <- NULL
    }

    model_settings <-
      grid_slice |>
      dplyr::select(models) |>
      tidyr::unnest(dplyr::everything())

    # meta data about the universe is saved regardless of errors
    results <- list()

    results$specifications <-
      grid_slice |>
      dplyr::select(-dplyr::any_of("parameter_keys")) |>
      tidyr::nest(specifications = c(-decision))

    results$pipeline_code <-
      build_step_code(pipeline_code) |>
      tidyr::nest(pipeline_code = dplyr::everything())

    # run the universe in steps: data -> conditions -> model -> postprocess
    # if an error occurs, current_step records the step where it happened
    current_step <- "data"

    run_outcome <-
      rlang::try_fetch(
        {
          data_run <-
            get_code(pipeline_code$pipeline, data_step) |>
            run_universe_code_quietly()

          model_data <- data_run$result

          results$data_steps <-
            tibble::tibble(
              data_rows = nrow(model_data),
              data_warnings =
                list(tibble::tibble(
                  data_warnings =
                    if(purrr::is_empty(data_run$warnings)) NA_character_ else data_run$warnings
                )),
              data_messages =
                list(tibble::tibble(
                  data_messages =
                    if(purrr::is_empty(data_run$messages)) NA_character_ else data_run$messages
                ))
            ) |>
            tidyr::nest(data_logs = dplyr::everything())

          condition_action <- "proceed"

          if(!is.null(pipeline_code$conditions)){
            current_step <- "conditions"

            curr_test <- process_conditions(model_data, pipeline_code$conditions)

            results$condition_results <-
              curr_test$condition_results |>
              tidyr::nest(condition_results = dplyr::everything())

            condition_action <- curr_test$action
          }

          if(condition_action == "proceed"){
            current_step <- "model"

            focal_model <-
              process_model(
                code = model_code,
                .model_coefs = model_settings$model_coefs_fn,
                .model_fit = model_settings$model_fit_fn,
                .model_standardize = model_settings$model_standardize_fn,
                param_keys = parameter_keys,
                env = rlang::current_env()
              )

            results$focal_model <-
              tibble::tibble(model_fitted = list(focal_model$results))

            if(!is.null(pipeline_code$pipeline$postprocess)){
              postprocessing_code <- pipeline_code$pipeline$postprocess

              results$postprocess <-
                purrr::map2(
                  postprocessing_code,
                  names(postprocessing_code),
                  \(code, func){
                    # update step to the current postprocess
                    current_step <<- glue::glue("postprocess ({func})")

                    tibble::tibble(
                      "{func}_fitted" := list(postprocess_model(focal_model$model, code))
                    )
                  }
                )
            }

            tibble::tibble(
              status = "completed",
              failed_step = NA_character_,
              run_message = NA_character_
            )

          } else{
            failed_conditions <-
              curr_test$condition_results |>
              dplyr::filter(implied_action == condition_action)

            tibble::tibble(
              status  = if(condition_action == "halt") "halted" else "skipped",
              failed_step = "conditions",
              run_message = stringr::str_flatten_comma(failed_conditions$condition)
            )
          }
        },
        error = function(cnd){
          if(.on_break == "stop"){
            rlang::abort(
              glue::glue("Decision {decision_index} failed at the {current_step} step."),
              parent = cnd,
              class = "multitool_decision_error"
            )
          }

          tibble::tibble(
            status  = "error",
            failed_step = as.character(current_step),
            run_message = rlang::cnd_message(cnd)
          )
        }
      )

    # a halt stops the run unless failures are being recorded
    if(.on_break == "stop" && run_outcome$status == "halted"){
      rlang::abort(
        c(
          glue::glue("Decision {decision_index} failed a condition with `on_fail = \"halt\"`."),
          x = glue::glue("Failed: {run_outcome$run_message}"),
          i = glue::glue("See the tests with `show_code_conditions(<grid>, {decision_index})`.")
        ),
        class = "multitool_condition_halt"
      )
    }

    results$run_outcome <- run_outcome

    purrr::reduce(results, dplyr::bind_cols) |>
      dplyr::select(
        decision,
        status,
        failed_step,
        run_message,
        specifications,
        dplyr::any_of(c("data_logs", "condition_results")),
        dplyr::ends_with("fitted"),
        pipeline_code
      )
  }
