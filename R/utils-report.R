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
    .txt_size = 6,
    .txt_family = NULL
  ){

    raw_txt <- row |> dplyr::pull(sec_txt) |> purrr::pluck(1) |> realize_slot("txt", txt_size = .txt_size, txt_family = .txt_family)
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
        sec_txt = if(is.null(raw_txt)) patchwork::plot_spacer() else raw_txt,
        sec_tbl = if(is.null(raw_tbl)) patchwork::plot_spacer() else raw_tbl,
        sec_fig = if(is.null(raw_fig)) patchwork::plot_spacer() else raw_fig
      )

    if (!is.null(.design) && stringr::str_detect(.syntax, "\\/|\\|", negate = TRUE)) {
      composed_expr <-
        glue::glue("{.syntax} + patchwork::plot_layout(design = '{.design}')") |>
        rlang::parse_expr()
    } else {
      composed_expr <-
        glue::glue("{.syntax} + patchwork::plot_layout()") |>
        rlang::parse_expr()
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
  function(value, kind = c("txt", "tbl", "fig"), txt_size = 6, txt_family = NULL) {
    kind <- match.arg(kind)

    value <- rlang::parse_expr(value) |> rlang::eval_tidy()

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
            family = txt_family,
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

#' Render contents of each section
#'
#' Composes every section's subsections to be fed to a back-end file writer.
#'
#' @noRd
generate_content <-
  function(.doc, .export = NULL){

    analysis_grid_nms <- attr(.doc, "analysis_grids")

    analysis_grids <-
      purrr::map(
        analysis_grid_nms,
        \(x) rlang::parse_expr(x) |> rlang::eval_tidy()
      )

    doc_grid <-
      .doc |>
      tidyr::unnest(content)

    referenced_syms <-
      doc_grid |>
      dplyr::select(sec_txt, sec_tbl, sec_fig) |>   # the full pipelines
      unlist() |>
      purrr::discard(\(x) x == "NULL") |>
      purrr::map(\(code) all.names(rlang::parse_expr(code))) |>
      unlist() |>
      unique()

    auto_fns <-
      referenced_syms |>
      purrr::keep(
        \(s) exists(s, envir = .GlobalEnv, inherits = FALSE) &&
          is.function(get(s, envir = .GlobalEnv))
      )

    globals_to_keep <-
      if(!is.null(.export)){
        c(auto_fns, .export)
      } else{
        auto_fns
      }

    shipped_objs <-
      .GlobalEnv |>
      as.list() |>
      purrr::keep_at(\(nm) nm %in% globals_to_keep)

    rendered_df <-
      purrr::pmap(
        doc_grid,
        purrr::in_parallel(
          \(
            report_index,
            sec_id,
            sec_sub_id,
            sec_title,
            sec_description,
            sec_txt,
            sec_tbl,
            sec_fig,
            doc_backend,
            doc_asp_ratio,
            doc_dpi,
            doc_margin,
            doc_canvas_width,
            doc_canvas_height,
            section_patchwork_syntax,
            section_inner_layout,
            section_outer_layout,
            section_incl_title,
            section_incl_desc,
            section_margin,
            section_width,
            section_height,
            section_title_size,
            section_subtitle_size,
            section_txt_size,
            section_txt_family,
            laid_out,
            ...
          ){

            for (pkg in c("multitool", "dplyr", "ggplot2")){
              library(pkg, character.only = TRUE)
            }

            purrr::walk2(
              analysis_grid_nms, analysis_grids,
              \(x, y) assign(x, y, envir = .GlobalEnv)
            )

            purrr::iwalk(
              shipped_objs,
              \(x, idx) assign(idx, x, envir = .GlobalEnv)
            )

            partition_df <-
              tibble::tibble(
                sec_txt = sec_txt,
                sec_tbl = sec_tbl,
                sec_fig = sec_fig,
                sec_title = sec_title,
                sec_description = sec_description
              )

            composition <-
              compose_partition(
                partition_df,
                .syntax = section_patchwork_syntax,
                .design = if (is.na(section_inner_layout)) NULL else section_inner_layout,
                .txt_size = section_txt_size,
                .txt_family = if (is.na(section_txt_family)) NULL else section_txt_family
              )

            curr_margin <-
              if(is.na(section_margin)){
                rlang::parse_expr(doc_margin) |> rlang::eval_tidy()
              }else {
                rlang::parse_expr(section_margin) |> rlang::eval_tidy()
              }

            rendered_canvas <-
              place_on_canvas(
                inner_fig = composition$inner_fig,
                .margin   = curr_margin,
                .design   = section_outer_layout,
                .title    = if(section_incl_title) composition$title else NULL,
                .subtitle = if(section_incl_desc)  composition$desc else NULL,
                .frame    = FALSE,
                .sizes    = c(section_title_size, section_subtitle_size)
              )

            tibble::tibble(
              report_index = report_index,
              sec_id = sec_id,
              sec_sub_id = sec_sub_id,
              rendered_content = list(rendered_canvas)
            )

          },
          shipped_objs = shipped_objs,
          analysis_grid_nms = analysis_grid_nms,
          analysis_grids = analysis_grids,
          compose_partition = compose_partition,
          place_on_canvas   = place_on_canvas,
          realize_slot = realize_slot
        )
      )

    dplyr::inner_join(
      doc_grid,
      purrr::list_rbind(rendered_df),
      dplyr::join_by(report_index, sec_id, sec_sub_id)
    )
  }

#' Call a render engine to generate files based on a document grid
#'
#' @noRd
generate_files <-
  function(
    .rendered_df,
    file,
    backend,
    output,
    dir,
    ...
  ){
    output <- match.arg(output)
    if (backend == "patchwork") {
      render_patchwork(
        .rendered_df = .rendered_df,
        file = file,
        output = output,
        dir = dir,
        ...
      )
    } else {
      stop("Unknown backend: ", backend, call. = FALSE)
    }
  }



#' Render a laid-out document with the patchwork backend
#'
#' Composes every section's subsections into placed pages and writes them as a
#' single multi-page PDF (single mode) or one file per page (pile mode).
#'
#' @noRd
render_patchwork <-
  function(.rendered_df, file, output, dir) {

    if(is.null(file)){
      stop("generate_docs() requires a `file`.", call. = FALSE)
    }

    stem <- tools::file_path_sans_ext(basename(file))
    ext <-
      if(tools::file_ext(basename(file)) == ""){
        "png"
      }else{
        tools::file_ext(basename(file))
      }

    canvas_width  <- .rendered_df |> dplyr::pull(doc_canvas_width)  |> unique()
    canvas_height <- .rendered_df |> dplyr::pull(doc_canvas_height) |> unique()
    doc_dpi       <- .rendered_df |> dplyr::pull(doc_dpi)           |> unique()

    if(output %in% c("single", "both")){

      pdf_path <- glue::glue("{stem}.pdf")

      dev_before <- grDevices::dev.cur()

      suppressWarnings(
        try(
          grDevices::cairo_pdf(
            filename = pdf_path,
            width    = canvas_width,
            height   = canvas_height,
            onefile  = TRUE
          ),
          silent = TRUE
        )
      )

      dev_after <- grDevices::dev.cur()

      used_cairo <- !identical(dev_before, dev_after)

      if(!used_cairo){
        if (grDevices::dev.cur() != 1L) grDevices::dev.off()

        rlang::inform(
          c(
            "cairo_pdf unavailable; using base pdf().",
            i = "For custom fonts, enable cairo or use pile output."
          ),
          .frequency = "once",
          .frequency_id = "multitool_pdf_device"
        )

        grDevices::pdf(
          file = pdf_path,
          width    = canvas_width,
          height   = canvas_height,
          onefile = TRUE
        )
      }

      .rendered_df |>
        dplyr::pull(rendered_content) |>
        purrr::walk(print)

      grDevices::dev.off()

    }

    if(output %in% c("multiple", "both")) {
      if (is.null(dir)) dir <- stem
      if (!dir.exists(dir)) dir.create(dir, recursive = TRUE)

      paths <-
        .rendered_df |>
        dplyr::transmute(
          path =
            file.path(dir, glue::glue("{stem}-{sec_id}-{sec_sub_id}.{ext}")),
          dpi = doc_dpi,
          width =
            ifelse(is.na(section_width), doc_canvas_width, section_width),
          height =
            ifelse(is.na(section_height), doc_canvas_height, section_height),
          content = rendered_content
        )

      purrr::pwalk(
        paths,
        purrr::in_parallel(
          \(path, dpi, width, height, content) {
            for (pkg in c("ggplot2")){
              library(pkg, character.only = TRUE)
            }
            ggplot2::ggsave(
              plot = content, filename = path,
              width = width, height = height, units = "in", dpi = dpi
            )
          }
        )
      )

      invisible(paths$path)
    } else {
      invisible(file)
    }
  }
