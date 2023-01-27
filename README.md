
<!-- README.md is generated from README.Rmd. Please edit that file -->

# multitool

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/multitool.png)](https://CRAN.R-project.org/package=multitool)
[![R-CMD-check](https://github.com/ethan-young/multiverse_tools/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ethan-young/multiverse_tools/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of `multitool` is to provide a set of tools for designing and
running multiverse-style analyses. My goal with this package is to
create an incremental workflow for slowly building up, keeping track of,
and unpacking multiverse analyses and results.

I designed `multitool` to help users take a single use case (e.g., a
single analysis pipeline) and expand it into a workflow to include
alternative versions of the same analysis.

For example, imagine you would like to take some data, remove outliers,
transform variables, run a linear model, do a post-hoc analysis, and
plot the results. `multitool` can take theses tasks and transform them
into a *specification blueprint*, which provides instructions for
running your analysis pipeline.

The functions were designed to play nice with the
[`tidyverse`](https://www.tidyverse.org/) and require using the base R
pipe `|>`. This makes it easy to quickly convert a single analysis into
a multiverse analysis.

## Basic components

My vision of a multiverse workflow contains three parts.

1.  **Base data:** original dataset waiting for further processing
2.  **specification blueprint:** aka specification grid. This a
    blueprint/map/recipe or whatever you want to call it. These are the
    instructions for what to do.
3.  **Multiverse results:** a table of results after feeding the base
    data to the blueprint.

A defining feature of `multitool` is that it saves pipeline code. This
allows the user to grab the *code that produces a result* and inspect it
for accuracy, errors, or simply for peace of mind. By quickly grabbing
code, the user can iterate between creating their blueprint and checking
that the code works as intended.

`multitool` allows the user to model data however they’d like. The user
is responsible for loading the relevant modeling packages. Regardless of
your model choice, `multitool` will capture your code and build a
pipeline.

Finally, multiverse analyses were originally intended to look at how
model parameters shift as a function of arbitrary analysis decisions.
However, any computation might change depending on how you slice and
dice the data. For this reason, I also built functions for computing
descriptive, correlation, and reliability analysis alongside a
particular modelling pipeline.

## Installation

You can install the development version of `multitool` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("ethan-young/multitool")
```

## Example

``` r
library(tidyverse)
library(multitool)
```

## The base data

Image we have some data with several predictor variables, moderators,
covariates, and dependent measures. We want to know if our predictors
(`ivs`) interact with our moderators (`mods`) to predict the outcome
(`dvs`).

But we have three versions of our predictor that measuring the same
construct in a different way.

In addition, because we collected messy data from the real world (not
really but let’s pretend), we have some idea of exclusions we might need
to make (e.g., `include1`, `include2`, `include3`).

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
    include1 == 0,           # --
    include2 != 3,           # Exclusion criteria
    scale(include3) > -2.5   # --
  )

# Model the data
my_model <- lm(dv1 ~ iv1 * mod, data = filtered_data)

# Check the results
my_results <- broom::tidy(my_model)
```

But what if there are valid alternative alternatives to this pipeline?

For example, using `iv2` instead of `iv1` or only using two exclusion
criteria instead of three? A sensible approach would be to copy the code
above, paste it, and edit with different decisions.

This quickly become tedious. It adds many lines of code, many new
objects, and is difficult to keep track of in a systematic way. Enter
`multitool`.

With `multitool`, the above analysis pipeline can be transformed into a
grid – a specification blueprint – for exploring all combinations of
sensible data decisions in a pipeline. It was designed to leverage
already written code (e.g., the `filter` statement above) to create a
multiverse of data analysis pipelines.

## Filtering specifications

Our example above has three exclusion criteria. If we don’t know which
are important, for example, because they are based on arbitrary ‘rules
of thumb’ (that may or may not have inherent wisdom) or we don’t know if
including/excluding these cases is valid, we can generate all
combinations:

``` r
the_data |> 
  add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5)
#> # A tibble: 6 × 3
#>   type    group    code                          
#>   <chr>   <chr>    <chr>                         
#> 1 filters include1 include1 == 0                 
#> 2 filters include1 include1 %in% unique(include1)
#> 3 filters include2 include2 != 3                 
#> 4 filters include2 include2 %in% unique(include2)
#> 5 filters include3 scale(include3) > -2.5        
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
`include1 == 1` is added to `add_filters()`, the *‘do nothing’*
alternative `include1 %in% unique(include1)` is automatically generated
so you can compare including versus excluding cases based on a
criterion.

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
versions of a variable, you can use `add_variables()`.

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

The output above generates the same `tibble` as `add_filters()`. Each
row is a particular decision to use a particular variable in your
pipeline.

In contrast to filter, however, you need to tell `add_variables()` what
to call each set of variables with the `var_group` argument. This is how
`multitool` knows that each variable name in the `code` column is a
different alternative of a larger set.

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
statements. For example, perhaps we want to explore our exclusion
criteria alternatives across different versions of our predictor and
outcome variables. We can simply pipe new blueprint specifications into
each other like so:

``` r
the_data |>
  add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5) |> 
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_variables(var_group = "dvs", dv1, dv2)
#> # A tibble: 11 × 3
#>    type      group    code                          
#>    <chr>     <chr>    <chr>                         
#>  1 filters   include1 include1 == 0                 
#>  2 filters   include1 include1 %in% unique(include1)
#>  3 filters   include2 include2 != 3                 
#>  4 filters   include2 include2 %in% unique(include2)
#>  5 filters   include3 scale(include3) > -2.5        
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

You can add a model to your blueprint by using `add_model()`. I designed
`add_model()` so the user can simply paste a model function. For
example, our call to `lm()` can be simply pasted into `add_model()`.
Make sure to give your model a label with the `model_desc` argument.

``` r
the_data |>
  add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5) |> 
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_variables(var_group = "dvs", dv1, dv2) |> 
  add_model("linear model", lm(dv1 ~ iv1 * mod))
#> # A tibble: 12 × 3
#>    type      group        code                          
#>    <chr>     <chr>        <chr>                         
#>  1 filters   include1     include1 == 0                 
#>  2 filters   include1     include1 %in% unique(include1)
#>  3 filters   include2     include2 != 3                 
#>  4 filters   include2     include2 %in% unique(include2)
#>  5 filters   include3     scale(include3) > -2.5        
#>  6 filters   include3     include3 %in% unique(include3)
#>  7 variables ivs          iv1                           
#>  8 variables ivs          iv2                           
#>  9 variables ivs          iv3                           
#> 10 variables dvs          dv1                           
#> 11 variables dvs          dv2                           
#> 12 models    linear model lm(dv1 ~ iv1 * mod)
```

Above, the model is completely unquoted. It also has no `data` argument.
This is intentional; `multitool` is tracking the base dataset along the
way (so you don’t have to). Note that you can still quote the model
formula, if that is more your style.

``` r
the_data |>
  add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5) |>
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_variables(var_group = "dvs", dv1, dv2) |> 
  add_model("lm(dv1 ~ iv1 * mod)")
#> # A tibble: 12 × 3
#>    type      group               code                            
#>    <chr>     <chr>               <chr>                           
#>  1 filters   include1            "include1 == 0"                 
#>  2 filters   include1            "include1 %in% unique(include1)"
#>  3 filters   include2            "include2 != 3"                 
#>  4 filters   include2            "include2 %in% unique(include2)"
#>  5 filters   include3            "scale(include3) > -2.5"        
#>  6 filters   include3            "include3 %in% unique(include3)"
#>  7 variables ivs                 "iv1"                           
#>  8 variables ivs                 "iv2"                           
#>  9 variables ivs                 "iv3"                           
#> 10 variables dvs                 "dv1"                           
#> 11 variables dvs                 "dv2"                           
#> 12 models    lm(dv1 ~ iv1 * mod) ""
```

To make sure your `add_variables()` works properly, `add_model()` was
designed to interpret `glue::glue()` syntax. For example:

``` r
the_data |>
  add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5) |> 
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_variables(var_group = "dvs", dv1, dv2) |> 
  add_model("linear model",lm({dvs} ~ {ivs} * mod))
#> # A tibble: 12 × 3
#>    type      group        code                          
#>    <chr>     <chr>        <chr>                         
#>  1 filters   include1     include1 == 0                 
#>  2 filters   include1     include1 %in% unique(include1)
#>  3 filters   include2     include2 != 3                 
#>  4 filters   include2     include2 %in% unique(include2)
#>  5 filters   include3     scale(include3) > -2.5        
#>  6 filters   include3     include3 %in% unique(include3)
#>  7 variables ivs          iv1                           
#>  8 variables ivs          iv2                           
#>  9 variables ivs          iv3                           
#> 10 variables dvs          dv1                           
#> 11 variables dvs          dv2                           
#> 12 models    linear model lm({dvs} ~ {ivs} * mod)
```

This allows `multitool` to insert the correct version of each variable
specified in a `add_variables()` step. Make sure to use embrace the
variable with the `var_group` argument from `add_variables()`, for
example `add_model(lm({dvs} ~ {ivs} * mod))`. Here, `{dvs}` and `{ivs}`
tells `multitool` to insert the current version of the `ivs` and `dvs`
into the model.

## Finalizing the specification blueprint

There are two steps in finalizing your bluerpint. The first is to
visualize your pipeline with a graph. This is optional, but I think it
is helpful.

You can automate making a chart with `blueprint()`. Feed your pipeline
to `blueprint()` to see a chart of your multiverse pipeline plan:

``` r
full_pipeline <- 
  the_data |>
  add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5) |> 
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_variables(var_group = "dvs", dv1, dv2) |> 
  add_model("linear model", lm({dvs} ~ {ivs} * mod))

my_blueprint <- blueprint(full_pipeline, height = 800)
```

<div>

<p>

<img src="README_files/figure-commonmark/dot-figure-1.png"
style="width:7in;height:5in" data-fig-pos="H" />

</p>

</div>

The final step in making your blueprint is expanding all your
specifications into all possible combinations. You can do this by
calling `expand_decisions()` at the end of your blueprint pipeline:

``` r
expanded_pipeline <- expand_decisions(full_pipeline)

expanded_pipeline
#> # A tibble: 48 × 4
#>    decision variables        filters          models          
#>    <chr>    <list>           <list>           <list>          
#>  1 1        <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 2]>
#>  2 2        <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 2]>
#>  3 3        <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 2]>
#>  4 4        <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 2]>
#>  5 5        <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 2]>
#>  6 6        <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 2]>
#>  7 7        <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 2]>
#>  8 8        <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 2]>
#>  9 9        <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 2]>
#> 10 10       <tibble [1 × 2]> <tibble [1 × 3]> <tibble [1 × 2]>
#> # … with 38 more rows
```

The result is an expanded `tibble` with 1 row per unique decision and
columns for each major blueprint category. In our example, we have
alternative variables (predictors and outcomes), filters (three
exclusion alternatives), and a model to run.

Note that we have 3 exclusions (each with two combinations), 3 versions
of our predictor, and 2 versions of our outcome. This means our
blueprint should have `2*2*2*3*2` rows.

``` r
2*2*2*3*2 == nrow(full_pipeline)
#> [1] FALSE
```

Our blueprint uses list columns to organize information. You can view
each list column by using `tidyr::unnest(<column name>)`. For example,
we can look at the filters:

``` r
expanded_pipeline |> unnest(filters)
#> # A tibble: 48 × 6
#>    decision variables        include1      include2      include3       models  
#>    <chr>    <list>           <chr>         <chr>         <chr>          <list>  
#>  1 1        <tibble [1 × 2]> include1 == 0 include2 != 3 scale(include… <tibble>
#>  2 2        <tibble [1 × 2]> include1 == 0 include2 != 3 scale(include… <tibble>
#>  3 3        <tibble [1 × 2]> include1 == 0 include2 != 3 scale(include… <tibble>
#>  4 4        <tibble [1 × 2]> include1 == 0 include2 != 3 scale(include… <tibble>
#>  5 5        <tibble [1 × 2]> include1 == 0 include2 != 3 scale(include… <tibble>
#>  6 6        <tibble [1 × 2]> include1 == 0 include2 != 3 scale(include… <tibble>
#>  7 7        <tibble [1 × 2]> include1 == 0 include2 != 3 include3 %in%… <tibble>
#>  8 8        <tibble [1 × 2]> include1 == 0 include2 != 3 include3 %in%… <tibble>
#>  9 9        <tibble [1 × 2]> include1 == 0 include2 != 3 include3 %in%… <tibble>
#> 10 10       <tibble [1 × 2]> include1 == 0 include2 != 3 include3 %in%… <tibble>
#> # … with 38 more rows
```

Or we could look at the models:

``` r
expanded_pipeline |> unnest(models)
#> # A tibble: 48 × 5
#>    decision variables        filters          model               model_meta  
#>    <chr>    <list>           <list>           <chr>               <chr>       
#>  1 1        <tibble [1 × 2]> <tibble [1 × 3]> lm(dv1 ~ iv1 * mod) linear model
#>  2 2        <tibble [1 × 2]> <tibble [1 × 3]> lm(dv2 ~ iv1 * mod) linear model
#>  3 3        <tibble [1 × 2]> <tibble [1 × 3]> lm(dv1 ~ iv2 * mod) linear model
#>  4 4        <tibble [1 × 2]> <tibble [1 × 3]> lm(dv2 ~ iv2 * mod) linear model
#>  5 5        <tibble [1 × 2]> <tibble [1 × 3]> lm(dv1 ~ iv3 * mod) linear model
#>  6 6        <tibble [1 × 2]> <tibble [1 × 3]> lm(dv2 ~ iv3 * mod) linear model
#>  7 7        <tibble [1 × 2]> <tibble [1 × 3]> lm(dv1 ~ iv1 * mod) linear model
#>  8 8        <tibble [1 × 2]> <tibble [1 × 3]> lm(dv2 ~ iv1 * mod) linear model
#>  9 9        <tibble [1 × 2]> <tibble [1 × 3]> lm(dv1 ~ iv2 * mod) linear model
#> 10 10       <tibble [1 × 2]> <tibble [1 × 3]> lm(dv2 ~ iv2 * mod) linear model
#> # … with 38 more rows
```

Notice that, with the `glue::glue()` syntax, different versions of our
predictors and outcomes were inserted appropriately. You can check their
correspondence by using `unnest()` on both the models and variable list
columns:

``` r
expanded_pipeline |> unnest(c(variables, models))
#> # A tibble: 48 × 6
#>    decision ivs   dvs   filters          model               model_meta  
#>    <chr>    <chr> <chr> <list>           <chr>               <chr>       
#>  1 1        iv1   dv1   <tibble [1 × 3]> lm(dv1 ~ iv1 * mod) linear model
#>  2 2        iv1   dv2   <tibble [1 × 3]> lm(dv2 ~ iv1 * mod) linear model
#>  3 3        iv2   dv1   <tibble [1 × 3]> lm(dv1 ~ iv2 * mod) linear model
#>  4 4        iv2   dv2   <tibble [1 × 3]> lm(dv2 ~ iv2 * mod) linear model
#>  5 5        iv3   dv1   <tibble [1 × 3]> lm(dv1 ~ iv3 * mod) linear model
#>  6 6        iv3   dv2   <tibble [1 × 3]> lm(dv2 ~ iv3 * mod) linear model
#>  7 7        iv1   dv1   <tibble [1 × 3]> lm(dv1 ~ iv1 * mod) linear model
#>  8 8        iv1   dv2   <tibble [1 × 3]> lm(dv2 ~ iv1 * mod) linear model
#>  9 9        iv2   dv1   <tibble [1 × 3]> lm(dv1 ~ iv2 * mod) linear model
#> 10 10       iv2   dv2   <tibble [1 × 3]> lm(dv2 ~ iv2 * mod) linear model
#> # … with 38 more rows
```

## Validate your blueprint

A `multitool` specification blueprint has a special feature: it captures
your code and generates analysis pipelines.

A special set of functions with the `show_code_*` prefix allow you to
see the code that will be executed for a single pipeline. For example,
we can look at our filtering code for the first decision of our
blueprint:

``` r
expanded_pipeline |> show_code_filter(decision_num = 1)
#> the_data |> 
#>   filter(include1 == 0, include2 != 3, scale(include3) > -2.5)
```

These functions allow you to generate the relevant code along the
analysis pipeline. For example, we can look at our model pipeline for
decision 17 using `show_code_model(decision_num = 17)`:

``` r
expanded_pipeline |> show_code_model(decision_num = 17)
#> the_data |> 
#>   filter(include1 == 0, include2 %in% unique(include2), scale(include3) > -2.5) |> 
#>   lm(dv1 ~ iv3 * mod, data = _)
```

Setting the `copy` argument to `TRUE` allows you to send the code
straight to your clipboard. You can paste it into the source or console
for testing/editing.

You can also run individual decisions to test that they work. See below
for details about the results.

``` r
run_universe_model(expanded_pipeline, decision_num = 1)
#> # A tibble: 1 × 2
#>   decision lm_fitted       
#>   <chr>    <list>          
#> 1 1        <tibble [1 × 5]>
```

## Implement your blueprint

Once you have built your full specification blueprint and feel
comfortable with how the pipeline is executed, you can implement a full
multiverse-style analysis.

Simply use `run_multiverse(<your pipeline object>)`:

``` r
multiverse_results <- run_multiverse(expanded_pipeline)
#> ■■■■■■■■■■■■■                     42% | ETA:  3s

multiverse_results
#> # A tibble: 48 × 3
#>    decision specifications   lm_fitted       
#>    <chr>    <list>           <list>          
#>  1 1        <tibble [1 × 3]> <tibble [1 × 5]>
#>  2 2        <tibble [1 × 3]> <tibble [1 × 5]>
#>  3 3        <tibble [1 × 3]> <tibble [1 × 5]>
#>  4 4        <tibble [1 × 3]> <tibble [1 × 5]>
#>  5 5        <tibble [1 × 3]> <tibble [1 × 5]>
#>  6 6        <tibble [1 × 3]> <tibble [1 × 5]>
#>  7 7        <tibble [1 × 3]> <tibble [1 × 5]>
#>  8 8        <tibble [1 × 3]> <tibble [1 × 5]>
#>  9 9        <tibble [1 × 3]> <tibble [1 × 5]>
#> 10 10       <tibble [1 × 3]> <tibble [1 × 5]>
#> # … with 38 more rows
```

The result will be another `tibble` with various list columns.

It will always contain a list column named `specifications` containing
all the information you generated in your blueprint. Next, there will be
one list column per model fitted, labelled with a suffix like so
`<function name>_fitted`.

Here, we ran a `lm()` so our results are contained in `lm_fitted`.

## Unpacking a multiverse analysis

There are two main ways to unpack and examine `multitool` results. The
first is by using `tidyr::unnest()` (similar to unpacking the
specification blueprint earlier).

### Unnest

``` r
multiverse_results |> unnest(lm_fitted)
#> # A tibble: 48 × 7
#>    decision specifications   lm_code         lm_tidy  lm_gla…¹ lm_war…² lm_mes…³
#>    <chr>    <list>           <glue>          <list>   <list>   <list>   <list>  
#>  1 1        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  2 2        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  3 3        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  4 4        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  5 5        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  6 6        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  7 7        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  8 8        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  9 9        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#> 10 10       <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#> # … with 38 more rows, and abbreviated variable names ¹​lm_glance, ²​lm_warnings,
#> #   ³​lm_messages
```

Inside a `<model function>_fitted` column (here `lm_fitted`),
`multitool` gives us 4 columns.

The first column is always the full code pipeline that produced the
results: `lm_code`. The next are results passed to
[`broom`](https://broom.tidymodels.org/) (if `tidy` and/or `glance`
methods exist). For `lm`, we have `lm_tidy` and `lm_glance`. Notice the
naming convention: `<model function>_tidy` and
`<model function>_glance`.

``` r
multiverse_results |> unnest(lm_fitted) |> unnest(lm_tidy)
#> # A tibble: 192 × 11
#>    decision specificati…¹ lm_code term  estim…² std.e…³ stati…⁴ p.value lm_gla…⁵
#>    <chr>    <list>        <glue>  <chr>   <dbl>   <dbl>   <dbl>   <dbl> <list>  
#>  1 1        <tibble>      the_da… (Int…  0.0718  0.0589   1.22    0.224 <tibble>
#>  2 1        <tibble>      the_da… iv1    0.0187  0.0595   0.314   0.754 <tibble>
#>  3 1        <tibble>      the_da… mod    0.0919  0.0584   1.57    0.117 <tibble>
#>  4 1        <tibble>      the_da… iv1:…  0.0484  0.0618   0.783   0.434 <tibble>
#>  5 2        <tibble>      the_da… (Int… -0.0572  0.0657  -0.871   0.385 <tibble>
#>  6 2        <tibble>      the_da… iv1    0.0676  0.0664   1.02    0.309 <tibble>
#>  7 2        <tibble>      the_da… mod    0.0835  0.0651   1.28    0.201 <tibble>
#>  8 2        <tibble>      the_da… iv1:…  0.0422  0.0689   0.613   0.540 <tibble>
#>  9 3        <tibble>      the_da… (Int…  0.0657  0.0588   1.12    0.264 <tibble>
#> 10 3        <tibble>      the_da… iv2   -0.0995  0.0618  -1.61    0.109 <tibble>
#> # … with 182 more rows, 2 more variables: lm_warnings <list>,
#> #   lm_messages <list>, and abbreviated variable names ¹​specifications,
#> #   ²​estimate, ³​std.error, ⁴​statistic, ⁵​lm_glance
```

The `lm_tidy` (or `<model function>_tidy`) column gives us the main
results of `lm()` per decision. These include terms, estimates, standard
errors, and p-values. `lm_glance` (or `<model function>_glance`) column
gives us model fit statistics (among other things):

``` r
multiverse_results |> unnest(lm_fitted) |> unnest(lm_glance)
#> # A tibble: 48 × 18
#>    decision specificat…¹ lm_code lm_tidy  r.squ…² adj.r.…³ sigma stati…⁴ p.value
#>    <chr>    <list>       <glue>  <list>     <dbl>    <dbl> <dbl>   <dbl>   <dbl>
#>  1 1        <tibble>     the_da… <tibble> 0.0108  -1.68e-4 0.973   0.985   0.400
#>  2 2        <tibble>     the_da… <tibble> 0.00989 -1.11e-3 1.08    0.899   0.442
#>  3 3        <tibble>     the_da… <tibble> 0.0186   7.68e-3 0.969   1.70    0.166
#>  4 4        <tibble>     the_da… <tibble> 0.0133   2.30e-3 1.08    1.21    0.307
#>  5 5        <tibble>     the_da… <tibble> 0.0210   1.02e-2 0.968   1.93    0.124
#>  6 6        <tibble>     the_da… <tibble> 0.00655 -4.49e-3 1.09    0.593   0.620
#>  7 7        <tibble>     the_da… <tibble> 0.0110   1.65e-4 0.970   1.02    0.386
#>  8 8        <tibble>     the_da… <tibble> 0.0102  -7.17e-4 1.08    0.934   0.425
#>  9 9        <tibble>     the_da… <tibble> 0.0181   7.31e-3 0.966   1.68    0.172
#> 10 10       <tibble>     the_da… <tibble> 0.0132   2.37e-3 1.08    1.22    0.303
#> # … with 38 more rows, 9 more variables: df <dbl>, logLik <dbl>, AIC <dbl>,
#> #   BIC <dbl>, deviance <dbl>, df.residual <int>, nobs <int>,
#> #   lm_warnings <list>, lm_messages <list>, and abbreviated variable names
#> #   ¹​specifications, ²​r.squared, ³​adj.r.squared, ⁴​statistic
```

### Reveal

I wrote wrappers around the `unnest()` workflow. The main function is
`reveal()`. Pass a multiverse results `tibble` to `reveal()` and tell it
which columns to grab by indicating the column name in the `.what`
argument:

``` r
multiverse_results |> reveal(.what = lm_fitted)
#> # A tibble: 48 × 7
#>    decision specifications   lm_code         lm_tidy  lm_gla…¹ lm_war…² lm_mes…³
#>    <chr>    <list>           <glue>          <list>   <list>   <list>   <list>  
#>  1 1        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  2 2        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  3 3        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  4 4        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  5 5        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  6 6        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  7 7        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  8 8        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#>  9 9        <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#> 10 10       <tibble [1 × 3]> the_data |> fi… <tibble> <tibble> <tibble> <tibble>
#> # … with 38 more rows, and abbreviated variable names ¹​lm_glance, ²​lm_warnings,
#> #   ³​lm_messages
```

If you want to get straight to a tidied result you can specify a
sub-list with the `.which` argument:

``` r
multiverse_results |> reveal(.what = lm_fitted, .which = lm_tidy)
#> # A tibble: 192 × 7
#>    decision specifications   term        estimate std.error statistic p.value
#>    <chr>    <list>           <chr>          <dbl>     <dbl>     <dbl>   <dbl>
#>  1 1        <tibble [1 × 3]> (Intercept)   0.0718    0.0589     1.22    0.224
#>  2 1        <tibble [1 × 3]> iv1           0.0187    0.0595     0.314   0.754
#>  3 1        <tibble [1 × 3]> mod           0.0919    0.0584     1.57    0.117
#>  4 1        <tibble [1 × 3]> iv1:mod       0.0484    0.0618     0.783   0.434
#>  5 2        <tibble [1 × 3]> (Intercept)  -0.0572    0.0657    -0.871   0.385
#>  6 2        <tibble [1 × 3]> iv1           0.0676    0.0664     1.02    0.309
#>  7 2        <tibble [1 × 3]> mod           0.0835    0.0651     1.28    0.201
#>  8 2        <tibble [1 × 3]> iv1:mod       0.0422    0.0689     0.613   0.540
#>  9 3        <tibble [1 × 3]> (Intercept)   0.0657    0.0588     1.12    0.264
#> 10 3        <tibble [1 × 3]> iv2          -0.0995    0.0618    -1.61    0.109
#> # … with 182 more rows
```

You can also choose to expand your specification blueprint with
`.unpack_specs = TRUE` to see which decisions produced what result:

``` r
multiverse_results |> 
  reveal(.what = lm_fitted, .which = lm_tidy, .unpack_specs = TRUE)
#> # A tibble: 192 × 13
#>    decision ivs   dvs   include1     inclu…¹ inclu…² model model…³ term  estim…⁴
#>    <chr>    <chr> <chr> <chr>        <chr>   <chr>   <chr> <chr>   <chr>   <dbl>
#>  1 1        iv1   dv1   include1 ==… includ… scale(… lm(d… linear… (Int…  0.0718
#>  2 1        iv1   dv1   include1 ==… includ… scale(… lm(d… linear… iv1    0.0187
#>  3 1        iv1   dv1   include1 ==… includ… scale(… lm(d… linear… mod    0.0919
#>  4 1        iv1   dv1   include1 ==… includ… scale(… lm(d… linear… iv1:…  0.0484
#>  5 2        iv1   dv2   include1 ==… includ… scale(… lm(d… linear… (Int… -0.0572
#>  6 2        iv1   dv2   include1 ==… includ… scale(… lm(d… linear… iv1    0.0676
#>  7 2        iv1   dv2   include1 ==… includ… scale(… lm(d… linear… mod    0.0835
#>  8 2        iv1   dv2   include1 ==… includ… scale(… lm(d… linear… iv1:…  0.0422
#>  9 3        iv2   dv1   include1 ==… includ… scale(… lm(d… linear… (Int…  0.0657
#> 10 3        iv2   dv1   include1 ==… includ… scale(… lm(d… linear… iv2   -0.0995
#> # … with 182 more rows, 3 more variables: std.error <dbl>, statistic <dbl>,
#> #   p.value <dbl>, and abbreviated variable names ¹​include2, ²​include3,
#> #   ³​model_meta, ⁴​estimate
```

### Condense

Unpacking specifications alongside specific results allows us to examine
the effects of our pipeline decisions.

A powerful way to organize these results is to `condense` a specific
results column, say our predictor regression coefficient, over the
entire multiverse. `condense()` takes a result column and summarizes it
with the `.how` argument, which takes a list in the form of
`list(<a name you pick> = <summary function>)`.

`.how` will create a column named like so
`<column being condsensed>_<summary function name provided>"`. For this
case, we have `estimate_mean` and `estimate_median`.

``` r
multiverse_results |> 
  reveal(.what = lm_fitted, .which = lm_tidy, .unpack_specs = TRUE) |> 
  filter(str_detect(term, "iv")) |> 
  condense(estimate, list(mean = mean, median = median))
#> # A tibble: 1 × 2
#>   estimate_mean estimate_median
#>           <dbl>           <dbl>
#> 1       0.00337          0.0181
```

Here, we have filtered our multiverse results to look at our predictors
`iv*` to see what the mean and median effect was (over all combinations
of decisions) on our outcomes.

However, we had three versions of our predictor and two outcomes, so
combining `dplyr::group_by()` with `condense()` might be more
informative:

``` r
multiverse_results |> 
  reveal(.what = lm_fitted, .which = lm_tidy, .unpack_specs = TRUE) |> 
  filter(str_detect(term, "iv")) |>
  group_by(ivs, dvs) |> 
  condense(estimate, list(mean = mean, median = median))
#> # A tibble: 6 × 4
#> # Groups:   ivs [3]
#>   ivs   dvs   estimate_mean estimate_median
#>   <chr> <chr>         <dbl>           <dbl>
#> 1 iv1   dv1         0.0211        0.0297   
#> 2 iv1   dv2         0.0455        0.0454   
#> 3 iv2   dv1        -0.0320       -0.0398   
#> 4 iv2   dv2        -0.0107       -0.0112   
#> 5 iv3   dv1         0.00379       0.0000711
#> 6 iv3   dv2        -0.00761      -0.00634
```

If we were interested in all the terms of the model, we can leverage
`group_by` further:

``` r
multiverse_results |> 
  reveal(.what = lm_fitted, .which = lm_tidy, .unpack_specs = TRUE) |> 
  group_by(term, ivs, dvs) |> 
  condense(estimate, list(mean = mean, median = median))
#> # A tibble: 24 × 5
#> # Groups:   term, ivs [12]
#>    term        ivs   dvs   estimate_mean estimate_median
#>    <chr>       <chr> <chr>         <dbl>           <dbl>
#>  1 (Intercept) iv1   dv1          0.0617         0.0596 
#>  2 (Intercept) iv1   dv2         -0.0136        -0.0118 
#>  3 (Intercept) iv2   dv1          0.0558         0.0563 
#>  4 (Intercept) iv2   dv2         -0.0156        -0.0146 
#>  5 (Intercept) iv3   dv1          0.0511         0.0515 
#>  6 (Intercept) iv3   dv2         -0.0117        -0.00949
#>  7 iv1         iv1   dv1         -0.0143        -0.0115 
#>  8 iv1         iv1   dv2          0.0442         0.0430 
#>  9 iv1:mod     iv1   dv1          0.0566         0.0591 
#> 10 iv1:mod     iv1   dv2          0.0468         0.0454 
#> # … with 14 more rows
```

## Learning more

There are many other features of `multitool`, such as including
pre-processing steps and/or post-processing to your blueprint. You can
also conduct multiverse-style descriptive analyses or measurement
analyses.

## Other related packages

- [`specr`](https://masurp.github.io/specr/index.html)
- [`multiverse`](https://mucollective.github.io/multiverse/)
- [`mverse`](https://mverseanalysis.github.io/mverse/index.html)
