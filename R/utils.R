
df_to_expand_prep <- function(decision_grid, decision_group, alternatives){

  grid_prep <-
    decision_grid |>
    dplyr::distinct({{decision_group}}) |>
    dplyr::pull() |>
    purrr::map(function(x){
      vect <-
        decision_grid |>
        dplyr::filter({{decision_group}} == x) |>
        dplyr::pull({{alternatives}})

      vect_chr <- paste0("'", vect, "'", collapse=",")

      new_vect <- glue::glue("{x} = c({paste0(vect_chr)})") |> as.character()
    })

  grid_prep
}

df_to_expand <- function(prep){

  glue::glue("tidyr::expand_grid({paste(prep, collapse = ', ')})") |>
    rlang::parse_expr() |>
    rlang::eval_tidy()

}

list_to_pipeline <- function(pipeline, for_print = FALSE, execute = FALSE){

  if(for_print){
    separator <- " |> \n  "
  } else{
    separator <- " |> "
  }

  pipeline_code <-
    pipeline |>
    purrr::compact() |>
    paste(collapse = separator) |>
    glue::glue(.trim = FALSE)

  if(execute){
    result <-
      pipeline_code |>
      rlang::parse_expr() |>
      rlang::eval_tidy()

    result
  } else{
    pipeline_code
  }
}

run_universe_code_quietly <-
  purrr::quietly(
    function(code){
      rlang::parse_expr(code) |>
        rlang::eval_tidy()
    }
  )

collect_quiet_results_easy <- function(code, standardize = TRUE, save_model = FALSE, post_process = FALSE){

  quiet_results <- list()

  model_func <-
    code |>
    stringr::str_extract("\\|\\>[^\\|\\>].*$") |>
    stringr::str_remove(".*\\|\\> ") |>
    stringr::str_remove("\\(.*\\)")

  is_easystats <- ifelse(model_func == "lmer", "merMod", model_func) %in% parameters::supported_models()

  quiet_results$model <- run_universe_code_quietly(code)

  if(is_easystats){
    ## Model coefficients
    quiet_results$params <-
      code |>
      paste("|> parameters::parameters()", collapse = " ") |>
      run_universe_code_quietly()

    ## Model fit
    quiet_results$performance <-
      code |>
      paste("|> performance::model_performance()", collapse = " ") |>
      run_universe_code_quietly()
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
          code |>
          paste("|> parameters::standardize_parameters()", collapse = " ") |>
          run_universe_code_quietly()

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

run_universe_model <- function(.grid, decision_num, run = TRUE, add_standardized = TRUE, save_model = FALSE){

  data_chr <- attr(.grid, "base_df")

  grid_elements <- paste(names(.grid), collapse = " ")

  universe <-
    .grid |>
    dplyr::filter(decision == decision_num)

  universe_pipeline <-list(original_data = data_chr)
  universe_analyses <- list()
  universe_results <- list()
  show_code <- list()

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
                save_model = save_model
              )
          } else{
            results <-
              collect_quiet_results_easy(
                x,
                standardize = add_standardized,
                save_model = save_model,
                post_process = TRUE
              ) |>
              dplyr::rename_with(~str_replace(.x, "model", y))
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

create_subgroup_nodes <- function(.grid){

  n_subgroup_datasets <- detect_n_subgroups(.grid)

  subgroup_nodes <-
    .grid |>
    dplyr::filter(type == "subgroups")

  if(nrow(subgroup_nodes) > 0){
    overview <-
      subgroup_nodes |>
      dplyr::group_by(type, group) |>
      dplyr::count() |>
      dplyr::ungroup() |>
      dplyr::summarize(
        type = unique(type),
        description =
          glue::glue(
            " _ {stringr::str_to_sentence(type)} __  --| {dplyr::n()} sets -| ({paste(n, collapse = '*')} = {n_subgroup_datasets}) - "
          ) |>
          as.character()
      )

    details <-
      subgroup_nodes |>
      dplyr::group_by(group) |>
      dplyr::summarize(
        type =  unique(type),
        description = glue::glue( "&#x2022; {code}") |> paste(... = _, collapse = " - ")
      ) |>
      summarize(
        type = glue::glue("{unique(type)}_set"),
        description = glue::glue( " _ {group} __  - {description}") |> paste(... = _, collapse = " -- ") |> as.character(),
        description = glue::glue("{description} - ")
      )

    list(overview, details)
  } else{
    message("No subgroups in your pipeline")
  }
}

create_var_nodes <- function(.grid){

  n_var_datasets <- detect_n_variables(.grid)

  variable_nodes <-
    .grid |>
    dplyr::filter(type == "variables")

  if(nrow(variable_nodes) > 0){
    overview <-
      variable_nodes |>
      dplyr::group_by(type, group) |>
      dplyr::count() |>
      dplyr::ungroup() |>
      dplyr::summarize(
        type        = unique(type),
        description = glue::glue(" _ {stringr::str_to_sentence(type)} __  --| {dplyr::n()} sets -| ({paste(n, collapse = '*')} = {n_var_datasets}) - ") |> as.character()
      )

    details <-
      variable_nodes |>
      dplyr::group_by(group) |>
      dplyr::summarize(
        type =  unique(type),
        description = glue::glue( "&#x2022; {code}") |> paste(... = _, collapse = " - ")
      ) |>
      summarize(
        type = glue::glue("{unique(type)}_set"),
        description = glue::glue( " _ {group} __  - {description}") |> paste(... = _, collapse = " -- ") |> as.character(),
        description = glue::glue("{description} - ")
      )

    list(overview, details)
  } else{
    message("No variable sets in your pipeline")
  }
}

create_filter_nodes <- function(.grid){

  filter_nodes <-
    .grid |>
    dplyr::filter(type == "filters") |>
    dplyr::mutate(
      code =
        stringr::str_replace_all(
          code,
          c(
            ">=" = "bigger than or equal to",
            "<=" = "less than or equal to",
            " > "  = " bigger than ",
            " < "  = " less than ",
            "==" = "equals",
            "!=" = "does not equal",
            "%in%.*$" = 'is any value',
            "scale\\((.*)\\)" = "z-scored \\1 is"
          )
        )
    )

  if(nrow(filter_nodes) > 0){
    n_filter_datasets <- detect_n_filters(.grid)

    overview <-
      filter_nodes |>
      dplyr::group_by(type, group) |>
      dplyr::count() |>
      dplyr::ungroup() |>
      dplyr::summarize(
        type = unique(type),
        description =
          glue::glue(
            " _ {stringr::str_to_sentence(type)} __  --| {dplyr::n()} sets -| ({paste(n, collapse = '*')} = {n_filter_datasets}) - "
          ) |>
          as.character()
      )

    details <-
      filter_nodes |>
      dplyr::group_by(group) |>
      dplyr::summarize(
        type =  unique(type),
        description =
          glue::glue( "&#x2022; {code}") |>
          paste(... = _, collapse = " - ")
      ) |>
      dplyr::summarize(
        type = glue::glue("{unique(type)}_set"),
        description =
          glue::glue(" _ {group} __  - {description}") |>
          paste(
            ... = _,
            collapse = " -- "
          ) |>
          as.character() |>
          paste0(... = _, " - ")
      )

    list(overview, details)
  } else{
    message("No filters in the pipeline")
  }
}

create_datasets_node <- function(.grid){

  n_datasets <- detect_multiverse_n(.grid, include_models = FALSE)
  n_subgroups <- detect_n_subgroups(.grid)
  n_vars <- detect_n_variables(.grid)
  n_filters <- detect_n_filters(.grid)

  if(n_datasets > 1){
    overview <-
      .grid |>
      dplyr::filter(type %in% c("subgroups","filters","variables")) |>
      dplyr::group_by(type, group) |>
      dplyr::count() |>
      dplyr::ungroup() |>
      dplyr::mutate(
        each =
          dplyr::case_when(
            type == "filters" ~ glue::glue("{n_filters}"),
            type == "variables" ~ glue::glue("{n_vars}"),
            type == "subgroups" ~ glue::glue("{n_subgroups}"),
            T~""
          ),
        .by = type
      ) |>
      dplyr::distinct(type, each) |>
      dplyr::summarize(
        description =
          glue::glue(
            " _ {n_datasets} analysis datasets __  --| {paste0(type, ' (', each, ')', collapse = ' * ')} - "
          ) |>
          as.character(),
        type = "total_dfs"
      )

    overview
  } else{
    tibble(
      type = "total_dfs",
      description = glue::glue(" _ {n_datasets} datasets __ ")
    )
  }
}

create_descriptive_node <- function(.grid){

  descriptives <-
    .grid |>
    dplyr::filter(type %in% c("summary_stats", "corrs", "reliabilities")) |>
    dplyr::filter(!stringr::str_detect(group, "_(matrix|focus|inter_corr|if_dropped)$")) |>
    dplyr::mutate(
      group = stringr::str_remove(group, "_(rs|alpha)$"),
      code_pipe = glue::glue("{attr(.grid, 'base_df')} |> {stringr::str_extract(code, '^.*\\\\|\\\\>')} ncol()"),
      code_names = ifelse(type == "summary_stats", glue::glue("{attr(.grid, 'base_df')} |> {code} |> names() |> stringr::str_remove('^.*_') |> unique() |> paste(... = _, collapse = ', ')"), "c()"),
    ) |>
    dplyr::mutate(
      code_result = purrr::map_chr(code_pipe, function(x) rlang::eval_tidy(rlang::parse_expr(x)) |> paste(... = _, collapse = ", ")),
      code_names = purrr::map_chr(code_names, function(x) rlang::eval_tidy(rlang::parse_expr(x)) |> paste(... = _, collapse = ", "))
    )

  if(nrow(descriptives) > 0){
    descriptives |>
      dplyr::group_by(type) |>
      dplyr::summarize(
        description =
          glue::glue(" _ {group} __  - {code_result} {ifelse(type == 'reliabilities','items', 'variables')}{ifelse(type == 'summary_stats', paste0(' - ', ' (',code_names,')'), '')}") |>
          paste(collapse = " -- ") |> paste0(... = _, " - ")
      ) |>
      mutate(
        type_pretty = dplyr::case_when(type == "corrs" ~ "Correlations",
                                       type == "summary_stats" ~ "Descriptive Statistics",
                                       type == "reliabilities" ~ "Reliabilities"),
        description = glue::glue(" _ {type_pretty} __  --| {description}")
      )
    # summarize(
    #   type = "descriptives",
    #   description = paste(description, collapse = " -- ")
    # )
  } else{
    message("no descriptives")
  }
}

create_preprocess_node <- function(.grid){
  preprocesses <-
    .grid |>
    dplyr::filter(type == "preprocess")

  if(nrow(preprocesses) > 0){
    preprocesses |>
      dplyr::group_by(type) |>
      dplyr::summarize(
        type = unique(type),
        description = glue::glue(" &#x2022; {group}") |> paste(... = _, collapse = " - ") |> as.character()
      ) |>
      dplyr::mutate(
        description = glue::glue(" _ Preprocessing Steps __  -- {description} - ")
      )
  } else{
    message("you have no preprocessing steps in your pipeline")
  }
}

create_postprocess_node <- function(.grid){
  postprocesses <-
    .grid |>
    dplyr::filter(type == "postprocess")

  if(nrow(postprocesses) > 0){
    postprocesses |>
      dplyr::group_by("type") |>
      dplyr::summarize(
        type = unique(type),
        description = glue::glue(" &#x2022; {group}") |> paste(... = _, collapse = " - ") |> as.character()
      ) |>
      dplyr::mutate(
        description = glue::glue(" _ Post-Processing Steps __  -- {description} - ")
      )
  } else{
    message("you have no post processing steps in your pipeline")
  }
}

create_model_nodes <- function(.grid){
  multi_models <-
    .grid |>
    dplyr::filter(type == "models")

  if(nrow(multi_models) > 0){
    multi_models |>
      dplyr::group_by(code) |>
      dplyr::summarize(
        type = glue::glue("model"),
        description = glue::glue(" _ {group} __  --| {code} - ") |> paste(... = _, collapse = "\n")
      ) |>
      dplyr::select(type, description) |>
      dplyr::mutate(
        type = glue::glue("{type}_{1:dplyr::n()}") |> as.character()
      )
  } else{
    message("you have no models specified in your pipeline")
  }
}

create_nmodels_node <- function(.grid){
  n_models <- detect_multiverse_n(.grid)

  n_models_summary <-
    .grid |>
    dplyr::filter(type %in% c("filters","variables","models"))

  if(nrow(n_models_summary) > 0){
    n_models_summary |>
      dplyr::mutate(group = ifelse(type=="models", "model", group)) |>
      dplyr::group_by(group) |>
      dplyr::count() |>
      dplyr::ungroup() |>
      dplyr::summarize(
        type        = "total_models",
        description = glue::glue(" _ {n_models} fitted models __  -- {paste0('(', paste(n, collapse = '*'), ')')} -| ") |> as.character()
      )
  } else{
    message("You don't have any models in your pipeline")
  }
}

create_pipeline_ndf <- function(.grid){

  node_list <- list()

  node_list$subgroups <- create_subgroup_nodes(.grid)
  node_list$var <- create_var_nodes(.grid)
  node_list$filter <- create_filter_nodes(.grid)
  node_list$datasets <- create_datasets_node(.grid)
  node_list$descr <- create_descriptive_node(.grid)
  node_list$pre <- create_preprocess_node(.grid)
  node_list$model <- create_model_nodes(.grid)
  node_list$nmodels <- create_nmodels_node(.grid)
  node_list$post <- create_postprocess_node(.grid)

  dplyr::bind_rows(node_list) |>
    dplyr::add_row(
      type = "base_df",
      description = paste0(" _ Base Dataset __  -- ", attr(.grid, "base_df"), " -| "),
      .before = 1
    ) |>
    dplyr::transmute(
      id = 1:dplyr::n(),
      nodes = type,
      label = description
    ) |>
    dplyr::mutate(
      order =
        dplyr::case_when(
          nodes == "base_df" ~ 1,
          nodes %in% c(
            "subgroups",
            "subgroups_set"
          ) ~ 2,
          nodes %in% c(
            "filters",
            "variables",
            "filters_set",
            "variables_set"
          ) ~ 3,
          nodes == "total_dfs" ~ 4,
          nodes == "descriptives" ~ 4,
          nodes %in% c("corrs", "reliabilities", "summary_stats") ~ 4,
          nodes == "preprocess" ~ 5,
          stringr::str_detect(nodes, "model_") ~ 6,
          nodes == "total_models" ~ 7,
          nodes == "postprocess" ~ 8
        ),
      rank = order
    ) |>
    as.data.frame()
}


multi_tab_interval <- function(x, range){
  tibble::tibble(stat = x) |>
    ggplot2::ggplot(ggplot2::aes(x = stat)) +
    ggdist::stat_pointinterval() +
    ggplot2::scale_x_continuous(limits = range) +
    ggplot2::theme_void()
}

multi_tab_dots <- function(x, range){
  tibble::tibble(stat = x) |>
    ggplot2::ggplot(ggplot2::aes(x = stat)) +
    ggdist::geom_dots() +
    ggplot2::scale_x_continuous(limits = range) +
    ggplot2::theme_void()
}

multi_tab_dotinterval <- function(x, range){
  tibble::tibble(stat = x) |>
    ggplot2::ggplot(ggplot2::aes(x = stat)) +
    ggdist::stat_dotsinterval() +
    ggplot2::scale_x_continuous(limits = range) +
    ggplot2::theme_void()
}

multi_tab_slab <- function(x, range){
  tibble::tibble(stat = x) |>
    ggplot2::ggplot(ggplot2::aes(x = stat)) +
    ggdist::stat_slab() +
    ggplot2::scale_x_continuous(limits = range) +
    ggplot2::theme_void()
}

multi_tab_slabinterval <- function(x, range){
  tibble::tibble(stat = x) |>
    ggplot2::ggplot(ggplot2::aes(x = stat)) +
    ggdist::stat_slabinterval() +
    ggplot2::scale_x_continuous(limits = range) +
    ggplot2::theme_void()
}

multi_tab_curve <- function(x, range){
  tibble(stat = sort(x), x = 1:length(x)) |>
    ggplot2::ggplot(ggplot2::aes(x = x, y = stat)) +
    ggplot2::geom_line() +
    ggplot2::scale_y_continuous(limits = range) +
    ggplot2::theme_void()
}

multi_tab_boxplot <- function(x, range){
  tibble::tibble(stat = x) |>
    ggplot2::ggplot(ggplot2::aes(x = stat)) +
    ggplot2::geom_boxplot() +
    ggplot2::scale_x_continuous(limits = range) +
    ggplot2::theme_void()
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
