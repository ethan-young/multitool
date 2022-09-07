# Libraries ---------------------------------------------------------------
library(tidyverse)
library(interactions)
library(ggeffects)

load("data/icar_data.rda")
load("data/icar_data_codebook.rda")

icar_pipeline <-
  icar_data |>
  add_filters(
    sample == "lab",
    att_interrupt == 0,
    dems_english_native == 1,
    dems_lang == 1,
    time_icar > 120,
    time_icar < 1500
  ) |>
  add_variables("ivs", c(ends_with("mean"))) |>
  add_variables("dvs", c(icar_sum, ln_sum, mx_sum, vr_sum, r3d_sum)) |>
  add_variables("covs", c(dems_age, dems_age)) |>
  add_preprocess("standardize", "mutate({ivs} = scale({ivs}) |> as.numeric())") |>
  add_preprocess("center_cond", "mutate(condition = ifelse(condition == 0, -1, 1))") |>
  add_model("lm({dvs} ~ {ivs}*condition + dems_edu + dems_age)") |>
  add_model("lm({dvs} ~ {ivs}*condition)") |>
  add_postprocess("simple_slopes", "sim_slopes(pred = condition, modx = {ivs}, modx_values = c(-1,1))") |>
  add_postprocess("points", ggpredict(terms = c("condition [-1,1]", "{ivs} [-1,1]"))) |>
  add_correlations("childhood", ends_with("mean")) |>
  add_correlations("icar_vars", ends_with("_sum"), method = "pearson") |>
  expand_decisions()

icar_multiverse <- run_multiverse(icar_pipeline)

icar_multiverse |>
  reveal(lm_fitted, lm_tidy, .unpack_specs = T) |>
  filter(str_detect(term, "mean")) |>
  group_by(dvs) |>
  mutate(
    decision_rank = rank(estimate),
    is_sig = ifelse(p.value < .05, T, F)
    ) |>
  ggplot(aes(x = decision_rank, y= estimate, color = is_sig)) +
  geom_point(size = .25) +
  facet_grid(cols = vars(dvs))

icar_multiverse |>
  reveal(lm_fitted, lm_tidy, .unpack_specs = T) |>
  filter(str_detect(term, "mean")) |>
  ggplot() +
  geom_histogram(aes(x = p.value)) +
  facet_grid(vars(term),  vars(dvs))


icar_multiverse |>
  reveal_corrs(icar_vars_matrix, .unpack_specs = T) |>
  filter(ivs == "unp_obj_mean", dvs == "icar_sum", model == "lm(icar_sum ~ unp_obj_mean*condition)") |>
  group_by(variable) |>
  summarize(across(where(is.numeric), ~median(.x))) |>
  select(variable, icar_sum, ln_sum, mx_sum, r3d_sum, vr_sum)

icar_multiverse |>
  reveal(ggpredict_fitted, ggpredict_full, .unpack_specs = T) |>
  mutate(predicted = ifelse(dvs == "icar_sum", predicted/16, predicted/4),
         condition = factor(x, levels = c(-1,1), labels = c("control", "recession")),
         unp       = factor(group, levels = c(-1,1), labels = c("low", "high"))) |>
  ggplot(aes(x = condition, y = predicted, color = unp, group = interaction(unp, decision))) +
  geom_point(size = .25) +
  geom_line(size = .25) +
  stat_summary(
    aes(x = condition, y = predicted, group = unp),
    geom = "line",
    fun = "median",
    color = "black",
    alpha = 1,
    size = 1,
    show.legend = F
  ) +
  stat_summary(
    aes(x = condition, y = predicted, group = unp, fill = unp),
    geom = "point",
    fun = "median",
    color = "black",
    shape = 21,
    stroke = 1,
    alpha = 1,
    size = 2,
    show.legend = T
  ) +
  facet_grid(rows = vars(ivs), cols = vars(dvs))
