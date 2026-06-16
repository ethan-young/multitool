# Inspect or scaffold pipeline labels

Prints the current label table attached to an object by
[`configure_labels()`](https://ethan-young.github.io/multitool/reference/configure_labels.md),
or — with `.code = TRUE` — prints a ready-to-edit
[`configure_labels()`](https://ethan-young.github.io/multitool/reference/configure_labels.md)
call pre-filled with every group and alternative, so the labels can be
customized by editing and re-running rather than typed from scratch.

## Usage

``` r
show_labels(.object, .code = FALSE)
```

## Arguments

- .object:

  An object carrying a `"labels"` attribute (i.e. one that has been
  passed through
  [`configure_labels()`](https://ethan-young.github.io/multitool/reference/configure_labels.md)).

- .code:

  If `FALSE` (default), print the label table. If `TRUE`, print a
  [`configure_labels()`](https://ethan-young.github.io/multitool/reference/configure_labels.md)
  call listing every group and alternative as an editable starting
  point.

## Value

`.object`, invisibly and unchanged. Called for its printed output.

## Details

In `.code = TRUE` mode the output is split into a "Groups" block and an
"Alternatives" block. Do-nothing filters are omitted from the
alternatives block, since their labels are managed automatically by the
group cascade in
[`configure_labels()`](https://ethan-young.github.io/multitool/reference/configure_labels.md).
Keys containing spaces are back-quoted so the printed call is valid to
paste back in.

## See also

[`configure_labels()`](https://ethan-young.github.io/multitool/reference/configure_labels.md)
to set the labels this function displays.

## Examples

``` r
if (FALSE) { # \dontrun{
results |> configure_labels() |> show_labels()

# Print an editable scaffold of every label:
results |> configure_labels() |> show_labels(.code = TRUE)
} # }
```
