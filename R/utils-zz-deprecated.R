run_universe_model <-
  function(
    .grid,
    decision_num,
    run = TRUE,
    add_standardized = TRUE,
    save_model = FALSE
  ){
    data_chr <- attr(.grid, "base_df")
    subgroup_in_path <- attr(.grid, "subgroup_in_path")
    pointer <- attr(.grid, "pointer_path")

    if(!is.null(pointer)){
      data_chr <- glue::glue("open_dataset('{pointer}')")
    }

    collect_info <- attr(.grid, "where_to_collect")

    if(is.null(collect_info)){
      collect_info <- "base_df"
    }

    collect_after <-
      dplyr::case_when(
        collect_info %in% c("filters", "subgroups", "preprocess") ~ collect_info,
        T ~ "base_df"
      )

    grid_elements <- paste(names(.grid), collapse = " ")

    universe <-
      .grid |>
      dplyr::filter(decision == decision_num)

    universe_pipeline <- list(original_data = data_chr)
    universe_analyses <- list()
    universe_results <- list()
    show_code <- list()

    if(collect_after == "base_df"){
      universe_pipeline$collect <- "collect()"
    }

    if(stringr::str_detect(grid_elements, "subgroups")){
      subgroup_vars <-
        universe |>
        dplyr::pull(subgroups) |>
        unlist()

      if(!subgroup_in_path){
        subgroup_string <-
          purrr::map2_chr(
            .x = names(subgroup_vars), .y = subgroup_vars,
            \(x, y) glue::glue("{x} == {y}")
          ) |>
          paste0(collapse = ", ")

        universe_pipeline$subgroups <-
          glue::glue("filter({subgroup_string})")
      }

      if(subgroup_in_path & !is.null(pointer)){
        subgroup_string <-
          purrr::map2_chr(
            .x = names(subgroup_vars), .y = subgroup_vars,
            \(x, y) glue::glue("{x}={stringr::str_remove_all(y, '\\\"')}")
          ) |>
          paste0(collapse = "/")

        universe_pipeline$original_data <-
          glue::glue(
            "open_dataset('{pointer}/{subgroup_string}/')"
          )
      }

      if(collect_after == "subgroups"){
        universe_pipeline$collect <- "collect()"
      }

      show_code$subgroups <-
        list_to_pipeline(universe_pipeline, for_print = TRUE)

      universe_results$subgroup_code <-
        tibble::tibble(
          subgroup_code = list_to_pipeline(universe_pipeline)
        )
    }

    if(stringr::str_detect(grid_elements, "filters")){
      universe_pipeline$filters <-
        universe |>
        dplyr::pull(filters) |>
        unlist() |>
        paste0(collapse = ", ") |>
        paste0("filter(", ... =  _, ")")

      if(collect_after == "filters"){
        universe_pipeline$collect <- "collect()"
      }

      show_code$filters <-
        list_to_pipeline(universe_pipeline, for_print = TRUE)

      universe_results$filter_code <-
        tibble::tibble(
          filter_code = list_to_pipeline(universe_pipeline)
        )
    }

    if(stringr::str_detect(grid_elements, "preprocess")){
      universe_pipeline$preprocess <-
        universe |>
        dplyr::pull(preprocess) |>
        unlist() |>
        paste0(collapse = " |> ")

      if(collect_after == "preprocess"){
        universe_pipeline$collect <- "collect()"
      }

      show_code$preprocess <-
        list_to_pipeline(universe_pipeline, for_print = TRUE)

      universe_results$pre_process_code <-
        tibble::tibble(
          preprocess_code = list_to_pipeline(universe_pipeline)
        )
    }

    if(stringr::str_detect(grid_elements, "models")){
      universe_pipeline$model_code <-
        universe |>
        tidyr::unnest(models) |>
        dplyr::pull(model) |>
        stringr::str_replace(string = _ ,"\\)$", ", data = _)")

      show_code$model <-
        list_to_pipeline(universe_pipeline, for_print = TRUE)

      universe_analyses$model <- list_to_pipeline(universe_pipeline)

      additional_args <-
        universe |>
        tidyr::unnest(models) |>
        dplyr::pull(model_args) |>
        stringr::str_remove_all("^list\\(|\\)$")
    }

    if(stringr::str_detect(grid_elements, "postprocess")){
      universe_postprocess <-
        universe |>
        dplyr::select(postprocess) |>
        tidyr::unnest(postprocess) |>
        as.list() |>
        purrr::map(
          function(x) paste0(list_to_pipeline(universe_pipeline), " |> ", x)
        )

      show_code$postprocess <-
        universe |>
        dplyr::select(postprocess) |>
        tidyr::unnest(postprocess) |>
        as.list() |>
        purrr::map(
          function(x) paste0(list_to_pipeline(universe_pipeline, for_print = TRUE), " |> \n  ", x)
        )

      universe_analyses <-
        append(universe_analyses, universe_postprocess)
    }

    if(run){
      universe_results$model_results <-
        purrr::map2_dfc(
          universe_analyses, names(universe_analyses),
          function(x, y){

            if(y == "model"){
              results <-
                collect_quiet_results_easy(
                  x,
                  standardize = add_standardized,
                  save_model = save_model,
                  additional_args = additional_args
                )
            } else{
              results <-
                collect_quiet_results_easy(
                  x,
                  standardize = add_standardized,
                  save_model = save_model,
                  post_process = TRUE,
                  additional_args = additional_args
                ) |>
                dplyr::rename_with(~stringr::str_replace(.x, "model", y))
            }

            tibble(
              "{y}_fitted" := list(results |> dplyr::select(-dplyr::ends_with("code")))
            ) |>
              dplyr::bind_cols(results |> dplyr::select(dplyr::ends_with("code")))
          })

      if(stringr::str_detect(grid_elements, "parameter_keys")){
        custom_param_keys <-
          universe |>
          dplyr::select(parameter_keys) |>
          tidyr::unnest(parameter_keys)

        universe_results$model_results <-
          universe_results$model_results |>
          tidyr::unnest(model_fitted) |>
          tidyr::unnest(model_parameters) |>
          dplyr::left_join(custom_param_keys, by = "parameter") |>
          dplyr::relocate(parameter_key, .before = parameter) |>
          tidyr::nest(model_parameters = -dplyr::matches("^model_|_code$|_fitted")) |>
          dplyr::relocate(model_parameters, .after = model_function) |>
          tidyr::nest(model_fitted = -dplyr::matches("code$|fitted$")) |>
          dplyr::relocate(model_fitted,.before = 1)
      }

      universe_results |>
        purrr::reduce(dplyr::bind_cols) |>
        dplyr::mutate(
          decision = decision_num |> as.character(),
        ) |>
        dplyr::select(decision, dplyr::everything()) |>
        tidyr::nest(pipeline_code = dplyr::ends_with("code"))
    } else{
      show_code
    }
  }

run_universe_corrs <- function(.grid, decision_num, run = TRUE){

  data_chr <- attr(.grid, "base_df")
  grid_elements <- paste(names(.grid), collapse = " ")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  universe_pipeline <-list(original_data = data_chr)
  universe_results <- list()

  if(stringr::str_detect(grid_elements, "subgroups")){
    subgroup_vars <-
      universe |>
      dplyr::pull(subgroups) |>
      unlist()

    universe_pipeline$subgroups <-
      paste0(
        "filter(",
        purrr::map2_chr(
          .x = names(subgroup_vars), .y = subgroup_vars,
          \(x, y) glue::glue("as.character({x}) == '{y}'")) |>
          paste0(collapse = ", "),
        ")"
      )
  }

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

  if(run){
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
  } else{
    universe |>
      dplyr::select(corrs) |>
      tidyr::unnest(corrs) |>
      as.list() |>
      purrr::map(
        function(x){
          paste0(
            list_to_pipeline(universe_pipeline, for_print = TRUE),
            " |> \n  ",
            x |> stringr::str_replace_all(" \\|\\> ", " |> \n  ")
          )
        }
      )
  }
}

run_universe_summary_stats <- function(.grid, decision_num, run = TRUE){

  data_chr <- attr(.grid, "base_df")
  grid_elements <- paste(names(.grid), collapse = " ")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  universe_pipeline <-list(original_data = data_chr)
  universe_results <- list()

  if(stringr::str_detect(grid_elements, "subgroups")){
    subgroup_vars <-
      universe |>
      dplyr::pull(subgroups) |>
      unlist()

    universe_pipeline$subgroups <-
      paste0(
        "filter(",
        purrr::map2_chr(
          .x = names(subgroup_vars), .y = subgroup_vars,
          \(x, y) glue::glue("as.character({x}) == '{y}'")) |>
          paste0(collapse = ", "),
        ")"
      )
  }

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

  if(run){
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
  } else{
    universe |>
      dplyr::select(summary_stats) |>
      tidyr::unnest(summary_stats) |>
      as.list() |>
      purrr::map(
        function(x){
          paste0(
            list_to_pipeline(universe_pipeline, for_print = TRUE),
            " |> \n  ",
            x |> stringr::str_replace_all(" \\|\\> ", " |> \n  ")
          )
        }
      )
  }
}

run_universe_reliabilities <- function(.grid, decision_num, run = TRUE){

  data_chr <- attr(.grid, "base_df")
  grid_elements <- paste(names(.grid), collapse = " ")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  universe_pipeline <-list(original_data = data_chr)
  universe_results <- list()

  if(stringr::str_detect(grid_elements, "subgroups")){
    subgroup_vars <-
      universe |>
      dplyr::pull(subgroups) |>
      unlist()

    universe_pipeline$subgroups <-
      paste0(
        "filter(",
        purrr::map2_chr(
          .x = names(subgroup_vars), .y = subgroup_vars,
          \(x, y) glue::glue("as.character({x}) == '{y}'")) |>
          paste0(collapse = ", "),
        ")"
      )
  }

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
    dplyr::select(reliabilities) |>
    tidyr::unnest(reliabilities) |>
    names() |>
    unique()

  universe_reliabilities <-
    universe |>
    dplyr::select(reliabilities) |>
    tidyr::unnest(reliabilities) |>
    as.list() |>
    purrr::map(
      function(x) paste0(list_to_pipeline(universe_pipeline), " |> ", x)
    )

  if(run){
    universe_results <-
      purrr::map2_dfc(
        universe_reliabilities, item_sets,
        function(x, y){
          reliability_results <- run_universe_code_quietly(x)
          reliability <-
            tibble::tibble("{y}" := list(reliability_results$result))
        })

    universe_results |>
      dplyr::mutate(
        decision = decision_num |> as.character(),
      ) |>
      tidyr::nest(reliabilities_computed = c(-decision)) |>
      dplyr::select(decision, dplyr::everything())
  } else{
    universe |>
      dplyr::select(reliabilities) |>
      tidyr::unnest(reliabilities) |>
      as.list() |>
      purrr::map(
        function(x){
          paste0(
            list_to_pipeline(universe_pipeline, for_print = TRUE),
            " |> \n  ",
            x |> stringr::str_replace_all(" \\|\\> ", " |> \n  ")
          )
        }
      )
  }
}

## Not using
# grid_to_list <- function(.grid){
#
#   purrr::map(seq_len(nrow(.grid)), function(x){
#
#     grid_data <- .grid |>
#       dplyr::select(-dplyr::matches("filter_decision|decision"))
#
#     grid_list <-
#       grid_data |>
#       dplyr::filter(dplyr::row_number() == x) |>
#       tidyr::pivot_longer(dplyr::everything()) |>
#       dplyr::pull(value)
#
#     names(grid_list) <- names(grid_data)
#
#     grid_list
#
#   }) |>
#     purrr::set_names(paste0("decision_", 1:nrow(grid_data)))
#
# }
# list_to_grid <- function(list_grid){
#
#   if(!is.list(list_grid)){
#     list_grid <- list(list_grid)
#   }
#
#   list_grid |>
#     purrr::map_df(function(x) x |> as.list() |> tibble::as_tibble())
#
# }
# grid_to_formulas <- function(grid, glue_string){
#   grid |>
#     glue::glue_data(glue_string)
# }
# generate_multi_data <- function(.df, filter_grid){
#
#   filter_list <- grid_to_list(filter_grid$grid)
#
#   multi_data_list <-
#     purrr::map(filter_list, function(x){
#
#       filter_expr <-
#         glue::glue("filter(.df, {paste(x, collapse = ', ')})") |>
#         as.character()
#       data <- rlang::parse_expr(filter_expr) |> rlang::eval_tidy()
#
#       list(
#         decisions = x,
#         data      = .df
#       )
#     })
#
#   multi_data_list
# }
#
# check_tidiers <- function(code){
#
#   tidiers <-
#     utils::methods(broom.mixed::tidy) |>
#     as.character() |>
#     stringr::str_remove("^tidy\\.")
#
#   can_be_tidied <-
#     stringr::str_remove_all(code, "(\\(.*|^.*\\:\\:)")
#
#   if(can_be_tidied %in% c("lmer","glmer")){
#     can_be_tidied <- "merMod"
#   }
#
#   str_detect(tidiers, can_be_tidied) |> sum() > 0
#
# }
#
# check_glance <- function(code){
#
#   glancers <-
#     utils::methods(broom.mixed::glance) |>
#     as.character() |>
#     stringr::str_remove("^glance\\.")
#
#   can_be_glanced <-
#     stringr::str_remove_all(code, "(\\(.*|^.*\\:\\:)")
#
#   if(can_be_glanced %in% c("lmer","glmer")){
#     can_be_glanced <- "merMod"
#   }
#
#   str_detect(glancers, can_be_glanced) |> sum() > 0
#
# }
#
# collect_quiet_results <- function(code, save_model = FALSE){
#
#   quiet_results <- list()
#
#   model_func <-
#     code |>
#     stringr::str_extract("\\|\\>[^\\|\\>].*$") |>
#     stringr::str_remove(".*\\|\\> ") |>
#     stringr::str_remove("\\(.*\\)")
#
#   is_tidy <- check_tidiers(model_func)
#   is_glance <- check_glance(model_func)
#
#   quiet_results$model <- run_universe_code_quietly(code)
#
#   if(is_tidy){
#     quiet_results$tidy <-
#       code |>
#       paste("|> broom.mixed::tidy()", collapse = " ") |>
#       run_universe_code_quietly()
#   }
#   if(is_glance){
#     quiet_results$glance <-
#       code |>
#       paste("|> broom.mixed::glance()", collapse = " ") |>
#       run_universe_code_quietly()
#   }
#
#   warnings <-
#     purrr::map_df(quiet_results, "warnings") |>
#     dplyr::rename_with(~paste0("warning_", .x))
#   messages <-
#     purrr::map_df(quiet_results, "messages") |>
#     dplyr::rename_with(~paste0("message_", .x))
#
#   results <-
#     tibble::tibble(
#       "{model_func}_code" := code
#     )
#
#   if(save_model || !is_tidy){
#     results <-
#       dplyr::bind_cols(
#         results,
#         tibble::tibble("{model_func}_full" := list(quiet_results$model$result))
#       )
#   }
#
#   if(is_tidy){
#     results <-
#       dplyr::bind_cols(
#         results,
#         tibble::tibble("{model_func}_tidy" := list(quiet_results$tidy$result))
#       )
#   }
#
#   if(is_glance){
#     results <-
#       dplyr::bind_cols(
#         results,
#         tibble::tibble("{model_func}_glance" := list(quiet_results$glance$result))
#       )
#   }
#
#   results |>
#     mutate(
#       "{model_func}_warnings" := list(warnings),
#       "{model_func}_messages" := list(messages)
#     )
# }
