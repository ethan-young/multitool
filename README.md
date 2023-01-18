
<!-- README.md is generated from README.Rmd. Please edit that file -->

# multitool

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/multitool)](https://CRAN.R-project.org/package=multitool)
<!-- badges: end -->

The goal of `multitool` is to provide a set of tools for designing and
running multiverse-style analyses. There are other packages that
accomplish this goal well (e.g., `specr`, `multiverse`), but I’ve found
navigating the multiverse can be a tricky.

My goal with this package is to create an incremental workflow for
slowly building up, keeping track of, and unpacking multiverse analyses
and results.

I designed `multitool` to help users take a single use case (e.g., a
single analysis pipeline) and expand it into a workflow to include
alternative versions of the same analysis.

For example, imagine you would like to take some data, remove outliers,
transform variables, run a linear model, do a post-hoc analysis, and
plot the results. `multitool` can take theses tasks and transform them
into a *specification blueprint*, which provides instructions for
running your analysis pipeline.

The functions were designed to play nice with the `tidyverse` and
require using the base R pipe (see below). This makes it easy to quickly
convert a single analysis into a multiverse analysis.

## Basic components

My vision of a multiverse workflow contains three parts.

1.  **Base data:** original dataset waiting for further processing
2.  **specification blueprint:** (also termed specification grid) a
    blueprint/map/recipe or whatever you want to call it. These are the
    instructions for what to do.
3.  **Multiverse results:** a table of results after feeding the base
    data to the blueprint.

A defining feature of `multitool` is that it saves intermediate code.
This allows the user to grab the *code that produces a result* and
inspect it for accuracy, errors, or simply for peace of mind. By quickly
grabbing code, the user can iterate between creating their blueprint and
checking that the code works as intended.

`multitool` allows the user to model data however they’d like. The user
is responsible for loading the relevant modeling packages. Regardless of
your model choice, `multitool` will capture your code and build a
pipeline.

Finally, multiverse analyses were originally intended to look at how
model parameters shift as a function of arbitrary analysis decisions.
However, any computation might change depending on how you slice and
dice the data. For this reason, I also extended the package to allow for
the computations of descriptive, correlation, and reliability analysis
alongside a particular modelling pipeline.

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

## Simulate some data

Image we have some data with several predictor variables, moderators,
covariates, and dependent measures. We want to know if our predictors
(`ivs`) interact with our moderators (`mods`) to predict the outcome
(`dvs`).

But we have three measures of our predictor, three measures of our
moderator, and two versions of our outcome. Our predictors are different
measures of the same construct and our moderators tap the same
construct.

In addition, because we collected messy data from the real world (not
really but let’s pretend), we have some idea of exclusions we might need
to make (e.g., `include1`, `include2`, `include3`).

``` r
the_data <-
  data.frame(
    id   = 1:500,
    iv1  = rnorm(500),
    iv2  = rnorm(500),
    iv3  = rnorm(500),
    mod1 = rnorm(500),
    mod2 = rnorm(500),
    mod3 = rnorm(500),
    cov1 = rnorm(500),
    cov2 = rnorm(500),
    dv1  = rnorm(500),
    dv2  = rnorm(500),
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
    include2 != 2,           # 
    scale(include3) > -2.5   # --
  )

# Preprocess the data
preprocessed <- 
  filtered_data |> 
  mutate(
    iv1 = as.numeric(scale(iv1)), # standardize predictor
    mod1 = as.numeric(scale(mod1)) # standardize moderator
  )

# Model the data
my_model <- lm(dv1 ~ iv1 * mod1, data = preprossed_data)

# Post-process the data (e.g., for plotting)
my_model_points <- 
  predict(
    my_model, 
    newdata = expand_grid(iv1 = c(-1,1), mod1 = c(-1,1)), 
    interval = "confidence"
  )
```

But what if there are valid alternative alternatives to this pipeline?

For example, using `iv2` instead of `iv1` or only using two exclusion
criteria instead of three?

A sensible approach would be to copy the code above, paste it, and edit
with different decisions. However, this quickly become tedious. It adds
many lines of code, many new objects, and is difficult to keep track of
in a systematic way.

Enter `multitool`.

With `multitool`, the above analysis pipeline can be transformed into a
grid – a specification blueprint – for exploring all combinations of
sensible data decisions in a pipeline. It was designed to leverage
already written code (e.g., the `filter` statement above) to create a
multiverse of data analysis pipelines.

### Filtering specifications

Our example above has three exclusion criteria. If we don’t know which
are important, for example, because they are based on arbitrary ‘rules
of thumb’ (that may or may not have inherent wisdom) or we don’t know if
including/excluding these cases is valid, we can generate all
combinations:

``` r
the_data |> 
  add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5)
#> # A tibble: 7 × 3
#>   type    group    code                          
#>   <chr>   <chr>    <chr>                         
#> 1 filters include1 include1 == 0                 
#> 2 filters include1 include1 %in% unique(include1)
#> 3 filters include2 include2 != 3                 
#> 4 filters include2 include2 != 2                 
#> 5 filters include2 include2 %in% unique(include2)
#> 6 filters include3 scale(include3) > -2.5        
#> 7 filters include3 include3 %in% unique(include3)
```

The output above is a simple `tibble` (i.e., `data.frame`) containing
three columns. Each row is a possible filter: the `type` column refers
to the type of blueprint specification (see below for types other than
filters), the `group` refers to the variable in the base data frame (in
our case `the_data`) for which the filter applies, and the `code` column
contains the code needed to execute the filter.

For filtering decisions (e.g., exclusion criteria), a ‘do nothing’
alternative is always generated.

For example, perhaps some observations belong to a subgroup,
`include1 == 1`. We may or may not have good reason to exclude these
cases (this depends on the specific situation).

But imagine that we don’t know if we should include them or not. When
`include1 == 1` is added to `add_filters()`, the ‘do nothing’
alternative `include1 %in% unique(include1)` is automatically generated
so you can compare including versus excluding cases based on a
criterion.

### Adding alternative analysis variables

Most multiverse-style analyses explore a range of exclusion criteria and
their alternatives. However, sometimes alternative versions of a
variable are also included.

In the social sciences, it is fairly common to have many measures of
roughly the same construct (i.e., measured variable). For example, a
happiness researcher might measure positive mood, life satisfaction,
and/or a single item measuring happiness (e.g., ‘how happy do your
feel?’).

If you want to explore the output of your pipeline with differing
versions of a variable, you can use ‘add_variables()’.

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

### Building up the blueprint

You can harness the real power of `multitool` by piping specification
statements. For example, perhaps we want to explore our exclusion
criteria alternatives across different versions of our predictor
variable. We can simply pipe new blueprint specifications into each
other like so:

``` r
the_data |>
  add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |> 
  add_variables(var_group = "ivs", iv1, iv2, iv3)
#> # A tibble: 10 × 3
#>    type      group    code                          
#>    <chr>     <chr>    <chr>                         
#>  1 filters   include1 include1 == 0                 
#>  2 filters   include1 include1 %in% unique(include1)
#>  3 filters   include2 include2 != 3                 
#>  4 filters   include2 include2 != 2                 
#>  5 filters   include2 include2 %in% unique(include2)
#>  6 filters   include3 scale(include3) > -2.5        
#>  7 filters   include3 include3 %in% unique(include3)
#>  8 variables ivs      iv1                           
#>  9 variables ivs      iv2                           
#> 10 variables ivs      iv3
```

Notice that we now have a specification blueprint with both exclusion
alternatives and variable alternatives.

### Adding a model

The whole point of building a specification blueprint is to eventually
feed it to a model and examine the results.

You can add a model to your blueprint in a similar fashion to adding
filtering decisions or variable alternatives by using `add_model()`.

I designed `add_model()` so the user can simply paste a model function.
For example, our call to `lm()` can be simply pasted into `add_model()`:

``` r
the_data |>
  add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |> 
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_model(lm(dv1 ~ iv1 * mod1))
#> # A tibble: 11 × 3
#>    type      group    code                          
#>    <chr>     <chr>    <chr>                         
#>  1 filters   include1 include1 == 0                 
#>  2 filters   include1 include1 %in% unique(include1)
#>  3 filters   include2 include2 != 3                 
#>  4 filters   include2 include2 != 2                 
#>  5 filters   include2 include2 %in% unique(include2)
#>  6 filters   include3 scale(include3) > -2.5        
#>  7 filters   include3 include3 %in% unique(include3)
#>  8 variables ivs      iv1                           
#>  9 variables ivs      iv2                           
#> 10 variables ivs      iv3                           
#> 11 models    model    lm(dv1 ~ iv1 * mod1)
```

Above, the model is completely unquoted. It also has no `data` argument.
This is intentional; `multitool` is tracking the base data set along the
way (so you don’t have to).

Note that you can still quote the model formula, if that is more your
style.

``` r
the_data |>
  add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |> 
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_model("lm(dv1 ~ iv1 * mod1)")
#> # A tibble: 11 × 3
#>    type      group    code                          
#>    <chr>     <chr>    <chr>                         
#>  1 filters   include1 include1 == 0                 
#>  2 filters   include1 include1 %in% unique(include1)
#>  3 filters   include2 include2 != 3                 
#>  4 filters   include2 include2 != 2                 
#>  5 filters   include2 include2 %in% unique(include2)
#>  6 filters   include3 scale(include3) > -2.5        
#>  7 filters   include3 include3 %in% unique(include3)
#>  8 variables ivs      iv1                           
#>  9 variables ivs      iv2                           
#> 10 variables ivs      iv3                           
#> 11 models    model    lm(dv1 ~ iv1 * mod1)
```

To make sure your `add_variables()` works properly, `add_model()` was
designed to interpret `glue::glue()` syntax. For example:

``` r
the_data |>
  add_filters(include1 == 0, include2 != 3, include2 != 2, scale(include3) > -2.5) |> 
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_model(lm(dv1 ~ {ivs} * mod1))
#> # A tibble: 11 × 3
#>    type      group    code                          
#>    <chr>     <chr>    <chr>                         
#>  1 filters   include1 include1 == 0                 
#>  2 filters   include1 include1 %in% unique(include1)
#>  3 filters   include2 include2 != 3                 
#>  4 filters   include2 include2 != 2                 
#>  5 filters   include2 include2 %in% unique(include2)
#>  6 filters   include3 scale(include3) > -2.5        
#>  7 filters   include3 include3 %in% unique(include3)
#>  8 variables ivs      iv1                           
#>  9 variables ivs      iv2                           
#> 10 variables ivs      iv3                           
#> 11 models    model    lm(dv1 ~ {ivs} * mod1)
```

This allows `multitool` to insert the correct version of each variable
specified in a `add_variables()` statement. Make sure to use embrace the
variable with the `var_group` name from `add_variables`.

Here, our model `glue::glue()` syntax is `lm(dv1 ~ {ivs} * mod1)`, where
`{ivs}` tells `multitool` to insert the current version of the `ivs`
into the model.

### Finalizing the specification blueprint

The final step in making your blueprint is expanding all your
specifications into all possible combinations. You can do this by
calling `expand_decisions()` at the end of your blueprint pipeline:

``` r
full_pipeline <- 
  the_data |>
  add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5) |> 
  add_variables(var_group = "ivs", iv1, iv2, iv3) |> 
  add_model(lm(dv1 ~ {ivs} * mod1)) |> 
  expand_decisions()
```

The result is an expanded `tibble` with 1 row per unique decision and
columns for each major blueprint category.

In our example, we have alternative variables, filters, and a model to
run. Note that we have 3 filtering decisions (each with two
combinations) and 3 versions of our predictor. This means our blueprint
should have $2*2*2*3$ rows.

``` r
2*2*2*3 == nrow(full_pipeline)
#> [1] TRUE
```

Our blueprint uses list columns to organize informatino. You can view
each list column by using `tidyr::unnest(<column name>)`. For example,
we can look at the filters:

``` r
full_pipeline |> unnest(filters)
#> # A tibble: 24 × 6
#>    decision variables        include1      include2             inclu…¹ models  
#>    <chr>    <list>           <chr>         <chr>                <chr>   <list>  
#>  1 1        <tibble [1 × 1]> include1 == 0 include2 != 3        scale(… <tibble>
#>  2 2        <tibble [1 × 1]> include1 == 0 include2 != 3        scale(… <tibble>
#>  3 3        <tibble [1 × 1]> include1 == 0 include2 != 3        scale(… <tibble>
#>  4 4        <tibble [1 × 1]> include1 == 0 include2 != 3        includ… <tibble>
#>  5 5        <tibble [1 × 1]> include1 == 0 include2 != 3        includ… <tibble>
#>  6 6        <tibble [1 × 1]> include1 == 0 include2 != 3        includ… <tibble>
#>  7 7        <tibble [1 × 1]> include1 == 0 include2 %in% uniqu… scale(… <tibble>
#>  8 8        <tibble [1 × 1]> include1 == 0 include2 %in% uniqu… scale(… <tibble>
#>  9 9        <tibble [1 × 1]> include1 == 0 include2 %in% uniqu… scale(… <tibble>
#> 10 10       <tibble [1 × 1]> include1 == 0 include2 %in% uniqu… includ… <tibble>
#> # … with 14 more rows, and abbreviated variable name ¹​include3
```

Or we could look at the models:

``` r
full_pipeline |> unnest(models)
#> # A tibble: 24 × 4
#>    decision variables        filters          model               
#>    <chr>    <list>           <list>           <chr>               
#>  1 1        <tibble [1 × 1]> <tibble [1 × 3]> lm(dv1 ~ iv1 * mod1)
#>  2 2        <tibble [1 × 1]> <tibble [1 × 3]> lm(dv1 ~ iv2 * mod1)
#>  3 3        <tibble [1 × 1]> <tibble [1 × 3]> lm(dv1 ~ iv3 * mod1)
#>  4 4        <tibble [1 × 1]> <tibble [1 × 3]> lm(dv1 ~ iv1 * mod1)
#>  5 5        <tibble [1 × 1]> <tibble [1 × 3]> lm(dv1 ~ iv2 * mod1)
#>  6 6        <tibble [1 × 1]> <tibble [1 × 3]> lm(dv1 ~ iv3 * mod1)
#>  7 7        <tibble [1 × 1]> <tibble [1 × 3]> lm(dv1 ~ iv1 * mod1)
#>  8 8        <tibble [1 × 1]> <tibble [1 × 3]> lm(dv1 ~ iv2 * mod1)
#>  9 9        <tibble [1 × 1]> <tibble [1 × 3]> lm(dv1 ~ iv3 * mod1)
#> 10 10       <tibble [1 × 1]> <tibble [1 × 3]> lm(dv1 ~ iv1 * mod1)
#> # … with 14 more rows
```

Notice that, with the `glue::glue()` syntax, different versions of our
predictors were inserted appropriately. You can check their
correspondence by using `unnest()` on both the models and variable list
columns:

``` r
full_pipeline |> unnest(c(variables, models))
#> # A tibble: 24 × 4
#>    decision ivs   filters          model               
#>    <chr>    <chr> <list>           <chr>               
#>  1 1        iv1   <tibble [1 × 3]> lm(dv1 ~ iv1 * mod1)
#>  2 2        iv2   <tibble [1 × 3]> lm(dv1 ~ iv2 * mod1)
#>  3 3        iv3   <tibble [1 × 3]> lm(dv1 ~ iv3 * mod1)
#>  4 4        iv1   <tibble [1 × 3]> lm(dv1 ~ iv1 * mod1)
#>  5 5        iv2   <tibble [1 × 3]> lm(dv1 ~ iv2 * mod1)
#>  6 6        iv3   <tibble [1 × 3]> lm(dv1 ~ iv3 * mod1)
#>  7 7        iv1   <tibble [1 × 3]> lm(dv1 ~ iv1 * mod1)
#>  8 8        iv2   <tibble [1 × 3]> lm(dv1 ~ iv2 * mod1)
#>  9 9        iv3   <tibble [1 × 3]> lm(dv1 ~ iv3 * mod1)
#> 10 10       iv1   <tibble [1 × 3]> lm(dv1 ~ iv1 * mod1)
#> # … with 14 more rows
```

## Validate your blueprint

`multitool` specification blueprint have a special feature: it captures
and generates the code to run individual pipelines.

A special set of functions with the `show_code_*` prefix allow you to
see the code that will be executed for a single pipeline. For example,
we can look at our filtering code for the first decision of our
blueprint:

``` r
full_pipeline |> show_code_filter(decision_num = 1)
#> the_data |> 
#>   filter(include1 == 0, include2 != 3, scale(include3) > -2.5)
```

These functions allow you to generate the relevant code along the
analysis pipeline. For example, we can look at our model pipeline for
decision 17 using `show_code_model(decision_num = 17)`:

``` r
full_pipeline |> show_code_model(decision_num = 17)
#> the_data |> 
#>   filter(include1 %in% unique(include1), include2 != 3, include3 %in% unique(include3)) |> 
#>   lm(dv1 ~ iv2 * mod1, data = _)
```

Setting the `copy` argument to `TRUE` allows you to send the code
straight to your clipboard. You can paste it into the script or console
for testing/editing.

You can also run individual decisions to test that they work. See below
for details about the results.

``` r
run_universe_model(full_pipeline, 1)
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
multiverse_results <- run_multiverse(full_pipeline)
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■ 83% | ETA: 0s
#> ■■■■■■■■■■■■■■■■■■■■■■■■■■■■■ 92% | ETA: 0s

multiverse_results
#> # A tibble: 24 × 3
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
#> # … with 14 more rows
```

The result will be another `tibble` with various list columns.

It will always contain a list column named `specifications`. This
contains all the information you generated in your blueprint. Next,
there will be one list column per model fitted, labelled with a
“\_fitted” suffix like so`<function name>_fitted`.

Here, we ran a `lm()` so our results are contained in `lm_fitted`.

### Unpacking a multiverse analysis

There are two main ways to unpack and examine `multitool` results. The
first is by using `tidyr::unnest()` (similar to unpacking the
specification blueprint earlier).

#### Unnest

``` r
multiverse_results |> unnest(lm_fitted)
#> # A tibble: 24 × 7
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
#> # … with 14 more rows, and abbreviated variable names ¹​lm_glance, ²​lm_warnings,
#> #   ³​lm_messages
```

Inside a `<model function>_fitted` column (here `lm_fitted`),
`multitool` gives us 4 columns.

The first column is always the full code pipeline executed to return
that row’s set of results: `lm_code`. The next are results passed to
`broom` (if `tidy` and/or `glance` methods exist). For `lm`, we have
`lm_tidy` and `lm_glance`.

``` r
multiverse_results |> unnest(lm_fitted) |> unnest(lm_tidy)
#> # A tibble: 96 × 11
#>    decision specificati…¹ lm_code term  estim…² std.e…³ stati…⁴ p.value lm_gla…⁵
#>    <chr>    <list>        <glue>  <chr>   <dbl>   <dbl>   <dbl>   <dbl> <list>  
#>  1 1        <tibble>      the_da… (Int… -0.0473  0.0610  -0.776  0.438  <tibble>
#>  2 1        <tibble>      the_da… iv1    0.0169  0.0588   0.287  0.774  <tibble>
#>  3 1        <tibble>      the_da… mod1   0.0321  0.0646   0.497  0.619  <tibble>
#>  4 1        <tibble>      the_da… iv1:… -0.120   0.0716  -1.68   0.0941 <tibble>
#>  5 2        <tibble>      the_da… (Int… -0.0500  0.0612  -0.818  0.414  <tibble>
#>  6 2        <tibble>      the_da… iv2   -0.0106  0.0656  -0.161  0.872  <tibble>
#>  7 2        <tibble>      the_da… mod1   0.0265  0.0647   0.409  0.683  <tibble>
#>  8 2        <tibble>      the_da… iv2:…  0.0645  0.0618   1.04   0.297  <tibble>
#>  9 3        <tibble>      the_da… (Int… -0.0511  0.0609  -0.838  0.402  <tibble>
#> 10 3        <tibble>      the_da… iv3   -0.104   0.0618  -1.68   0.0940 <tibble>
#> # … with 86 more rows, 2 more variables: lm_warnings <list>,
#> #   lm_messages <list>, and abbreviated variable names ¹​specifications,
#> #   ²​estimate, ³​std.error, ⁴​statistic, ⁵​lm_glance
```

The `lm_tidy` (or `<model function>_tidy`) column gives us the main
results of `lm()` per decision. These include terms, estimates, standard
errors, and p-values. `lm_glance` (or `<model function>_glance`) column
gives us model fit statistics (among other things):

``` r
multiverse_results |> unnest(lm_fitted) |> unnest(lm_glance)
#> # A tibble: 24 × 18
#>    decision specificat…¹ lm_code lm_tidy  r.squ…² adj.r.…³ sigma stati…⁴ p.value
#>    <chr>    <list>       <glue>  <list>     <dbl>    <dbl> <dbl>   <dbl>   <dbl>
#>  1 1        <tibble>     the_da… <tibble> 1.07e-2  4.86e-4  1.04   1.05    0.372
#>  2 2        <tibble>     the_da… <tibble> 4.39e-3 -5.87e-3  1.05   0.428   0.733
#>  3 3        <tibble>     the_da… <tibble> 1.05e-2  2.50e-4  1.04   1.02    0.382
#>  4 4        <tibble>     the_da… <tibble> 1.07e-2  5.73e-4  1.04   1.06    0.368
#>  5 5        <tibble>     the_da… <tibble> 4.38e-3 -5.84e-3  1.04   0.429   0.733
#>  6 6        <tibble>     the_da… <tibble> 1.05e-2  3.01e-4  1.04   1.03    0.380
#>  7 7        <tibble>     the_da… <tibble> 6.81e-4 -5.95e-3  1.03   0.103   0.959
#>  8 8        <tibble>     the_da… <tibble> 1.20e-3 -5.43e-3  1.03   0.181   0.909
#>  9 9        <tibble>     the_da… <tibble> 2.63e-3 -3.98e-3  1.03   0.398   0.754
#> 10 10       <tibble>     the_da… <tibble> 6.74e-4 -5.93e-3  1.02   0.102   0.959
#> # … with 14 more rows, 9 more variables: df <dbl>, logLik <dbl>, AIC <dbl>,
#> #   BIC <dbl>, deviance <dbl>, df.residual <int>, nobs <int>,
#> #   lm_warnings <list>, lm_messages <list>, and abbreviated variable names
#> #   ¹​specifications, ²​r.squared, ³​adj.r.squared, ⁴​statistic
```

#### Reveal

I wrote wrappers around the `unnest()` workflow. The main function is
`reveal()`. Pass a multiverse results `tibble` to `reveal()` and tell it
which columns to grab by indicating the column name in the `.what`
argument:

``` r
multiverse_results |> reveal(.what = lm_fitted)
#> # A tibble: 24 × 7
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
#> # … with 14 more rows, and abbreviated variable names ¹​lm_glance, ²​lm_warnings,
#> #   ³​lm_messages
```

If you want to get straight to a tidied result you can specify a
sub-list with the `.which` argument:

``` r
multiverse_results |> reveal(.what = lm_fitted, .which = lm_tidy)
#> # A tibble: 96 × 7
#>    decision specifications   term        estimate std.error statistic p.value
#>    <chr>    <list>           <chr>          <dbl>     <dbl>     <dbl>   <dbl>
#>  1 1        <tibble [1 × 3]> (Intercept)  -0.0473    0.0610    -0.776  0.438 
#>  2 1        <tibble [1 × 3]> iv1           0.0169    0.0588     0.287  0.774 
#>  3 1        <tibble [1 × 3]> mod1          0.0321    0.0646     0.497  0.619 
#>  4 1        <tibble [1 × 3]> iv1:mod1     -0.120     0.0716    -1.68   0.0941
#>  5 2        <tibble [1 × 3]> (Intercept)  -0.0500    0.0612    -0.818  0.414 
#>  6 2        <tibble [1 × 3]> iv2          -0.0106    0.0656    -0.161  0.872 
#>  7 2        <tibble [1 × 3]> mod1          0.0265    0.0647     0.409  0.683 
#>  8 2        <tibble [1 × 3]> iv2:mod1      0.0645    0.0618     1.04   0.297 
#>  9 3        <tibble [1 × 3]> (Intercept)  -0.0511    0.0609    -0.838  0.402 
#> 10 3        <tibble [1 × 3]> iv3          -0.104     0.0618    -1.68   0.0940
#> # … with 86 more rows
```

You can also choose to expand your specification blueprint with
`.unpack_specs = TRUE` to see which decisions produced what result:

``` r
multiverse_results |> 
  reveal(.what = lm_fitted, .which = lm_tidy, .unpack_specs = TRUE)
#> # A tibble: 96 × 11
#>    decision ivs   include1   inclu…¹ inclu…² model term  estim…³ std.e…⁴ stati…⁵
#>    <chr>    <chr> <chr>      <chr>   <chr>   <chr> <chr>   <dbl>   <dbl>   <dbl>
#>  1 1        iv1   include1 … includ… scale(… lm(d… (Int… -0.0473  0.0610  -0.776
#>  2 1        iv1   include1 … includ… scale(… lm(d… iv1    0.0169  0.0588   0.287
#>  3 1        iv1   include1 … includ… scale(… lm(d… mod1   0.0321  0.0646   0.497
#>  4 1        iv1   include1 … includ… scale(… lm(d… iv1:… -0.120   0.0716  -1.68 
#>  5 2        iv2   include1 … includ… scale(… lm(d… (Int… -0.0500  0.0612  -0.818
#>  6 2        iv2   include1 … includ… scale(… lm(d… iv2   -0.0106  0.0656  -0.161
#>  7 2        iv2   include1 … includ… scale(… lm(d… mod1   0.0265  0.0647   0.409
#>  8 2        iv2   include1 … includ… scale(… lm(d… iv2:…  0.0645  0.0618   1.04 
#>  9 3        iv3   include1 … includ… scale(… lm(d… (Int… -0.0511  0.0609  -0.838
#> 10 3        iv3   include1 … includ… scale(… lm(d… iv3   -0.104   0.0618  -1.68 
#> # … with 86 more rows, 1 more variable: p.value <dbl>, and abbreviated variable
#> #   names ¹​include2, ²​include3, ³​estimate, ⁴​std.error, ⁵​statistic
```

#### Condense

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
#> 1       -0.0248         -0.0135
```

Here, we have filtered our multiverse results to look at our predictors
`iv*` to see what the mean and median effect was (over all combinations
of decisions) on our outcome.

However, we had three versions of our predictor, so combining
`dplyr::group_by()` with `condense()` might be more informative:

``` r
multiverse_results |> 
  reveal(.what = lm_fitted, .which = lm_tidy, .unpack_specs = TRUE) |> 
  filter(str_detect(term, "iv")) |>
  group_by(ivs) |> 
  condense(estimate, list(mean = mean, median = median))
#> # A tibble: 3 × 3
#>   ivs   estimate_mean estimate_median
#>   <chr>         <dbl>           <dbl>
#> 1 iv1        -0.0189          0.00828
#> 2 iv2        -0.00131         0.00231
#> 3 iv3        -0.0543         -0.0509
```

If we were interested in all the terms of the model, we can leverage
`group_by` further:

``` r
multiverse_results |> 
  reveal(.what = lm_fitted, .which = lm_tidy, .unpack_specs = TRUE) |> 
  group_by(term, ivs) |> 
  condense(estimate, list(mean = mean, median = median))
#> # A tibble: 12 × 4
#> # Groups:   term [8]
#>    term        ivs   estimate_mean estimate_median
#>    <chr>       <chr>         <dbl>           <dbl>
#>  1 (Intercept) iv1         -0.0198         -0.0173
#>  2 (Intercept) iv2         -0.0216         -0.0192
#>  3 (Intercept) iv3         -0.0212         -0.0189
#>  4 iv1         iv1          0.0130          0.0137
#>  5 iv1:mod1    iv1         -0.0508         -0.0482
#>  6 iv2         iv2         -0.0402         -0.0410
#>  7 iv2:mod1    iv2          0.0376          0.0354
#>  8 iv3         iv3         -0.0770         -0.0777
#>  9 iv3:mod1    iv3         -0.0316         -0.0268
#> 10 mod1        iv1          0.0199          0.0184
#> 11 mod1        iv2          0.0179          0.0160
#> 12 mod1        iv3          0.0168          0.0157
```

## Learning more

There are many other features of `multitool`, such as including
pre-processing steps and/or post-processing to your blueprint. You can
also conduct multiverse-style descriptive analyses or measurement
analyses.
