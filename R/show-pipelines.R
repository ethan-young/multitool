show_filter_pipeline <- function(multiverse, decision_num, copy = F){

  code <-
    multiverse |>
    filter(decision == decision_num) |>
    unnest(code) |>
    pull(filter_code) |>
    str_replace_all("\\|\\>", " |>\n  ") |>
    glue::glue(.trim = FALSE)

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Filter pipline copied!")
  }

  code
}

show_post_filter_pipeline <- function(multiverse, decision_num, copy = F){

  code <-
    multiverse |>
    filter(decision == decision_num) |>
    select(code) |>
    unnest(code) |>
    select(starts_with("step")) |>
    map(function(x){
      str_replace_all(x, "\\|\\>", " |>\n  ") |>
        glue::glue(.trim = FALSE)
    })

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Post filter pipline copied!")
  }

  code
}

show_model_pipeline <- function(multiverse, decision_num, copy = F){

  code <-
    multiverse |>
    filter(decision == decision_num) |>
    unnest(code) |>
    pull(model_code) |>
    str_replace_all("\\|\\>", " |>\n  ") |>
    glue::glue(.trim = FALSE)

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Model pipline copied!")
  }

  code

}

show_summary_pipeline <- function(multiverse, decision_num, copy = F){

  code <-
    multiverse |>
    filter(decision == decision_num) |>
    select(code) |>
    unnest(code) |>
    select(starts_with("summary")) |>
    map(function(x){
      str_replace_all(x, "\\|\\>", " |>\n  ") |>
        glue::glue(.trim = FALSE)
    })

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Summary pipline copied!")
  }

  code
}

show_post_hoc_pipeline <- function(multiverse, decision_num, copy = F){

  code <-
    multiverse |>
    filter(decision == decision_num) |>
    select(code) |>
    unnest(code) |>
    select(starts_with("post_hoc")) |>
    map(function(x){
      str_replace_all(x, "\\|\\>", " |>\n  ") |>
        glue::glue(.trim = FALSE)
    })

  if(copy){
    suppressWarnings({clipr::write_clip(code)})
    message("Post hoc pipline copied!")
  }

  suppressWarnings(code)
}
