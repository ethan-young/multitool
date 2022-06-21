show_pipe_filter <- function(multiverse, decision_num, copy = F){

  code <-
    multiverse |>
    filter(decision == decision_num) |>
    unnest(data_pipeline) |>
    pull(filter_code) |>
    str_replace_all("\\|\\>", " |>\n  ") |>
    glue::glue(.trim = FALSE)

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Filter pipline copied!")
  }

  code
}

show_pipe_preprocess <- function(multiverse, decision_num, copy = F){

  code <-
    multiverse |>
    filter(decision == decision_num) |>
    unnest(data_pipeline) |>
    pull(preprocess_code) |>
    str_replace_all("\\|\\>", " |>\n  ") |>
    glue::glue(.trim = FALSE)

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Post filter pipline copied!")
  }

  code
}

show_pipe_model <- function(multiverse, decision_num, mod, copy = F){

  code <-
    multiverse |>
    filter(decision == decision_num) |>
    select({{mod}}) |>
    unnest({{mod}}) |>
    select(ends_with("code")) |>
    pull() |>
    str_replace_all("\\|\\>", " |>\n  ") |>
    glue::glue(.trim = FALSE)

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Model pipline copied!")
  }

  code

}
