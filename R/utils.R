# multitool internal utilities


# Build functions ---------------------------------------------------------
capture_base_data <- function(.df, df_expr, env){
  force(df_expr)

  base_df_name <- attr(.df, "base_df")

  # first verb in the pipeline: .df is the base data itself
  if(is.null(base_df_name)){
    if(!rlang::is_symbol(df_expr)){
      rlang::abort(
        c(
          "A pipeline must start from a named data object.",
          x = glue::glue("The pipeline starts from `{rlang::expr_text(df_expr)}`."),
          i = "Assign the data to a name first (e.g., `my_data <- ...`), then pipe `my_data` into the add_* functions."
        )
      )
    }

    return(list(name = rlang::as_string(df_expr), data = .df))
  }

  list(
    name = base_df_name,
    data = rlang::env_get(env, base_df_name, inherit = TRUE)
  )
}

append_decisions <- function(.df, decisions, base){
  if(!is.null(attr(.df, "base_df"))){
    decisions <- dplyr::bind_rows(.df, decisions)
  }

  attr(decisions, "base_df") <- base$name
  decisions
}



# Grid Expansion ----------------------------------------------------------
# Prepare decision grid for expansion
df_to_expand_prep <- function(decision_grid, decision_group, alternatives){
  alternatives_by_group <-
    decision_grid |>
    dplyr::summarise(
      alternatives = list({{ alternatives }}),
      .by = {{ decision_group }}
    )

  rlang::set_names(
    alternatives_by_group$alternatives,
    dplyr::pull(alternatives_by_group, {{ decision_group }})
  )
}

# Expand prepared grid
df_to_expand <- function(prep){
  tidyr::expand_grid(!!!prep)
}

# Pipeline Code Building --------------------------------------------------
# Convert pipeline list to code string
list_to_pipeline <- function(pipeline, for_print = FALSE, execute = FALSE){

  pipeline_code <-
    pipeline |>
    purrr::compact() |>
    paste(collapse = " |> ")

  if(for_print){
    pipeline_code <-
      pipeline_code |>
      stringr::str_replace_all("( *)\\|\\>( *)", " |> \n  ")
  }

  pipeline_code <- glue::as_glue(pipeline_code)

  if(execute){
    pipeline_code |>
      rlang::parse_expr() |>
      rlang::eval_tidy()
  } else{
    pipeline_code
  }
}

# Get code up to a specific elementl
get_code <- function(pipeline_list, which_element, for_print = FALSE){
  pipeline_elements <- names(pipeline_list)

  if(!which_element %in% pipeline_elements){
    rlang::abort(
      c(
        glue::glue("This decision's code has no `{which_element}` step."),
        i = glue::glue("Steps available: {stringr::str_flatten_comma(pipeline_elements)}")
      )
    )
  }

  code <- pipeline_list[seq_len(match(which_element, pipeline_elements))]
  list_to_pipeline(code, for_print = for_print)
}

# Build pipeline code for a decision
build_pipeline_code <- function(.grid, decision_num){

  universe_conditions <- NULL
  model_summaries     <- NULL

  data_chr <- attr(.grid, "base_df")
  subgroup_in_path <- attr(.grid, "subgroup_in_path")
  pointer <- attr(.grid, "pointer_path")

  if(isTRUE(subgroup_in_path) && is.null(pointer)){
    rlang::abort(
      c(
        "This grid sets `subgroup_in_path` but has no `pointer_path`.",
        i = "Expand the pipeline again with `.pointer_path`, or with `.subgroup_in_path = FALSE`."
      )
    )
  }

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

  grid_slice <-
    .grid |>
    dplyr::filter(decision == decision_num)

  universe_pipeline <- list(original_data = data_chr)

  if(collect_after == "base_df"){
    universe_pipeline$collect <- "collect()"
  }

  if(stringr::str_detect(grid_elements, "subgroups")){
    subgroup_vars <-
      grid_slice |>
      dplyr::pull(subgroups) |>
      unlist()

    if(isTRUE(subgroup_in_path)){
      # each subgroup is a hive directory; arrow writes missing values to a default partition
      subgroup_string <-
        purrr::map2_chr(names(subgroup_vars), subgroup_vars, \(x, y){
          value <- if(y == "NA") "__HIVE_DEFAULT_PARTITION__" else stringr::str_remove_all(y, stringr::fixed('"'))
          glue::glue("{x}={value}")
        }) |>
        paste0(collapse = "/")

      universe_pipeline$original_data <-
        glue::glue("open_dataset('{pointer}/{subgroup_string}/')")
    } else{
      # `x == NA` matches no rows, so missing values are selected with is.na()
      subgroup_string <-
        purrr::map2_chr(names(subgroup_vars), subgroup_vars, \(x, y){
          if(y == "NA") glue::glue("is.na({x})") else glue::glue("{x} == {y}")
        }) |>
        paste0(collapse = ", ")

      universe_pipeline$subgroups <-
        glue::glue("filter({subgroup_string})")
    }

    if(collect_after == "subgroups"){
      universe_pipeline$collect <- "collect()"
    }
  }

  if(stringr::str_detect(grid_elements, "filters")){
    universe_pipeline$filters <-
      grid_slice |>
      dplyr::pull(filters) |>
      unlist() |>
      paste0(collapse = ", ") |>
      paste0("filter(", ... =  _, ")")

    if(collect_after == "filters"){
      universe_pipeline$collect <- "collect()"
    }
  }

  if(stringr::str_detect(grid_elements, "preprocess")){
    universe_pipeline$preprocess <-
      grid_slice |>
      dplyr::pull(preprocess) |>
      unlist() |>
      paste0(collapse = " |> ")

    if(collect_after == "preprocess"){
      universe_pipeline$collect <- "collect()"
    }
  }

  if(stringr::str_detect(grid_elements, "conditions")){
    universe_conditions <-
      grid_slice |>
      dplyr::pull(conditions) |>
      purrr::pluck(1)
  }

  if(stringr::str_detect(grid_elements, "models")){
    universe_pipeline$model <-
      grid_slice |>
      tidyr::unnest(models) |>
      dplyr::pull(model) |>
      stringr::str_replace(string = _ ,"\\)$", ", data = _)")

    model_summaries <-
      grid_slice |>
      tidyr::unnest(models) |>
      dplyr::select(
        dplyr::any_of(
          c("model_coefs_fn", "model_fit_fn", "model_standardize_fn")
        )
      ) |>
      as.list()
  }

  if(stringr::str_detect(grid_elements, "postprocess")){
    universe_pipeline$postprocess <-
      grid_slice |>
      dplyr::select(postprocess) |>
      tidyr::unnest(postprocess) |>
      as.list()
  }

  list(
    pipeline        = universe_pipeline,
    conditions      = universe_conditions,
    model_summaries = model_summaries
  )

}

# Arrow file systems ------------------------------------------------------
detect_partitions <- function(arrow_ds) {
  field_names <- arrow_ds$schema$names

  tibble::tibble(dir = arrow_ds$files) |>
    dplyr::mutate(dir = stringr::str_remove(dir, "/[^/]+$")) |>
    dplyr::distinct(dir) |>
    dplyr::mutate(combination = dplyr::row_number()) |>
    tidyr::separate_longer_delim(dir, delim = "/") |>
    dplyr::filter(stringr::str_detect(dir, "=")) |>
    tidyr::separate_wider_delim(
      dir,
      delim    = "=",
      names    = c("field", "value"),
      too_many = "merge"
    ) |>
    dplyr::filter(field %in% field_names) |>
    tidyr::pivot_wider(
      id_cols     = combination,
      names_from  = field,
      values_from = value
    ) |>
    dplyr::select(-combination) |>
    dplyr::distinct()
}

cast_to_field <- function(raw_values, field_name, schema) {
  target_type <- schema[[field_name]]$type

  path_values <-
    raw_values |>
    dplyr::na_if("__HIVE_DEFAULT_PARTITION__") |>
    arrow::Array$create()

  path_values$cast(target_type) |> as.vector()
}

type_partitions <- function(partition_tbl, arrow_ds) {

  partition_tbl |>
    dplyr::mutate(
      dplyr::across(
        dplyr::everything(),
        \(raw_values) cast_to_field(raw_values, dplyr::cur_column(), arrow_ds$schema)
      )
    )
}

check_partition_source <- function(base_df) {
  if (!inherits(base_df, "FileSystemDataset")) {
    rlang::abort(
      c(
        "`.use_partitions = TRUE` requires a dataset opened with `arrow::open_dataset()`.",
        x = glue::glue("The base data is a <{class(base_df)[1]}>."),
        i = "Set `.use_partitions = FALSE` to read subgroups from columns."
      )
    )
  }
}

check_subgroups_partitioned <- function(subgroup_names, partition_tbl) {
  not_partitioned <- setdiff(subgroup_names, names(partition_tbl))

  if (length(not_partitioned) > 0) {
    rlang::abort(
      c(
        "With `.use_partitions = TRUE`, every subgroup variable must be a hive partition.",
        x = glue::glue("Not partitions: {stringr::str_flatten_comma(not_partitioned)}"),
        i = glue::glue("Partitions found: {stringr::str_flatten_comma(names(partition_tbl))}")
      )
    )
  }
}
