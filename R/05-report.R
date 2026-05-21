configure_labels <- function(.results, ...) {

  labels <- attr(.results, "labels")

  if (is.null(labels)) {
    if (!is.null(attr(.results, "pipeline"))) {
      pipeline_data <- attr(.results, "pipeline")
    } else {
      rlang::abort("Input must be an expanded grid or analyzed grid.")
    }

    labels <-
      pipeline_data |>
      dplyr::select(type, group, code) |>
      dplyr::mutate(
        group_label = group,
        alt_label = dplyr::case_when(
          type == "filters" & stringr::str_detect(code, "%in% unique") ~
            glue::glue("No filter on {group}") |> as.character(),
          type == "models" ~ group,
          TRUE ~ code
        )
      )
  }

  pairs <- list(...)

  for (key in names(pairs)) {
    val <- pairs[[key]]

    if (key %in% labels$group) {
      # Update group label
      labels <-
        labels |>
        dplyr::mutate(
          group_label = ifelse(group == key, val, group_label)
        )

      # Auto-cascade do-nothing filter labels
      labels <-
        labels |>
        dplyr::mutate(
          alt_label = dplyr::case_when(
            group == key &
              type == "filters" &
              stringr::str_detect(code, "%in% unique") ~
              glue::glue("No filter on {val}") |> as.character(),
            TRUE ~ alt_label
          )
        )

    } else if (key %in% labels$code) {
      labels <-
        labels |>
        dplyr::mutate(
          alt_label = ifelse(code == key, val, alt_label)
        )
    } else {
      rlang::warn(
        glue::glue('"{key}" not found in pipeline groups or codes. Skipping.')
      )
    }
  }

  attr(.results, "labels") <- labels
  .results
}

show_labels <- function(.object, .code = FALSE) {

  if (!is.null(attr(.object, "labels"))) {
    label_tbl <- attr(.object, "labels")
  } else {
    rlang::abort(
      c(
        "No labels found.",
        i = "Pipe through configure_labels() first."
      )
    )
  }

  if (.code) {
    # Helper to wrap keys with spaces in backticks
    format_key <- function(key, quote = FALSE) {
      if (quote) {
        glue::glue('"{key}"')
      } else if (stringr::str_detect(key, "\\s")) {
        glue::glue('`{key}`')
      } else {
        key
      }
    }

    group_pairs <-
      label_tbl |>
      dplyr::distinct(group, group_label) |>
      dplyr::mutate(key = purrr::map_chr(group, format_key)) |>
      glue::glue_data('  {key} = "{group_label}"')

    alt_pairs <-
      label_tbl |>
      dplyr::filter(
        !(type == "filters" & stringr::str_detect(code, "%in% unique"))
      ) |>
      dplyr::mutate(
        key = purrr::map2_chr(code, type == "filters", format_key)
      ) |>
      glue::glue_data('  {key} = "{alt_label}"')

    cat("configure_labels(\n")
    cat("\n  # Groups\n")
    cat(paste(group_pairs, collapse = ",\n"))
    cat(",\n")
    cat("\n  # Alternatives\n")
    cat(paste(alt_pairs, collapse = ",\n"))
    cat("\n)\n")
  }else {
    print(label_tbl, n = nrow(label_tbl))
  }

  invisible(.object)
}

add_section <-
  function(
    .report,
    code,
    .title,
    .layout,
    .description,
    .widths = c(50, 50),
    .v_pad = "1.5cm"
  ){
    code <- dplyr::enexprs(code)
    code_chr <-
      as.character(code) |>
      stringr::str_remove_all("\n|    ")

    data_chr <- dplyr::enexpr(.report) |> as.character()
    data_attr <- attr(.report, "analysis_grid")

    if(!is.null(data_attr)){
      data_chr <- attr(.report, "analysis_grid")
    }

    analysis_grid <-
      rlang::parse_expr(data_chr) |>
      rlang::eval_tidy(env = parent.frame())

    report_code <-
      glue::glue("{data_chr} |> {code_chr}")

    report_data <-
      rlang::parse_expr(report_code) |>
      rlang::eval_tidy()

    report_prep <-
      tibble::tibble(
        sec_title = .title,
        sec_layout = .layout,
        sec_descr = .description,
        sec_code = report_code,
        sec_content = list(report_data),
        sec_widths = list(.widths),
        sec_v_pad = .v_pad
      )

    if(!is.null(data_attr)){
      report_prep <- dplyr::bind_rows(.report, report_prep)
    } else{
      report_prep <- report_prep
    }

    attr(report_prep, "analysis_grid") <- data_chr
    report_prep  |>
      dplyr::mutate(sec_id = 1:n()) |>
      dplyr::relocate(sec_id)
  }

add_sections <-
  function(
    .report,
    code,
    .fn,
    .by,
    .title,
    .layout,
    .description,
    .widths = c(50, 50),
    .print_specs = TRUE,
    .spec_style = "callout",
    .v_pad = "1.5cm"
  ) {

    code <- dplyr::enexprs(code)
    code_chr <- as.character(code)

    fn <- dplyr::enexprs(.fn)
    fn_chr <- as.character(fn)

    data_chr <- dplyr::enexpr(.report) |> as.character()
    data_attr <- attr(.report, "analysis_grid")

    if (!is.null(data_attr)) {
      data_chr <- attr(.report, "analysis_grid")
    }

    analysis_grid <-
      rlang::parse_expr(data_chr) |>
      rlang::eval_tidy(env = parent.frame())

    report_code <-
      glue::glue("{data_chr} |> {code_chr}")

    report_data <-
      rlang::parse_expr(report_code) |>
      rlang::eval_tidy()

    nested_data <-
      report_data |>
      tidyr::nest(.by = {{.by}})  |>
      tidyr::nest(keys = -data)

    report_prep <-
      nested_data |>
      dplyr::mutate(
        sec_title = purrr::map_chr(keys,\(x) glue::glue_data(x, .title)),
        sec_layout = .layout,
        sec_descr = purrr::map_chr(keys,\(x) glue::glue_data(x, .description)),
        sec_filter =
          map_chr(keys, function(x){
            filter_exprs <-
              map2_chr(x, names(x), function(y, z){
                glue::glue("{z} == '{y}'")
              }) |>
              paste(collapse = ", ")
            glue::glue("filter({filter_exprs})")
          }),
        sec_code = glue::glue("{report_code} |> {sec_filter} |> {fn_chr}"),
        sec_content = map(sec_code, \(x) rlang::parse_expr(x) |> rlang::eval_tidy()),
        sec_widths = list(.widths),
        sec_print_specs = .print_specs,
        sec_specs = purrr::map_chr(keys, function(k) {
          k |>
            tidyr::unnest(dplyr::everything()) |>
            purrr::imap_chr(\(val, name) glue::glue("- **{name}**: {val}")) |>
            paste(collapse = "\n")
        }),
        sec_spec_style = .spec_style,
        sec_v_pad = .v_pad
      ) |>
      select(-sec_filter) |>
      select(
        starts_with("sec"),
        keys,
        data
      )

    if (!is.null(data_attr)) {
      report_prep <-
        dplyr::bind_rows(.report, report_prep)
    }

    attr(report_prep, "analysis_grid") <- data_chr
    report_prep |>
      dplyr::mutate(sec_id = 1:n()) |>
      dplyr::relocate(sec_id)
  }

show_section <- function(.report, sec_index, .what = "all", for_render = FALSE) {
  section <-
    .report |>
    dplyr::filter(sec_id == sec_index)

  section <-
    section |>
    dplyr::mutate(
      sec_descr = dplyr::if_else(
        sec_print_specs,
        paste0(sec_descr, "\n\n", format_specs(sec_specs, sec_spec_style)),
        sec_descr
      )
    )

  layout_template <-
    get_layout_template(
      section$sec_layout,
      section$sec_widths[[1]],
      section$sec_v_pad
    )

  slide_body <- glue::glue_data(section, layout_template)

  if(for_render){
    return(slide_body)
  }

  if (.what == "code") {
    cat(section$sec_code)
    return(invisible(section))
  }

  if (.what == "qmd") {
    cat(slide_body)
    return(invisible(section))
  }

  if (.what == "content") {
    print(section$sec_content[[1]])
    return(invisible(section))
  }

  # .what == "all"
  cat(
    glue::glue(
      "--- Section {sec_index} ---\n",
      "Title:       {section$sec_title}\n",
      "Layout:      {section$sec_layout}\n",
      "Description: {section$sec_descr}\n\n",
      "Code:\n",
      "{str_replace_all(section$sec_code, '(\\\\|\\\\> )', '|> \n  ')}",
      .trim = FALSE
    )
  )

  invisible(section)
}

# render_section <- function(.report, sec_index, .format = "html") {
#
#   knitr_dev <- ifelse(.format == "pdf", "pdf", "ragg_png")
#
#   section <-
#     .report |>
#     dplyr::filter(sec_id == sec_index)
#
#   tmp_dir <- tempdir()
#   tmp_rds <- file.path(tmp_dir, glue::glue("section_{sec_index}.rds"))
#   tmp_qmd <- file.path(tmp_dir, glue::glue("section_{sec_index}.qmd"))
#
#   readr::write_rds(section, tmp_rds)
#
#   qmd_body <- show_section(.report, sec_index, .what = "qmd", for_render = TRUE)
#
#   knitr_dev <- ifelse(
#     requireNamespace("ragg", quietly = TRUE),
#     "ragg_png",
#     "png"
#   )
#
#   qmd_full <- glue::glue(
#     '---\n',
#     'format: {.format}\n',
#     'knitr:\n',
#     '  opts_chunk:\n',
#     '    dev: {knitr_dev}\n',
#     '---\n\n',
#     '```{{r}}\n',
#     '#| include: false\n',
#     '.section <- readr::read_rds("{tmp_rds}")\n',
#     '```\n\n',
#     '{qmd_body}',
#     .trim = FALSE
#   )
#
#   writeLines(qmd_full, tmp_qmd)
#   quarto::quarto_render(tmp_qmd, quiet = FALSE)
#
#   output_ext <- dplyr::case_when(
#     .format == "html" ~ ".html",
#     .format == "typst" ~ ".pdf",
#     .format == "pdf" ~ ".pdf",
#     TRUE ~ ".html"
#   )
#
#   output_file <- stringr::str_replace(tmp_qmd, "\\.qmd$", output_ext)
#   rstudioapi::viewer(output_file)
#
#   invisible(section)
# }
render_section <- function(.report, sec_index, .format = "typst") {
  section <-
    .report |>
    dplyr::filter(sec_id == sec_index)

  tmp_dir <- tempdir()
  tmp_rds <- file.path(tmp_dir, glue::glue("section_{sec_index}.rds"))
  tmp_qmd <- file.path(tmp_dir, glue::glue("section_{sec_index}.qmd"))

  readr::write_rds(section, tmp_rds)

  knitr_dev <- ifelse(
    requireNamespace("ragg", quietly = TRUE),
    "ragg_png",
    "png"
  )

  section <-
    section |>
    dplyr::mutate(
      sec_descr = dplyr::if_else(
        sec_print_specs,
        paste0(sec_descr, "\n\n", format_specs(sec_specs, sec_spec_style)),
        sec_descr
      )
    )

  layout_template <- get_layout_template(
    section$sec_layout,
    section$sec_widths[[1]],
    section$sec_v_pad
  )

  slide_body <- glue::glue_data(section, layout_template)

  qmd_full <- glue::glue(
    '---\n',
    'format:\n',
    '  typst:\n',
    '    papersize: presentation-16-9\n',
    '    fontsize: 14pt\n',
    '    margin:\n',
    '      x: 0.75in\n',
    '      y: 0.5in\n',
    'fig-format: retina\n',
    # 'knitr:\n',
    # '  opts_chunk:\n',
    # '    dev: jpg\n',
    '---\n\n',
    '```{{r}}\n',
    '#| include: false\n',
    '.section <- readr::read_rds("{tmp_rds}")\n',
    '```\n\n',
    '{slide_body}',
    .trim = FALSE
  )

  writeLines(qmd_full, tmp_qmd)
  quarto::quarto_render(tmp_qmd, quiet = FALSE)

  output_file <- stringr::str_replace(tmp_qmd, "\\.qmd$", ".pdf")
  utils::browseURL(output_file)

  invisible(section)
}
