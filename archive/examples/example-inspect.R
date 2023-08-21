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
  add_model("my model 1", lm({dvs} ~ {ivs} * {mods})) |>
  add_model("my model 2", lm({dvs} ~ {ivs} * {mods} + cov1)) |>
  add_postprocess("Predicted Values", ggpredict(terms = c("{ivs} [-1,1]", "{mods} [-1,1]"))) |>
  add_postprocess("Simple Slopes", hypothesis_test(c("{ivs}", "{mods}"), test = NULL))

full_pipeline_expanded <-
  full_pipeline |>
  expand_decisions()

full_pipeline_expanded |>
  select(filters) |>
  unnest(c(everything())) |>
  distinct()


create_blueprint_graph(full_pipeline, "line")$graph |> grViz()

the_data |>
  add_postprocess("Predicted Values", ggpredict(terms = c("{ivs} [-1,1]", "{mods} [-1,1]")))

run_descriptives(full_pipeline)

test_multi <- run_multiverse(full_pipeline_expanded)

test_multi |>
  reveal(model_fitted, lm_params) |>
  filter(str_detect(parameter, ":")) |>
  ggplot(aes(x = coefficient, y = -log10(p))) +
  geom_point()

icar_icc <-
  inspect_iccs(icar_multiverse, model_fitted, lm_tidy, estimate, "")

icar_icc |>
  ggplot(aes(x = grp, y = icc_per)) +
  geom_bar(stat = "identity")


icar_multiverse |>
  reveal(model_fitted, lm_tidy, .unpack_specs = TRUE) |>
  filter(str_detect(term, ":")) |>
  pivot_longer(c(2:8), names_to = "spec", values_to = "alternates") |>
  summarize(
    median = median(estimate),
    .by = c(spec, alternates)
  ) |>
  ggplot(aes(x = median, y = fct_reorder(alternates, median))) +
  geom_point() +
  facet_wrap(~spec, scales = "free_y", ncol = 1)

icar_spec_curve <-
  icar_multiverse |>
  reveal(model_fitted, lm_tidy, .unpack_specs = TRUE) |>
  filter(str_detect(term, ":")) |>
  mutate(ordered_decison = fct_reorder(decision, estimate) |> as.numeric())

icar_spec_groups <-
  icar_spec_curve |>
  pivot_longer(c(2:8), names_to = "spec", values_to = "alternates") |>
  summarize(
    median = median(estimate),
    sd     = sd(estimate),
    min    = min(estimate),
    max    = max(estimate),
    .by = c(spec, alternates)
  ) |>
  arrange(median) |>
  mutate(
    ordered_median = factor(1:n()),
    ordered_median = fct_reorder(ordered_median, median) |> as.numeric(),
    bins = cut_medians(1:960, 20)
  )


icar_spec_curve |>
  ggplot(aes(x = fct_reorder(decision, estimate) |> as.numeric(), y = estimate)) +
  geom_point() +
  geom_errorbar(
    data = icar_spec_groups,
    aes(y = median, ymin = min, ymax = max, x = bins, color = spec)
  )

cut_medians <- function(.range, .n){
  .range |>
    cut(.n) |>
    unique() |>
    as.character() |>
    str_remove_all("\\(|\\]") |>
    str_split(",") |>
    map(as.numeric) |>
    map_dbl(function(x) mean(x[[1]], x[[2]]))
}

icar_spec_groups |>
  left_join(icar_icc, by = c("spec" = "grp")) |>
  arrange(icc_per)

icar_spec_curve$estimate |> hist()


lme4::lmer(icar_sum ~ condition * unp_changes_mean + (1|sample), data = icar_data) |>
  parameters::model_parameters(pretty_names = F)

the_data |>
  filter(include1 == 0, include2 != 3, scale(include3) > -2.5) |>
  mutate(`:=`(iv1, as.numeric(scale(iv1)))) |>
  mutate(`:=`(mod1, as.numeric(scale(mod1)))) |>
  lm(dv1 ~ iv1 * mod1, data = _) |>
  ggpredict(terms = c("iv1 [-1,1]", "mod1 [-1,1]"))

the_data |>
  filter(include1 == 0, include2 != 3, scale(include3) > -2.5) |>
  mutate(`:=`(iv1, as.numeric(scale(iv1)))) |>
  mutate(`:=`(mod1, as.numeric(scale(mod1)))) |>
  lm(dv1 ~ iv1 * mod1, data = _) |>
  hypothesis_test(c("iv1", "mod1"))

full_pipeline |>
  filter(str_detect(type, "filters|corrs|summary_stats|cron_alphas")) |>
  expand_decisions()


haven::read_sav("archive/ECLSK_BaseYear_School_SPSS.sav")

read_csv("archive/CASchools.csv")
