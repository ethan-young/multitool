# Render an assembled document

Renders a document — built with
[`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md)
and laid out with
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
— into output. This is the terminal step of the assembly chain: it
renders every section's content according to the recorded layouts, then
writes the result through the chosen backend.

## Usage

``` r
generate_docs(
  .doc,
  file,
  backend = "patchwork",
  output = c("single", "multiple", "both"),
  dir = NULL,
  globals = NULL
)
```

## Arguments

- .doc:

  A laid-out document grid from the
  [`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md)
  /
  [`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
  chain.

- file:

  Output file path. In `"single"` mode this is the PDF; in `"multiple"`
  mode its extension determines the per-page file type and its stem
  names the files.

- backend:

  The rendering backend (default `"patchwork"`). Determines how each
  section's recorded layout is composed and written. The architecture
  dispatches on the backend, so other backends can interpret the same
  recorded layouts differently in future.

- output:

  One of `"single"` (default, one multi-page PDF), `"multiple"` (one
  file per page), or `"both"`.

- dir:

  Output directory for `"multiple"`/`"both"` modes. `NULL` (default)
  writes to the current directory.

- globals:

  Optional character vector of names of global objects (functions or
  data) that section content references but that cannot be auto-detected
  from the stored code. Named here, they are shipped to workers for
  parallel rendering.

## Value

Invisibly, the path(s) written. Called for the side effect of producing
the output file(s).

## Details

Before rendering, `generate_docs()` checks that every section in the
document has been laid out. It then renders each subsection's content to
a placed page object and hands those pages to the backend to write to
disk.

Every section must be laid out before rendering. If any section was
added to the document but never passed through
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md),
`generate_docs()` stops and names the un-laid-out sections, rather than
silently dropping or mis-rendering them.

Effective settings are resolved per page as a cascade: a value set on
the section in
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
takes precedence, otherwise the document default from
[`initialize_doc()`](https://ethan-young.github.io/multitool/reference/initialize_doc.md)
applies. In `"single"` mode the canvas is held uniform across all pages
(so the deck reads as a coherent whole); per-section canvas dimensions
apply only when writing a pile.

## Output modes

`output = "single"` produces one multi-page document — a deck — with
every section (and its subsections) as pages of uniform size, written as
a single PDF.

`output = "multiple"` writes each page as its own file (a "pile"), named
by section and subsection, into `dir`. The file type follows the
extension of `file`. Per-section dimensions from
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
take effect in this mode.

`output = "both"` produces the single PDF *and* the pile of per-page
files.

## Parallel rendering

If [`mirai::daemons()`](https://mirai.r-lib.org/reference/daemons.html)
have been provisioned before calling `generate_docs()`, content
rendering (and, for `"multiple"`/`"both"`, file writing) is distributed
across the daemons; otherwise it runs sequentially. Parallelism helps
for large documents and adds overhead for small ones, so it is opt-in
via daemon provisioning rather than on by default. When rendering in
parallel, the daemons must have the same graphical session setup as the
host — in particular any custom theme (e.g. via
[`theme_set()`](https://ggplot2.tidyverse.org/reference/get_theme.html))
and fonts — or pages will render against the workers' defaults.
Replicate that setup on the daemons with
[`mirai::everywhere()`](https://mirai.r-lib.org/reference/everywhere.html)
before generating.

Functions and objects that a section's content code references are
shipped to the workers automatically when they can be detected from the
stored code; anything that cannot be detected (for example a data object
referenced indirectly) can be named in `globals`.

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
  layout_section("estimates", patchwork_syntax = sec_txt + sec_fig) |>
  layout_section("robustness", patchwork_syntax = sec_tbl) |>
  generate_docs(file = "report.pdf")
} # }
```
