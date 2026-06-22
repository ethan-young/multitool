# Inspect one section's content and code

Prints a single content type — figure, text, or table — for one
subsection of a report, along with the code that produced it. This is
the granular inspector for report content: where
[`preview_section()`](https://ethan-young.github.io/multitool/reference/preview_section.md)
composes all of a section's content into a laid-out slide,
`show_section_content()` isolates a single channel of a single
subsection so it can be examined on its own and its generating code read
back.

## Usage

``` r
show_section_content(
  .report,
  section,
  sub_section = NULL,
  content = c("fig", "txt", "tbl")
)
```

## Arguments

- .report:

  A report grid produced by
  [`add_section()`](https://ethan-young.github.io/multitool/reference/add_section.md).

- section:

  The `id` of the section to inspect.

- sub_section:

  The `sec_sub_id` of the subsection to show. If `NULL` (default), a
  subsection is sampled at random.

- content:

  Which content channel to show: `"fig"` (default), `"txt"`, or `"tbl"`.

## Value

The realized content object for the chosen channel and subsection,
returned invisibly. Called primarily for its console output: the
section's id, subsection, title, and description, followed by the
content itself (figures render to the plot pane) and its styled
generating code.

## Details

If no subsection is named, one is chosen at random — useful for
spot-checking that a section's content function generalizes across the
subsections it was fanned out into.

The printed code is run through
[`styler::style_text()`](https://styler.r-lib.org/reference/style_text.html)
so it reads cleanly, reflecting the package's code-as-artifact principle
— the content shown and the code that produced it are inspected
together.

Because the realized content object is returned invisibly, it can also
be captured for further use, e.g.
`fig <- show_section_content(report, "estimates")`.

## See also

[`preview_section()`](https://ethan-young.github.io/multitool/reference/preview_section.md)
to preview a section's full composed layout;
[`add_section()`](https://ethan-young.github.io/multitool/reference/add_section.md)
to create the sections this inspects.

## Examples

``` r
if (FALSE) { # \dontrun{
# Show a randomly sampled subsection's figure and its code
show_section_content(report, section = "estimates")

# Inspect a specific subsection's table
show_section_content(
  report,
  section     = "robustness",
  sub_section = 2,
  content     = "tbl"
)

# Capture the returned object
fig <- show_section_content(report, "estimates", content = "fig")
} # }
```
