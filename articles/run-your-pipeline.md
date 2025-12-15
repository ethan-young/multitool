# Run your Pipeline

Once you have built your full specification blueprint and feel
comfortable with how the pipeline is executed, you can implement a full
multiverse-style analysis.

Simply use `run_multiverse(<your expanded grid object>)`:

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

# expand the pipeline
expanded_pipeline <- expand_decisions(full_pipeline)

# Run the multiverse
multiverse_results <- analyze_grid(expanded_pipeline)

multiverse_results
#> # A tibble: 48 × 5
#>    decision specifications   model_fitted     pipeline_code    timing_logs     
#>       <dbl> <list>           <list>           <list>           <list>          
#>  1        1 <tibble [1 × 3]> <tibble [1 × 5]> <tibble [1 × 4]> <tibble [1 × 4]>
#>  2        2 <tibble [1 × 3]> <tibble [1 × 5]> <tibble [1 × 4]> <tibble [1 × 4]>
#>  3        3 <tibble [1 × 3]> <tibble [1 × 5]> <tibble [1 × 4]> <tibble [1 × 4]>
#>  4        4 <tibble [1 × 3]> <tibble [1 × 5]> <tibble [1 × 4]> <tibble [1 × 4]>
#>  5        5 <tibble [1 × 3]> <tibble [1 × 5]> <tibble [1 × 4]> <tibble [1 × 4]>
#>  6        6 <tibble [1 × 3]> <tibble [1 × 5]> <tibble [1 × 4]> <tibble [1 × 4]>
#>  7        7 <tibble [1 × 3]> <tibble [1 × 5]> <tibble [1 × 4]> <tibble [1 × 4]>
#>  8        8 <tibble [1 × 3]> <tibble [1 × 5]> <tibble [1 × 4]> <tibble [1 × 4]>
#>  9        9 <tibble [1 × 3]> <tibble [1 × 5]> <tibble [1 × 4]> <tibble [1 × 4]>
#> 10       10 <tibble [1 × 3]> <tibble [1 × 5]> <tibble [1 × 4]> <tibble [1 × 4]>
#> # ℹ 38 more rows
```

The result will be another `tibble` with various list columns.

It will always contain a list column named `specifications` containing
all the information you generated in your blueprint. Next, there will a
list column for your fitted model fitted, labelled `model_fitted`.

## Unpacking a multiverse analysis

There are two main ways to unpack and examine `multitool` results. The
first is by using
[`tidyr::unnest()`](https://tidyr.tidyverse.org/reference/unnest.html).

### Unnest

Inside the `model_fitted` column, `multitool` gives us 4 columns:
`model_parameters`, `model_performance`, `model_warnings`, and
`model_messages`.

``` r
multiverse_results |> unnest(model_fitted)
#> # A tibble: 48 × 9
#>    decision specifications   model_function model_parameters  model_performance
#>       <dbl> <list>           <chr>          <list>            <list>           
#>  1        1 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  2        2 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  3        3 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  4        4 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  5        5 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  6        6 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  7        7 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  8        8 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  9        9 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#> 10       10 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#> # ℹ 38 more rows
#> # ℹ 4 more variables: model_warnings <list>, model_messages <list>,
#> #   pipeline_code <list>, timing_logs <list>
```

The `model_parameters` column gives you the result of calling
[`parameters::parameters()`](https://easystats.github.io/parameters/reference/model_parameters.html)
on each model in your grid, which is a `data.frame` of model
coefficients and their associated standard errors, confidence intervals,
test statistic, and p-values.

``` r
multiverse_results |> 
  unnest(model_fitted) |> 
  unnest(model_parameters)
#> # A tibble: 192 × 21
#>    decision specifications   model_function parameter unstd_coef     se unstd_ci
#>       <dbl> <list>           <chr>          <chr>          <dbl>  <dbl>    <dbl>
#>  1        1 <tibble [1 × 3]> lm             (Interce…   0.00102  0.0560     0.95
#>  2        1 <tibble [1 × 3]> lm             iv1        -0.000728 0.0538     0.95
#>  3        1 <tibble [1 × 3]> lm             mod         0.0584   0.0623     0.95
#>  4        1 <tibble [1 × 3]> lm             iv1:mod    -0.105    0.0585     0.95
#>  5        2 <tibble [1 × 3]> lm             (Interce…   0.0807   0.0575     0.95
#>  6        2 <tibble [1 × 3]> lm             iv1        -0.0230   0.0552     0.95
#>  7        2 <tibble [1 × 3]> lm             mod        -0.142    0.0640     0.95
#>  8        2 <tibble [1 × 3]> lm             iv1:mod    -0.0787   0.0601     0.95
#>  9        3 <tibble [1 × 3]> lm             (Interce…  -0.00802  0.0561     0.95
#> 10        3 <tibble [1 × 3]> lm             iv2         0.0229   0.0574     0.95
#> # ℹ 182 more rows
#> # ℹ 14 more variables: unstd_ci_low <dbl>, unstd_ci_high <dbl>, t <dbl>,
#> #   df_error <int>, p <dbl>, std_coef <dbl>, std_ci <dbl>, std_ci_low <dbl>,
#> #   std_ci_high <dbl>, model_performance <list>, model_warnings <list>,
#> #   model_messages <list>, pipeline_code <list>, timing_logs <list>
```

The `model_performance` column gives fit statistics, such as r² or AIC
and BIC values, computed by running
[`performance::performance()`](https://easystats.github.io/performance/reference/model_performance.html)
on each model in your grid.

``` r
multiverse_results |> 
  unnest(model_fitted) |>
  unnest(model_performance)
#> # A tibble: 48 × 15
#>    decision specifications   model_function model_parameters    AIC  AICc   BIC
#>       <dbl> <list>           <chr>          <list>            <dbl> <dbl> <dbl>
#>  1        1 <tibble [1 × 3]> lm             <tibble [4 × 13]>  866.  866.  885.
#>  2        2 <tibble [1 × 3]> lm             <tibble [4 × 13]>  883.  883.  901.
#>  3        3 <tibble [1 × 3]> lm             <tibble [4 × 13]>  868.  868.  887.
#>  4        4 <tibble [1 × 3]> lm             <tibble [4 × 13]>  878.  878.  896.
#>  5        5 <tibble [1 × 3]> lm             <tibble [4 × 13]>  867.  867.  886.
#>  6        6 <tibble [1 × 3]> lm             <tibble [4 × 13]>  883.  883.  901.
#>  7        7 <tibble [1 × 3]> lm             <tibble [4 × 13]>  870.  870.  889.
#>  8        8 <tibble [1 × 3]> lm             <tibble [4 × 13]>  886.  887.  905.
#>  9        9 <tibble [1 × 3]> lm             <tibble [4 × 13]>  872.  873.  891.
#> 10       10 <tibble [1 × 3]> lm             <tibble [4 × 13]>  881.  882.  900.
#> # ℹ 38 more rows
#> # ℹ 8 more variables: R2 <dbl>, R2_adjusted <dbl>, RMSE <dbl>, Sigma <dbl>,
#> #   model_warnings <list>, model_messages <list>, pipeline_code <list>,
#> #   timing_logs <list>
```

The `model_messages` and `model_warnings` columns contain information
provided by the modeling function. If something went wrong or you need
to know something about a particular model, these columns will have
captured messages and warnings printed by the modeling function.

### Reveal

I wrote wrappers around the
[`tidyr::unnest()`](https://tidyr.tidyverse.org/reference/unnest.html)
workflow. The main function is
[`reveal()`](https://ethan-young.github.io/multitool/reference/reveal.md).
Pass a multiverse results object to
[`reveal()`](https://ethan-young.github.io/multitool/reference/reveal.md)
and tell it which columns to grab by indicating the column name in the
`.what` argument:

``` r
multiverse_results |> 
  reveal(.what = model_fitted)
#> # A tibble: 48 × 9
#>    decision specifications   model_function model_parameters  model_performance
#>       <dbl> <list>           <chr>          <list>            <list>           
#>  1        1 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  2        2 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  3        3 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  4        4 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  5        5 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  6        6 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  7        7 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  8        8 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#>  9        9 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#> 10       10 <tibble [1 × 3]> lm             <tibble [4 × 13]> <tibble [1 × 7]> 
#> # ℹ 38 more rows
#> # ℹ 4 more variables: model_warnings <list>, model_messages <list>,
#> #   pipeline_code <list>, timing_logs <list>
```

If you want to get straight to a specific result you can specify a
sub-list with the `.which` argument:

``` r
multiverse_results |> 
  reveal(.what = model_fitted, .which = model_parameters)
#> # A tibble: 192 × 21
#>    decision specifications   model_function parameter unstd_coef     se unstd_ci
#>       <dbl> <list>           <chr>          <chr>          <dbl>  <dbl>    <dbl>
#>  1        1 <tibble [1 × 3]> lm             (Interce…   0.00102  0.0560     0.95
#>  2        1 <tibble [1 × 3]> lm             iv1        -0.000728 0.0538     0.95
#>  3        1 <tibble [1 × 3]> lm             mod         0.0584   0.0623     0.95
#>  4        1 <tibble [1 × 3]> lm             iv1:mod    -0.105    0.0585     0.95
#>  5        2 <tibble [1 × 3]> lm             (Interce…   0.0807   0.0575     0.95
#>  6        2 <tibble [1 × 3]> lm             iv1        -0.0230   0.0552     0.95
#>  7        2 <tibble [1 × 3]> lm             mod        -0.142    0.0640     0.95
#>  8        2 <tibble [1 × 3]> lm             iv1:mod    -0.0787   0.0601     0.95
#>  9        3 <tibble [1 × 3]> lm             (Interce…  -0.00802  0.0561     0.95
#> 10        3 <tibble [1 × 3]> lm             iv2         0.0229   0.0574     0.95
#> # ℹ 182 more rows
#> # ℹ 14 more variables: unstd_ci_low <dbl>, unstd_ci_high <dbl>, t <dbl>,
#> #   df_error <int>, p <dbl>, std_coef <dbl>, std_ci <dbl>, std_ci_low <dbl>,
#> #   std_ci_high <dbl>, model_performance <list>, model_warnings <list>,
#> #   model_messages <list>, pipeline_code <list>, timing_logs <list>
```

### `reveal_model_*`

`multitool` will run and save anything you put in your pipeline but most
often, you will want to look at model parameters and/or performance. To
that end, there are a set of convenience functions for getting at the
most common multiverse results: `reveal_model_parameters`,
`reveal_model_performance`, `reveal_model_messages`, and
`reveal_model_warnings`.

`reveal_model_parameters` unpacks the model parameters in your
multiverse:

``` r
multiverse_results |> 
  reveal_model_parameters()
#> # A tibble: 192 × 21
#>    decision specifications   model_function parameter unstd_coef     se unstd_ci
#>       <dbl> <list>           <chr>          <chr>          <dbl>  <dbl>    <dbl>
#>  1        1 <tibble [1 × 3]> lm             (Interce…   0.00102  0.0560     0.95
#>  2        1 <tibble [1 × 3]> lm             iv1        -0.000728 0.0538     0.95
#>  3        1 <tibble [1 × 3]> lm             mod         0.0584   0.0623     0.95
#>  4        1 <tibble [1 × 3]> lm             iv1:mod    -0.105    0.0585     0.95
#>  5        2 <tibble [1 × 3]> lm             (Interce…   0.0807   0.0575     0.95
#>  6        2 <tibble [1 × 3]> lm             iv1        -0.0230   0.0552     0.95
#>  7        2 <tibble [1 × 3]> lm             mod        -0.142    0.0640     0.95
#>  8        2 <tibble [1 × 3]> lm             iv1:mod    -0.0787   0.0601     0.95
#>  9        3 <tibble [1 × 3]> lm             (Interce…  -0.00802  0.0561     0.95
#> 10        3 <tibble [1 × 3]> lm             iv2         0.0229   0.0574     0.95
#> # ℹ 182 more rows
#> # ℹ 14 more variables: unstd_ci_low <dbl>, unstd_ci_high <dbl>, t <dbl>,
#> #   df_error <int>, p <dbl>, std_coef <dbl>, std_ci <dbl>, std_ci_low <dbl>,
#> #   std_ci_high <dbl>, model_performance <list>, model_warnings <list>,
#> #   model_messages <list>, pipeline_code <list>, timing_logs <list>
```

`reveal_model_performance` unpacks the model performance:

``` r
multiverse_results |> 
  reveal_model_performance()
#> # A tibble: 48 × 15
#>    decision specifications   model_function model_parameters    AIC  AICc   BIC
#>       <dbl> <list>           <chr>          <list>            <dbl> <dbl> <dbl>
#>  1        1 <tibble [1 × 3]> lm             <tibble [4 × 13]>  866.  866.  885.
#>  2        2 <tibble [1 × 3]> lm             <tibble [4 × 13]>  883.  883.  901.
#>  3        3 <tibble [1 × 3]> lm             <tibble [4 × 13]>  868.  868.  887.
#>  4        4 <tibble [1 × 3]> lm             <tibble [4 × 13]>  878.  878.  896.
#>  5        5 <tibble [1 × 3]> lm             <tibble [4 × 13]>  867.  867.  886.
#>  6        6 <tibble [1 × 3]> lm             <tibble [4 × 13]>  883.  883.  901.
#>  7        7 <tibble [1 × 3]> lm             <tibble [4 × 13]>  870.  870.  889.
#>  8        8 <tibble [1 × 3]> lm             <tibble [4 × 13]>  886.  887.  905.
#>  9        9 <tibble [1 × 3]> lm             <tibble [4 × 13]>  872.  873.  891.
#> 10       10 <tibble [1 × 3]> lm             <tibble [4 × 13]>  881.  882.  900.
#> # ℹ 38 more rows
#> # ℹ 8 more variables: R2 <dbl>, R2_adjusted <dbl>, RMSE <dbl>, Sigma <dbl>,
#> #   model_warnings <list>, model_messages <list>, pipeline_code <list>,
#> #   timing_logs <list>
```

### Unpacking Specifications

You can also choose to expand your decision grid with `.unpack_specs` to
see which decisions produced what result. You have two options for
unpacking your decisions - `wide` or `long`. If you set
`.unpack_specs = 'wide'`, you get one column per decision variable. This
is exactly the same as how your decisions appeared in your grid.

``` r
multiverse_results |> 
  reveal_model_parameters(.unpack_specs = "wide")
#> # A tibble: 192 × 30
#>    decision ivs   dvs   include1   include2 include3 model model_meta model_args
#>       <dbl> <chr> <chr> <chr>      <chr>    <chr>    <chr> <chr>      <chr>     
#>  1        1 iv1   dv1   include1 … include… include… lm(d… linear mo… ""        
#>  2        1 iv1   dv1   include1 … include… include… lm(d… linear mo… ""        
#>  3        1 iv1   dv1   include1 … include… include… lm(d… linear mo… ""        
#>  4        1 iv1   dv1   include1 … include… include… lm(d… linear mo… ""        
#>  5        2 iv1   dv2   include1 … include… include… lm(d… linear mo… ""        
#>  6        2 iv1   dv2   include1 … include… include… lm(d… linear mo… ""        
#>  7        2 iv1   dv2   include1 … include… include… lm(d… linear mo… ""        
#>  8        2 iv1   dv2   include1 … include… include… lm(d… linear mo… ""        
#>  9        3 iv2   dv1   include1 … include… include… lm(d… linear mo… ""        
#> 10        3 iv2   dv1   include1 … include… include… lm(d… linear mo… ""        
#> # ℹ 182 more rows
#> # ℹ 21 more variables: model_standardize <chr>, model_perform <chr>,
#> #   model_function <chr>, parameter <chr>, unstd_coef <dbl>, se <dbl>,
#> #   unstd_ci <dbl>, unstd_ci_low <dbl>, unstd_ci_high <dbl>, t <dbl>,
#> #   df_error <int>, p <dbl>, std_coef <dbl>, std_ci <dbl>, std_ci_low <dbl>,
#> #   std_ci_high <dbl>, model_performance <list>, model_warnings <list>,
#> #   model_messages <list>, pipeline_code <list>, timing_logs <list>
```

If you set `.unpack_specs = 'long'`, your decisions get stacked into two
columns: `decision_set` and `alternatives`. This format is nice for
plotting a particular result from a multiverse analyses per different
decision alternatives.

``` r
multiverse_results |> 
  reveal_model_performance(.unpack_specs = "long")
#> # A tibble: 384 × 16
#>    decision decision_set      alternatives model_function model_parameters   AIC
#>       <dbl> <chr>             <chr>        <chr>          <list>           <dbl>
#>  1        1 ivs               iv1          lm             <tibble>          866.
#>  2        1 dvs               dv1          lm             <tibble>          866.
#>  3        1 include1          include1 ==… lm             <tibble>          866.
#>  4        1 include2          include2 !=… lm             <tibble>          866.
#>  5        1 include3          include3 > … lm             <tibble>          866.
#>  6        1 model             linear model lm             <tibble>          866.
#>  7        1 model_standardize TRUE         lm             <tibble>          866.
#>  8        1 model_perform     TRUE         lm             <tibble>          866.
#>  9        2 ivs               iv1          lm             <tibble>          883.
#> 10        2 dvs               dv2          lm             <tibble>          883.
#> # ℹ 374 more rows
#> # ℹ 10 more variables: AICc <dbl>, BIC <dbl>, R2 <dbl>, R2_adjusted <dbl>,
#> #   RMSE <dbl>, Sigma <dbl>, model_warnings <list>, model_messages <list>,
#> #   pipeline_code <list>, timing_logs <list>
```

### Condense

Unpacking specifications alongside specific results allows us to examine
the effects of our pipeline decisions.

A powerful way to organize these results is to summarize a specific
results column, say the r² values of our model over the entire
multiverse.
[`condense()`](https://ethan-young.github.io/multitool/reference/condense.md)
takes a result column and summarizes it with the `.how` argument, which
takes a list in the form of
`list(<a name you pick> = <summary function>)`.

`.how` will create a column named like so
`<column being condsensed>_<summary function name provided>`. For this
case, we have `r2_mean` and `r2_median`.

``` r
# model performance r2 summaries
multiverse_results |>
  reveal_model_performance() |> 
  condense(R2, list(mean = mean, median = median))
#> # A tibble: 1 × 3
#>   R2_mean R2_median R2_list   
#>     <dbl>     <dbl> <list>    
#> 1  0.0142    0.0109 <dbl [48]>

# model parameters for our predictor of interest
multiverse_results |>
  reveal_model_parameters() |> 
  filter(str_detect(parameter, "iv")) |>
  condense(unstd_coef, list(mean = mean, median = median))
#> # A tibble: 1 × 3
#>   unstd_coef_mean unstd_coef_median unstd_coef_list
#>             <dbl>             <dbl> <list>         
#> 1        -0.00907           -0.0273 <dbl [96]>
```

In the last example, we have filtered our multiverse results to look at
our predictors `iv*` to see what the mean and median effect was (over
all combinations of decisions) on our outcomes.

However, we had three versions of our predictor and two outcomes, so
combining
[`dplyr::group_by()`](https://dplyr.tidyverse.org/reference/group_by.html)
with
[`condense()`](https://ethan-young.github.io/multitool/reference/condense.md)
might be more informative:

``` r
multiverse_results |>
  reveal_model_parameters(.unpack_specs = "wide") |> 
  filter(str_detect(parameter, "iv")) |>
  group_by(ivs, dvs) |>
  condense(unstd_coef, list(mean = mean, median = median))
#> # A tibble: 6 × 5
#> # Groups:   ivs [3]
#>   ivs   dvs   unstd_coef_mean unstd_coef_median unstd_coef_list
#>   <chr> <chr>           <dbl>             <dbl> <list>         
#> 1 iv1   dv1          -0.0372           -0.0228  <dbl [16]>     
#> 2 iv1   dv2          -0.0535           -0.0547  <dbl [16]>     
#> 3 iv2   dv1          -0.00545           0.00334 <dbl [16]>     
#> 4 iv2   dv2           0.0530            0.0550  <dbl [16]>     
#> 5 iv3   dv1           0.00918           0.00561 <dbl [16]>     
#> 6 iv3   dv2          -0.0204           -0.0148  <dbl [16]>
```

If we were interested in all the terms of the model, we can leverage
`group_by` further:

``` r
multiverse_results |>
  reveal_model_parameters(.unpack_specs = "wide") |> 
  group_by(parameter, dvs) |>
  condense(unstd_coef, list(mean = mean, median = median))
#> # A tibble: 16 × 5
#> # Groups:   parameter [8]
#>    parameter   dvs   unstd_coef_mean unstd_coef_median unstd_coef_list
#>    <chr>       <chr>           <dbl>             <dbl> <list>         
#>  1 (Intercept) dv1           0.00431           0.00696 <dbl [24]>     
#>  2 (Intercept) dv2           0.0701            0.0755  <dbl [24]>     
#>  3 iv1         dv1          -0.00875          -0.00906 <dbl [8]>      
#>  4 iv1         dv2          -0.0337           -0.0309  <dbl [8]>      
#>  5 iv1:mod     dv1          -0.0656           -0.0647  <dbl [8]>      
#>  6 iv1:mod     dv2          -0.0734           -0.0753  <dbl [8]>      
#>  7 iv2         dv1           0.0115            0.0153  <dbl [8]>      
#>  8 iv2         dv2           0.148             0.148   <dbl [8]>      
#>  9 iv2:mod     dv1          -0.0224           -0.0205  <dbl [8]>      
#> 10 iv2:mod     dv2          -0.0418           -0.0433  <dbl [8]>      
#> 11 iv3         dv1           0.0613            0.0629  <dbl [8]>      
#> 12 iv3         dv2           0.0230            0.0207  <dbl [8]>      
#> 13 iv3:mod     dv1          -0.0430           -0.0423  <dbl [8]>      
#> 14 iv3:mod     dv2          -0.0639           -0.0640  <dbl [8]>      
#> 15 mod         dv1           0.0153            0.0121  <dbl [24]>     
#> 16 mod         dv2          -0.117            -0.116   <dbl [24]>
```
