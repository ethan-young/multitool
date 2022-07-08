library(tidyverse)

## Simulate some data
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

## Create variable grid
my_var_grid <-
  create_var_grid(
    .df = the_data,
    iv  = c(iv1, iv2, iv3),
    mod = c(mod1, mod2, mod3),
    dv  = c(dv1, dv2),
    cov = c(cov1, cov2)
  )

my_var_grid

## Create a filter grid
my_filter_grid <-
  create_filter_grid(
    .df = the_data,
    include1 == 0,
    include2 != 3,
    include2 != 2,
    scale(include3) > -2.5
  )

my_filter_grid

## Create model grid
my_model_grid <-
  create_model_grid(
    lm({dv} ~ {iv} * {mod}),
    lm({dv} ~ {iv} * {mod} + {cov})
  )

my_model_grid

## Add arbitrary code

# Code to execute after filtering step
my_preprocess <-
  create_preprocess(
    'mutate({iv} =  scale({iv}) |> as.numeric(), {mod} = scale({mod}) |> as.numeric())'
  )

my_preprocess

# Code to execute after analysis is done
my_postprocess <-
  create_postprocess(
    aov()
  )

my_postprocess

## Combine all grids together
my_full_grid <-
  combine_all_grids(
    the_data,
    my_var_grid,
    my_filter_grid,
    my_model_grid,
    my_preprocess,
    my_postprocess
  )

my_full_grid

## Run a universe
run_universe_model(my_full_grid, 1)
run_universe_model(my_full_grid, 36, T)

## Run a multiverse
my_multiverse <- run_multiverse(my_full_grid[1:10,])

## Extract the underlying code for a universe
show_code_filter(my_full_grid, decision_num = 1)
show_code_preprocess(my_full_grid, decision_num = 1)
show_code_model(my_full_grid, decision_num = 1)
show_code_postprocess(my_full_grid, decision_num = 1)

## Generate a console report of a universe
report_universe_console(my_multiverse, decision_num = 7)

# Completely different approach -------------------------------------------
full_pipeline <-
  the_data |>
  add_variables("ivs", iv1, iv2, iv3) |>
  add_variables("dvs", dv1, dv2) |>
  add_variables("mods", starts_with("mod")) |>
  add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
  add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
  add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
  add_model(lm({dvs} ~ {ivs} * {mods})) |>
  add_model(lm({dvs} ~ {ivs} * {mods} + cov1)) |>
  add_postprocess("aov", aov()) |>
  add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
  add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis")) |>
  add_corrs("predictors", matches("iv|mod|cov"), focus = c(cov1,cov2)) |>
  add_corrs("outcomes", matches("dv")) |>
  add_cron_alpha("unp_scale", c(iv1,iv2,iv3)) |>
  add_cron_alpha("vio_scale", starts_with("mod")) |>
  expand_decisions()

## Show formatted code and copy ----
show_code_filter(full_pipeline, decision_num = 120)
show_code_preprocess(full_pipeline, decision_num = 120)
show_code_model(full_pipeline, decision_num = 120)
show_code_postprocess(full_pipeline, decision_num = 120)
show_code_summary_stats(full_pipeline, decision_num = 120)
show_code_corrs(full_pipeline, decision_num = 120)
show_code_cron_alpha(full_pipeline, decision_num = 120)

## Run a single decision set ----
run_universe_model(full_pipeline, 120)

run_universe_corrs(full_pipeline, 120)
run_universe_corrs(full_pipeline, 120) |>
  unnest(corrs_computed) |>
  unnest(predictors_rs)
run_universe_cron_alphas(full_pipeline, 120) |> unnest(cron_alphas_computed)

run_universe_summary_stats(full_pipeline, 120) |> unnest(summary_stats_computed)

## Run the whole multiverse ----
the_multiverse <- run_multiverse(full_pipeline[1:10,])
the_multiverse
the_multiverse |> unnest(lm_fitted) |> unnest(lm_tidy)

## Unpack the multiverse ----
the_multiverse |>
  look_at(lm_fitted, matches("tidy"), T)

the_multiverse |>
  look_at(cron_alphas_computed)

the_multiverse |>
  look_at(corrs_computed, predictors_rs)

the_multiverse |>
  look_at_summary_stats(iv_stats)

the_multiverse |>
  look_at_corrs(predictors_rs)

the_multiverse |>
  look_at_alphas(unp_scale_total)
