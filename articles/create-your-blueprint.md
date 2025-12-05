# Defining an Analysis Pipeline Blueprint

## Setup

First things first. `multitool` leverages the `tidyverse` package so
lets load both:

``` r
library(tidyverse)
library(multitool)
```

## Setting up a data analysis pipeline

Image we have some data with several predictor variables, moderators,
covariates, and dependent measures. We want to know if our predictors
(`ivs`) interact with our moderators (`mods`) to predict the outcome
(`dvs`).

But we have three versions of our predictor that (supposedly) measure
the same thing, albeit in slightly different ways.

In addition, because we collected messy data from the real world (not
really but let’s pretend), we have some idea of which observations to
include and which we might exclude (e.g., `include1`, `include2`,
`include3`).

``` r
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
```

## Create a blueprint

Say we don’t know much about this new and exciting area of research.

We want to maximize our knowledge but we also want to be systematic. One
approach would be to specify a reasonable analysis pipeline. Something
that looks like the following:

``` r
# Filter out exclusions
filtered_data <- 
  the_data |> 
  filter(
    include1 == 0,  # --
    include2 != 3,  # Exclusion criteria
    include3 > -2.5 # --
  )

# Model the data
my_model <- lm(dv1 ~ iv1 * mod, data = filtered_data)

# Check the results
my_results <- parameters::parameters(my_model)
```

But what if there are valid alternative alternatives to this pipeline?

For example, using `iv2` instead of `iv1` or only using two exclusion
criteria instead of three? A sensible approach would be to copy the code
above, paste it, and edit with different decisions.

This quickly become tedious. It adds many lines of code, many new
objects, and is difficult to keep track of in a systematic way.

Enter `multitool`.

With `multitool`, the above analysis pipeline can be transformed into
**a specification blueprint** for exploring all combinations of sensible
data decisions in a pipeline. It was designed to leverage already
written code (e.g., the `filter` statement above) to create a all
possible combinations of data analysis pipelines.

## Filtering specifications

Our example above has three exclusion criteria. If we don’t know which
are important, for example, because they are based on arbitrary ‘rules
of thumb’ (that may or may not have inherent wisdom) or we don’t know if
including/excluding these cases is valid, we can generate all
combinations:

``` r
the_data |> 
  add_filters(include1 == 0, include2 != 3, include3 > -2.5)
#> # A tibble: 6 × 3
#>   type    group    code                          
#>   <chr>   <chr>    <chr>                         
#> 1 filters include1 include1 == 0                 
#> 2 filters include1 include1 %in% unique(include1)
#> 3 filters include2 include2 != 3                 
#> 4 filters include2 include2 %in% unique(include2)
#> 5 filters include3 include3 > -2.5               
#> 6 filters include3 include3 %in% unique(include3)
```

The output above is a simple `tibble` (i.e., `data.frame`) containing
three columns.

Each row is a possible filter: the `type` column refers to the type of
blueprint specification (see below for types other than filters), the
`group` refers to the variable in the base data frame (in our case
`the_data`) for which the filter applies, and the `code` column contains
the code needed to execute the filter.

For filtering decisions (e.g., exclusion criteria), a *‘do nothing’*
alternative is always generated.

For example, perhaps some observations belong to a subgroup,
`include1 == 1`. We may or may not have good reason to exclude these
cases (this depends on the specific situation).

But imagine that we don’t know if we should include them or not. When
`include1 == 1` is added to
[`add_filters()`](https://ethan-young.github.io/multitool/reference/add_filters.md),
the *‘do nothing’* alternative `include1 %in% unique(include1)` is
automatically generated so you can compare including versus excluding
cases based on a criterion.

## Adding alternative analysis variables

Most multiverse-style analyses explore a range of exclusion criteria and
their alternatives. However, sometimes alternative versions of a
variable are also included.

In the social sciences, it is fairly common to have many measures of
roughly the same construct (i.e., measured variable). For example, a
happiness researcher might measure positive mood, life satisfaction,
and/or a single item measuring happiness (e.g., ‘how happy do your
feel?’).

If you want to explore the output of your pipeline with differing
versions of a variable, you can use
[`add_variables()`](https://ethan-young.github.io/multitool/reference/add_variables.md).

``` r
the_data |>
  add_variables(var_group = "ivs", iv1, iv2, iv3)
#> # A tibble: 3 × 3
#>   type      group code 
#>   <chr>     <chr> <chr>
#> 1 variables ivs   iv1  
#> 2 variables ivs   iv2  
#> 3 variables ivs   iv3
```

The output above generates the same `tibble` as
[`add_filters()`](https://ethan-young.github.io/multitool/reference/add_filters.md).
Each row is a particular decision to use a particular variable in your
pipeline.

In contrast to filter, however, you need to tell
[`add_variables()`](https://ethan-young.github.io/multitool/reference/add_variables.md)
what to call each set of variables with the `var_group` argument. This
is how `multitool` knows that each variable name in the `code` column is
a different alternative of a larger set.

Here, `var_group = "ivs"` indicates that `iv1, iv2, iv3` are all
different versions of `ivs`. I used “ivs” as way of indicating to myself
that these are alternative versions of my main independent variable.

You can add as many variable sets as you want. For example, we might
also want to analyze our two versions of the outcome, `dv1` and `dv2`.

``` r
the_data |>
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_variables(var_group = "dvs", dv1, dv2)
#> # A tibble: 5 × 3
#>   type      group code 
#>   <chr>     <chr> <chr>
#> 1 variables ivs   iv1  
#> 2 variables ivs   iv2  
#> 3 variables ivs   iv3  
#> 4 variables dvs   dv1  
#> 5 variables dvs   dv2
```

## Building up the blueprint

You can harness the real power of `multitool` by piping specification
statements.

For example, perhaps we want to explore our exclusion criteria
alternatives across different versions of our predictor and outcome
variables. We can simply pipe new blueprint specifications into each
other like so:

``` r
the_data |>
  add_filters(include1 == 0, include2 != 3, include3 > -2.5) |> 
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_variables(var_group = "dvs", dv1, dv2)
#> # A tibble: 11 × 3
#>    type      group    code                          
#>    <chr>     <chr>    <chr>                         
#>  1 filters   include1 include1 == 0                 
#>  2 filters   include1 include1 %in% unique(include1)
#>  3 filters   include2 include2 != 3                 
#>  4 filters   include2 include2 %in% unique(include2)
#>  5 filters   include3 include3 > -2.5               
#>  6 filters   include3 include3 %in% unique(include3)
#>  7 variables ivs      iv1                           
#>  8 variables ivs      iv2                           
#>  9 variables ivs      iv3                           
#> 10 variables dvs      dv1                           
#> 11 variables dvs      dv2
```

Notice that we now have a specification blueprint with both exclusion
alternatives and variable alternatives.

## Adding a model

The whole point of building a specification blueprint is to eventually
feed it to a model and examine the results.

You can add a model to your blueprint by using
[`add_model()`](https://ethan-young.github.io/multitool/reference/add_model.md).
I designed
[`add_model()`](https://ethan-young.github.io/multitool/reference/add_model.md)
so the user can simply paste a model function. For example, our call to
[`lm()`](https://rdrr.io/r/stats/lm.html) can be simply pasted into
[`add_model()`](https://ethan-young.github.io/multitool/reference/add_model.md).
Make sure to give your model a label with the `model_desc` argument.

``` r
the_data |>
  add_filters(include1 == 0, include2 != 3, include3 > -2.5) |> 
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_variables(var_group = "dvs", dv1, dv2) |> 
  add_model("linear model", lm(dv1 ~ iv1 * mod))
#> # A tibble: 12 × 6
#>    type      group        code  additional_args add_standardized add_performance
#>    <chr>     <chr>        <chr> <lgl>           <lgl>            <lgl>          
#>  1 filters   include1     incl… NA              NA               NA             
#>  2 filters   include1     incl… NA              NA               NA             
#>  3 filters   include2     incl… NA              NA               NA             
#>  4 filters   include2     incl… NA              NA               NA             
#>  5 filters   include3     incl… NA              NA               NA             
#>  6 filters   include3     incl… NA              NA               NA             
#>  7 variables ivs          iv1   NA              NA               NA             
#>  8 variables ivs          iv2   NA              NA               NA             
#>  9 variables ivs          iv3   NA              NA               NA             
#> 10 variables dvs          dv1   NA              NA               NA             
#> 11 variables dvs          dv2   NA              NA               NA             
#> 12 models    linear model lm(d… NA              TRUE             TRUE
```

Above, the model is completely unquoted. It also has no `data` argument.
This is intentional; `multitool` is tracking the base dataset along the
way (so you don’t have to). Note that you can still quote the model
formula, if that is more your style.

``` r
the_data |>
  add_filters(include1 == 0, include2 != 3, include3 > -2.5) |>
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_variables(var_group = "dvs", dv1, dv2) |> 
  add_model("linear model", "lm(dv1 ~ iv1 * mod)")
#> # A tibble: 12 × 6
#>    type      group        code  additional_args add_standardized add_performance
#>    <chr>     <chr>        <chr> <lgl>           <lgl>            <lgl>          
#>  1 filters   include1     incl… NA              NA               NA             
#>  2 filters   include1     incl… NA              NA               NA             
#>  3 filters   include2     incl… NA              NA               NA             
#>  4 filters   include2     incl… NA              NA               NA             
#>  5 filters   include3     incl… NA              NA               NA             
#>  6 filters   include3     incl… NA              NA               NA             
#>  7 variables ivs          iv1   NA              NA               NA             
#>  8 variables ivs          iv2   NA              NA               NA             
#>  9 variables ivs          iv3   NA              NA               NA             
#> 10 variables dvs          dv1   NA              NA               NA             
#> 11 variables dvs          dv2   NA              NA               NA             
#> 12 models    linear model lm(d… NA              TRUE             TRUE
```

To make sure your
[`add_variables()`](https://ethan-young.github.io/multitool/reference/add_variables.md)
works properly,
[`add_model()`](https://ethan-young.github.io/multitool/reference/add_model.md)
was designed to interpret
[`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) syntax.
For example:

``` r
the_data |>
  add_filters(include1 == 0, include2 != 3, include3 > -2.5) |> 
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_variables(var_group = "dvs", dv1, dv2) |> 
  add_model("linear model", lm({dvs} ~ {ivs} * mod)) # see the {} here
#> # A tibble: 12 × 6
#>    type      group        code  additional_args add_standardized add_performance
#>    <chr>     <chr>        <chr> <lgl>           <lgl>            <lgl>          
#>  1 filters   include1     incl… NA              NA               NA             
#>  2 filters   include1     incl… NA              NA               NA             
#>  3 filters   include2     incl… NA              NA               NA             
#>  4 filters   include2     incl… NA              NA               NA             
#>  5 filters   include3     incl… NA              NA               NA             
#>  6 filters   include3     incl… NA              NA               NA             
#>  7 variables ivs          iv1   NA              NA               NA             
#>  8 variables ivs          iv2   NA              NA               NA             
#>  9 variables ivs          iv3   NA              NA               NA             
#> 10 variables dvs          dv1   NA              NA               NA             
#> 11 variables dvs          dv2   NA              NA               NA             
#> 12 models    linear model lm({… NA              TRUE             TRUE
```

This allows `multitool` to insert the correct version of each variable
specified in a
[`add_variables()`](https://ethan-young.github.io/multitool/reference/add_variables.md)
step. Make sure to embrace the variable with the `var_group` argument
from
[`add_variables()`](https://ethan-young.github.io/multitool/reference/add_variables.md),
for example `add_model(lm({dvs} ~ {ivs} * mod))`.

Here, `dvs` and `ivs` tells `multitool` to insert the current version of
the `ivs` and `dvs` into the model.

## Finalizing the specification blueprint

There are two steps in finalizing your blueprint. The first is to
visualize your pipeline with a graph. This is optional, but I think it
is helpful.

You can automate making a chart with
[`create_blueprint_graph()`](https://ethan-young.github.io/multitool/reference/create_blueprint_graph.md).
Feed your pipeline to
[`create_blueprint_graph()`](https://ethan-young.github.io/multitool/reference/create_blueprint_graph.md)
to see a chart of your multiverse pipeline plan:

``` r
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
```

The final step in making your blueprint is expanding all your
specifications into all possible combinations. You can do this by
calling
[`expand_decisions()`](https://ethan-young.github.io/multitool/reference/expand_decisions.md)
at the end of your blueprint pipeline:

``` r
expanded_pipeline <- expand_decisions(full_pipeline)

expanded_pipeline
#> # A tibble: 48 × 4
#>    decision variables        filters          models          
#>       <dbl> <list>           <list>           <list>          
#>  1        1 <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 5]>
#>  2        2 <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 5]>
#>  3        3 <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 5]>
#>  4        4 <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 5]>
#>  5        5 <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 5]>
#>  6        6 <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 5]>
#>  7        7 <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 5]>
#>  8        8 <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 5]>
#>  9        9 <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 5]>
#> 10       10 <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 5]>
#> # ℹ 38 more rows
```

The result is an expanded `tibble` with 1 row per unique decision and
columns for each major blueprint category. In our example, we have
alternative variables (predictors and outcomes), filters (three
exclusion alternatives), and a model to run.

Note that we have 3 exclusions (each with two combinations), 3 versions
of our predictor, and 2 versions of our outcome. This means our
blueprint should have `2*2*2*3*2` or 48 rows, which corresponds with our
expanded pipeline:

``` r
2*2*2*3*2 == nrow(expanded_pipeline)
#> [1] TRUE
```

Our blueprint uses list columns to organize information. You can view
each list column by using `tidyr::unnest(<column name>)`. For example,
we can look at the filters:

``` r
expanded_pipeline |> unnest(filters)
#> # A tibble: 48 × 6
#>    decision variables        include1      include2      include3       models  
#>       <dbl> <list>           <chr>         <chr>         <chr>          <list>  
#>  1        1 <tibble [1 × 2]> include1 == 0 include2 != 3 include3 > -2… <tibble>
#>  2        2 <tibble [1 × 2]> include1 == 0 include2 != 3 include3 > -2… <tibble>
#>  3        3 <tibble [1 × 2]> include1 == 0 include2 != 3 include3 > -2… <tibble>
#>  4        4 <tibble [1 × 2]> include1 == 0 include2 != 3 include3 > -2… <tibble>
#>  5        5 <tibble [1 × 2]> include1 == 0 include2 != 3 include3 > -2… <tibble>
#>  6        6 <tibble [1 × 2]> include1 == 0 include2 != 3 include3 > -2… <tibble>
#>  7        7 <tibble [1 × 2]> include1 == 0 include2 != 3 include3 %in%… <tibble>
#>  8        8 <tibble [1 × 2]> include1 == 0 include2 != 3 include3 %in%… <tibble>
#>  9        9 <tibble [1 × 2]> include1 == 0 include2 != 3 include3 %in%… <tibble>
#> 10       10 <tibble [1 × 2]> include1 == 0 include2 != 3 include3 %in%… <tibble>
#> # ℹ 38 more rows
```

Or we could look at the models:

``` r
expanded_pipeline |> unnest(models)
#> # A tibble: 48 × 8
#>    decision variables filters  model     model_meta model_args model_standardize
#>       <dbl> <list>    <list>   <chr>     <chr>      <chr>      <chr>            
#>  1        1 <tibble>  <tibble> lm(dv1 ~… linear mo… ""         TRUE             
#>  2        2 <tibble>  <tibble> lm(dv2 ~… linear mo… ""         TRUE             
#>  3        3 <tibble>  <tibble> lm(dv1 ~… linear mo… ""         TRUE             
#>  4        4 <tibble>  <tibble> lm(dv2 ~… linear mo… ""         TRUE             
#>  5        5 <tibble>  <tibble> lm(dv1 ~… linear mo… ""         TRUE             
#>  6        6 <tibble>  <tibble> lm(dv2 ~… linear mo… ""         TRUE             
#>  7        7 <tibble>  <tibble> lm(dv1 ~… linear mo… ""         TRUE             
#>  8        8 <tibble>  <tibble> lm(dv2 ~… linear mo… ""         TRUE             
#>  9        9 <tibble>  <tibble> lm(dv1 ~… linear mo… ""         TRUE             
#> 10       10 <tibble>  <tibble> lm(dv2 ~… linear mo… ""         TRUE             
#> # ℹ 38 more rows
#> # ℹ 1 more variable: model_perform <chr>
```

Notice that, with the
[`glue::glue()`](https://glue.tidyverse.org/reference/glue.html) syntax,
different versions of our predictors and outcomes were inserted
appropriately. You can check their correspondence by using
[`unnest()`](https://tidyr.tidyverse.org/reference/unnest.html) on both
the models and variable list columns:

``` r
expanded_pipeline |> unnest(c(variables, models))
#> # A tibble: 48 × 9
#>    decision ivs   dvs   filters  model   model_meta model_args model_standardize
#>       <dbl> <chr> <chr> <list>   <chr>   <chr>      <chr>      <chr>            
#>  1        1 iv1   dv1   <tibble> lm(dv1… linear mo… ""         TRUE             
#>  2        2 iv1   dv2   <tibble> lm(dv2… linear mo… ""         TRUE             
#>  3        3 iv2   dv1   <tibble> lm(dv1… linear mo… ""         TRUE             
#>  4        4 iv2   dv2   <tibble> lm(dv2… linear mo… ""         TRUE             
#>  5        5 iv3   dv1   <tibble> lm(dv1… linear mo… ""         TRUE             
#>  6        6 iv3   dv2   <tibble> lm(dv2… linear mo… ""         TRUE             
#>  7        7 iv1   dv1   <tibble> lm(dv1… linear mo… ""         TRUE             
#>  8        8 iv1   dv2   <tibble> lm(dv2… linear mo… ""         TRUE             
#>  9        9 iv2   dv1   <tibble> lm(dv1… linear mo… ""         TRUE             
#> 10       10 iv2   dv2   <tibble> lm(dv2… linear mo… ""         TRUE             
#> # ℹ 38 more rows
#> # ℹ 1 more variable: model_perform <chr>
```

## Going further

This example uses relatively simple pipeline steps. You can also add
more sophisticated steps to your pipeline, such as preprocessing data,
post-processing model results, or calculating descriptive statistics
alongside your model.
