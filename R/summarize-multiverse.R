summary_console <-
  function(multiverse, my_data, decision_num){

    data_chr <- enexpr(my_data) |> as.character()
    grid_elements <- paste(names(multiverse), collapse = " ")

    universe <-
      multiverse |>
      filter(decision == decision_num)
    cli::cli_h1("Multiverse Analysis - Decision set {decision_num}")
    cli::cli_h2("Decisions")
    data_ul <- cli::cli_ul()
    cli::cli_li("Input data:")
    sub_filter_ul <- cli::cli_ul()
    cli::cli_li("{cli::col_yellow(data_chr)}")
    cli::cli_end(data_ul)

    if(stringr::str_detect(grid_elements, "filters")){

      filters <-
        universe |>
        select(filters) |>
        pull() |>
        unlist() |>
        unname()

      filter_ul <- cli::cli_ul()
      cli::cli_li("Filters applied:")
      sub_filter_ul <- cli::cli_ul()
      cli::cli_li(cli::col_red(filters))
      cli::cli_end(sub_filter_ul)
      cli::cli_end(filter_ul)

    } else{ cli::cli_ul("No filters applied")}

    if(stringr::str_detect(grid_elements, "variables")){

      variables <-
        universe |>
        select(variables) |>
        pull() |>
        unlist()

      variable_ul <- cli::cli_ul()
      cli::cli_li("Variables:")
      sub_variables_ul <- cli::cli_ul()
      cli::cli_li(cli::col_cyan(variables))
      cli::cli_end(sub_variables_ul)
      cli::cli_end(variable_ul)

    } else{ cli::cli_ul("Same variables used for all analyses")}

    model <-
      universe |>
      pull(model)

    model_ul <- cli::cli_ul()
    cli::cli_li("Mdoel Syntax:")
    sub_model_ul <- cli::cli_ul()
    cli::cli_li(cli::col_blue(model))
    cli::cli_end(sub_model_ul)
    cli::cli_end(model_ul)

    cli::cli_h2("Literal Code")
    cli::cli_code(show_model_pipeline(multiverse, decision_num = decision_num))

    cli::cli_h2("Results Summary")
    universe |> select(summary_result) |> unnest(summary_result)
  }
