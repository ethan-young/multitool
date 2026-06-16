# Add a content section to a report

Defines a section of a report by attaching content-generating code to an
analysis grid. A section bundles up to three kinds of content — text, a
table, and a figure — each produced by a function applied to the
section's gathered data. Sections accumulate: piping one `add_section()`
into the next builds a multi-section report grid.

## Usage

``` r
add_section(
  .report,
  id = "",
  title = "",
  description = "",
  report_data,
  txt.fn = NULL,
  tbl.fn = NULL,
  fig.fn = NULL,
  .by = NULL
)
```

## Arguments

- .report:

  A named analysis grid (e.g. an analyzed decision grid), or the result
  of a previous `add_section()` call to append to. `add_section()`
  re-evaluates against the grid by name, so the grid must be a named
  object in the calling environment.

- id:

  A short identifier for the section, used later to lay it out and
  assemble it (e.g. `"robustness"`). Should be unique within a report.

- title, description:

  Section heading text. Processed with
  [`glue::glue()`](https://glue.tidyverse.org/reference/glue.html), so
  they may interpolate `.by` columns to vary per subsection.

- report_data:

  A code expression — usually a
  [`compose_view()`](https://ethan-young.github.io/multitool/reference/compose_view.md)
  call — applied to the grid to gather this section's data into a single
  data frame. This data frame is what each content function receives.

- txt.fn, tbl.fn, fig.fn:

  Content functions, each taking the `report_data` data frame as its
  first argument and returning one rendered object: `txt.fn` a text
  string, `tbl.fn` a table (`data.frame`, `gt`, or `flextable`),
  `fig.fn` a figure (`ggplot` or `patchwork`). Must be written as a call
  (with parentheses), since the data is piped in. Any may be `NULL`; an
  omitted content type yields an empty slot and is skipped when the
  section is rendered.

- .by:

  Columns that split the section into subsections, one per unique
  combination. When `NULL`, the section is a single unit.

## Value

A report grid (a tibble) with one row per subsection, carrying the
section's id, the realized `sec_txt`/`sec_tbl`/`sec_fig` content, a
nested `code` column holding the generating code for each, and
per-subsection titles and descriptions. The originating grid name is
recorded as an `"analysis_grid"` attribute so successive `add_section()`
calls can chain.

## Details

The content functions (`txt.fn`, `tbl.fn`, `fig.fn`) are captured as
code, recorded so the section remains a transparent, auditable artifact,
then run against the section's data to realize the actual text, table,
and figure objects. Both the realized content and the generating code
are stored, so a section can be rendered *and* inspected.

Each content slot stores both the realized object (`sec_txt`, `sec_tbl`,
`sec_fig`) and its code (nested under `code`), supporting the package's
code-as-artifact principle: a section can be rendered into a report and
also read back as the exact code that produced it.

Content functions have access only to the gathered section data, not to
the section's metadata fields — a figure title, for instance, belongs
inside `fig.fn`, while a section- or slide-level heading belongs in
`title`.

## Section content

gather, then distil: A section is built in two steps. First,
`report_data` gathers the data the section needs from the grid —
typically a
[`compose_view()`](https://ethan-young.github.io/multitool/reference/compose_view.md)
call that joins the relevant unpacked results into a single data frame.
Second, each content function (`txt.fn`, `tbl.fn`, `fig.fn`) receives
that gathered data frame as its first argument and distils it into one
rendered object: a text string, a table, or a figure.

So the flow is always: `report_data` produces the section's data frame,
and each content function consumes that same data frame. A content
function is written as code that takes the `compose_view` output as its
first argument — for example `fig.fn = ggplot(aes(...)) + geom_point()`,
or a call to a named function whose first argument is the data, written
with parentheses as `fig.fn = make_spec_curve()` so it sits correctly
after the pipe. Because the data is piped into the content function, the
function must be written as a call (with parentheses), not a bare name.

A section need not have all three content types. Any of `txt.fn`,
`tbl.fn`, or `fig.fn` may be left `NULL`, in which case that content
slot is empty (stored as `NULL`) and simply omitted wherever the section
is rendered. A figure-only section, a table-plus-text section, or any
combination is valid.

## Sections and subsections

When `.by` is supplied, the section is *fanned out* into one subsection
per unique combination of the `.by` columns. Each subsection receives
its own filtered slice of the grid and its own title and description.
Because `title` and `description` are processed with
[`glue::glue()`](https://glue.tidyverse.org/reference/glue.html), they
can reference the `.by` columns to produce per-subsection labels — for
example, `title = "Results for {outcome}"` yields a distinct title per
`outcome`.

Without `.by`, the section is a single unit with one title and
description, and glue interpolation of the `.by` columns does not apply
(there are no subsections to vary over).

## See also

[`compose_view()`](https://ethan-young.github.io/multitool/reference/compose_view.md)
for gathering results for section reporting;
[`show_section_content()`](https://ethan-young.github.io/multitool/reference/show_section_content.md)
to inspect one section's realized content and code;
[`preview_section()`](https://ethan-young.github.io/multitool/reference/preview_section.md)
to preview a section's composed layout;
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
and
[`generate_docs()`](https://ethan-young.github.io/multitool/reference/generate_docs.md)
to assemble sections into a document.

## Examples

``` r
if (FALSE) { # \dontrun{
# A figure-only section, fanned out by outcome
report <-
  analyzed_grid |>
  add_section(
    id          = "estimates",
    title       = "Effect estimates for {outcome}",
    description = "Distribution across specifications",
    report_data = compose_view(model_parameters, model_performance),
    fig.fn      = make_spec_curve(),
    .by         = outcome
  )

# Chain a table-only section onto the same report
report <-
  report |>
  add_section(
    id          = "robustness",
    title       = "Robustness summary",
    report_data = compose_view(rob = assess_robustness),
    tbl.fn      = gt::gt()
  )
} # }
```
