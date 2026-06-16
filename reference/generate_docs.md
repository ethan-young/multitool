# Render an assembled document

Renders a document — built with
[`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md)
and laid out with
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
— into output. This is the terminal step of the assembly chain: it
composes every section's content according to the recorded layouts and
produces the final artifact.

## Usage

``` r
generate_docs(
  .doc,
  file = NULL,
  output = c("single", "pile"),
  extension = "png",
  dir = "multitool_report"
)
```

## Arguments

- .doc:

  A laid-out document object from the
  [`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md)
  /
  [`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
  chain.

- file:

  Output file path for `"single"` mode (e.g. `"report.pdf"`).

- output:

  `"single"` (default) for one multi-page deck, or `"pile"` for one file
  per section (in development).

- extension:

  File extension for `"pile"` mode (default `"png"`).

- dir:

  Output directory for `"pile"` mode (default `"multitool_report"`).

## Value

Invisibly, the path(s) written. Called for the side effect of producing
the output file(s).

## Details

Before rendering, `generate_docs()` checks that every section in the
document has been laid out, resolves each section's effective settings
(section overrides falling through to document defaults), and hands the
result to the backend named in
[`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md).

Every section must be laid out before rendering. If any section was
added to the document but never passed through
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md),
`generate_docs()` stops and names the un-laid-out sections, rather than
silently dropping or mis-rendering them.

Effective settings are resolved per section as a cascade: a value set on
the section in
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
takes precedence, otherwise the document default from
[`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md)
applies. In `"single"` mode the canvas is held uniform across all pages
(so the deck reads as a coherent whole); per-section canvas dimensions
apply only in `"pile"` mode.

## Output modes

`output = "single"` produces one multi-page document — a deck — with
every section (and its subsections) as pages of uniform size. This is
the working mode for the patchwork backend, rendering a single PDF.

`output = "pile"` is *in development*: it will render each section as an
independent file (using `extension` and `dir`), the mode in which
per-section dimensions from
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
take effect.

## Backends

The backend is set in
[`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md).
`"patchwork"` composes each section with patchwork and renders it; the
architecture dispatches on the backend, so other backends can interpret
the same recorded layouts differently in future.

## See also

[`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md)
to begin a document;
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
to lay out its sections;
[`preview_section()`](https://ethan-young.github.io/multitool/reference/preview_section.md)
to preview a section before assembling.

## Examples

``` r
if (FALSE) { # \dontrun{
report |>
  initialize_doc() |>
  layout_section("estimates", .patchwork_syntax = sec_txt + sec_fig) |>
  layout_section("robustness", .patchwork_syntax = sec_tbl) |>
  generate_docs(file = "report.pdf")
} # }
```
