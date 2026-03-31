# multitool internal utilities


# Grid Expansion ----------------------------------------------------------
# Prepare decision grid for expansion
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

# Expand prepared grid
df_to_expand <- function(prep){

  glue::glue("tidyr::expand_grid({paste(prep, collapse = ', ')})") |>
    rlang::parse_expr() |>
    rlang::eval_tidy()

}

# Pipeline Code Building --------------------------------------------------
# Convert pipeline list to code string
list_to_pipeline <- function(pipeline, for_print = FALSE, execute = FALSE){

  # if(for_print){
  #   separator <- " |> \n  "
  # } else{
  #   separator <- " |> "
  # }

  if(for_print){
    pipeline_code <-
      pipeline |>
      purrr::compact() |>
      paste(collapse = " |> ") |>
      stringr::str_replace_all("( *)\\|\\>( *)", " |> \n  ") |>
      glue::glue(.trim = FALSE)
  } else{
    pipeline_code <-
      pipeline |>
      purrr::compact() |>
      paste(collapse = " |> ") |>
      glue::glue(.trim = FALSE)
  }

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

# Get code up to a specific elementl
get_code <- function(pipeline_list, which_element, for_print = FALSE){
  pipeline_elements <- names(pipeline_list)
  code <- pipeline_list[1:which(pipeline_elements == which_element)]
  list_to_pipeline(code, for_print = for_print)
}

# Build pipeline code for a decision
build_pipeline_code <- function(.grid, decision_num){

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
    pipeline = universe_pipeline,
    model_summaries = model_summaries
  )

}
