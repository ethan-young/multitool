library(tidyverse)
library(multitool)
library(ggeffects)

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
  add_model(lm({dvs} ~ {ivs} * condition)) |>
  add_correlations("childhood", ends_with("mean")) |>
  add_correlations("memory_vars", matches("round$|agg$"), method = "pearson")


blueprint <- function(.grid, layout = "dot", rankdir = "LR"){

  if("variables" %in% unique(.grid$type)){
    v_data <-
      .grid |>
      filter(type == "variables")

    v_n_sets <-
      v_data |>
      group_by(group) |>
      count() |>
      nrow()

    v_nodes <-
      glue::glue("variables [label = <<B>variables</B> {v_n_sets}'>]\n")

    v_group_nodes <-
      v_data |>
      group_by(group) |>
      summarize(vars = paste0(code, collapse = " <BR ALIGN = 'LEFT'/> ")) |>
      glue::glue_data("{group} [rank = 1 label = <<B>{group}</B><BR ALIGN = 'LEFT'/> {vars} <BR ALIGN = 'LEFT'/>>]")

  }

  if("filters" %in% unique(.grid$type)){
    f_data <-
      .grid |>
      filter(type == "filters")

    f_n_sets <-
      v_data |>
      group_by(group) |>
      count() |>
      nrow()

    f_nodes <-
      glue::glue("variables [label = '{f_n_sets}']\n")

    f_group_nodes <-
      f_data |>
      group_by(group) |>
      summarize(vars = paste0(code, collapse = " <BR ALIGN = 'LEFT'/> ")) |>
      glue::glue_data("{group} [rank = 1 label = <<B>{group}</B><BR ALIGN = 'LEFT'/> {vars} <BR ALIGN = 'LEFT'/>>]")

  }

  pipeline_nodes <-
    .grid |>
    mutate(
      type_node = glue::glue("  {type} [label = '{type}']\n"),
      group_node = glue::glue("  {group} [label = '{group}']\n"),
      code_node = glue::glue("  {paste0('dec_', row_number())} [label = '{code}' group = '{group}']\n")
    )

  start_text <-
    glue::glue(
      .open="<", .close = ">",
      "digraph graph2 {\n",
      "graph [layout = <layout> rankdir = <rankdir> splines=ortho ordering = 'out'\n",
      "outputorder = 'edgesfirst' newrank = 'true']\n",
      "# Base nodes\n",
      "node [shape = rect]\n",
      "base_df [label = 'base data']\n"
    ) |>
    paste(collapse = "\n")

  type_nodes <-
    pipeline_nodes |>
    distinct(type_node) |>
    glue::glue_data("{type_node}")

  groups_nodes <-
    pipeline_nodes |>
    distinct(group_node) |>
    glue::glue_data("{group_node}")

  code_nodes <-
    pipeline_nodes |>
    distinct(code_node) |>
    glue::glue_data("{code_node}")

  all_nodes <-
    paste(c("  ", type_nodes, groups_nodes, code_nodes), collapse = "\n  ")

  edges_df_type <-
    pipeline_nodes |>
    distinct(type) |>
    glue::glue_data(
      "  base_df -> {type}\n"
    )

  edges_type_group <-
    pipeline_nodes |>
    distinct(type, group) |>
    glue::glue_data(
      "  {type} -> {group}\n"
    )

  edges_group_code <-
    pipeline_nodes |>
    distinct(group, code_node) |>
    glue::glue_data(
      "  {group} -> {str_extract(code_node, 'dec_(\\\\d\\\\d|\\\\d)')} \n"
    )

  all_edges <-
    paste(c("  ", edges_df_type, edges_type_group, edges_group_code), collapse = "\n  ")

  glue::glue(
    .open = "<", .close = ">",
    "<start_text>",
    "\n\n    # Nodes",
    "<all_nodes>",
    "\n\n    # Edges",
    "<all_edges>",
    "\n  }"
  )
}

blueprint(stm_pipeline, layout = "dot", rankdir = "TB")

stm_pipeline |>
  distinct(group) |>
  mutate(
    node = glue::glue("{group} [label = {group}]")
  )

my_text <-
  "
  digraph graph2 {
  graph [layout = dot, rankdir = LR]
  # node definitions with substituted label text
  node [shape = oval]
  base_df [label = 'base data']
  b [label = '@@2']
  c [label = '@@3']
  d [label = '@@4']
  e [label = '@@5']
  variables [label = '2']
  dvs [label = 'dvs stm_agg\nstm_round2 ifr_agg']
  ivs [label = 'ivs unp_mean cstress_mean childses_mean']

  a -> b
  a -> c
  a -> d
  a -> e
  }

  [1]: names(iris)[1]
  [2]: names(iris)[2]
  [3]: names(iris)[3]
  [4]: names(iris)[4]
  [5]: names(iris)[4]
  "

DiagrammeR::grViz(my_text)

DiagrammeR::grViz("
  digraph graph2 {

  graph [layout = dot, rankdir = LR]

  # node definitions with substituted label text
  node [shape = rect]
  base_df [label =  <<B>help</B> <BR ALIGN='LEFT'/>this is a base data \n and more>]
  ather [label = <<FONT COLOR='RED' POINT-SIZE='24.0' FACE='ambrosia'>line4</FONT> and then more stuff>]
  dvs [label = <<B>dvs</B><BR ALIGN = 'LEFT'/> stm_agg <BR ALIGN = 'LEFT'/> stm_round2 <BR ALIGN = 'LEFT'/> ifr_agg <BR ALIGN = 'LEFT'/>>]
  ivs [label = <<B>ivs</B><BR ALIGN = 'LEFT'/> unp_mean <BR ALIGN = 'LEFT'/> cstress_mean <BR ALIGN = 'LEFT'/> childses_mean <BR ALIGN = 'LEFT'/>>]
}
  ")

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





