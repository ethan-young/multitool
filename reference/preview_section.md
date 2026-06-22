# Preview a report section's composed layout

Composes one subsection of a section — its text, table, and figure
arranged by a patchwork layout — and previews it on a slide canvas at
true size. This is the report-facing previewer: where
[`view_real_size()`](https://ethan-young.github.io/multitool/reference/view_real_size.md)
previews an arbitrary figure, `preview_section()` pulls a section's
content from the report grid, composes it, and shows how it will look as
a slide, so a layout can be validated before assembling the full
document.

## Usage

``` r
preview_section(
  .report,
  section,
  sub_section = NULL,
  add_title = TRUE,
  add_desc = TRUE,
  codify = TRUE,
  patchwork_syntax = NULL,
  mode = "slide",
  inner_design = NULL,
  outer_design = "A",
  txt_size = 6,
  ...
)
```

## Arguments

- .report:

  A report grid produced by
  [`add_section()`](https://ethan-young.github.io/multitool/reference/add_section.md).

- section:

  The `id` of the section to preview.

- sub_section:

  The `sec_sub_id` to preview. If `NULL` (default), one is sampled at
  random.

- add_title, add_desc:

  Whether to show the section's title and description as slide
  annotations (default `TRUE` for both). The text comes from the
  section's stored title and description; empty values are omitted.

- codify:

  Whether to print a call to `layout_section` based on preview settings.
  Defaults to `TRUE`.

- patchwork_syntax:

  Patchwork syntax composing the section's content slots — `sec_txt`,
  `sec_tbl`, `sec_fig` — e.g. `sec_txt + sec_fig`. Slots that are empty
  for this section render as blank spacers.

- mode:

  Passed to
  [`view_real_size()`](https://ethan-young.github.io/multitool/reference/view_real_size.md)
  as `mode`; `"slide"` (default) previews the composition placed on a
  slide canvas.

- inner_design:

  Optional patchwork design string arranging the content slots (the
  *inner* layout). Applies only when `.patchwork_syntax` uses no
  positional operators (`|`, `/`); see
  [`view_real_size()`](https://ethan-young.github.io/multitool/reference/view_real_size.md)
  and patchwork's layout documentation.

- outer_design:

  Patchwork design string placing the composed section on the slide (the
  *outer* layout); defaults to `"A"` (full-bleed).

- txt_size:

  The size of text to appear when a composition contains a textual
  section. Defaults to 6.

- ...:

  Passed to
  [`view_real_size()`](https://ethan-young.github.io/multitool/reference/view_real_size.md)
  — e.g. `asp_ratio`, `anchor_height`, `dpi`, `margin`, `pt_sizes` — to
  control the slide canvas and styling.

## Value

Invisibly, the composed section placed on its slide canvas (as returned
by
[`view_real_size()`](https://ethan-young.github.io/multitool/reference/view_real_size.md)).
Called primarily to open the preview.

## Details

If no subsection is named, one is chosen at random — a check that the
section's layout generalizes across all the subsections it was fanned
out into, not just one.

Unlike a standalone
[`view_real_size()`](https://ethan-young.github.io/multitool/reference/view_real_size.md)
call, `preview_section()` previews without the canvas border and without
printing implied dimensions: a section preview is about confirming the
*composition and placement*, not sizing a figure for export, so those
standalone aids are turned off here.

## Inner and outer layout

A section preview involves two layouts. The *inner* layout
(`.patchwork_syntax` with `.inner_design`) arranges the section's own
content — text, table, figure — into a composition, using patchwork
syntax over the slot names `sec_txt`, `sec_tbl`, and `sec_fig`. The
*outer* layout (`.outer_design`) then places that whole composition onto
the slide canvas, typically full-bleed (`"A"`) or in a region with
reserved space (e.g. `"#AA"`).

The inner layout is what the section *contains*; the outer layout is
where it *sits* on the slide. Most previews set only the inner
arrangement and leave the outer at `"A"` (the composition fills the
slide); the outer design matters when you want the content to occupy
part of the slide and leave the rest blank.

## See also

[`view_real_size()`](https://ethan-young.github.io/multitool/reference/view_real_size.md)
for the underlying previewer and its slide-canvas controls;
[`show_section_content()`](https://ethan-young.github.io/multitool/reference/show_section_content.md)
to inspect a single content channel and its code;
[`add_section()`](https://ethan-young.github.io/multitool/reference/add_section.md)
to create sections;
[`layout_section()`](https://ethan-young.github.io/multitool/reference/layout_section.md)
to record a section's layout for assembly.

## Examples

``` r
if (FALSE) { # \dontrun{
# Preview a section's figure-and-text composition, full-bleed
preview_section(
  report,
  section           = "estimates",
  patchwork_syntax = sec_txt + sec_fig,
  inner_design     = "AABB"
)

# Preview with the section title shown, content in the right two-thirds
preview_section(
  report,
  section           = "estimates",
  add_title         = TRUE,
  patchwork_syntax = sec_fig,
  outer_design     = "#AA"
)
} # }
```
