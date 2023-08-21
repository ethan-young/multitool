library(tidyverse)
#library(multitool)
library(ggeffects)
library(DiagrammeR)

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
  add_preprocess(process_name = "Standardize IVs",  mutate({ivs} := scale({ivs}) |> as.numeric())) |>
  add_preprocess(process_name = "Standardize Moderators", mutate({mods} := scale({mods}) |> as.numeric())) |>
  add_summary_stats("IV Summary Stats", starts_with("iv"), c("mean", "sd")) |>
  add_summary_stats("DV Summary Stats", starts_with("dv"), c("skewness", "kurtosis")) |>
  add_correlations("Between Predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2)) |>
  add_correlations("Between Outcomes", matches("dv|mod"), focus_set = matches("dv")) |>
  add_cron_alpha("unp_scale", c(iv1,iv2,iv3)) |>
  add_cron_alpha("vio_scale", starts_with("mod")) |>
  add_model("my model", lm({dvs} ~ {ivs} * {mods})) |>
  add_postprocess("plotting", ggpredict(terms = c("{ivs} [-1,1]", "{mods} [-1,1]"))) |>
  add_postprocess("simple_slopes", hypothesis_test(c("{ivs}", "{mods}"), test = NULL))


create_blueprint_graph(full_pipeline)$ndf
create_blueprint_graph(full_pipeline)$edf
create_blueprint_graph(full_pipeline, "line")$graph |> grViz()

pipeline_expanded <-
  full_pipeline |>
  expand_decisions()

## Show formatted code and copy ----
show_code_filter(pipeline_expanded, decision_num = 1)
show_code_preprocess(pipeline_expanded, decision_num = 1)
show_code_model(pipeline_expanded, decision_num = 1)
show_code_postprocess(pipeline_expanded, decision_num = 1)
show_code_summary_stats(pipeline_expanded, decision_num = 1)
show_code_corrs(pipeline_expanded, decision_num = 1)
show_code_cron_alpha(pipeline_expanded, decision_num = 1)

## Run a single decision set ----
run_universe_model(pipeline_expanded, 1)
run_universe_corrs(full_pipeline, 120)
run_universe_corrs(full_pipeline, 120) |>
  unnest(corrs_computed) |>
  unnest(predictors_rs)

run_universe_cron_alphas(pipeline_expanded, decision_num = 2) |> unnest(cron_alphas_computed) |> unnest(unp_scale_total)
run_universe_summary_stats(full_pipeline, 120) |> unnest(summary_stats_computed)

## Run the whole multiverse ----
the_multiverse <- run_multiverse(pipeline_expanded)
the_multiverse

the_multiverse |>
  reveal(model_fitted, lm_tidy,.unpack_specs = T) |>
  filter(str_detect(term, "iv.$")) |>
  lme4::lmer(estimate ~ 1 + (1|ivs) + (1|dvs) + (1|mods), data = _) |>
  performance::icc(by_group = T)

the_multiverse |>
  reveal(model_fitted, lm_tidy,.unpack_specs = T) |>
  filter(str_detect(term, "iv")) |>
  lme4::lmer(estimate ~ 1 + (1|ivs) + (1|dvs) + (1|mods), data = _) |>
  specr::icc_specs()



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
