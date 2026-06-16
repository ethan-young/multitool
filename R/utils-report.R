#' Compose one partition's content into a single patchwork object
#'
#' Realizes a section row's text, table, and figure slots, composes them by the
#' supplied patchwork syntax (and optional inner design), and returns the
#' wrapped composition plus its title and description text.
#'
#' @noRd
compose_partition <-
  function(
    row,
    .syntax = NULL,
    .design = NULL,
    .txt_size = 6
  ){

    raw_txt <- row |> dplyr::pull(sec_txt) |> purrr::pluck(1) |> realize_slot("txt", txt_size = .txt_size)
    raw_tbl <- row |> dplyr::pull(sec_tbl) |> purrr::pluck(1) |> realize_slot("tbl")
    raw_fig <- row |> dplyr::pull(sec_fig) |> purrr::pluck(1) |> realize_slot("fig")

    referenced <-
      .syntax |>
      stringr::str_extract_all("sec_txt|sec_tbl|sec_fig") |>
      unlist() |>
      unique()

    slots_raw <- list(sec_txt = raw_txt, sec_tbl = raw_tbl, sec_fig = raw_fig)
    purrr::walk(referenced, function(x) {
      if (is.null(slots_raw[[x]])) {
        message(glue::glue(
          "{x} is empty but is referenced in your patchwork syntax. ",
          "Rendering an empty spacer in its place."
        ))
      }
    })

    mask <-
      list(
        sec_txt = if (is.null(raw_txt)) patchwork::plot_spacer() else raw_txt,
        sec_tbl = if (is.null(raw_tbl)) patchwork::plot_spacer() else raw_tbl,
        sec_fig = if (is.null(raw_fig)) patchwork::plot_spacer() else raw_fig
      )

    if (!is.null(.design) && stringr::str_detect(.syntax, "\\/|\\|", negate = TRUE)) {
      composed_expr <-
        glue::glue("{.syntax} + patchwork::plot_layout(design = '{.design}')") |>
        rlang::parse_expr()
    } else {
      composed_expr <- rlang::parse_expr(.syntax)
    }

    composed <- rlang::eval_tidy(composed_expr, data = mask)

    p_title <- row |> dplyr::pull(sec_title)
    p_desc  <- row |> dplyr::pull(sec_description)

    list(
      inner_fig = patchwork::wrap_elements(composed),
      title = p_title,
      desc = p_desc
    )
  }

#' Place a composed inner figure onto a slide/page canvas
#'
#' Applies the outer layout design, margin, optional dev frame, and optional
#' title/subtitle annotation to an inner composition, returning the placed
#' patchwork object.
#'
#' @noRd
place_on_canvas <-
  function(
    inner_fig,
    .margin,
    .design = "A",
    .title = NULL,
    .subtitle = NULL,
    .frame = FALSE,
    .sizes = c(24, 16)
  ) {

    placed <-
      inner_fig +
      patchwork::plot_layout(design = .design)

    theme_args <-
      list(
        plot.margin =
          if (is.null(.margin)) ggplot2::margin(0, 0, 0, 0) else .margin
      )

    if (.frame) {
      theme_args$plot.background <-
        ggplot2::element_rect(color = "black", fill = NA)

      placed <-
        placed +
        ggplot2::theme(
          plot.background = ggplot2::element_rect(color = "black", fill = NA)
        )
    }

    p_title <-
      if (!is.null(.title) && nzchar(.title)){
        .title
      } else NULL

    p_desc  <-
      if (!is.null(.subtitle) && nzchar(.subtitle)){
        .subtitle
      } else NULL

    theme_args$plot.title <-
      ggplot2::element_text(size = .sizes[1])

    theme_args$plot.subtitle <-
      ggplot2::element_text(size = .sizes[2])

    placed +
      patchwork::plot_annotation(
        title    = p_title,
        subtitle = p_desc,
        theme    = do.call(ggplot2::theme, theme_args)
      )
  }

#' Resolve one margin side to inches
#'
#' Converts a single side of a margin() unit object to a numeric value in inches.
#'
#' @noRd
resolve_margin_side <- function(m, i, to_units) {
  as.numeric(
    grid::convertUnit(m[i], unitTo = to_units, valueOnly = TRUE)
  )
}

#' Resolve a margin object to inches on all four sides
#'
#' Returns a named list (t, r, b, l) of margin sizes in inches, or zeros when
#' the margin is NULL.
#'
#' @noRd
compute_margins <- function(margin){
  if (is.null(margin)) {
    list(t = 0, r = 0, b = 0, l = 0)
  } else {
    list(
      t = resolve_margin_side(margin, 1, "in"),
      r = resolve_margin_side(margin, 2, "in"),
      b = resolve_margin_side(margin, 3, "in"),
      l = resolve_margin_side(margin, 4, "in")
    )
  }
}

#' Estimate the figure's width and height ratios from a layout design
#'
#' Parses a patchwork design string into the fraction of canvas width and height
#' occupied by the content region.
#'
#' @noRd
parse_design <- function(design){
  design |>
    stringr::str_split("\n", simplify = TRUE) |>
    as.data.frame() |>
    tidyr::pivot_longer(dplyr::everything()) |>
    dplyr::mutate(
      w_denom = nchar(value),
      w_numer = stringr::str_remove_all(value, "#") |> nchar(),
      h_denom = dplyr::n(),
      h_numer = sum(ifelse(stringr::str_detect(value, "A"), 1, 0))
    ) |>
    dplyr::summarize(
      width_ratio = max(w_numer)/max(w_denom),
      height_ratio = max(h_numer)/max(h_denom)
    )
}

#' Realize one content slot into a patchwork-placeable object
#'
#' Turns a raw slot value into a placeable object: text into a ggtext panel,
#' tables (data.frame, gt, flextable, or grob) into a wrapped table, figures
#' passed through; empty slots return NULL.
#'
#' @noRd
realize_slot <-
  function(value, kind = c("txt", "tbl", "fig"), txt_size = 6) {
    kind <- match.arg(kind)

    is_empty <-
      is.null(value) ||
      (is.atomic(value) && length(value) == 0) ||
      (is.character(value) && (all(is.na(value)) || !any(nzchar(value))))

    if (is_empty) {
      return(NULL)
    }

    if (kind == "txt") {
      label <- paste(value, collapse = " ")
      return(
        ggplot2::ggplot() +
          ggtext::geom_textbox(
            ggplot2::aes(x = 0, y = 0, label = label),
            size = txt_size,
            minwidth = grid::unit(1, "npc"),
            minheight =  grid::unit(1, "npc"),
            valign = .5,
            box.color = NA
          ) +
          ggplot2::scale_x_continuous(expand = c(0, 0)) +
          ggplot2::scale_y_continuous(expand = c(0, 0)) +
          ggplot2::theme_void() +
          ggplot2::theme(
            plot.title =
              ggtext::element_textbox_simple(
                size = 13,
                lineheight = 1,
                vjust = .5,
                hjust = .5,
                padding = ggplot2::margin(5.5, 5.5, 5.5, 5.5),
                margin = ggplot2::margin(0, 0, 0, 0)
              ),
            plot.margin = ggplot2::margin(.25,.25,.25,.25, "in")
          )
      )
    }

    if (kind == "tbl") {
      if (inherits(value, c("grob", "gTree"))) {
        return(patchwork::wrap_elements(full = value))
      }
      if (inherits(value, "flextable")) {
        message(
          "flextable rendered via gen_grob(); ",
          "any flextable caption is dropped in grob output."
        )
        return(patchwork::wrap_elements(full = flextable::gen_grob(value)))
      }
      return(patchwork::wrap_table(value, panel = "full", space = "free"))
    }
    value
  }

#' Render an object to a temp PNG at true size and open it
#'
#' Writes a figure to a temporary PNG at the given canvas dimensions and dpi via
#' ragg, then opens it for inspection.
#'
#' @noRd
temp_fig <- function(.p, canvas, dpi){

  out_path <- tempfile(fileext = ".png")
  ragg::agg_png(
    filename = out_path,
    width    = canvas$w,
    height   = canvas$h,
    units    = "in",
    res      = dpi
  )
  print(.p)
  grDevices::dev.off()
  utils::browseURL(out_path)

}

#' Render a laid-out document with the patchwork backend
#'
#' Composes every section's subsections into placed pages and writes them as a
#' single multi-page PDF (single mode) or one file per page (pile mode).
#'
#' @noRd
render_patchwork <-
  function(resolved, settings, output, file, dir) {

    if(is.null(file)){
      stop("generate_docs() requires a `file`.", call. = FALSE)
    }

    stem <- tools::file_path_sans_ext(basename(file))
    ext <- tools::file_ext(basename(file))

    pages <-
      resolved |>
      dplyr::mutate(
        section_pages =
          purrr::pmap(
            list(
              content      = content,
              syntax       = patchwork_syntax,
              inner_design = inner_layout,
              outer_design = outer_layout,
              incl_title   = section_incl_title,
              incl_desc    = section_incl_desc,
              margin       = eff_margin,
              meta_sizes   = eff_meta_sizes,
              txt_size    = eff_txt_size
            ),
            \(content, syntax, inner_design, outer_design,
              incl_title, incl_desc, margin, meta_sizes, txt_size) {
              content |>
                dplyr::arrange(sec_sub_id) |>
                dplyr::group_split(sec_sub_id) |>
                purrr::map(\(sub_row) {
                  part <-
                    compose_partition(
                      row     = sub_row,
                      .syntax = syntax,
                      .design = if (is.na(inner_design)) NULL else inner_design,
                      .txt_size = txt_size
                    )
                  place_on_canvas(
                    inner_fig = part$inner_fig,
                    .margin   = margin,
                    .design   = outer_design,
                    .title    = if (incl_title) part$title    else NULL,
                    .subtitle = if (incl_desc)  part$desc else NULL,
                    .frame    = FALSE,
                    .sizes    = meta_sizes
                  )
                })
            }
          )
      )

    all_pages <-
      pages |>
      dplyr::pull(section_pages) |>
      purrr::list_flatten()

    if(length(all_pages) == 0){
      stop(
        "Nothing to render: the document has no laid-out sections.",
        call. = FALSE
      )
    }

    if (output == "single") {
      grDevices::pdf(
        file    = glue::glue("{stem}.pdf"),
        width   = settings$canvas_width,
        height  = settings$canvas_height,
        onefile = TRUE
      )
      on.exit(grDevices::dev.off(), add = TRUE)

      purrr::walk(all_pages, print)
      invisible(file)

    } else {
      if (is.null(dir)) {
        dir <- "."
      } else if (!dir.exists(dir)) {
        dir.create(dir, recursive = TRUE)
      }

      paths <-
        purrr::imap_chr(all_pages, \(pg, i) {
          out <- file.path(dir, glue::glue("{stem}-page-{i}.{ext}"))
          ggplot2::ggsave(
            plot     = pg,
            filename = out,
            width    = settings$canvas_width,
            height   = settings$canvas_height,
            units    = "in",
            dpi      = settings$dpi
          )
          out
        })

      invisible(paths)
    }
  }
