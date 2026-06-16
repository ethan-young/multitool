# add_section <-
#   function(
#     .report,
#     code,
#     .title,
#     .layout,
#     .description,
#     .widths = c(50, 50),
#     .v_pad = "1.5cm"
#   ){
#     code <- dplyr::enexprs(code)
#     code_chr <-
#       as.character(code) |>
#       stringr::str_remove_all("\n|    ")
#
#     data_chr <- dplyr::enexpr(.report) |> as.character()
#     data_attr <- attr(.report, "analysis_grid")
#
#     if(!is.null(data_attr)){
#       data_chr <- attr(.report, "analysis_grid")
#     }
#
#     analysis_grid <-
#       rlang::parse_expr(data_chr) |>
#       rlang::eval_tidy(env = parent.frame())
#
#     report_code <-
#       glue::glue("{data_chr} |> {code_chr}")
#
#     report_data <-
#       rlang::parse_expr(report_code) |>
#       rlang::eval_tidy()
#
#     report_prep <-
#       tibble::tibble(
#         sec_title = .title,
#         sec_layout = .layout,
#         sec_descr = .description,
#         sec_code = report_code,
#         sec_content = list(report_data),
#         sec_widths = list(.widths),
#         sec_v_pad = .v_pad
#       )
#
#     if(!is.null(data_attr)){
#       report_prep <- dplyr::bind_rows(.report, report_prep)
#     } else{
#       report_prep <- report_prep
#     }
#
#     attr(report_prep, "analysis_grid") <- data_chr
#     report_prep  |>
#       dplyr::mutate(sec_id = 1:n()) |>
#       dplyr::relocate(sec_id)
#   }
#
# add_sections <-
#   function(
#     .report,
#     code,
#     .fn,
#     .by,
#     .title,
#     .layout,
#     .description,
#     .widths = c(50, 50),
#     .print_specs = TRUE,
#     .spec_style = "callout",
#     .v_pad = "1.5cm"
#   ) {
#
#     code <- dplyr::enexprs(code)
#     code_chr <- as.character(code)
#
#     print(code_chr)
#
#     fn <- dplyr::enexprs(.fn)
#     fn_chr <- as.character(fn)
#
#     data_chr <- dplyr::enexpr(.report) |> as.character()
#     data_attr <- attr(.report, "analysis_grid")
#
#     if (!is.null(data_attr)) {
#       data_chr <- attr(.report, "analysis_grid")
#     }
#
#     analysis_grid <-
#       rlang::parse_expr(data_chr) |>
#       rlang::eval_tidy(env = parent.frame())
#
#     report_code <-
#       glue::glue("{data_chr} |> {code_chr}")
#
#     report_data <-
#       rlang::parse_expr(report_code) |>
#       rlang::eval_tidy()
#
#     nested_data <-
#       report_data |>
#       tidyr::nest(.by = {{.by}})  |>
#       tidyr::nest(keys = -data)
#
#     report_prep <-
#       nested_data |>
#       dplyr::mutate(
#         sec_title = purrr::map_chr(keys,\(x) glue::glue_data(x, .title)),
#         sec_layout = .layout,
#         sec_descr = purrr::map_chr(keys,\(x) glue::glue_data(x, .description)),
#         sec_filter =
#           map_chr(keys, function(x){
#             filter_exprs <-
#               map2_chr(x, names(x), function(y, z){
#                 glue::glue("{z} == '{y}'")
#               }) |>
#               paste(collapse = ", ")
#             glue::glue("filter({filter_exprs})")
#           }),
#         sec_code = glue::glue("{report_code} |> {sec_filter} |> {fn_chr}"),
#         sec_content = map(sec_code, \(x) rlang::parse_expr(x) |> rlang::eval_tidy()),
#         sec_widths = list(.widths),
#         sec_print_specs = .print_specs,
#         sec_specs = purrr::map_chr(keys, function(k) {
#           k |>
#             tidyr::unnest(dplyr::everything()) |>
#             purrr::imap_chr(\(val, name) glue::glue("- **{name}**: {val}")) |>
#             paste(collapse = "\n")
#         }),
#         sec_spec_style = .spec_style,
#         sec_v_pad = .v_pad
#       ) |>
#       select(-sec_filter) |>
#       select(
#         starts_with("sec"),
#         keys,
#         data
#       )
#
#     if (!is.null(data_attr)) {
#       report_prep <-
#         dplyr::bind_rows(.report, report_prep)
#     }
#
#     attr(report_prep, "analysis_grid") <- data_chr
#     report_prep |>
#       dplyr::mutate(sec_id = 1:n()) |>
#       dplyr::relocate(sec_id)
#   }
#
# # render_section <- function(.report, sec_index, .format = "html") {
# #
# #   knitr_dev <- ifelse(.format == "pdf", "pdf", "ragg_png")
# #
# #   section <-
# #     .report |>
# #     dplyr::filter(sec_id == sec_index)
# #
# #   tmp_dir <- tempdir()
# #   tmp_rds <- file.path(tmp_dir, glue::glue("section_{sec_index}.rds"))
# #   tmp_qmd <- file.path(tmp_dir, glue::glue("section_{sec_index}.qmd"))
# #
# #   readr::write_rds(section, tmp_rds)
# #
# #   qmd_body <- show_section(.report, sec_index, .what = "qmd", for_render = TRUE)
# #
# #   knitr_dev <- ifelse(
# #     requireNamespace("ragg", quietly = TRUE),
# #     "ragg_png",
# #     "png"
# #   )
# #
# #   qmd_full <- glue::glue(
# #     '---\n',
# #     'format: {.format}\n',
# #     'knitr:\n',
# #     '  opts_chunk:\n',
# #     '    dev: {knitr_dev}\n',
# #     '---\n\n',
# #     '```{{r}}\n',
# #     '#| include: false\n',
# #     '.section <- readr::read_rds("{tmp_rds}")\n',
# #     '```\n\n',
# #     '{qmd_body}',
# #     .trim = FALSE
# #   )
# #
# #   writeLines(qmd_full, tmp_qmd)
# #   quarto::quarto_render(tmp_qmd, quiet = FALSE)
# #
# #   output_ext <- dplyr::case_when(
# #     .format == "html" ~ ".html",
# #     .format == "typst" ~ ".pdf",
# #     .format == "pdf" ~ ".pdf",
# #     TRUE ~ ".html"
# #   )
# #
# #   output_file <- stringr::str_replace(tmp_qmd, "\\.qmd$", output_ext)
# #   rstudioapi::viewer(output_file)
# #
# #   invisible(section)
# # }
# render_section <- function(.report, sec_index, .format = "typst") {
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
#   knitr_dev <- ifelse(
#     requireNamespace("ragg", quietly = TRUE),
#     "ragg_png",
#     "png"
#   )
#
#   section <-
#     section |>
#     dplyr::mutate(
#       sec_descr = dplyr::if_else(
#         sec_print_specs,
#         paste0(sec_descr, "\n\n", format_specs(sec_specs, sec_spec_style)),
#         sec_descr
#       )
#     )
#
#   layout_template <- get_layout_template(
#     section$sec_layout,
#     section$sec_widths[[1]],
#     section$sec_v_pad
#   )
#
#   slide_body <- glue::glue_data(section, layout_template)
#
#   qmd_full <- glue::glue(
#     '---\n',
#     'format:\n',
#     '  typst:\n',
#     '    papersize: presentation-16-9\n',
#     '    fontsize: 14pt\n',
#     '    margin:\n',
#     '      x: 0.75in\n',
#     '      y: 0.5in\n',
#     'fig-format: retina\n',
#     # 'knitr:\n',
#     # '  opts_chunk:\n',
#     # '    dev: jpg\n',
#     '---\n\n',
#     '```{{r}}\n',
#     '#| include: false\n',
#     '.section <- readr::read_rds("{tmp_rds}")\n',
#     '```\n\n',
#     '{slide_body}',
#     .trim = FALSE
#   )
#
#   writeLines(qmd_full, tmp_qmd)
#   quarto::quarto_render(tmp_qmd, quiet = FALSE)
#
#   output_file <- stringr::str_replace(tmp_qmd, "\\.qmd$", ".pdf")
#   utils::browseURL(output_file)
#
#   invisible(section)
# }
#
#
# show_section <- function(.report, sec_index, .what = "all", for_render = FALSE) {
#   section <-
#     .report |>
#     dplyr::filter(sec_id == sec_index)
#
#   section <-
#     section |>
#     dplyr::mutate(
#       sec_descr = dplyr::if_else(
#         sec_print_specs,
#         paste0(sec_descr, "\n\n", format_specs(sec_specs, sec_spec_style)),
#         sec_descr
#       )
#     )
#
#   layout_template <-
#     get_layout_template(
#       section$sec_layout,
#       section$sec_widths[[1]],
#       section$sec_v_pad
#     )
#
#   slide_body <- glue::glue_data(section, layout_template)
#
#   if(for_render){
#     return(slide_body)
#   }
#
#   if (.what == "code") {
#     cat(section$sec_code)
#     return(invisible(section))
#   }
#
#   if (.what == "qmd") {
#     cat(slide_body)
#     return(invisible(section))
#   }
#
#   if (.what == "content") {
#     print(section$sec_content[[1]])
#     return(invisible(section))
#   }
#
#   # .what == "all"
#   cat(
#     glue::glue(
#       "--- Section {sec_index} ---\n",
#       "Title:       {section$sec_title}\n",
#       "Layout:      {section$sec_layout}\n",
#       "Description: {section$sec_descr}\n\n",
#       "Code:\n",
#       "{str_replace_all(section$sec_code, '(\\\\|\\\\> )', '|> \n  ')}",
#       .trim = FALSE
#     )
#   )
#
#   invisible(section)
# }

# preview_content <-
#   function(
#     .fig,
#     asp_ratio = "wide",
#     units = "in",
#     dpi = 96,
#     mode = "figure",
#     margin = NULL,
#     design = NULL,
#     width = NULL,
#     height = NULL
#   ){
#
#     anchor_height_in <- 7.5
#     in_to_units <- switch(units, `in` = 1, cm = 2.54, mm = 25.4)
#
#     canvas <-
#       if (asp_ratio == "custom") {
#         if (is.null(width) || is.null(height)) {
#           stop(
#             "asp_ratio = 'custom' requires both width and height (in `units`).",
#             call. = FALSE
#           )
#         }
#         list(w = width, h = height)
#       } else {
#         h <- anchor_height_in * in_to_units
#         aspect <- if (asp_ratio == "wide") 16 / 9 else 4 / 3
#         list(w = h * aspect, h = h)
#       }
#
#     if(mode == "figure"){
#       out_path <- tempfile(fileext = ".png")
#       ragg::agg_png(
#         filename = out_path,
#         width    = canvas$w,
#         height   = canvas$h,
#         units    = units,
#         res      = dpi
#       )
#       print(.fig)
#       grDevices::dev.off()
#       #if (rstudioapi::isAvailable()) rstudioapi::viewer(out_path)
#       utils::browseURL(out_path)
#
#       dim_print <-
#         glue::glue(
#           "mode: {mode}",
#           "dpi: {dpi}",
#           "canvas: {round(canvas$w, 2)}{units} by {round(canvas$h,2)}{units}",
#           .sep = "\n"
#         )
#
#       message(dim_print)
#
#       invisible(
#         list(
#           canvas = c(canvas$w, canvas$h),
#           dpi = dpi,
#           unit = units,
#           figure = .fig
#         )
#       )
#
#     } else if(mode == "slide"){
#       if(is.null(design)){
#         design <- "A"
#       }
#
#       fig_content <-
#         .fig +
#         ggplot2::theme(
#           plot.background = ggplot2::element_rect(color = "black")
#         ) +
#         patchwork::plot_layout(design = design)
#
#       if(!is.null(margin)){
#         fig_content <-
#           fig_content +
#           patchwork::plot_annotation(
#             theme =
#               ggplot2::theme(
#                 plot.margin = margin,
#                 plot.background = ggplot2::element_rect(color = "black")
#               )
#           )
#       }
#
#       out_path <- tempfile(fileext = ".png")
#       ragg::agg_png(
#         filename = out_path,
#         width    = canvas$w,
#         height   = canvas$h,
#         units    = units,
#         res      = dpi
#       )
#       print(fig_content)
#       grDevices::dev.off()
#       #if (rstudioapi::isAvailable()) rstudioapi::viewer(out_path)
#       utils::browseURL(out_path)
#
#       fig_w <-
#         (canvas$w - margins$r - margins$l) * parse_design$width_ratio
#
#       fig_h <-
#         (canvas$h - margins$t - margins$b) * parse_design$height_ratio
#
#       dim_print <-
#         glue::glue(
#           "mode: {mode}",
#           "slide aspect ratio: {asp_ratio}",
#           "dpi: {dpi}",
#           "canvas: {round(canvas$w, 2)}{units} by {round(canvas$h,2)}{units}",
#           "canvas design:\n{design}",
#           "implied figure dims: {round(fig_w, 2)}{units} by {round(fig_h, 2)}{units}",
#           "test using figure mode:\n",
#           .sep = "\n",
#           .trim = FALSE
#         )
#
#       test_code <-
#         styler::style_text(
#           glue::glue(
#             "preview_content(",
#             ".fig, mode = 'figure', ",
#             "units = '{units}', ",
#             "width = {round(fig_w, 2)}, ",
#             "height = {round(fig_h, 2)}",
#             ")",
#           )
#         )
#       message(dim_print, test_code, appendLF = TRUE)
#
#       invisible(
#         list(
#           canvas = c(canvas$w, canvas$h),
#           fig = c(fig_w, fig_h),
#           dpi = dpi,
#           unit = units,
#           figure = fig_content
#         )
#       )
#     }
#
#   }



# format_specs <- function(sec_specs, .style = "block") {
#   if (.style == "block") {
#     typst_specs <- sec_specs |>
#       stringr::str_replace_all("- \\*\\*(.+?)\\*\\*: ", "  *\\1*: ") |>
#       stringr::str_replace_all("\n", " \\\\\n")
#
#     glue::glue(
#       '```{{=typst}}\n',
#       '#block(fill: luma(235), inset: 8pt, radius: 4pt)[\n',
#       '  *Specifications* \\\\\n',
#       '  {typst_specs}\n',
#       ']\n',
#       '```'
#     )
#   } else if (.style == "callout") {
#     glue::glue(
#       '::: {{.callout-note appearance="minimal"}}\n',
#       '## Specifications\n',
#       '{sec_specs}\n',
#       ':::'
#     )
#   } else if (.style == "bullet") {
#     sec_specs
#   } else if (.style == "inline") {
#     sec_specs |>
#       stringr::str_remove_all("- ") |>
#       stringr::str_replace_all("\n", " | ")
#   }
# }

# get_layout_template <- function(.layout, .widths = c(50, 50)) {
#
#   fig_width <- round(12 * (.widths[2] / 100), 1)
#   text_width <- .widths[1]
#   fig_col_width <- .widths[2]
#
#   templates <- list(
#
#     full = paste0(
#       '## {sec_title}\n\n',
#       '```{{r}}\n',
#       '#| echo: false\n',
#       '#| fig-width: 12\n',
#       '#| fig-height: 6.5\n',
#       '.section$sec_content[[1]]\n',
#       '```'
#     ),
#
#     text_figure = paste0(
#       '## {sec_title}\n\n',
#       '{sec_descr}\n\n',
#       '```{{r}}\n',
#       '#| echo: false\n',
#       '#| fig-width: 12\n',
#       '#| fig-height: 5\n',
#       '.section$sec_content[[1]]\n',
#       '```'
#     ),
#
#     figure_text = paste0(
#       '## {sec_title}\n\n',
#       '```{{r}}\n',
#       '#| echo: false\n',
#       '#| fig-width: 12\n',
#       '#| fig-height: 5\n',
#       '.section$sec_content[[1]]\n',
#       '```\n\n',
#       '{sec_descr}'
#     ),
#
#     text_left = paste0(
#       '## {sec_title}\n\n',
#       ':::: {{.columns}}\n\n',
#       '::: {{.column width="', text_width, '%"}}\n',
#       '{sec_descr}\n',
#       ':::\n\n',
#       '::: {{.column width="', fig_col_width, '%"}}\n',
#       '```{{r}}\n',
#       '#| echo: false\n',
#       '#| fig-width: ', fig_width, '\n',
#       '#| fig-height: 5\n',
#       '.section$sec_content[[1]]\n',
#       '```\n',
#       ':::\n\n',
#       '::::'
#     ),
#
#     text_right = paste0(
#       '## {sec_title}\n\n',
#       ':::: {{.columns}}\n\n',
#       '::: {{.column width="', fig_col_width, '%"}}\n',
#       '```{{r}}\n',
#       '#| echo: false\n',
#       '#| fig-width: ', fig_width, '\n',
#       '#| fig-height: 5\n',
#       '.section$sec_content[[1]]\n',
#       '```\n',
#       ':::\n\n',
#       '::: {{.column width="', text_width, '%"}}\n',
#       '{sec_descr}\n',
#       ':::\n\n',
#       '::::'
#     )
#   )
#
#   if (!.layout %in% names(templates)) {
#     rlang::abort(
#       c(
#         glue::glue("Layout '{.layout}' not recognized."),
#         i = "Available layouts: full, text_figure, figure_text, text_left, text_right"
#       )
#     )
#   }
#
#   templates[[.layout]]
# }
# get_layout_template <- function(.layout, .widths = c(50, 50), .v_pad = NULL) {
#
#   full_fig_w <- 9
#   full_fig_h <- 4
#   text_fig_h <- 3
#   col_fig_w <- round(full_fig_w * (.widths[2] / 100), 1)
#   col_fig_h <- 3.8
#
#   layout_str <- paste0("[[", .widths[1], ", ", .widths[2], "]]")
#   layout_str_flipped <- paste0("[[", .widths[2], ", ", .widths[1], "]]")
#
#   v_pad_str <- if (!is.null(.v_pad)) {
#     paste0('```{{=typst}}\n#v(', .v_pad, ')\n```\n\n')
#   } else {
#     ""
#   }
#
#   templates <- list(
#
#     full = paste0(
#       '# {sec_title}\n\n',
#       '```{{r}}\n',
#       '#| echo: false\n',
#       '#| fig-width: ', full_fig_w, '\n',
#       '#| fig-height: ', full_fig_h, '\n',
#       '.section$sec_content[[1]]\n',
#       '```\n\n',
#       '\\pagebreak'
#     ),
#
#     text_figure = paste0(
#       '# {sec_title}\n\n',
#       '{sec_descr}\n\n',
#       '```{{r}}\n',
#       '#| echo: false\n',
#       '#| fig-width: ', full_fig_w, '\n',
#       '#| fig-height: ', text_fig_h, '\n',
#       '.section$sec_content[[1]]\n',
#       '```\n\n',
#       '\\pagebreak'
#     ),
#
#     figure_text = paste0(
#       '# {sec_title}\n\n',
#       '```{{r}}\n',
#       '#| echo: false\n',
#       '#| fig-width: ', full_fig_w, '\n',
#       '#| fig-height: ', text_fig_h, '\n',
#       '.section$sec_content[[1]]\n',
#       '```\n\n',
#       '{sec_descr}\n\n',
#       '\\pagebreak'
#     ),
#
#     text_left = paste0(
#       '# {sec_title}\n\n',
#       ':::: {{layout="', layout_str, '"}}\n\n',
#       '::: {{}}\n',
#       v_pad_str,
#       '{sec_descr}\n',
#       ':::\n\n',
#       '```{{r}}\n',
#       '#| echo: false\n',
#       '#| fig-width: ', col_fig_w, '\n',
#       '#| fig-height: ', col_fig_h, '\n',
#       '.section$sec_content[[1]]\n',
#       '```\n\n',
#       '::::\n\n',
#       '\\pagebreak'
#     ),
#
#     text_right = paste0(
#       '# {sec_title}\n\n',
#       ':::: {{layout="', layout_str_flipped, '"}}\n\n',
#       '```{{r}}\n',
#       '#| echo: false\n',
#       '#| fig-width: ', col_fig_w, '\n',
#       '#| fig-height: ', col_fig_h, '\n',
#       '.section$sec_content[[1]]\n',
#       '```\n\n',
#       '::: {{}}\n',
#       v_pad_str,
#       '{sec_descr}\n',
#       ':::\n\n',
#       '::::\n\n',
#       '\\pagebreak'
#     )
#   )
#
#   if (!.layout %in% names(templates)) {
#     rlang::abort(
#       c(
#         glue::glue("Layout '{.layout}' not recognized."),
#         i = "Available layouts: full, text_figure, figure_text, text_left, text_right"
#       )
#     )
#   }
#
#   templates[[.layout]]
# }
