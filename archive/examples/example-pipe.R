library(tidyverse)
#library(multitool)
library(interactions)
library(ggeffects)

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

# Completely different approach -------------------------------------------
full_pipeline <-
  the_data |>
  add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
  add_variables("ivs", iv1, iv2, iv3) |>
  add_variables("dvs", dv1, dv2) |>
  add_variables("mods", starts_with("mod")) |>
  add_preprocess(process_name = "Standardize IVs", 'mutate({ivs} = scale({ivs}))') |>
  add_preprocess(process_name = "Standardize Moderators", mutate({mods} := scale({mods}))) |>
  add_summary_stats("IV Summary Stats", starts_with("iv"), c("mean", "sd")) |>
  add_summary_stats("DV Summary Stats", starts_with("dv"), c("skewness", "kurtosis")) |>
  add_correlations("Between Predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2)) |>
  add_correlations("Between Outcomes", matches("dv|mod"), focus_set = matches("dv")) |>
  add_cron_alpha("unp_scale", c(iv1,iv2,iv3)) |>
  add_cron_alpha("vio_scale", starts_with("mod")) |>
  add_model("no covariates",lm({dvs} ~ {ivs} * {mods})) |>
  add_model("covariates",lm({dvs} ~ {ivs} * {mods} + cov1)) |>
  add_postprocess("simple slopes", "sim_slopes(pred = {ivs}, modx = {mods}, modx_values = c(-1,1))") |>
  add_postprocess("plotting interactions", ggeffect(terms = c("{ivs} [-1,1]", "{mods} [-1,1]")))

blueprint(full_pipeline)
blueprint(full_pipeline, splines = "polyline")
blueprint(full_pipeline, show_code = TRUE)


my_graph <- blueprint(full_pipeline, height = 600, width = 600)


DiagrammeR::render_graph(my_graph, height = 600)

pipeline_expanded <-
  full_pipeline |>
  expand_decisions()

## Run the whole multiverse ----
the_multiverse <- run_multiverse(pipeline_expanded[1:5,])
the_multiverse

## Show formatted code and copy ----
show_code_filter(pipeline_expanded, decision_num = 1)
show_code_preprocess(pipeline_expanded, decision_num = 1)
show_code_model(pipeline_expanded, decision_num = 1)
show_code_postprocess(pipeline_expanded, decision_num = 1)
show_code_summary_stats(pipeline_expanded, decision_num = 1)
show_code_corrs(pipeline_expanded, decision_num = 1)
show_code_cron_alpha(pipeline_expanded, decision_num = 1)

the_data |>
  filter(include1 == 0, include2 != 3, scale(include3) > -2.5) |>
  mutate(iv1 = scale(iv1)) |>
  mutate(`:=`(mod1, scale(mod1))) |>
  lm(dv1 ~ iv1 * mod1, data = _) |>
  ggeffects::gg(terms = c("iv1 [-1,1]", "mod1 [-1,1]"))


## Run a single decision set ----
run_universe_model(pipeline_expanded, 1)

run_universe_corrs(full_pipeline, 120)
run_universe_corrs(full_pipeline, 120) |>
  unnest(corrs_computed) |>
  unnest(predictors_rs)

run_universe_cron_alphas(pipeline_expanded, decision_num = 2) |> unnest(cron_alphas_computed) |> unnest(unp_scale_total)

run_universe_summary_stats(full_pipeline, 120) |> unnest(summary_stats_computed)

## Unpack the multiverse ----
the_multiverse |>
  reveal(model, matches("tidy"), T)

the_multiverse |>
  reveal(cron_alphas_computed)

the_multiverse |>
  reveal(corrs_computed, predictors_rs)

the_multiverse |>
  reveal_summary_stats(iv_stats)

the_multiverse |>
  reveal_corrs(predictors_rs)

the_multiverse |>
  reveal_corrs(predictors_focus, .unpack_specs = T) |>
  group_by(variable, include1) |>
  summarize(across(c(cov1,cov2), list(mean = mean, median = median)))

the_multiverse |>
  reveal(lm_fitted, matches("tidy"), T) |>
  group_by(term, dvs) |>
  condense(estimate, list(mn = mean, med = median))
