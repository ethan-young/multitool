# Preview a figure at its true output size

Renders a figure to a temporary file at exact physical dimensions and
opens it, so what you see matches what will be exported — sidestepping
the RStudio plot pane, which rescales figures to its own dimensions and
is a poor guide to how a figure will actually look at its intended size.

## Usage

``` r
view_real_size(
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
)
```

## Arguments

- .fig:

  A `ggplot` or `patchwork` object to preview.

- mode:

  `"figure"` (default) to render at an exact `width`/`height`, or
  `"slide"` to place the figure on a slide canvas and estimate its
  dimensions.

- width, height:

  Figure dimensions in inches. Required in `"figure"` mode; ignored in
  `"slide"` mode (the canvas is derived from `asp_ratio`).

- asp_ratio:

  Slide aspect ratio in `"slide"` mode: `"wide"` (16:9, default) or
  `"full"` (4:3).

- anchor_height:

  The slide height in inches in `"slide"` mode (default `7.5`); the
  width is this times the aspect ratio.

- design:

  A patchwork layout design string placing the figure on the slide (e.g.
  `"A"` for full-bleed, `"#AA"` to occupy the right two-thirds with
  reserved blank space). `"slide"` mode only; defaults to `"A"`.

- dpi:

  Resolution for the rendered preview (default `96`).

- margin:

  A
  [`ggplot2::margin()`](https://ggplot2.tidyverse.org/reference/element.html)
  giving the slide margin in `"slide"` mode, in any unit; converted to
  inches and subtracted from the canvas when estimating implied
  dimensions.

- frame:

  If `TRUE` (default), draw a border around the slide in `"slide"` mode
  so the canvas edges and content boundaries are visible while
  previewing.

- give_dims:

  If `TRUE` (default), print the implied figure dimensions in `"slide"`
  mode.

- title, subtitle:

  Optional slide title and subtitle text in `"slide"` mode. Note these
  are not accounted for in the implied-dimension estimate (see the
  slide-mode section).

- meta_pt_sizes:

  Point sizes for the slide `title` and `subtitle`, as a length-2
  numeric (default `c(24, 16)`).

## Value

Invisibly, the sized object: in `"figure"` mode the figure as given; in
`"slide"` mode the figure placed on its canvas. Called primarily for the
side effect of opening the rendered preview, and in `"slide"` mode for
the printed dimension estimate.

## Details

All dimensions are in **inches**, matching the units used by the output
devices these previews stand in for (PDF,
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html),
slides). If you think in centimetres or millimetres, convert before
passing dimensions (e.g. 10 cm is about 3.94 in). The one exception is
`margin`, which may be given in any unit via
[`ggplot2::margin()`](https://ggplot2.tidyverse.org/reference/element.html)
and is converted to inches for you.

Two modes serve two purposes. In `"figure"` mode, the figure is rendered
at the exact `width` and `height` you specify — use this to judge a
figure at its real export dimensions and dial in a size before saving.
In `"slide"` mode, the figure is placed onto a slide-shaped canvas via a
layout `design`, with an optional margin and title — use this to see how
a figure will sit on a slide, and to get an estimate of the dimensions
it should be exported at to fill its region of that slide.

## Figure mode — exact sizing

`mode = "figure"` requires `width` and `height` in inches and renders
the figure to fill exactly that canvas. This is the tool for "what does
this plot look like at 6 by 4 inches?" — render, look, adjust, repeat,
then export at the size that looked right.

## Slide mode — placement and dimension estimation

`mode = "slide"` builds a slide canvas from `asp_ratio` and
`anchor_height` (slides are conventionally `anchor_height` inches tall;
width follows the aspect ratio), places the figure on it according to
`design`, and reports the *implied dimensions*: how large the figure
itself is within its region of the slide, after the margin is
subtracted. Those implied dimensions are what you would pass back to
`mode = "figure"` (or to
[`ggplot2::ggsave()`](https://ggplot2.tidyverse.org/reference/ggsave.html))
to export the figure standalone at the size it occupies on the slide.

The implied-dimension estimate assumes the figure has no slide title or
subtitle. When a `title` or `subtitle` is supplied, it occupies space
the estimate cannot account for, and `view_real_size()` says so. To
reserve room for a title without distorting the estimate, add top
`margin` rather than a title: the margin is subtracted exactly, so it
gives a clean, controllable approximation of the space a heading will
take.

## See also

[`preview_section()`](https://ethan-young.github.io/multitool/reference/preview_section.md),
which uses slide mode to preview a report section's composed layout.

## Examples

``` r
if (FALSE) { # \dontrun{
# Figure mode: see a plot at exactly 6 by 4 inches
view_real_size(my_plot, mode = "figure", width = 6, height = 4)

# Slide mode: place a figure in the right two-thirds of a 16:9 slide
# and get the dimensions to export it at
view_real_size(my_plot, mode = "slide", design = "#AA")

# Reserve space for a heading via top margin rather than a title,
# to keep the dimension estimate clean
view_real_size(
  my_plot,
  mode   = "slide",
  margin = ggplot2::margin(1, 0, 0, 0, "in")
)
} # }
```
