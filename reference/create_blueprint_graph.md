# Create a Analysis Pipeline diagram

Create a Analysis Pipeline diagram

## Usage

``` r
create_blueprint_graph(
  .pipeline,
  splines = "line",
  render = TRUE,
  show_code = FALSE,
  ...
)
```

## Arguments

- .pipeline:

  a `data.frame` produced by calling a series of add\_\* functions.

- splines:

  options for how to draw edges (lines) for a grViz diagram

- render:

  whether to render the graph or just output grViz code

- show_code:

  whether to show the code that generated the diagram

- ...:

  additional options passed to
  [`DiagrammeR::grViz()`](https://rich-iannone.github.io/DiagrammeR/reference/grViz.html)

## Value

grViz graph of your pipeline

## Examples

``` r
library(tidyverse)
library(multitool)

# create some data
the_data <-
  data.frame(
    id  = 1:500,
    iv1 = rnorm(500),
    iv2 = rnorm(500),
    iv3 = rnorm(500),
    mod = rnorm(500),
    dv1 = rnorm(500),
    dv2 = rnorm(500),
    include1 = rbinom(500, size = 1, prob = .1),
    include2 = sample(1:3, size = 500, replace = TRUE),
    include3 = rnorm(500)
  )

# create a pipeline blueprint
full_pipeline <-
  the_data |>
  add_filters(include1 == 0, include2 != 3, include3 > -2.5) |>
  add_variables(var_group = "ivs", iv1, iv2, iv3) |>
  add_variables(var_group = "dvs", dv1, dv2) |>
  add_model("linear model", lm({dvs} ~ {ivs} * mod))

create_blueprint_graph(full_pipeline)
#> No subgroups in your pipeline
#> no descriptives
#> you have no preprocessing steps in your pipeline
#> you have no post processing steps in your pipeline

{"x":{"diagram":"digraph {\n\ngraph [layout = \"dot\",\n       outputorder = \"edgesfirst\",\n       bgcolor = \"white\",\n       splines = \"line\",\n       overlap = \"false\"]\n\nnode [fontname = \"Helvetica\",\n      fontsize = \"10\",\n      shape = \"rect\",\n      fixedsize = \"false\",\n      width = \"0.5\",\n      style = \"rounded\",\n      fillcolor = \"aliceblue\",\n      color = \"gray\",\n      fontcolor = \"black\",\n      margin = \".25, 0\"]\n\nedge [fontname = \"Helvetica\",\n     fontsize = \"8\",\n     len = \"1.5\",\n     color = \"gray80\",\n     arrowsize = \"0.5\",\n     tailport = \"s\",\n     headport = \"n\",\n     concentrate = \"false\",\n     constraint = \"true\"]\n\n  \"1\" [label = <<BR/><B>Base Dataset<\/B><BR ALIGN=\"LEFT\"/><BR ALIGN=\"LEFT\"/>the_data<BR/> >] \n  \"2\" [label = <<BR/><B>Variables<\/B><BR/><BR/>2 sets<BR/>(2*3 = 6)<BR ALIGN=\"LEFT\"/> >] \n  \"3\" [label = <<BR/><B>dvs<\/B><BR ALIGN=\"LEFT\"/>&#x2022; dv1<BR ALIGN=\"LEFT\"/>&#x2022; dv2<BR ALIGN=\"LEFT\"/><BR ALIGN=\"LEFT\"/><B>ivs<\/B><BR ALIGN=\"LEFT\"/>&#x2022; iv1<BR ALIGN=\"LEFT\"/>&#x2022; iv2<BR ALIGN=\"LEFT\"/>&#x2022; iv3<BR ALIGN=\"LEFT\"/> >] \n  \"4\" [label = <<BR/><B>Filters<\/B><BR/><BR/>3 sets<BR/>(2*2*2 = 8)<BR ALIGN=\"LEFT\"/> >] \n  \"5\" [label = <<BR/><B>include1<\/B><BR ALIGN=\"LEFT\"/>&#x2022; include1 equals 0<BR ALIGN=\"LEFT\"/>&#x2022; include1 is any value<BR ALIGN=\"LEFT\"/><BR ALIGN=\"LEFT\"/><B>include2<\/B><BR ALIGN=\"LEFT\"/>&#x2022; include2 does not equal 3<BR ALIGN=\"LEFT\"/>&#x2022; include2 is any value<BR ALIGN=\"LEFT\"/><BR ALIGN=\"LEFT\"/><B>include3<\/B><BR ALIGN=\"LEFT\"/>&#x2022; include3 bigger than -2.5<BR ALIGN=\"LEFT\"/>&#x2022; include3 is any value<BR ALIGN=\"LEFT\"/> >] \n  \"6\" [label = <<BR/><B>48 analysis datasets<\/B><BR/><BR/>filters (8) * variables (6)<BR ALIGN=\"LEFT\"/> >] \n  \"7\" [label = <<BR/><B>linear model<\/B><BR/><BR/>lm({dvs} ~ {ivs} * mod)<BR ALIGN=\"LEFT\"/> >] \n  \"8\" [label = <<BR/><B>48 fitted models<\/B><BR ALIGN=\"LEFT\"/><BR ALIGN=\"LEFT\"/>(2*2*2*2*3*1)<BR/> >] \n  \"1\" [label = <<BR/><B>Base Dataset<\/B><BR ALIGN=\"LEFT\"/><BR ALIGN=\"LEFT\"/>the_data<BR/> >] \nsubgraph{rank = same\n  \"2\" [label = <<BR/><B>Variables<\/B><BR/><BR/>2 sets<BR/>(2*3 = 6)<BR ALIGN=\"LEFT\"/> >] \n  \"3\" [label = <<BR/><B>dvs<\/B><BR ALIGN=\"LEFT\"/>&#x2022; dv1<BR ALIGN=\"LEFT\"/>&#x2022; dv2<BR ALIGN=\"LEFT\"/><BR ALIGN=\"LEFT\"/><B>ivs<\/B><BR ALIGN=\"LEFT\"/>&#x2022; iv1<BR ALIGN=\"LEFT\"/>&#x2022; iv2<BR ALIGN=\"LEFT\"/>&#x2022; iv3<BR ALIGN=\"LEFT\"/> >] \n  \"4\" [label = <<BR/><B>Filters<\/B><BR/><BR/>3 sets<BR/>(2*2*2 = 8)<BR ALIGN=\"LEFT\"/> >] \n  \"5\" [label = <<BR/><B>include1<\/B><BR ALIGN=\"LEFT\"/>&#x2022; include1 equals 0<BR ALIGN=\"LEFT\"/>&#x2022; include1 is any value<BR ALIGN=\"LEFT\"/><BR ALIGN=\"LEFT\"/><B>include2<\/B><BR ALIGN=\"LEFT\"/>&#x2022; include2 does not equal 3<BR ALIGN=\"LEFT\"/>&#x2022; include2 is any value<BR ALIGN=\"LEFT\"/><BR ALIGN=\"LEFT\"/><B>include3<\/B><BR ALIGN=\"LEFT\"/>&#x2022; include3 bigger than -2.5<BR ALIGN=\"LEFT\"/>&#x2022; include3 is any value<BR ALIGN=\"LEFT\"/> >] }\n\n  \"6\" [label = <<BR/><B>48 analysis datasets<\/B><BR/><BR/>filters (8) * variables (6)<BR ALIGN=\"LEFT\"/> >] \n  \"7\" [label = <<BR/><B>linear model<\/B><BR/><BR/>lm({dvs} ~ {ivs} * mod)<BR ALIGN=\"LEFT\"/> >] \n  \"8\" [label = <<BR/><B>48 fitted models<\/B><BR ALIGN=\"LEFT\"/><BR ALIGN=\"LEFT\"/>(2*2*2*2*3*1)<BR/> >] \n\"3\"->\"2\" [style = \"invis\", style = \"invis\", style = \"invis\", headport = \"n\", tailport = \"s\"] \n\"2\"->\"4\" [style = \"invis\", style = \"invis\", style = \"invis\", headport = \"n\", tailport = \"s\"] \n\"4\"->\"5\" [style = \"invis\", style = \"invis\", style = \"invis\", headport = \"n\", tailport = \"s\"] \n\"1\"->\"4\" [tailport = \"s\", tailport = \"s\", tailport = \"s\", headport = \"n\", tailport = \"s\"] \n\"1\"->\"2\" [tailport = \"s\", tailport = \"s\", tailport = \"s\", headport = \"n\", tailport = \"s\"] \n\"3\"->\"2\" [style = \"solid\", arrowhead = \"none\", arrowtail = \"none\", headport = \"w\", tailport = \"e\"] \n\"4\"->\"5\" [style = \"solid\", arrowhead = \"none\", arrowtail = \"none\", headport = \"w\", tailport = \"e\"] \n\"2\"->\"6\" [tailport = \"e\", tailport = \"e\", tailport = \"e\", headport = \"n\", tailport = \"s\"] \n\"4\"->\"6\" [tailport = \"s\", tailport = \"s\", tailport = \"s\", headport = \"n\", tailport = \"s\"] \n\"6\"->\"7\" [tailport = \"s\", tailport = \"s\", tailport = \"s\", headport = \"n\", tailport = \"s\"] \n\"7\"->\"8\" [tailport = \"s\", tailport = \"s\", tailport = \"s\", headport = \"n\", tailport = \"s\"] \n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}
```
