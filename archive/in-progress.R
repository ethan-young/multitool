generate_p_curve <- function(.multiverse, .which, .by_specs){

  .multiverse |>
    .multi |>
    dplyr::select(decision, specifications, model_fitted) |>
    tidyr::unnest({{.which}})

}

the_multiverse |>
  reveal(model_fitted, lm_performance, .unpack_specs = T)


reveal_and_stack <- function(.multi, .what, .which){
  which_sublist <- dplyr::enexprs(.which) |> as.character()

  unpacked <-
    .multi |>
    tidyr::unnest({{.what}}) |>
    select(decision, {{.which}}) |>
    tidyr::unnest({{.which}})

  unpacked_and_stacked <-
    .multi |>
    select(decision, specifications) |>
    unnest(specifications) |>
    dplyr::select(
      -dplyr::any_of(
        c("preprocess","postprocess","corrs","summary_stats","cron_alphas")
      ),
      -ends_with("_code")
    ) |>
    unnest(everything()) |>
    select(-model) |>
    rename(model = model_meta) |>
    pivot_longer(-decision, names_to = "decision_set", values_to = "alternatives")

  left_join(unpacked_and_stacked, unpacked, join_by(decision == decision))
}

the_multiverse |>
  reveal_and_stack(model_fitted, lm_performance) |>
  ggplot() +
  ggdist::stat_dist_halfeye(aes(x = rmse, y = alternatives, fill = decision_set)) +
  facet_wrap(~decision_set, scales = "free_y", ncol = 1) +
  theme_multitool()

the_multiverse |>
  select(decision, specifications) |>
  unnest(specifications) |>
  dplyr::select(
    -dplyr::any_of(
      c("preprocess","postprocess","corrs","summary_stats","cron_alphas")
    ),
    -ends_with("_code")
  ) |>
  unnest(everything()) |>
  select(-model) |>
  pivot_longer(-decision, names_to = "decision_set", values_to = "alternatives")

the_multiverse |>
  select(specifications) |>
  unnest()



the_multiverse |>
  reveal_and_stack(model_fitted, lm_params)


theme_multitool <- function(base_size = 12, base_family = "Lato") {

  theme_bw(base_size = base_size, base_family = base_family) %+replace%
    theme(
      axis.line.y       = element_line(),
      axis.text.y       = element_text(size = rel(1.1), hjust = 1),
      axis.title.y      = element_text(size = rel(1.25), angle = 90, margin = margin(1,1,1,1,"lines")),
      axis.ticks.y      = element_line(),
      axis.text.x       = element_text(size = rel(1.1)),
      axis.title.x      = element_text(size = rel(1.25), margin = margin(1,1,1,1,"lines")),
      axis.line.x       = element_line(),
      panel.border      = element_blank(),
      panel.spacing.y   = unit(0.5, "lines"),
      plot.margin       = margin(.25,.25,.25,.25,"lines"),
      plot.background   = element_rect(color = NA),
      plot.title        = element_text(size = rel(1.25), hjust = 0, margin = margin(0,0,.5,0, "lines")),
      panel.grid        = element_line(color = NA),
      strip.background  = element_blank(),
      strip.text        = element_text(size = rel(1))
    )
}

my_multi <- run_multiverse(pipeline_expanded[1:5,])

my_multi |> unnest(model_fitted)

my_multi |>
  reveal(model_fitted, .unpack_specs = "long")

my_multi |>
  reveal_model_parameters(parameter_key = "interaction" ,.unpack_specs = "long")

my_multi |>
  reveal(model_fitted) |>
  unnest(pipeline_code)

glue::glue(
  'select(variables) |>
    correlation(method = "method", redundant = redundant) |>
    select(1:3) |>
    pivot_wider(names_from = Parameter2, values_from = r) |>
    rename(variable = Parameter1)'
)

glue::glue(
  'select(variables) |>
    correlation(method = "method", redundant = redundant) |>
    select(1:3) |>
    filter(
      Parameter1 %in% c(focus_set_chr),
      r!=1,
      !Parameter2 %in% c(focus_set_chr)
     ) |>
    pivot_wider(names_from = Parameter1, values_from = r) |>
    rename(variable = Parameter2)',
  .trim = FALSE
)

glue::glue(
  'select(variables) |> ',
  'correlation(method = "method", redundant = redundant)'
)

glue::glue(
  'select(variables) |> ',
  'correlation(method = "method", redundant = redundant) |> ',
  'select(1:3) |> ',
  'filter(',
  'Parameter1 %in% c(focus_set_chr), ',
  'r!=1, ',
  '!Parameter2 %in% c(focus_set_chr)',
  ') |> ',
  'pivot_wider(names_from = Parameter1, values_from = r) |> ',
  'rename(variable = Parameter2)',
  .trim = FALSE
)
