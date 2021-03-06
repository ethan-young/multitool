#' Create a 'universe' console report
#'
#' @param multiverse a \code{tibble} created from \code{\link{run_multiverse}}
#' @param decision_num which decision set to create a report for
#'
#' @export
#'
#' @examples
#'
#' \dontrun{
#' my_multi_results <- run_multiverse(my_grid, .df)
#'
#' report_universe_console(my_multi_verse, .df, 1)
#' }
report_universe_console <-
  function(multiverse, decision_num){

    data_chr <- attr(multiverse, "base_df")
    grid_elements <- paste(names(multiverse), collapse = " ")

    universe <-
      multiverse |>
      dplyr::filter(decision == decision_num)

    cli::cli_rule(cli::style_bold(cli::col_green("Multiverse Analysis - Decision set {decision_num}")))
    cli::cli_par()
    cli::cli_end()
    cli::cli_text(cli::style_bold("Decisions"))
    data_ul <- cli::cli_ul()
    cli::cli_li("Input data:")
    sub_filter_ul <- cli::cli_ul()
    cli::cli_li("{cli::col_yellow(data_chr)}")
    cli::cli_end(data_ul)

    if(stringr::str_detect(grid_elements, "filters")){

      filters <-
        universe |>
        dplyr::select(filters) |>
        dplyr::pull() |>
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
        dplyr::select(variables) |>
        dplyr::pull() |>
        unlist()

      variable_ul <- cli::cli_ul()
      cli::cli_li("Variables:")
      sub_variables_ul <- cli::cli_ul()
      cli::cli_li(cli::col_cyan(variables))
      cli::cli_end(sub_variables_ul)
      cli::cli_end(variable_ul)

    } else{
      cli::cli_ul("Same variables used for all analyses")
    }

    model <-
      universe |>
      dplyr::pull(models) |>
      unlist()

    model_ul <- cli::cli_ul()
    cli::cli_li("Model Syntax:")
    sub_model_ul <- cli::cli_ul()
    cli::cli_li(cli::col_blue(model))
    cli::cli_end(sub_model_ul)
    cli::cli_end(model_ul)

    cli::cli_par()
    cli::cli_end()

    results <-
      universe |>
      dplyr::select(c(ends_with("fitted")))

    purrr::walk2(results, names(results), function(x, y){


      cli::cli_rule()
      cli::cli_text(cli::style_bold("{y} Code and Results"))

      map(x, function(z){
        cli::cli_h3("Code Pipeline")
        cli::cli_code(
          z |>
            dplyr::select(dplyr::ends_with("code")) |>
            dplyr::pull() |>
            stringr::str_replace_all("\\|\\>", " |>\n  ") |>
            glue::glue(.trim = FALSE)
        )

        cli::cli_h3("Tidy Results")
        z |>
          dplyr::select(dplyr::ends_with("tidy")) |>
          tidyr::unnest(dplyr::everything()) |>
          print()

        cli::cli_h3("Glance")
        z |>
          dplyr::select(dplyr::ends_with("glance")) |>
          tidyr::unnest(dplyr::everything()) |>
          print()

      })
      cli::cli_par()
      cli::cli_end()
    })
  }
