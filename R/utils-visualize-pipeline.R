#' @noRd
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

#' @noRd
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

#' @noRd
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

#' @noRd
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

#' @noRd
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

#' @noRd
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

#' @noRd
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

#' @noRd
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

#' @noRd
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

#' @noRd
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
