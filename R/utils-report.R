format_specs <- function(sec_specs, .style = "block") {
  if (.style == "block") {
    typst_specs <- sec_specs |>
      stringr::str_replace_all("- \\*\\*(.+?)\\*\\*: ", "  *\\1*: ") |>
      stringr::str_replace_all("\n", " \\\\\n")

    glue::glue(
      '```{{=typst}}\n',
      '#block(fill: luma(235), inset: 8pt, radius: 4pt)[\n',
      '  *Specifications* \\\\\n',
      '  {typst_specs}\n',
      ']\n',
      '```'
    )
  } else if (.style == "callout") {
    glue::glue(
      '::: {{.callout-note appearance="minimal"}}\n',
      '## Specifications\n',
      '{sec_specs}\n',
      ':::'
    )
  } else if (.style == "bullet") {
    sec_specs
  } else if (.style == "inline") {
    sec_specs |>
      stringr::str_remove_all("- ") |>
      stringr::str_replace_all("\n", " | ")
  }
}

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
get_layout_template <- function(.layout, .widths = c(50, 50), .v_pad = NULL) {

  full_fig_w <- 9
  full_fig_h <- 4
  text_fig_h <- 3
  col_fig_w <- round(full_fig_w * (.widths[2] / 100), 1)
  col_fig_h <- 3.8

  layout_str <- paste0("[[", .widths[1], ", ", .widths[2], "]]")
  layout_str_flipped <- paste0("[[", .widths[2], ", ", .widths[1], "]]")

  v_pad_str <- if (!is.null(.v_pad)) {
    paste0('```{{=typst}}\n#v(', .v_pad, ')\n```\n\n')
  } else {
    ""
  }

  templates <- list(

    full = paste0(
      '# {sec_title}\n\n',
      '```{{r}}\n',
      '#| echo: false\n',
      '#| fig-width: ', full_fig_w, '\n',
      '#| fig-height: ', full_fig_h, '\n',
      '.section$sec_content[[1]]\n',
      '```\n\n',
      '\\pagebreak'
    ),

    text_figure = paste0(
      '# {sec_title}\n\n',
      '{sec_descr}\n\n',
      '```{{r}}\n',
      '#| echo: false\n',
      '#| fig-width: ', full_fig_w, '\n',
      '#| fig-height: ', text_fig_h, '\n',
      '.section$sec_content[[1]]\n',
      '```\n\n',
      '\\pagebreak'
    ),

    figure_text = paste0(
      '# {sec_title}\n\n',
      '```{{r}}\n',
      '#| echo: false\n',
      '#| fig-width: ', full_fig_w, '\n',
      '#| fig-height: ', text_fig_h, '\n',
      '.section$sec_content[[1]]\n',
      '```\n\n',
      '{sec_descr}\n\n',
      '\\pagebreak'
    ),

    text_left = paste0(
      '# {sec_title}\n\n',
      ':::: {{layout="', layout_str, '"}}\n\n',
      '::: {{}}\n',
      v_pad_str,
      '{sec_descr}\n',
      ':::\n\n',
      '```{{r}}\n',
      '#| echo: false\n',
      '#| fig-width: ', col_fig_w, '\n',
      '#| fig-height: ', col_fig_h, '\n',
      '.section$sec_content[[1]]\n',
      '```\n\n',
      '::::\n\n',
      '\\pagebreak'
    ),

    text_right = paste0(
      '# {sec_title}\n\n',
      ':::: {{layout="', layout_str_flipped, '"}}\n\n',
      '```{{r}}\n',
      '#| echo: false\n',
      '#| fig-width: ', col_fig_w, '\n',
      '#| fig-height: ', col_fig_h, '\n',
      '.section$sec_content[[1]]\n',
      '```\n\n',
      '::: {{}}\n',
      v_pad_str,
      '{sec_descr}\n',
      ':::\n\n',
      '::::\n\n',
      '\\pagebreak'
    )
  )

  if (!.layout %in% names(templates)) {
    rlang::abort(
      c(
        glue::glue("Layout '{.layout}' not recognized."),
        i = "Available layouts: full, text_figure, figure_text, text_left, text_right"
      )
    )
  }

  templates[[.layout]]
}
