reveal <- function(.multi, .what, .which = NULL, .unpack_specs = FALSE){

  which_sublist <- enexprs(.which) |> as.character()
  which_sublist <- which_sublist != "NULL"

  unpacked <-
    .multi |>
    select(decision, specifications,{{.what}}) |>
    unnest({{.what}})

  if(which_sublist){
    unpacked <-
      unpacked |>
      select(decision, specifications, {{.which}}) |>
      unnest({{.which}})
  }

  if(.unpack_specs){
    unpacked <-
      unpacked |>
      unnest(specifications) |>
      select(
        -any_of(
          c("preprocess","postprocess","corrs","summary_stats","cron_alphas"))
      ) |>
      unnest(everything())
  }

  unpacked
}

reveal_summary_stats <- function(.multi, .which, .unpack_specs = FALSE){
  which_sublist <- enexprs(.which) |> as.character()
  which_sublist <- which_sublist != "NULL"

  unpacked <-
    .multi |>
    unnest(summary_stats_computed) |>
    select(decision, specifications, {{.which}}) |>
    unnest({{.which}})

  if(.unpack_specs){
    unpacked <-
      unpacked |>
      unnest(specifications) |>
      select(
        -any_of(
          c("preprocess","postprocess","corrs","summary_stats","cron_alphas"))
      ) |>
      unnest(everything())
  }

  unpacked
}

reveal_corrs <- function(.multi, .which, .unpack_specs = FALSE){
  which_sublist <- enexprs(.which) |> as.character()
  which_sublist <- which_sublist != "NULL"

  unpacked <-
    .multi |>
    unnest(corrs_computed) |>
    select(decision, specifications, {{.which}}) |>
    unnest({{.which}})

  if(.unpack_specs){
    unpacked <-
      unpacked |>
      unnest(specifications) |>
      select(
        -any_of(
          c("preprocess","postprocess","corrs","summary_stats","cron_alphas"))
      ) |>
      unnest(everything())
  }

  unpacked
}

reveal_alphas <- function(.multi, .which, .type = NULL, .unpack_specs = FALSE){
  which_sublist <- enexprs(.which) |> as.character()
  which_sublist <- which_sublist != "NULL"

  unpacked <-
    .multi |>
    unnest(cron_alphas_computed) |>
    select(decision, specifications, {{.which}}) |>
    unnest({{.which}})

  if(.unpack_specs){
    unpacked <-
      unpacked |>
      unnest(specifications) |>
      select(
        -any_of(
          c("preprocess","postprocess","corrs","summary_stats","cron_alphas"))
      ) |>
      unnest(everything())
  }

  unpacked
}

condense <- function(.multi, .what, .how){

  .multi |>
    mutate(across(.cols = {{.what}}, .fns = {{.how}}, .names = "{.col}_{.fn}"))

}

