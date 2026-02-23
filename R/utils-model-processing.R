# Model Processing Utilities
# Internal functions for processing fitted models, extracting parameters,
# and handling post-processing steps.

# Execute code ------------------------------------------------------------
run_universe_code <-
  function(code, ...){
    rlang::parse_expr(code) |>
      rlang::eval_tidy(...)
  }

run_universe_code_quietly <-
  purrr::quietly(
    function(code, ...){
      rlang::parse_expr(code) |>
        rlang::eval_tidy(...)
    }
  )

# Model Processing --------------------------------------------------------
# Run and Process a model
process_model <-
  function(
    code,
    standardize = TRUE,
    run_performance = TRUE,
    save_model = FALSE,
    additional_args = "",
    param_keys = NULL
  ){

    model_results <- list()

    model_func <-
      code |>
      stringr::str_extract("\\|\\>[^\\|\\>].*$") |>
      stringr::str_remove(".*\\|\\> ") |>
      stringr::str_remove("\\(.*\\)")

    is_easystats <-
      dplyr::case_when(
        model_func %in% c("lmer", "glmer") ~ "merMod",
        model_func == "feols" ~ "fixest",
        TRUE ~ model_func
      ) %in% parameters::supported_models()

    model_obj <- run_universe_code_quietly(code)

    if(is_easystats){
      ## Model coefficients
      model_params <-
        "model_obj$result" |>
        paste(
          " |> parameters::model_parameters(",
          additional_args,
          ") |> suppressMessages()",
          collapse = " "
        ) |>
        run_universe_code(env = rlang::current_env()) |>
        dplyr::rename_with(tolower) |>
        dplyr::rename(
          unstd_coef = coefficient,
          unstd_ci = ci,
          unstd_ci_low = ci_low,
          unstd_ci_high = ci_high
        ) |>
        tibble::as_tibble()

      if(standardize){
        model_std <-
          "model_obj$result" |>
          paste(" |> parameters::standardize_parameters() |> suppressMessages()", collapse = "") |>
          run_universe_code(env = rlang::current_env())

        model_params <-
          model_params |>
          dplyr::left_join(
            model_std |>
              dplyr::rename_with(tolower) |>
              dplyr::rename(
                std_coef = std_coefficient,
                std_ci = ci,
                std_ci_low = ci_low,
                std_ci_high = ci_high
              ),
            dplyr::join_by(parameter)
          )
      }

      if(!is.null(param_keys)){
        model_params <-
          model_params |>
          dplyr::left_join(
            param_keys,
            dplyr::join_by(parameter)
          ) |>
          dplyr::relocate(parameter_key, .before = parameter)
      }

      ## Model fit
      if(run_performance){
        model_perform <-
          "model_obj$result" |>
          paste(
            "|> performance::model_performance() |> suppressMessages()",
            collapse = ""
          ) |>
          run_universe_code(env = rlang::current_env()) |>
          tibble::as_tibble()
      } else{
        model_perform <- NA
      }
    }

    # Messages & Warnings
    model_messages <-
      tibble::tibble(
        model_messages =
          ifelse(
            purrr::is_empty(model_obj$messages),
            NA,
            model_obj$messages
          )
      )

    model_warnings <-
      tibble::tibble(
        model_warnings =
          ifelse(
            purrr::is_empty(model_obj$warnings),
            NA,
            model_obj$warnings
          )
      )

    if(!is_easystats){
      # Not easystats compatible
      output_full <-
        tibble::tibble(
          "model_function" := model_func,
          "model_full" := list(model_obj$result),
          "model_warnings" := list(model_warnings),
          "model_messages" := list(model_messages)
        )
    } else if(save_model){
      # easystats compatible with full model
      output_full <-
        tibble::tibble(
          "model_function" := model_func,
          "model_object" := list(model_obj$result),
          "model_parameters" := list(model_params),
          "model_performance" := list(model_perform),
          "model_warnings" := list(model_warnings),
          "model_messages" := list(model_messages)
        )
    } else{
      # Default, easystats compatible & lightweight
      output_full <-
        tibble::tibble(
          "model_function" := model_func,
          "model_parameters" := list(model_params),
          "model_performance" := list(model_perform),
          "model_warnings" := list(model_warnings),
          "model_messages" := list(model_messages)
        )
    }

    list(
      results = output_full,
      model = model_obj$result
    )
  }

#' Post-process a fitted model
#' @keywords internal
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
      glue::glue("model |> {code}") |>
      run_universe_code_quietly(env = rlang::current_env())

    # Messages & Warnings
    postmodel_messages <-
      tibble::tibble(
        model_messages =
          ifelse(
            purrr::is_empty(postmodel_obj$messages),
            NA,
            postmodel_obj$messages
          )
      )

    postmodel_warnings <-
      tibble::tibble(
        model_warnings =
          ifelse(
            purrr::is_empty(postmodel_obj$warnings),
            NA,
            postmodel_obj$warnings
          )
      )

    postmodel_output_full <-
      tibble::tibble(
        "{postmodel_func}_function" := postmodel_func,
        "{postmodel_func}_output" := list(postmodel_obj$result),
        "{postmodel_func}_warnings" := list(postmodel_warnings),
        "{postmodel_func}_messages" := list(postmodel_messages)
      )

    postmodel_output_full
  }

# Collect results using easystats
collect_quiet_results_easy <-
  function(
    code,
    standardize = TRUE,
    save_model = FALSE,
    post_process = FALSE,
    additional_args = ""
  ){

    quiet_results <- list()

    model_func <-
      code |>
      stringr::str_extract("\\|\\>[^\\|\\>].*$") |>
      stringr::str_remove(".*\\|\\> ") |>
      stringr::str_remove("\\(.*\\)")

    is_easystats <-
      ifelse(
        model_func %in% c("lmer", "glmer"),
        "merMod",
        model_func
      ) %in% parameters::supported_models()

    quiet_results$model <- run_universe_code_quietly(code)

    if(is_easystats){
      ## Model coefficients
      quiet_results$params <-
        #code
        "quiet_results$model$result" |>
        paste(
          "|> parameters::parameters(",
          additional_args,
          ") |> suppressMessages()",
          collapse = " "
        ) |>
        run_universe_code_quietly(env = rlang::current_env())

      ## Model fit
      quiet_results$performance <-
        #code |>
        "quiet_results$model$result" |>
        paste("|> performance::model_performance() |> suppressMessages()", collapse = " ") |>
        run_universe_code_quietly(env = rlang::current_env())
    }

    ## Warnings and Messages
    warnings <-
      purrr::map_df(quiet_results, "warnings") |>
      dplyr::rename_with(~paste0("warning_", .x))
    messages <-
      purrr::map_df(quiet_results, "messages") |>
      dplyr::rename_with(~paste0("message_", .x))

    results <-
      tibble::tibble(
        "model_code" := code
      )

    if(save_model || !is_easystats){
      results <-
        dplyr::bind_cols(
          results,
          tibble::tibble("model_full" := list(quiet_results$model$result))
        )
    }

    if(is_easystats & !save_model){
      if(post_process){
        final_results <-
          dplyr::bind_cols(
            results,
            tibble::tibble(
              "{model_func}_parameters" := list(quiet_results$params$result),
              "{model_func}_warnings" := list(warnings),
              "{model_func}_messages" := list(messages)
            )
          )
      } else{

        model_results <-
          quiet_results$params$result |>
          dplyr::rename_with(tolower) |>
          dplyr::rename(
            unstd_coef = coefficient,
            unstd_ci = ci,
            unstd_ci_low = ci_low,
            unstd_ci_high = ci_high
          )

        if(standardize){

          quiet_results$std_params <-
            #code |>
            "quiet_results$model$result" |>
            paste("|> parameters::standardize_parameters() |> suppressMessages()", collapse = " ") |>
            run_universe_code_quietly(env = rlang::current_env())

          model_results <-
            dplyr::left_join(
              model_results,
              quiet_results$std_params$result |>
                dplyr::rename_with(tolower) |>
                dplyr::rename(
                  std_coef = std_coefficient,
                  std_ci = ci,
                  std_ci_low = ci_low,
                  std_ci_high = ci_high
                ),
              dplyr::join_by(parameter)
            )
        }

        final_results <-
          dplyr::bind_cols(
            results,
            tibble::tibble(
              model_function = model_func,
              model_parameters = list(model_results),
              model_performance =
                list(
                  quiet_results$performance$result |>
                    dplyr::rename_with(tolower)
                )
            ) |>
              mutate(
                "model_warnings" := list(warnings),
                "model_messages" := list(messages)
              )
          )
      }
    } else{
      final_results <-
        results |>
        mutate(
          "model_warnings" := list(warnings),
          "model_messages" := list(messages)
        )
    }

    final_results

  }

# Model execution ---------------------------------------------------------
# Execute a single universe specification
execute_universe_model <-
  function(
    .grid,
    decision_index,
    save_model = FALSE
  ){
    stopifnot("models" %in% names(.grid))

    grid_slice <-
      .grid |>
      dplyr::filter(decision == decision_index)

    pipeline_code <- build_pipeline_code(.grid, decision_num = decision_index)

    model_code <- get_code(pipeline_code$pipeline, "model")

    if("parameter_keys" %in% names(.grid)){
      parameter_keys <-
        grid_slice |>
        dplyr::select(parameter_keys) |>
        tidyr::unnest(dplyr::everything())
    } else{
      parameter_keys <- NULL
    }

    add_standardized <-
      grid_slice |>
      dplyr::select(models) |>
      tidyr::unnest(dplyr::everything()) |>
      dplyr::pull(model_standardize) |>
      as.logical()

    add_performance <-
      grid_slice |>
      dplyr::select(models) |>
      tidyr::unnest(dplyr::everything()) |>
      dplyr::pull(model_perform) |>
      as.logical()

    focal_model <-
      process_model(
        code = model_code,
        save_model = save_model,
        standardize = add_standardized,
        run_performance = add_performance,
        additional_args = pipeline_code$model_args,
        param_keys = parameter_keys
      )

    results <- list()

    results$specifications <-
      grid_slice |>
      dplyr::select(-dplyr::any_of("parameter_keys")) |>
      tidyr::nest(specifications = c(-decision))

    results$focal_model <-
      tibble::tibble(
        model_fitted = list(focal_model$result)
      )

    if("postprocess" %in% names(.grid)){
      postprocessing_code <- pipeline_code$pipeline$postprocess

      results$postprocess <-
        purrr::map2(
          postprocessing_code,
          names(postprocessing_code),
          function(code, func){
            tibble::tibble(
              "{func}_fitted" :=
                list(
                  postprocess_model(focal_model$model, code)
                )
            )
          }
        )
    }

    pipeline_ref <- purrr::list_flatten(pipeline_code$pipeline)

    results$pipeline_code <-
      purrr::map(seq_along(pipeline_ref), function(step){
        tibble::tibble(
          pipeline_step = names(pipeline_ref[step]),
          code = list_to_pipeline(pipeline_ref[1:step])
        )
      }) |>
      purrr::list_rbind() |>
      dplyr::mutate(
        pipeline_step = stringr::str_remove(pipeline_step, "postprocess_")
      ) |>
      tidyr::pivot_wider(names_from = pipeline_step, values_from = code) |>
      tidyr::nest(pipeline_code = dplyr::everything())

    purrr::reduce(results, dplyr::bind_cols)
  }
