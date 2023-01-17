#' Reveal the contents of a multiverse analysis
#'
#' @param .multi a multiverse list-column \code{tibble} produced by
#'   \code{\link{run_multiverse}}.
#' @param .what the name of a list-column you would like to unpack
#' @param .which any sub-list columns you would like to unpack
#' @param .unpack_specs logical, whether to unnest the specifications that built
#'   the multiverse grid. Defaults to FALSE.
#'
#' @return the unnested part of the multiverse requested. This usually contains
#'   the particular estimates or statistics you would like to analyze over the
#'   decision grid specified.
#' @export
#'
#' @examples
#' \dontrun{
#' library(tidyverse)
#' library(multitool)
#'
#' # Simulate some data
#' the_data <-
#'   data.frame(
#'     id   = 1:500,
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     iv3  = rnorm(500),
#'     mod1 = rnorm(500),
#'     mod2 = rnorm(500),
#'     mod3 = rnorm(500),
#'     cov1 = rnorm(500),
#'     cov2 = rnorm(500),
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # Decision pipeline
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#'   add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
#'   add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#'   add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis")) |>
#'   add_correlations("predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2)) |>
#'   add_correlations("outcomes", matches("dv|mod"), focus_set = matches("dv")) |>
#'   add_cron_alpha("unp_scale", c(iv1,iv2,iv3)) |>
#'   add_cron_alpha("vio_scale", starts_with("mod")) |>
#'   add_model(lm({dvs} ~ {ivs} * {mods})) |>
#'   add_model(lm({dvs} ~ {ivs} * {mods} + cov1)) |>
#'   add_postprocess("aov", aov()) |>
#'   expand_decisions()
#'
#' # Run the whole multiverse
#' the_multiverse <- run_multiverse(full_pipeline[1:10,])
#'
#' # Reveal results of the linear model
#' the_multiverse |> reveal(lm_fitted, matches("tidy"), .unpack_specs = TRUE)
#' }
reveal <- function(.multi, .what, .which = NULL, .unpack_specs = FALSE){

  which_sublist <- dplyr::enexprs(.which) |> as.character()
  which_sublist <- which_sublist != "NULL"

  unpacked <-
    .multi |>
    dplyr::select(decision, specifications,{{.what}}) |>
    tidyr::unnest({{.what}})

  if(which_sublist){
    unpacked <-
      unpacked |>
      dplyr::select(decision, specifications, {{.which}}) |>
      tidyr::unnest({{.which}})
  }

  if(.unpack_specs){
    unpacked <-
      unpacked |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","cron_alphas"))
      ) |>
      tidyr::unnest(dplyr::everything())
  }

  unpacked
}

#' Reveal a set of summary statistics from a multiverse analysis
#'
#' @param .multi a multiverse list-column \code{tibble} produced by
#'   \code{\link{run_multiverse}}.
#' @param .which the specific name of the summary statistics
#' @param .unpack_specs logical, whether to unnest the specifications that built
#'   the multiverse grid. Defaults to FALSE.
#'
#' @return an unnested set of summary statistics per decision from the
#'   multiverse.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(tidyverse)
#' library(multitool)
#'
#' # Simulate some data
#' the_data <-
#'   data.frame(
#'     id   = 1:500,
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     iv3  = rnorm(500),
#'     mod1 = rnorm(500),
#'     mod2 = rnorm(500),
#'     mod3 = rnorm(500),
#'     cov1 = rnorm(500),
#'     cov2 = rnorm(500),
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # Decision pipeline
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#'   add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
#'   add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#'   add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis")) |>
#'   add_correlations("predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2)) |>
#'   add_correlations("outcomes", matches("dv|mod"), focus_set = matches("dv")) |>
#'   add_cron_alpha("unp_scale", c(iv1,iv2,iv3)) |>
#'   add_cron_alpha("vio_scale", starts_with("mod")) |>
#'   add_model(lm({dvs} ~ {ivs} * {mods})) |>
#'   add_model(lm({dvs} ~ {ivs} * {mods} + cov1)) |>
#'   add_postprocess("aov", aov()) |>
#'   expand_decisions()
#'
#' # Run the whole multiverse
#' the_multiverse <- run_multiverse(full_pipeline[1:10,])
#'
#' # Reveal summary statistics
#' the_multiverse |> reveal_summary_stats(iv_stats)
#' }
reveal_summary_stats <- function(.multi, .which, .unpack_specs = FALSE){
  which_sublist <- dplyr::enexprs(.which) |> as.character()
  which_sublist <- which_sublist != "NULL"

  unpacked <-
    .multi |>
    tidyr::unnest(summary_stats_computed) |>
    dplyr::select(decision, specifications, {{.which}}) |>
    tidyr::unnest({{.which}})

  if(.unpack_specs){
    unpacked <-
      unpacked |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","cron_alphas"))
      ) |>
      tidyr::unnest(dplyr::everything())
  }

  unpacked
}

#' Reveal a set of multiverse correlations
#'
#' @param .multi a multiverse list-column \code{tibble} produced by
#'   \code{\link{run_multiverse}}.
#' @param .which the specific name of the correlations requested
#' @param .unpack_specs logical, whether to unnest the specifications that built
#'   the multiverse grid. Defaults to FALSE.
#'
#' @return an unnested set of correlations per decision from the
#'   multiverse.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(tidyverse)
#' library(multitool)
#'
#' # Simulate some data
#' the_data <-
#'   data.frame(
#'     id   = 1:500,
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     iv3  = rnorm(500),
#'     mod1 = rnorm(500),
#'     mod2 = rnorm(500),
#'     mod3 = rnorm(500),
#'     cov1 = rnorm(500),
#'     cov2 = rnorm(500),
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # Decision pipeline
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#'   add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
#'   add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#'   add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis")) |>
#'   add_correlations("predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2)) |>
#'   add_correlations("outcomes", matches("dv|mod"), focus_set = matches("dv")) |>
#'   add_cron_alpha("unp_scale", c(iv1,iv2,iv3)) |>
#'   add_cron_alpha("vio_scale", starts_with("mod")) |>
#'   add_model(lm({dvs} ~ {ivs} * {mods})) |>
#'   add_model(lm({dvs} ~ {ivs} * {mods} + cov1)) |>
#'   add_postprocess("aov", aov()) |>
#'   expand_decisions()
#'
#' # Run the whole multiverse
#' the_multiverse <- run_multiverse(full_pipeline[1:10,])
#'
#' # Reveal correlations among predictor across decision set
#' the_multiverse |> reveal_corrs(predictors_rs)
#' }
reveal_corrs <- function(.multi, .which, .unpack_specs = FALSE){
  which_sublist <- dplyr::enexprs(.which) |> as.character()
  which_sublist <- which_sublist != "NULL"

  unpacked <-
    .multi |>
    tidyr::unnest(corrs_computed) |>
    dplyr::select(decision, specifications, {{.which}}) |>
    tidyr::unnest({{.which}})

  if(.unpack_specs){
    unpacked <-
      unpacked |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","cron_alphas"))
      ) |>
      tidyr::unnest(dplyr::everything())
  }

  unpacked
}

#' Reveal a set of multiverse cronbach's alpha statistics
#'
#' @param .multi a multiverse list-column \code{tibble} produced by
#'   \code{\link{run_multiverse}}.
#' @param .which the specific name of the alphas
#' @param .unpack_specs logical, whether to unnest the specifications that built
#'   the multiverse grid. Defaults to FALSE.
#'
#' @return an unnested set of correlations per decision from the
#'   multiverse.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' library(tidyverse)
#' library(multitool)
#'
#' # Simulate some data
#' the_data <-
#'   data.frame(
#'     id   = 1:500,
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     iv3  = rnorm(500),
#'     mod1 = rnorm(500),
#'     mod2 = rnorm(500),
#'     mod3 = rnorm(500),
#'     cov1 = rnorm(500),
#'     cov2 = rnorm(500),
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # Decision pipeline
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#'   add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
#'   add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#'   add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis")) |>
#'   add_correlations("predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2)) |>
#'   add_correlations("outcomes", matches("dv|mod"), focus_set = matches("dv")) |>
#'   add_cron_alpha("unp_scale", c(iv1,iv2,iv3)) |>
#'   add_cron_alpha("vio_scale", starts_with("mod")) |>
#'   add_model(lm({dvs} ~ {ivs} * {mods})) |>
#'   add_model(lm({dvs} ~ {ivs} * {mods} + cov1)) |>
#'   add_postprocess("aov", aov()) |>
#'   expand_decisions()
#'
#' # Run the whole multiverse
#' the_multiverse <- run_multiverse(full_pipeline[1:10,])
#'
#' # Reveal multiverse reliability analyses
#' the_multiverse |> reveal(cron_alphas_computed)
#' }
reveal_alphas <- function(.multi, .which, .unpack_specs = FALSE){
  which_sublist <- dplyr::enexprs(.which) |> as.character()
  which_sublist <- which_sublist != "NULL"

  unpacked <-
    .multi |>
    tidyr::unnest(cron_alphas_computed) |>
    dplyr::select(decision, specifications, {{.which}}) |>
    tidyr::unnest({{.which}})

  if(.unpack_specs){
    unpacked <-
      unpacked |>
      tidyr::unnest(specifications) |>
      dplyr::select(
        -dplyr::any_of(
          c("preprocess","postprocess","corrs","summary_stats","cron_alphas"))
      ) |>
      tidyr::unnest(dplyr::everything())
  }

  unpacked
}


#' Summarize multiverse parameters
#'
#' @param .unpacked an unpacked (with \code{\link{reveal}} or
#'   \code{\link{unnest}}) multiverse dataset.
#' @param .what a specific column to summarize. This could be a model estimate,
#'   a summary statistic, correlation, or any other estimate computed over the
#'   multiverse.
#' @param .how a named list. The list should contain summary functions (e.g.,
#'   mean or median) the user would like to compute over the individual
#'   estimates from the multiverse
#'
#' @return a summarized \code{tibble} containing a column for each summary
#'   method from \code{.how}
#' @export
#'
#' @examples
#' \dontrun{
#'
#' library(tidyverse)
#' library(multitool)
#'
#' # Simulate some data
#' the_data <-
#'   data.frame(
#'     id   = 1:500,
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     iv3  = rnorm(500),
#'     mod1 = rnorm(500),
#'     mod2 = rnorm(500),
#'     mod3 = rnorm(500),
#'     cov1 = rnorm(500),
#'     cov2 = rnorm(500),
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # Decision pipeline
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#'   add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
#'   add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#'   add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis")) |>
#'   add_correlations("predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2)) |>
#'   add_correlations("outcomes", matches("dv|mod"), focus_set = matches("dv")) |>
#'   add_cron_alpha("unp_scale", c(iv1,iv2,iv3)) |>
#'   add_cron_alpha("vio_scale", starts_with("mod")) |>
#'   add_model(lm({dvs} ~ {ivs} * {mods})) |>
#'   add_model(lm({dvs} ~ {ivs} * {mods} + cov1)) |>
#'   add_postprocess("aov", aov()) |>
#'   expand_decisions()
#'
#' # Run the whole multiverse
#' the_multiverse <- run_multiverse(full_pipeline[1:10,])
#'
#' # Reveal results of the linear model
#' the_multiverse |> reveal(lm_fitted, matches("tidy"), .unpack_specs = TRUE)
#'
#' # Reveal and condense
#' the_multiverse |>
#'   reveal(lm_fitted, matches("tidy"), .unpack_specs = TRUE) |>
#'   group_by(term, dvs) |>
#'   condense(estimate, list(mn = mean, med = median))
#'   }
condense <- function(.unpacked, .what, .how){

  .unpacked |>
    dplyr::summarize(dplyr::across(.cols = {{.what}}, .fns = {{.how}}, .names = "{.col}_{.fn}"))

}

