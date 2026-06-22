# Begin assembling a report document

Starts a document from one or more report grids, producing a document
grid that subsequent
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
calls fill in and
[`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md)
renders. This is the head of the assembly chain: gather your built
sections here, lay each one out, then generate.

## Usage

``` r
initialize_doc(
  ...,
  default_asp_ratio = "wide",
  default_height = 7.5,
  default_width = NULL,
  default_dpi = 96,
  default_margin = ggplot2::margin(0, 0, 0, 0, "in")
)
```

## Arguments

- ...:

  One or more report grids, each built with
  [`add_section()`](https://ethan-young.github.io/multitool/reference/add_section.md).
  Section ids must be unique across all supplied grids.

- default_asp_ratio:

  Default slide aspect ratio: `"wide"` (16:9, default) or `"full"`
  (4:3). Used to derive the canvas width from `default_height` when
  `default_width` is not given.

- default_height:

  Default slide height in inches (default `7.5`).

- default_width:

  Optional explicit slide width in inches. When `NULL` (default), the
  width is derived from `default_height` and `default_asp_ratio`.

- default_dpi:

  Default rendering resolution (default `96`).

- default_margin:

  Default slide margin, a
  [`ggplot2::margin()`](https://ggplot2.tidyverse.org/reference/element.html)
  object (default zero on all sides). May be given in any unit.

## Value

A document grid: a tibble with one row per section, the section's
subsections nested in a `content` column, the document-level defaults
denormalized across rows as `doc_*` columns (aspect ratio, dpi, margin,
canvas width and height), and the per-section layout columns initialized
empty (to be filled by
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md))
with a `laid_out` flag set `FALSE`. The names of the originating
analysis grids are recorded in an `"analysis_grids"` attribute, so the
grids can be shipped to workers if
[`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md)
renders in parallel.

## Details

Multiple report grids may be supplied. This supports the common case
where a single research question spans several analysis pipelines whose
decision spaces diverge enough to be built separately, yet belong in one
document. The grids are combined into a single universe of sections, and
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
and
[`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md)
treat them uniformly thereafter.

Section ids must be unique across all supplied grids, since
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
and
[`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md)
address sections by id. If the same id appears in more than one grid,
`initialize_doc()` stops and reports the collisions, so the ambiguity is
caught at assembly time rather than producing a confusing result later.

Each section begins un-laid-out; it must be passed through
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
before
[`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md)
can render it.

## Document-level defaults

The settings given here — aspect ratio, height, width, dpi, margin — are
the document's defaults, applied to every section unless a section
overrides them in
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md).
The canvas is sized once for the whole document: slides are
`default_height` inches tall, with width either given explicitly via
`default_width` or derived from the aspect ratio, so a single-document
output is a uniform deck. The rendering backend and output mode are
*not* set here; they are chosen later, at
[`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md).

## See also

[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
to specify each section's layout;
[`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md)
to render the assembled document;
[`add_section()`](https://ethan-young.github.io/multitool/reference/add_section.md)
to build the report grids supplied here.

## Examples

``` r
if (FALSE) { # \dontrun{
# Single grid
doc <-
  report |>
  initialize_doc(
    default_asp_ratio = "wide",
    default_margin    = ggplot2::margin(0.5, 0.5, 0.5, 0.5, "in")
  )

# Multiple grids from divergent pipelines, one document
doc <-
  initialize_doc(
    main_results,
    sensitivity_results,
    default_asp_ratio = "wide"
  )

# Continue the chain
doc <-
  doc |>
  layout_section("estimates", patchwork_syntax = sec_fig) |>
  generate_docs(file = "deck.pdf")
} # }
```
