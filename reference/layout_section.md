# Record a section's layout for assembly

Specifies how one section should be composed and placed when the
document is rendered, writing that layout into the document begun by
[`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md).
This is the middle of the assembly chain: it records intent — the
patchwork syntax, the inner and outer designs, whether to show the title
and description — without rendering anything. Rendering happens later,
all at once, in
[`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md).

## Usage

``` r
layout_section(
  .doc,
  section,
  patchwork_syntax = NULL,
  inner_design = NULL,
  outer_design = "A",
  add_title = TRUE,
  add_desc = TRUE,
  meta_pt_sizes = c(24, 16),
  txt_size = 6,
  txt_family = NULL,
  sec_margin = NULL,
  height = NULL,
  width = NULL
)
```

## Arguments

- .doc:

  A document grid from
  [`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md).

- section:

  The `id` of the section to lay out. Must exist in the document.

- patchwork_syntax:

  Patchwork syntax composing the section's content slots — `sec_txt`,
  `sec_tbl`, `sec_fig` — e.g. `sec_txt + sec_fig`. Written unquoted;
  captured as code.

- inner_design:

  Optional patchwork design string arranging the content slots (the
  *inner* layout). Applies when `patchwork_syntax` uses no positional
  operators (`|`, `/`). `NULL` (default) leaves arrangement to the
  syntax.

- outer_design:

  Patchwork design string placing the composed section on the page (the
  *outer* layout); defaults to `"A"` (full-bleed).

- add_title, add_desc:

  Whether to show the section's title and description when rendered
  (default `TRUE` for both).

- meta_pt_sizes:

  Point sizes for the title and description, as a length-2 numeric
  (default `c(24, 16)`).

- txt_size:

  Point size for a textual content slot, if any (default `6`).

- txt_family:

  Font family for a textuial content slot.

- sec_margin:

  Optional per-section margin, given unquoted as a
  [`ggplot2::margin()`](https://ggplot2.tidyverse.org/reference/element.html)
  call (e.g. `margin(0.5, 0.5, 0.5, 0.5, "in")`); captured as code and
  applied when this section is placed. `NULL` (default) uses the
  document margin from
  [`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md).

- height, width:

  Optional per-section canvas dimensions in inches, used when writing a
  pile (`output = "multiple"`/`"both"` in
  [`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md)):
  they override the document canvas for this section's standalone file.
  In single-PDF output the canvas is uniform and these are ignored.
  `NULL` (default) uses the document canvas.

## Value

The document grid, with this section's layout recorded and its
`laid_out` flag set `TRUE`. Returned so `layout_section()` calls can be
chained.

## Details

`layout_section()` is chainable: pipe one call into the next to lay out
each section in turn, building the document's structure as a readable
sequence of calls.

Layout settings left at their `NULL`/default are recorded as missing, so
that
[`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md)
can fall through to the document-level defaults set in
[`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md).
This cascade — section setting if given, document default otherwise —
lets most sections inherit a consistent look while individual sections
override what they need.

A section must be laid out before it can be rendered;
[`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md)
will report any section that was added to the document but never passed
through `layout_section()`.

## Inner and outer layout

Each section has two layouts, the same distinction used in
[`preview_section()`](https://ethan-young.github.io/multitool/reference/preview_section.md).
The *inner* layout (`patchwork_syntax` with `inner_design`) arranges the
section's own content — `sec_txt`, `sec_tbl`, `sec_fig` — into a
composition. The *outer* layout (`outer_design`) places that composition
onto the page, full-bleed (`"A"`, the default) or in a region with
reserved space (e.g. `"#AA"`).

The layout recorded here is applied to *every* subsection of the section
when the document is generated, so a section fanned out into many
subsections is composed consistently across all of them.

## See also

[`preview_section()`](https://ethan-young.github.io/multitool/reference/preview_section.md)
to preview a single section's layout before recording it — and to print
a ready-to-paste `layout_section()` call codifying that preview;
[`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md)
to begin the document;
[`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md)
to render it.

## Examples

``` r
if (FALSE) { # \dontrun{
doc <-
  report |>
  initialize_doc() |>
  layout_section(
    "estimates",
    patchwork_syntax = sec_txt + sec_fig,
    inner_design     = "AABB"
  ) |>
  layout_section(
    "robustness",
    patchwork_syntax = sec_tbl,
    add_desc         = FALSE
  )
} # }
```
