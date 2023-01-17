grid_to_list <- function(.grid){

  purrr::map(seq_len(nrow(.grid)), function(x){

    grid_data <- .grid |>
      dplyr::select(-dplyr::matches("filter_decision|decision"))

    grid_list <-
      grid_data |>
      dplyr::filter(dplyr::row_number() == x) |>
      tidyr::pivot_longer(dplyr::everything()) |>
      dplyr::pull(value)

    names(grid_list) <- names(grid_data)

    grid_list

  }) |>
    purrr::set_names(paste0("decision_", 1:nrow(grid_data)))

}

list_to_grid <- function(list_grid){

  if(!is.list(list_grid)){
    list_grid <- list(list_grid)
  }

  list_grid |>
    purrr::map_df(function(x) x |> as.list() |> tibble::as_tibble())

}

grid_to_formulas <- function(grid, glue_string){
  grid |>
    glue::glue_data(glue_string)
}

generate_multi_data <- function(.df, filter_grid){

  filter_list <- grid_to_list(filter_grid$grid)

  multi_data_list <-
    purrr::map(filter_list, function(x){

      filter_expr <-
        glue::glue("filter(.df, {paste(x, collapse = ', ')})") |>
        as.character()
      data <- rlang::parse_expr(filter_expr) |> rlang::eval_tidy()

      list(
        decisions = x,
        data      = .df
      )
    })

  multi_data_list
}

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
    glue::glue(.trim = F)

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

check_tidiers <- function(code){

  tidiers <-
    utils::methods(broom.mixed::tidy) |>
    as.character() |>
    stringr::str_remove("^tidy\\.")

  can_be_tidied <-
    stringr::str_remove_all(code, "(\\(.*|^.*\\:\\:)")

  if(can_be_tidied %in% c("lmer","glmer")){
    can_be_tidied <- "merMod"
  }

  str_detect(tidiers, can_be_tidied) |> sum() > 0

}

check_glance <- function(code){

  glancers <-
    utils::methods(broom.mixed::glance) |>
    as.character() |>
    stringr::str_remove("^glance\\.")

  can_be_glanced <-
    stringr::str_remove_all(code, "(\\(.*|^.*\\:\\:)")

  if(can_be_glanced %in% c("lmer","glmer")){
    can_be_glanced <- "merMod"
  }

  str_detect(glancers, can_be_glanced) |> sum() > 0

}

run_universe_code_quietly <-
  purrr::quietly(
    function(code){
      rlang::parse_expr(code) |>
        rlang::eval_tidy()
    }
  )

collect_quiet_results <- function(code, save_model = FALSE){

  quiet_results <- list()

  model_func <-
    code |>
    stringr::str_extract("\\|\\>[^\\|\\>].*$") |>
    stringr::str_remove(".*\\|\\> ") |>
    stringr::str_remove("\\(.*\\)")

  is_tidy <- check_tidiers(model_func)
  is_glance <- check_glance(model_func)

  quiet_results$model <- run_universe_code_quietly(code)

  if(is_tidy){
    quiet_results$tidy <-
      code |>
      paste("|> broom.mixed::tidy()", collapse = " ") |>
      run_universe_code_quietly()
  }
  if(is_glance){
    quiet_results$glance <-
      code |>
      paste("|> broom.mixed::glance()", collapse = " ") |>
      run_universe_code_quietly()
  }

  warnings <-
    purrr::map_df(quiet_results, "warnings") |>
    dplyr::rename_with(~paste0("warning_", .x))
  messages <-
    purrr::map_df(quiet_results, "messages") |>
    dplyr::rename_with(~paste0("message_", .x))

  results <-
    tibble::tibble(
      "{model_func}_code" := code
    )

  if(save_model || !is_tidy){
    results <-
      dplyr::bind_cols(
        results,
        tibble::tibble("{model_func}_full" := list(quiet_results$model$result))
      )
  }

  if(is_tidy){
    results <-
      dplyr::bind_cols(
        results,
        tibble::tibble("{model_func}_tidy" := list(quiet_results$tidy$result))
      )
  }

  if(is_glance){
    results <-
      dplyr::bind_cols(
        results,
        tibble::tibble("{model_func}_glance" := list(quiet_results$glance$result))
      )
  }

  results |>
    mutate(
      "{model_func}_warnings" := list(warnings),
      "{model_func}_messages" := list(messages)
    ) |>
    tidyr::nest("{model_func}_fitted" := dplyr::starts_with(model_func))
}


