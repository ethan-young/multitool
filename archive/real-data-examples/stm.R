library(tidyverse)
library(multitool)
library(ggeffects)
library(DiagrammeR)
library(gt)

load("data-raw/stm-exp1.Rdata")

stm_data1_raw <- LHT.WM.clean

stm_data2_analysis <-
  stm_data1_raw |>
  mutate(
    condition = ifelse(Condition == 0, -1, 1),
    ex_time_manip = ifelse(condition == -1, cT, rT),
    ex_booster_words = booster.words,
    ex_getup = getup,
    ex_sitting = sitting,
    ex_interrupt = interrupt,
    ex_english = english,
    ex_fluency = fluency,
    stm_round1 = PA.round1,
    stm_round2 = PA.round2,
    stm_agg    = PA.total,
    ifr_round1 = IFR.round1,
    ifr_round2 = IFR.round2,
    ifr_agg    = IFR.total,
    dems_sex = ifelse(sex == 1, -1, 1),
    dems_age = age,
    dems_edu = education
  ) |>
  mutate(
    cstress_mean = across(matches("cstress_\\d")) |> rowMeans(na.rm = TRUE),
    unp_mean = across(matches("unp_\\d")) |> rowMeans(na.rm = TRUE),
    childses_mean = across(matches("childses_\\d")) |> rowMeans(na.rm = TRUE) * -1
  ) |>
  select(
    condition,
    starts_with("ex_"),
    matches("cstress_"),
    matches("unp_"),
    matches("childses_"),
    matches("(stm|ifr)_"),
    starts_with("dems_")
  )

# Filtering Data ----------------------------------------------------------
#filter.01 <-
#  LHT.WM.clean %>%
#  filter((rT>60 & rT<500)|(cT<350)) %>%
#  mutate(unp  = scale(UNP)  %>% as.numeric(),
#         ses  = scale(cses) %>% as.numeric(),
#         age  = scale(age)  %>% as.numeric(),
#         gend = car::recode(sex,"1=-1;2=1"))
#
#model.01 <- lm(agg.mem~Condition*unp, data = filter.01)
#
#ggpredict(model.01, terms = c("Condition [0, 1]", "unp [-1, 1]")) |>
#  as_tibble() |>
#  ggplot(aes(x = x, y = predicted, color = group, group = group)) +
#  geom_line() +
#  geom_point()
#


# Decision Pipeline -------------------------------------------------------
stm_pipeline <-
  stm_data2_analysis |>
  add_filters(ex_time_manip >= 60, ex_time_manip <= 500, ex_interrupt == 2, ex_getup == 2, ex_sitting == 1) |>
  add_variables("ivs", unp_mean, cstress_mean, childses_mean) |>
  add_variables("dvs", stm_agg, stm_round2, ifr_agg) |>
  add_preprocess("standardize", "mutate({ivs} = scale({ivs}) |> as.numeric())") |>
  add_preprocess("center_cond", "mutate(condition = ifelse(condition == 0, -1, 1))") |>
  add_model("linear model1",lm({dvs} ~ {ivs} * condition)) |>
  add_model("linear model2",lm({dvs} ~ {ivs} * condition + dems_sex)) |>
  add_correlations("childhood", ends_with("mean")) |>
  add_correlations("memory_vars", matches("round$|agg$"), method = "pearson")

blueprint(stm_pipeline)
blueprint(stm_pipeline, show_code = T)
create_blueprint_graph(stm_pipeline, render = T, show_code = F)


stm_pipeline_expanded <-
  stm_pipeline |>
  expand_decisions()

stm_multiverse <- run_multiverse(stm_pipeline_expanded)
stm_descriptives <- run_descriptives(stm_pipeline)

stm_descriptives |>
  reveal(corrs_computed, childhood_matrix, .unpack_specs = T) |>
  group_by(variable) |>
  condense(c(childses_mean, cstress_mean, unp_mean), median)



stm_descriptives |>
  reveal(corrs_computed, childhood_rs, .unpack_specs = T) |>
  mutate(r = ifelse(r == 1,  NA, r)) |>
  ggplot(aes(x = r, y = factor(1))) +
  ggdist::stat_pointinterval() +
  facet_grid(vars(Parameter1), vars(Parameter2),drop = T)


stm_descriptives |>
  reveal(corrs_computed, childhood_rs, .unpack_specs = T) |>
  group_by(Parameter1,Parameter2) |>
  condense(r, list(median = median, sd = sd, list = list)) |>
  filter(r_median != 1) |>
  ungroup() |>
  distinct(r_median, .keep_all = T) |>
  gt() |>
  gt::fmt_number() |>
  my_gt_dist(r_list, type = "histogram",bw = .02, custom_range = c(-1,1))

# stm_descriptives |>
  reveal(corrs_computed, childhood_rs) |>
  filter(r != 1, Parameter1 == "cstress_mean", Parameter2 == "unp_mean") |>
  inspect_iccs(.estimate = r)

inspect_corr_iccs(stm_descriptives, childhood_rs, "childses_mean", "unp_mean")

# Plots -------------------------------------------------------------------

## Effect Curves ----


## P-curves ----


## Sample Sizes ----


## Vibration of Effects ----


## Predicted Values ----


# Specifications ----------------------------------------------------------

## Combined Curve and Table

## Grouped Proportion Bars


# Tables ------------------------------------------------------------------

## Correlations ----

## Reliability and Item statitistics

# Variance Components -----------------------------------------------------





