inspect_model_iccs <- function(.multiverse, .part, .type, .estimate, term_filter = NULL){

  zoomed_multi <-
    .multiverse |>
    reveal({{.part}}, {{.type}}) |>
    dplyr::select(specifications, any_of("term"), {{.estimate}})

  outcome <- zoomed_multi |> dplyr::select({{.estimate}}) |> names()

  if(!is.null(term_filter)){
    zoomed_multi <-
      zoomed_multi |>
      dplyr::filter(stringr::str_detect(term, ":"))
  }

  multi_icc_data <-
    zoomed_multi |>
    tidyr::unnest(c(specifications)) |>
    dplyr::select(dplyr::any_of(c("variables", "filters")), {{.estimate}}) |>
    tidyr::unnest(everything())

  multi_icc_formula <-
    multi_icc_data |>
    dplyr::select(!{{.estimate}}) |>
    names() |>
    paste0("(1|", ... = _, ")", collapse = " + ")

  icc_formula <- glue::glue("lme4::lmer({outcome} ~ {multi_icc_formula}, data = multi_icc_data)")

  rlang::parse_expr(icc_formula) |>
    rlang::eval_tidy() |>
    lme4::VarCorr() |>
    as.data.frame() |>
    dplyr::mutate(
      sum_var = sum(vcov),
      icc     = vcov/sum_var,
      icc_per = icc * 100
    ) |>
    dplyr::select(
      grp, vcov, icc, icc_per
    ) |>
    dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~round(.x, 4)))

}

inspect_corr_iccs <- function(.corrs, .set, .var1, .var2){

  zoomed_multi <-
    .corrs |>
    reveal(corrs_computed, {{.set}}) |>
    filter(r != 1, Parameter1 == .var1, Parameter2 == .var2)

  outcome <- "r"

  multi_icc_data <-
    zoomed_multi |>
    tidyr::unnest(c(specifications)) |>
    dplyr::select(dplyr::any_of(c("variables", "filters")), r) |>
    tidyr::unnest(everything())

  multi_icc_formula <-
    multi_icc_data |>
    dplyr::select(-r) |>
    names() |>
    paste0("(1|", ... = _, ")", collapse = " + ")

  icc_formula <- glue::glue("lme4::lmer({outcome} ~ {multi_icc_formula}, data = multi_icc_data)")

  rlang::parse_expr(icc_formula) |>
    rlang::eval_tidy() |>
    lme4::VarCorr() |>
    as.data.frame() |>
    dplyr::mutate(
      sum_var = sum(vcov),
      icc     = vcov/sum_var,
      icc_per = icc * 100
    ) |>
    dplyr::select(
      grp, vcov, icc, icc_per
    ) |>
    dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~round(.x, 4)))

}
