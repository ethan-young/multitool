# Configure human-readable labels for pipeline decisions

Attaches or updates a table of display labels for the groups and
alternatives in a decision pipeline. Labels are stored as a `"labels"`
attribute on the object and are used downstream wherever decisions need
human-readable names rather than raw code.

## Usage

``` r
configure_labels(.results, ...)
```

## Arguments

- .results:

  An expanded or analyzed decision grid carrying a `"pipeline"`
  attribute (or an existing `"labels"` attribute from a prior call).

- ...:

  Named overrides of the form `group = "Label"` or `code = "Label"`.
  Names matching a group update the group label (and cascade to its
  do-nothing filter); names matching a code update that alternative's
  label. Names matching neither are skipped with a warning.

## Value

`.results`, unchanged except for an updated `"labels"` attribute.

## Details

On first use, `configure_labels()` derives a default label table from
the object's `"pipeline"` attribute: each group is labelled with its own
name, and each alternative with its code. Do-nothing filters (detected
by the `%in% unique` pattern) are given the label
`"No filter on {group}"`, and model alternatives are labelled with their
group name. Subsequent calls update this table.

Overrides are supplied as named arguments in `...`, where each name is a
group or a code and each value is the desired label. Relabelling a group
also cascades to that group's do-nothing filter label, so renaming a
group keeps its "No filter on ..." alternative consistent automatically.

Keys containing spaces must be back-quoted when passed in `...`, e.g.
`` `my group` = "My Group" ``. Unmatched keys do not error; they emit a
warning and are ignored, so a typo in one label does not abort the call.

## See also

[`show_labels()`](https://ethan-young.github.io/multitool/reference/show_labels.md)
to inspect the current label table or print a ready-to-edit
`configure_labels()` call.

## Examples

``` r
if (FALSE) { # \dontrun{
results |>
  configure_labels(
    covariates = "Covariate set",
    `iv ~ dv`  = "Unadjusted model"
  )
} # }
```
