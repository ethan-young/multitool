#' Configure human-readable labels for pipeline decisions
#'
#' Attaches or updates a table of display labels for the groups and
#' alternatives in a decision pipeline. Labels are stored as a `"labels"`
#' attribute on the object and are used downstream wherever decisions need
#' human-readable names rather than raw code.
#'
#' On first use, `configure_labels()` derives a default label table from the
#' object's `"pipeline"` attribute: each group is labelled with its own name,
#' and each alternative with its code. Do-nothing filters (detected by the
#' `%in% unique` pattern) are given the label `"No filter on {group}"`, and
#' model alternatives are labelled with their group name. Subsequent calls
#' update this table.
#'
#' Overrides are supplied as named arguments in `...`, where each name is a
#' group or a code and each value is the desired label. Relabelling a group
#' also cascades to that group's do-nothing filter label, so renaming a group
#' keeps its "No filter on ..." alternative consistent automatically.
#'
#' @param .results An expanded or analyzed decision grid carrying a
#'   `"pipeline"` attribute (or an existing `"labels"` attribute from a prior
#'   call).
#' @param ... Named overrides of the form `group = "Label"` or
#'   `code = "Label"`. Names matching a group update the group label (and
#'   cascade to its do-nothing filter); names matching a code update that
#'   alternative's label. Names matching neither are skipped with a warning.
#'
#' @return `.results`, unchanged except for an updated `"labels"` attribute.
#'
#' @details
#' Keys containing spaces must be back-quoted when passed in `...`, e.g.
#' `` `my group` = "My Group" ``. Unmatched keys do not error; they emit a
#' warning and are ignored, so a typo in one label does not abort the call.
#'
#' @seealso [show_labels()] to inspect the current label table or print a
#'   ready-to-edit `configure_labels()` call.
#'
#' @examples
#' \dontrun{
#' results |>
#'   configure_labels(
#'     covariates = "Covariate set",
#'     `iv ~ dv`  = "Unadjusted model"
#'   )
#' }
#'
#' @export
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

#' Inspect or scaffold pipeline labels
#'
#' Prints the current label table attached to an object by
#' [configure_labels()], or — with `.code = TRUE` — prints a ready-to-edit
#' `configure_labels()` call pre-filled with every group and alternative, so
#' the labels can be customized by editing and re-running rather than typed
#' from scratch.
#'
#' @param .object An object carrying a `"labels"` attribute (i.e. one that has
#'   been passed through [configure_labels()]).
#' @param .code If `FALSE` (default), print the label table. If `TRUE`, print
#'   a `configure_labels()` call listing every group and alternative as an
#'   editable starting point.
#'
#' @return `.object`, invisibly and unchanged. Called for its printed output.
#'
#' @details
#' In `.code = TRUE` mode the output is split into a "Groups" block and an
#' "Alternatives" block. Do-nothing filters are omitted from the alternatives
#' block, since their labels are managed automatically by the group cascade in
#' [configure_labels()]. Keys containing spaces are back-quoted so the printed
#' call is valid to paste back in.
#'
#' @seealso [configure_labels()] to set the labels this function displays.
#'
#' @examples
#' \dontrun{
#' results |> configure_labels() |> show_labels()
#'
#' # Print an editable scaffold of every label:
#' results |> configure_labels() |> show_labels(.code = TRUE)
#' }
#'
#' @export
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

#' Add a content section to a report
#'
#' Defines a section of a report by attaching content-generating code to an
#' analysis grid. A section bundles up to three kinds of content — text, a
#' table, and a figure — each produced by a function applied to the section's
#' gathered data. Sections accumulate: piping one `add_section()` into the next
#' builds a multi-section report grid.
#'
#' The content functions (`txt.fn`, `tbl.fn`, `fig.fn`) are captured as code,
#' recorded so the section remains a transparent, auditable artifact, then run
#' against the section's data to realize the actual text, table, and figure
#' objects. Both the realized content and the generating code are stored, so a
#' section can be rendered *and* inspected.
#'
#' @section Section content: gather, then distil:
#' A section is built in two steps. First, `report_data` gathers the data the
#' section needs from the grid — typically a [compose_view()] call that joins
#' the relevant unpacked results into a single data frame. Second, each content
#' function (`txt.fn`, `tbl.fn`, `fig.fn`) receives that gathered data frame as
#' its first argument and distils it into one rendered object: a text string, a
#' table, or a figure.
#'
#' So the flow is always: `report_data` produces the section's data frame, and
#' each content function consumes that same data frame. A content function is
#' written as code that takes the `compose_view` output as its first argument —
#' for example `fig.fn = ggplot(aes(...)) + geom_point()`, or a call to a named
#' function whose first argument is the data, written with parentheses as
#' `fig.fn = make_spec_curve()` so it sits correctly after the pipe. Because the
#' data is piped into the content function, the function must be written as a
#' call (with parentheses), not a bare name.
#'
#' A section need not have all three content types. Any of `txt.fn`, `tbl.fn`,
#' or `fig.fn` may be left `NULL`, in which case that content slot is empty
#' (stored as `NULL`) and simply omitted wherever the section is rendered. A
#' figure-only section, a table-plus-text section, or any combination is valid.
#'
#' @section Sections and subsections:
#' When `.by` is supplied, the section is *fanned out* into one subsection per
#' unique combination of the `.by` columns. Each subsection receives its own
#' filtered slice of the grid and its own title and description. Because
#' `title` and `description` are processed with [glue::glue()], they can
#' reference the `.by` columns to produce per-subsection labels — for example,
#' `title = "Results for {outcome}"` yields a distinct title per `outcome`.
#'
#' Without `.by`, the section is a single unit with one title and description,
#' and glue interpolation of the `.by` columns does not apply (there are no
#' subsections to vary over).
#'
#' @param .report A named analysis grid (e.g. an analyzed decision grid), or
#'   the result of a previous `add_section()` call to append to. `add_section()`
#'   re-evaluates against the grid by name, so the grid must be a named object
#'   in the calling environment.
#' @param id A short identifier for the section, used later to lay it out and
#'   assemble it (e.g. `"robustness"`). Should be unique within a report.
#' @param title,description Section heading text. Processed with [glue::glue()],
#'   so they may interpolate `.by` columns to vary per subsection.
#' @param report_data A code expression — usually a [compose_view()] call —
#'   applied to the grid to gather this section's data into a single data frame.
#'   This data frame is what each content function receives.
#' @param txt.fn,tbl.fn,fig.fn Content functions, each taking the `report_data`
#'   data frame as its first argument and returning one rendered object:
#'   `txt.fn` a text string, `tbl.fn` a table (`data.frame`, `gt`, or
#'   `flextable`), `fig.fn` a figure (`ggplot` or `patchwork`). Must be written
#'   as a call (with parentheses), since the data is piped in. Any may be
#'   `NULL`; an omitted content type yields an empty slot and is skipped when
#'   the section is rendered.
#' @param .by Columns that split the section into subsections, one per unique
#'   combination. When `NULL`, the section is a single unit.
#'
#' @return A report grid (a tibble) with one row per subsection, carrying the
#'   section's id, the realized `sec_txt`/`sec_tbl`/`sec_fig` content, a nested
#'   `code` column holding the generating code for each, and per-subsection
#'   titles and descriptions. The originating grid name is recorded as an
#'   `"analysis_grid"` attribute so successive `add_section()` calls can chain.
#'
#' @details
#' Each content slot stores both the realized object (`sec_txt`, `sec_tbl`,
#' `sec_fig`) and its code (nested under `code`), supporting the package's
#' code-as-artifact principle: a section can be rendered into a report and also
#' read back as the exact code that produced it.
#'
#' Content functions have access only to the gathered section data, not to the
#' section's metadata fields — a figure title, for instance, belongs inside
#' `fig.fn`, while a section- or slide-level heading belongs in `title`.
#'
#' @seealso
#'   [compose_view()] for gathering results for section reporting;
#'   [show_section_content()] to inspect one section's realized content and code;
#'   [preview_section()] to preview a section's composed layout;
#'   [layout_section()] and [generate_docs()] to assemble sections into a document.
#'
#' @examples
#' \dontrun{
#' # A figure-only section, fanned out by outcome
#' report <-
#'   analyzed_grid |>
#'   add_section(
#'     id          = "estimates",
#'     title       = "Effect estimates for {outcome}",
#'     description = "Distribution across specifications",
#'     report_data = compose_view(model_parameters, model_performance),
#'     fig.fn      = make_spec_curve(),
#'     .by         = outcome
#'   )
#'
#' # Chain a table-only section onto the same report
#' report <-
#'   report |>
#'   add_section(
#'     id          = "robustness",
#'     title       = "Robustness summary",
#'     report_data = compose_view(rob = assess_robustness),
#'     tbl.fn      = gt::gt()
#'   )
#' }
#'
#' @export
add_section <-
  function(
    .report,
    id = "",
    title = "",
    description = "",
    report_data,
    txt.fn = NULL,
    tbl.fn = NULL,
    fig.fn = NULL,
    .by = NULL
  ){

    code <- dplyr::enexprs(report_data)
    code_chr <- as.character(code)

    fn_txt <- dplyr::enexprs(txt.fn)
    fn_txt_chr <- as.character(fn_txt)

    fn_tbl <- dplyr::enexprs(tbl.fn)
    fn_tbl_chr <- as.character(fn_tbl)

    fn_fig <- dplyr::enexprs(fig.fn)
    fn_fig_chr <- as.character(fn_fig)

    by_cols <- dplyr::enexprs(.by)
    by_cols_chr <- as.character(by_cols)

    data_chr <- dplyr::enexpr(.report) |> as.character()
    data_attr <- attr(.report, "analysis_grid")

    if (!is.null(data_attr)) {
      data_chr <- attr(.report, "analysis_grid")
    }

    analysis_grid <-
      rlang::parse_expr(data_chr) |>
      rlang::eval_tidy(env = parent.frame())

    section_expansion <-
      glue::glue(
        "{data_chr} |> {code_chr} |> select({by_cols_chr}) |> distinct()"
      ) |>
      rlang::parse_expr() |>
      rlang::eval_tidy()

    if(by_cols_chr != "NULL"){
      section_expansion <-
        section_expansion |>
        dplyr::mutate(sec_sub_id = 1:dplyr::n()) |>
        dplyr::rowwise() |>
        dplyr::mutate(
          sec_subset =
            paste0(
              "filter(",
              paste0(
                dplyr::across(
                  -sec_sub_id,
                  ~ glue::glue("{cur_column()} == '{.x}'")
                ),
                collapse = ", "
              ),
              ")"
            )
        ) |>
        tidyr::nest(by_specs = -c(sec_sub_id, sec_subset)) |>
        dplyr::ungroup()
    } else{
      section_expansion <-  dplyr::tibble(sec_sub_id = 1, sec_subset = "NULL")
    }

    section_prep <-
      section_expansion |>
      dplyr::mutate(
        sec_id = id,
        sec_title = title,
        sec_description = description,
        sec_source = code_chr,
        sec_txt_fn = fn_txt_chr,
        sec_tbl_fn = fn_tbl_chr,
        sec_fig_fn = fn_fig_chr
      ) |>
      dplyr::mutate(
        sec_piping =
          ifelse(
            sec_subset != "NULL",
            glue::glue("{data_chr} |> {code_chr} |> {sec_subset}"),
            glue::glue("{data_chr} |> {code_chr}")
          )
      ) |>
      dplyr::transmute(
        sec_id,
        sec_sub_id,
        sec_title =
          ifelse(
            sec_subset != "NULL",
            purrr::map_chr(by_specs, \(x) glue::glue_data(x, title)),
            sec_title
          ),
        sec_description =
          ifelse(
            sec_subset != "NULL",
            purrr::map_chr(by_specs, \(x) glue::glue_data(x, description)),
            sec_description
          ),
        sec_txt =
          ifelse(
            sec_txt_fn != "NULL",
            glue::glue("{sec_piping} |> {sec_txt_fn}"),
            sec_txt_fn
          ),
        sec_tbl =
          ifelse(
            sec_tbl_fn != "NULL",
            glue::glue("{sec_piping} |> {sec_tbl_fn}"),
            sec_tbl_fn
          ),
        sec_fig =
          ifelse(
            sec_fig_fn != "NULL",
            glue::glue("{sec_piping} |> {sec_fig_fn}"),
            sec_fig_fn
          )
      ) |>
      dplyr::mutate(
        dplyr::across(c(sec_txt, sec_tbl, sec_fig), ~.x, .names = "code_{.col}")
      ) |>
      tidyr::nest(code = dplyr::starts_with("code")) |>
      dplyr::mutate(
        sec_txt = purrr::map(sec_txt, \(x) rlang::parse_expr(x) |> rlang::eval_tidy()),
        sec_tbl = purrr::map(sec_tbl, \(x) rlang::parse_expr(x) |> rlang::eval_tidy()),
        sec_fig = purrr::map(sec_fig, \(x) rlang::parse_expr(x) |> rlang::eval_tidy())
      )

    if(!is.null(data_attr)){
      section_prep <- dplyr::bind_rows(.report, section_prep)
    } else{
      section_prep <- section_prep
    }

    attr(section_prep, "analysis_grid") <- data_chr
    section_prep
  }

#' Inspect one section's content and code
#'
#' Prints a single content type — figure, text, or table — for one subsection
#' of a report, along with the code that produced it. This is the granular
#' inspector for report content: where [preview_section()] composes all of a
#' section's content into a laid-out slide, `show_section_content()` isolates a
#' single channel of a single subsection so it can be examined on its own and
#' its generating code read back.
#'
#' If no subsection is named, one is chosen at random — useful for spot-checking
#' that a section's content function generalizes across the subsections it was
#' fanned out into.
#'
#' @param .report A report grid produced by [add_section()].
#' @param section The `id` of the section to inspect.
#' @param sub_section The `sec_sub_id` of the subsection to show. If `NULL`
#'   (default), a subsection is sampled at random.
#' @param content Which content channel to show: `"figure"` (default),
#'   `"text"`, or `"tbl"`.
#'
#' @return The realized content object for the chosen channel and subsection,
#'   returned invisibly. Called primarily for its console output: the section's
#'   id, subsection, title, and description, followed by the content itself
#'   (figures render to the plot pane) and its styled generating code.
#'
#' @details
#' The printed code is run through [styler::style_text()] so it reads cleanly,
#' reflecting the package's code-as-artifact principle — the content shown and
#' the code that produced it are inspected together.
#'
#' Because the realized content object is returned invisibly, it can also be
#' captured for further use, e.g. `fig <- show_section_content(report,
#' "estimates")`.
#'
#' @seealso
#'   [preview_section()] to preview a section's full composed layout;
#'   [add_section()] to create the sections this inspects.
#'
#' @examples
#' \dontrun{
#' # Show a randomly sampled subsection's figure and its code
#' show_section_content(report, section = "estimates")
#'
#' # Inspect a specific subsection's table
#' show_section_content(
#'   report,
#'   section     = "robustness",
#'   sub_section = 2,
#'   content     = "tbl"
#' )
#'
#' # Capture the returned object
#' fig <- show_section_content(report, "estimates", content = "figure")
#' }
#'
#' @export
show_section_content <-
  function(.report, section, sub_section = NULL, content = "figure"){

    report_section <-
      .report |>
      dplyr::filter(sec_id == section) |>
      tidyr::unnest(code)

    if(is.null(sub_section)){
      report_section <-
        report_section |>
        dplyr::slice_sample()
    } else{
      report_section <-
        report_section |>
        dplyr::filter(sec_sub_id == sub_section)
    }

    report_section <-
      report_section |>
      dplyr::mutate(
        content_col =
          dplyr::case_when(
            content == "figure" ~ sec_fig,
            content == "text" ~ sec_txt,
            content == "tbl" ~ sec_tbl,
            TRUE ~ NA
          ),
        content_code =
          dplyr::case_when(
            content == "figure" ~ code_sec_fig,
            content == "text" ~ code_sec_txt,
            content == "tbl" ~ code_sec_tbl,
            TRUE ~ NA
          )
      )

    cat(
      glue::glue_data(
        report_section,
        "\nsection id: {sec_id}\nsub section: {sec_sub_id}\n\n",
        "Title: {sec_title}\n",
        "Description: {sec_description}\n\n\n"
      )
    )

    cat(
      glue::glue(
        "{stringr::str_to_title(content)}:",
        "{ifelse(content == 'figure','\n(see plot pane)', '')}",
        "\n\n"
      )
    )

    report_section |>
      dplyr::pull(content_col) |>
      print()

    cat(glue::glue("{stringr::str_to_title(content)} Code:\n\n"))

    report_section |>
      dplyr::pull(content_code) |>
      styler::style_text() |>
      print()

    invisible(
      report_section |>
        dplyr::pull(content_col) |>
        purrr::pluck(1)
    )
  }

#' Preview a figure at its true output size
#'
#' Renders a figure to a temporary file at exact physical dimensions and opens
#' it, so what you see matches what will be exported — sidestepping the RStudio
#' plot pane, which rescales figures to its own dimensions and is a poor guide
#' to how a figure will actually look at its intended size.
#'
#' All dimensions are in **inches**, matching the units used by the output
#' devices these previews stand in for (PDF, [ggplot2::ggsave()], slides). If
#' you think in centimetres or millimetres, convert before passing dimensions
#' (e.g. 10 cm is about 3.94 in). The one exception is `margin`, which may be
#' given in any unit via [ggplot2::margin()] and is converted to inches for you.
#'
#' Two modes serve two purposes. In `"figure"` mode, the figure is rendered at
#' the exact `width` and `height` you specify — use this to judge a figure at
#' its real export dimensions and dial in a size before saving. In `"slide"`
#' mode, the figure is placed onto a slide-shaped canvas via a layout `design`,
#' with an optional margin and title — use this to see how a figure will sit on
#' a slide, and to get an estimate of the dimensions it should be exported at to
#' fill its region of that slide.
#'
#' @section Figure mode — exact sizing:
#' `mode = "figure"` requires `width` and `height` in inches and renders the
#' figure to fill exactly that canvas. This is the tool for "what does this plot
#' look like at 6 by 4 inches?" — render, look, adjust, repeat, then export at
#' the size that looked right.
#'
#' @section Slide mode — placement and dimension estimation:
#' `mode = "slide"` builds a slide canvas from `asp_ratio` and `anchor_height`
#' (slides are conventionally `anchor_height` inches tall; width follows the
#' aspect ratio), places the figure on it according to `design`, and reports the
#' *implied dimensions*: how large the figure itself is within its region of the
#' slide, after the margin is subtracted. Those implied dimensions are what you
#' would pass back to `mode = "figure"` (or to [ggplot2::ggsave()]) to export the
#' figure standalone at the size it occupies on the slide.
#'
#' The implied-dimension estimate assumes the figure has no slide title or
#' subtitle. When a `title` or `subtitle` is supplied, it occupies space the
#' estimate cannot account for, and `view_real_size()` says so. To reserve room
#' for a title without distorting the estimate, add top `margin` rather than a
#' title: the margin is subtracted exactly, so it gives a clean, controllable
#' approximation of the space a heading will take.
#'
#' @param .fig A `ggplot` or `patchwork` object to preview.
#' @param mode `"figure"` (default) to render at an exact `width`/`height`, or
#'   `"slide"` to place the figure on a slide canvas and estimate its
#'   dimensions.
#' @param width,height Figure dimensions in inches. Required in `"figure"` mode;
#'   ignored in `"slide"` mode (the canvas is derived from `asp_ratio`).
#' @param asp_ratio Slide aspect ratio in `"slide"` mode: `"wide"` (16:9,
#'   default) or `"full"` (4:3).
#' @param anchor_height The slide height in inches in `"slide"` mode (default
#'   `7.5`); the width is this times the aspect ratio.
#' @param design A patchwork layout design string placing the figure on the
#'   slide (e.g. `"A"` for full-bleed, `"#AA"` to occupy the right two-thirds
#'   with reserved blank space). `"slide"` mode only; defaults to `"A"`.
#' @param dpi Resolution for the rendered preview (default `96`).
#' @param margin A [ggplot2::margin()] giving the slide margin in `"slide"`
#'   mode, in any unit; converted to inches and subtracted from the canvas when
#'   estimating implied dimensions.
#' @param frame If `TRUE` (default), draw a border around the slide in `"slide"`
#'   mode so the canvas edges and content boundaries are visible while
#'   previewing.
#' @param give_dims If `TRUE` (default), print the implied figure dimensions in
#'   `"slide"` mode.
#' @param title,subtitle Optional slide title and subtitle text in `"slide"`
#'   mode. Note these are not accounted for in the implied-dimension estimate
#'   (see the slide-mode section).
#' @param meta_pt_sizes Point sizes for the slide `title` and `subtitle`, as a
#'   length-2 numeric (default `c(24, 16)`).
#'
#' @return Invisibly, the sized object: in `"figure"` mode the figure as given;
#'   in `"slide"` mode the figure placed on its canvas. Called primarily for the
#'   side effect of opening the rendered preview, and in `"slide"` mode for the
#'   printed dimension estimate.
#'
#' @seealso
#'   [preview_section()], which uses slide mode to preview a report section's
#'   composed layout.
#'
#' @examples
#' \dontrun{
#' # Figure mode: see a plot at exactly 6 by 4 inches
#' view_real_size(my_plot, mode = "figure", width = 6, height = 4)
#'
#' # Slide mode: place a figure in the right two-thirds of a 16:9 slide
#' # and get the dimensions to export it at
#' view_real_size(my_plot, mode = "slide", design = "#AA")
#'
#' # Reserve space for a heading via top margin rather than a title,
#' # to keep the dimension estimate clean
#' view_real_size(
#'   my_plot,
#'   mode   = "slide",
#'   margin = ggplot2::margin(1, 0, 0, 0, "in")
#' )
#' }
#'
#' @export
view_real_size <-
  function(
    .fig,
    mode = "figure",
    width = NULL,
    height = NULL,
    asp_ratio = "wide",
    anchor_height = 7.5,
    design = NULL,
    dpi = 96,
    margin = NULL,
    frame = TRUE,
    give_dims = TRUE,
    title = NULL,
    subtitle = NULL,
    meta_pt_sizes = c(24, 16)
  ){

    canvas <-
      if(mode == "figure"){
        if (is.null(width) || is.null(height)) {
          stop(
            "mode = 'figure' requires both width and height (in inches).",
            call. = FALSE
          )
        }
        list(w = width, h = height)
      } else if (mode == "slide") {
        aspect <- if (asp_ratio == "wide") 16 / 9 else 4 / 3
        list(w = anchor_height * aspect, h = anchor_height)
      }

    if(mode == "figure"){
      temp_fig(.fig, canvas = canvas, dpi = dpi)
      sized_fig <- .fig
    }

    if(mode == "slide"){
      if(is.null(design)){
        design <- "A"
      }

      sized_fig <-
        place_on_canvas(
          .fig,
          .design   = design,
          .frame    = frame,
          .margin   = margin,
          .title    = title,
          .subtitle = subtitle,
          .sizes    = meta_pt_sizes
        )

      temp_fig(sized_fig, canvas = canvas, dpi = dpi)

      computed_margin <- compute_margins(margin)
      implied_ratios  <- parse_design(design = design)

      fig_w <-
        (canvas$w - computed_margin$r - computed_margin$l) * implied_ratios$width_ratio
      fig_h <-
        (canvas$h - computed_margin$t - computed_margin$b) * implied_ratios$height_ratio

      if(give_dims){
        message(
          glue::glue("implied dims: {round(fig_w, 2)}in by {round(fig_h, 2)}in")
        )

        if(!is.null(title) || !is.null(subtitle)){
          message(
            "dimensions include titles/subtitles\n",
            "set titles/subtitles to `NULL` to estimate accurate implied dimensions\n",
            "change margin alone to get better dimensions and simulate space for titles"
          )
        }
      }
    }

    sized_fig
  }

#' Preview a report section's composed layout
#'
#' Composes one subsection of a section — its text, table, and figure arranged
#' by a patchwork layout — and previews it on a slide canvas at true size. This
#' is the report-facing previewer: where [view_real_size()] previews an
#' arbitrary figure, `preview_section()` pulls a section's content from the
#' report grid, composes it, and shows how it will look as a slide, so a layout
#' can be validated before assembling the full document.
#'
#' If no subsection is named, one is chosen at random — a check that the
#' section's layout generalizes across all the subsections it was fanned out
#' into, not just one.
#'
#' @section Inner and outer layout: A section preview involves two layouts. The
#'   *inner* layout (`.patchwork_syntax` with `.inner_design`) arranges the
#'   section's own content — text, table, figure — into a composition, using
#'   patchwork syntax over the slot names `sec_txt`, `sec_tbl`, and `sec_fig`.
#'   The *outer* layout (`.outer_design`) then places that whole composition
#'   onto the slide canvas, typically full-bleed (`"A"`) or in a region with
#'   reserved space (e.g. `"#AA"`).
#'
#'   The inner layout is what the section *contains*; the outer layout is where
#'   it
#' *sits* on the slide. Most previews set only the inner arrangement and leave
#'   the outer at `"A"` (the composition fills the slide); the outer design
#'   matters when you want the content to occupy part of the slide and leave the
#'   rest blank.
#'
#' @param .report A report grid produced by [add_section()].
#' @param section The `id` of the section to preview.
#' @param sub_section The `sec_sub_id` to preview. If `NULL` (default), one is
#'   sampled at random.
#' @param add_title,add_desc Whether to show the section's title and description
#'   as slide annotations (default `TRUE` for both). The text comes from the
#'   section's stored title and description; empty values are omitted.
#' @param codify Whether to print a call to `layout_section` based on preview
#'   settings. Defaults to `TRUE`.
#' @param .patchwork_syntax Patchwork syntax composing the section's content
#'   slots — `sec_txt`, `sec_tbl`, `sec_fig` — e.g. `sec_txt + sec_fig`. Slots
#'   that are empty for this section render as blank spacers.
#' @param .mode Passed to [view_real_size()] as `mode`; `"slide"` (default)
#'   previews the composition placed on a slide canvas.
#' @param .inner_design Optional patchwork design string arranging the content
#'   slots (the *inner* layout). Applies only when `.patchwork_syntax` uses no
#'   positional operators (`|`, `/`); see [view_real_size()] and patchwork's
#'   layout documentation.
#' @param .outer_design Patchwork design string placing the composed section on
#'   the slide (the *outer* layout); defaults to `"A"` (full-bleed).
#' @param .txt_size The size of text to appear when a composition contains a
#'   textual section. Defaults to 6.
#' @param ... Passed to [view_real_size()] — e.g. `asp_ratio`, `anchor_height`,
#'   `dpi`, `margin`, `pt_sizes` — to control the slide canvas and styling.
#'
#' @return Invisibly, the composed section placed on its slide canvas (as
#'   returned by [view_real_size()]). Called primarily to open the preview.
#'
#' @details Unlike a standalone [view_real_size()] call, `preview_section()`
#'   previews without the canvas border and without printing implied dimensions:
#'   a section preview is about confirming the *composition and placement*, not
#'   sizing a figure for export, so those standalone aids are turned off here.
#'
#' @seealso [view_real_size()] for the underlying previewer and its slide-canvas
#'   controls; [show_section_content()] to inspect a single content channel and
#'   its code; [add_section()] to create sections; [layout_section()] to record
#'   a section's layout for assembly.
#'
#' @examples
#' \dontrun{
#' # Preview a section's figure-and-text composition, full-bleed
#' preview_section(
#'   report,
#'   section           = "estimates",
#'   .patchwork_syntax = sec_txt + sec_fig,
#'   .inner_design     = "AABB"
#' )
#'
#' # Preview with the section title shown, content in the right two-thirds
#' preview_section(
#'   report,
#'   section           = "estimates",
#'   add_title         = TRUE,
#'   .patchwork_syntax = sec_fig,
#'   .outer_design     = "#AA"
#' )
#' }
#'
#' @export
preview_section <-
  function(
    .report,
    section,
    sub_section = NULL,
    add_title = TRUE,
    add_desc = TRUE,
    codify = TRUE,
    .patchwork_syntax = NULL,
    .mode = "slide",
    .inner_design = NULL,
    .outer_design = "A",
    .txt_size = 6,
    ...
  ){

    patch_syntax <- dplyr::enexprs(.patchwork_syntax)
    patch_syntax_chr <- as.character(patch_syntax)

    report_section <-
      .report |>
      dplyr::filter(sec_id == section) |>
      tidyr::unnest(code)

    if(is.null(sub_section)){
      report_section <-
        report_section |>
        dplyr::slice_sample(n = 1)
    } else{
      report_section <-
        report_section |>
        dplyr::filter(sec_sub_id == sub_section)
    }

    composed_section <-
      compose_partition(
        report_section,
        .syntax = patch_syntax_chr,
        .design = .inner_design,
        .txt_size = .txt_size
      )

    inner_fig <- composed_section$inner_fig

    if(add_title){
      p_title <-
        if (!is.null(composed_section$title) && nzchar(composed_section$title)){
          composed_section$title
        } else NULL
    } else{
      p_title <- NULL
    }

    if(add_desc){
      p_desc <-
        if (!is.null(composed_section$desc) && nzchar(composed_section$desc)){
          composed_section$desc
        } else NULL
    } else{
      p_desc <- NULL
    }

    if(codify){
      inner_line <-
        if(is.null(.inner_design)){
          ''
        } else {
          glue::glue(
            ".inner_design = '{.inner_design}',"
          )
        }

      layout_call <-
        glue::glue(
          "\n\n",
          "layout_section(",
          "section = '{section}',",
          ".patchwork_syntax = {patch_syntax_chr},",
          "{str_replace_all(inner_line, '\n', '\\\\\\\\n')}",
          ".outer_design = '{.outer_design}',",
          "add_title = {add_title},",
          "add_desc = {add_desc}",
          ")",
          .trim = FALSE,
          .sep = "\n"
        )

      rlang::inform("Codify this layout with:")
      cli::cli_code(
        styler::style_text(layout_call)
      )

    }

    view_real_size(
      .fig = inner_fig,
      mode = .mode,
      design = .outer_design,
      frame = FALSE,
      title = p_title,
      subtitle = p_desc,
      give_dims = FALSE,
      ...
    )
  }

#' Begin assembling a report document
#'
#' Starts a document from one or more report grids, producing a document object
#' that subsequent [layout_section()] calls fill in and [generate_docs()]
#' renders. This is the head of the assembly chain: gather your built sections
#' here, lay each one out, then generate.
#'
#' Multiple report grids may be supplied. This supports the common case where a
#' single research question spans several analysis pipelines whose decision
#' spaces diverge enough to be built separately, yet belong in one document. The
#' grids are combined into a single universe of sections, and `layout_section()`
#' and `generate_docs()` treat them uniformly thereafter.
#'
#' @section Document-level defaults:
#' The settings given here — backend, aspect ratio, height, dpi, margin — are
#' the document's defaults, applied to every section unless a section overrides
#' them in [layout_section()]. The canvas is sized once for the whole document:
#' slides are `default_height` inches tall, with width following the aspect
#' ratio, so a single-document output is a uniform deck.
#'
#' @param ... One or more report grids, each built with [add_section()]. Section
#'   ids must be unique across all supplied grids.
#' @param backend The rendering backend (default `"patchwork"`). Determines how
#'   [generate_docs()] interprets each section's layout and what it produces.
#' @param default_asp_ratio Default slide aspect ratio: `"wide"` (16:9, default)
#'   or `"full"` (4:3).
#' @param default_height Default slide height in inches (default `7.5`); the
#'   width follows the aspect ratio.
#' @param default_dpi Default rendering resolution (default `96`).
#' @param default_margin Default slide margin, a [ggplot2::margin()] object
#'   (default zero on all sides). May be given in any unit.
#'
#' @return A document object: a list with a `settings` element (the
#'   document-level defaults) and a `grid` element (one row per section, with
#'   its subsections nested and its layout to be filled in by
#'   [layout_section()]).
#'
#' @details
#' Section ids must be unique across all supplied grids, since `layout_section()`
#' and `generate_docs()` address sections by id. If the same id appears in more
#' than one grid, `initialize_doc()` stops and reports the collisions, so the
#' ambiguity is caught at assembly time rather than producing a confusing
#' result later.
#'
#' Each section begins un-laid-out; it must be passed through [layout_section()]
#' before [generate_docs()] can render it.
#'
#' @seealso
#'   [layout_section()] to specify each section's layout;
#'   [generate_docs()] to render the assembled document;
#'   [add_section()] to build the report grids supplied here.
#'
#' @examples
#' \dontrun{
#' # Single grid
#' doc <-
#'   report |>
#'   initialize_doc(
#'     default_asp_ratio = "wide",
#'     margin = ggplot2::margin(0.5, 0.5, 0.5, 0.5, "in")
#'   )
#'
#' # Multiple grids from divergent pipelines, one document
#' doc <-
#'   initialize_doc(
#'     main_results,
#'     sensitivity_results,
#'     default_asp_ratio = "wide"
#'   )
#'
#' # Continue the chain
#' doc <-
#'   doc |>
#'   layout_section("estimates", .patchwork_syntax = sec_fig) |>
#'   generate_docs(file = "deck.pdf")
#' }
#'
#' @export
initialize_doc <-
  function(
    ...,
    backend          = "patchwork",
    default_asp_ratio = "wide",
    default_height    = 7.5,
    default_dpi       = 96,
    default_margin    = ggplot2::margin(0, 0, 0, 0, "in")
  ) {

    aspect   <- if (default_asp_ratio == "wide") 16 / 9 else 4 / 3
    canvas_w <- default_height * aspect
    canvas_h <- default_height

    report_grids <- list(...)
    if (length(report_grids) == 0) {
      stop("initialize_doc() needs at least one report grid.", call. = FALSE)
    }

    combined_grid <- dplyr::bind_rows(report_grids, .id = "report_index")

    dup_ids <-
      combined_grid |>
      dplyr::distinct(report_index, sec_id) |>
      dplyr::count(sec_id) |>
      dplyr::filter(n > 1) |>
      dplyr::pull(sec_id)

    if (length(dup_ids) > 0) {
      stop(
        "Duplicate sec_id across the supplied report grids: ",
        paste(dup_ids, collapse = ", "),
        ". Give each section a unique id before combining.",
        call. = FALSE
      )
    }

    grid <-
      combined_grid |>
      tidyr::nest(content = -c(report_index, sec_id)) |>
      dplyr::mutate(
        patchwork_syntax   = NA_character_,
        inner_layout       = NA_character_,
        outer_layout       = NA_character_,
        section_incl_title = NA,
        section_incl_desc  = NA,
        section_width      = NA_real_,
        section_height     = NA_real_,
        section_meta_sizes = list(NULL),
        section_txt_size   = NA_real_,
        laid_out           = FALSE
      )

    list(
      settings =
        list(
          backend       = backend,
          asp_ratio     = default_asp_ratio,
          dpi           = default_dpi,
          margin        = default_margin,
          canvas_width  = canvas_w,
          canvas_height = canvas_h
        ),
      grid = grid
    )
  }

#' Record a section's layout for assembly
#'
#' Specifies how one section should be composed and placed when the document is
#' rendered, writing that layout into the document begun by [initialize_doc()].
#' This is the middle of the assembly chain: it records intent — the patchwork
#' syntax, the inner and outer designs, whether to show the title and
#' description — without rendering anything. Rendering happens later, all at
#' once, in [generate_docs()].
#'
#' `layout_section()` is chainable: pipe one call into the next to lay out each
#' section in turn, building the document's structure as a readable sequence of
#' calls.
#'
#' @section Inner and outer layout:
#' Each section has two layouts, the same distinction used in
#' [preview_section()]. The *inner* layout (`.patchwork_syntax` with
#' `.inner_design`) arranges the section's own content — `sec_txt`, `sec_tbl`,
#' `sec_fig` — into a composition. The *outer* layout (`.outer_design`) places
#' that composition onto the page, full-bleed (`"A"`, the default) or in a
#' region with reserved space (e.g. `"#AA"`).
#'
#' The layout recorded here is applied to *every* subsection of the section when
#' the document is generated, so a section fanned out into many subsections is
#' composed consistently across all of them.
#'
#' @param .doc A document object from [initialize_doc()].
#' @param section The `id` of the section to lay out. Must exist in the
#'   document.
#' @param .patchwork_syntax Patchwork syntax composing the section's content
#'   slots — `sec_txt`, `sec_tbl`, `sec_fig` — e.g. `sec_txt + sec_fig`. Written
#'   unquoted; captured as code.
#' @param .inner_design Optional patchwork design string arranging the content
#'   slots (the *inner* layout). Applies when `.patchwork_syntax` uses no
#'   positional operators (`|`, `/`). `NULL` (default) leaves arrangement to the
#'   syntax.
#' @param .outer_design Patchwork design string placing the composed section on
#'   the page (the *outer* layout); defaults to `"A"` (full-bleed).
#' @param add_title,add_desc Whether to show the section's title and
#'   description when rendered (default `TRUE` for both).
#' @param meta_pt_sizes Point sizes for the title and description, as a length-2
#'   numeric (default `c(24, 16)`).
#' @param txt_size Point sizes for a textual section (if any). Defaults to 6.
#' @param height,width Optional per-section canvas dimensions in inches. *In
#'   development*: reserved for a future pile backend that renders each section
#'   as an independent file. Ignored when the document is rendered as a single
#'   uniform deck. `NULL` (default) uses the document canvas.
#'
#' @return The document object, with this section's layout recorded. Returned so
#'   `layout_section()` calls can be chained.
#'
#' @details
#' Layout settings left `NULL` are recorded as missing, so that
#' [generate_docs()] can fall through to the document-level defaults set in
#' [initialize_doc()]. This cascade — section setting if given, document default
#' otherwise — lets most sections inherit a consistent look while individual
#' sections override what they need.
#'
#' A section must be laid out before it can be rendered; [generate_docs()] will
#' report any section that was added to the document but never passed through
#' `layout_section()`.
#'
#' @seealso
#'   [preview_section()] to preview a single section's layout before recording
#'   it — and to print a ready-to-paste `layout_section()` call codifying that
#'   preview; [initialize_doc()] to begin the document; [generate_docs()] to
#'   render it.
#'
#' @examples
#' \dontrun{
#' doc <-
#'   report |>
#'   initialize_doc() |>
#'   layout_section(
#'     "estimates",
#'     .patchwork_syntax = sec_txt + sec_fig,
#'     .inner_design     = "AABB"
#'   ) |>
#'   layout_section(
#'     "robustness",
#'     .patchwork_syntax = sec_tbl,
#'     add_desc          = FALSE
#'   )
#' }
#'
#' @export
layout_section <-
  function(
    .doc,
    section,
    .patchwork_syntax = NULL,
    .inner_design     = NULL,
    .outer_design     = "A",
    add_title = TRUE,
    add_desc  = TRUE,
    meta_pt_sizes  = c(24, 16),
    txt_size = 6,
    height = NULL,
    width  = NULL
  ){

    patch_syntax_chr <- as.character(dplyr::enexprs(.patchwork_syntax))

    if (!section %in% .doc$grid$sec_id) {
      stop("No section with sec_id = '", section, "' in this document.",
           call. = FALSE)
    }

    section_settings <-
      dplyr::tibble(
        sec_id             = section,
        patchwork_syntax   = patch_syntax_chr,
        inner_layout       = .inner_design %||% NA_character_,
        outer_layout       = .outer_design,
        section_incl_title = add_title,
        section_incl_desc  = add_desc,
        section_width      = width  %||% NA_real_,
        section_height     = height %||% NA_real_,
        section_meta_sizes = list(meta_pt_sizes),
        section_txt_size   = txt_size,
        laid_out           = TRUE
      )

    .doc$grid <-
      dplyr::rows_update(
        .doc$grid,
        section_settings,
        by = "sec_id"
      )

    .doc
  }

#' Render an assembled document
#'
#' Renders a document — built with [initialize_doc()] and laid out with
#' [layout_section()] — into output. This is the terminal step of the assembly
#' chain: it composes every section's content according to the recorded layouts
#' and produces the final artifact.
#'
#' Before rendering, `generate_docs()` checks that every section in the document
#' has been laid out, resolves each section's effective settings (section
#' overrides falling through to document defaults), and hands the result to the
#' backend named in [initialize_doc()].
#'
#' @section Output modes:
#' `output = "single"` produces one multi-page document — a deck — with every
#' section (and its subsections) as pages of uniform size. This is the working
#' mode for the patchwork backend, rendering a single PDF.
#'
#' `output = "pile"` is *in development*: it will render each section as an
#' independent file (using `extension` and `dir`), the mode in which
#' per-section dimensions from [layout_section()] take effect.
#'
#' @param .doc A laid-out document object from the
#'   [initialize_doc()] / [layout_section()] chain.
#' @param file Output file path for `"single"` mode (e.g. `"report.pdf"`).
#' @param output `"single"` (default) for one multi-page deck, or `"pile"` for
#'   one file per section (in development).
#' @param extension File extension for `"pile"` mode (default `"png"`).
#' @param dir Output directory for `"pile"` mode (default `"multitool_report"`).
#'
#' @return Invisibly, the path(s) written. Called for the side effect of
#'   producing the output file(s).
#'
#' @details
#' Every section must be laid out before rendering. If any section was added to
#' the document but never passed through [layout_section()], `generate_docs()`
#' stops and names the un-laid-out sections, rather than silently dropping or
#' mis-rendering them.
#'
#' Effective settings are resolved per section as a cascade: a value set on the
#' section in [layout_section()] takes precedence, otherwise the document
#' default from [initialize_doc()] applies. In `"single"` mode the canvas is
#' held uniform across all pages (so the deck reads as a coherent whole);
#' per-section canvas dimensions apply only in `"pile"` mode.
#'
#' @section Backends:
#' The backend is set in [initialize_doc()]. `"patchwork"` composes each section
#' with patchwork and renders it; the architecture dispatches on the backend, so
#' other backends can interpret the same recorded layouts differently in future.
#'
#' @seealso
#'   [initialize_doc()] to begin a document; [layout_section()] to lay out its
#'   sections; [preview_section()] to preview a section before assembling.
#'
#' @examples
#' \dontrun{
#' report |>
#'   initialize_doc() |>
#'   layout_section("estimates", .patchwork_syntax = sec_txt + sec_fig) |>
#'   layout_section("robustness", .patchwork_syntax = sec_tbl) |>
#'   generate_docs(file = "report.pdf")
#' }
#'
#' @export
generate_docs <-
  function(
    .doc,
    file = NULL,
    output = c("single", "pile"),
    extension = "png",
    dir = "multitool_report"
  ) {

    output   <- match.arg(output)
    settings <- .doc$settings
    grid     <- .doc$grid

    not_laid <- grid |> dplyr::filter(!laid_out) |> dplyr::pull(sec_id)
    if (length(not_laid) > 0) {
      stop(
        "These sections were initialized but never laid out via ",
        "layout_section(): ", paste(not_laid, collapse = ", "),
        call. = FALSE
      )
    }

    resolved <-
      grid |>
      dplyr::mutate(
        eff_margin    = list(settings$margin),
        eff_meta_sizes = section_meta_sizes,
        eff_txt_size = section_txt_size,
        eff_width =
          if (output == "pile")
            dplyr::coalesce(section_width,  settings$canvas_width)
        else settings$canvas_width,
        eff_height =
          if (output == "pile")
            dplyr::coalesce(section_height, settings$canvas_height)
        else settings$canvas_height
      )

    switch(
      settings$backend,
      patchwork = render_patchwork(resolved, settings, output, file, dir),
      stop("Unknown backend: ", settings$backend, call. = FALSE)
    )
  }
