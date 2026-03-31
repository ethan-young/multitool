#' Assess the robustness of multiverse analysis results
#'
#' Summarizes the distribution of a particular model parameter, fit statistics,
#' or any other values returned by the focal modeling process or a
#' post-processing step. The summaries are computed over all specifications in
#' the analysis grid. This function helps evaluate whether results are robust to
#' analytical decisions by computing key distributional properties and sign
#' consistency metrics.
#'
#' @param .multi An object returned by \code{\link{analyze_grid}} containing
#'   results from a \code{multitool} pipeline.
#' @param .estimand The parameter or coefficient to assess. Defaults to
#'   \code{std_coef} (standardized coefficients). Can be any numeric column from
#'   the model parameters, performance, or a post-processing analysis (e.g.,
#'   \code{unstd_coef}, \code{r2}, \code{p_value}). Use unquoted column names
#'   with tidy evaluation.
#' @param zero_threshold Numeric value defining the threshold for "practically
#'   zero" effects. Effects between \code{-zero_threshold} and
#'   \code{+zero_threshold} are classified as zero. Defaults to \code{.01}. Used
#'   to compute sign entropy and proportion of positive/negative/zero effects.
#' @param .by Optional grouping variable(s) for stratified summaries. Useful for
#'   examining robustness within specific subsets of decisions (e.g., different
#'   models or subgroups). Use unquoted column names.
#'
#' @return A \code{data.frame} with the following columns:
#'   \describe{
#'     \item{metric}{Name of the summarized metric (e.g., "std_coef", "AIC")}
#'     \item{metric_type}{Type of metric: "parameter" for model coefficients or
#'       "fit index" for model fit statistics}
#'     \item{reference}{The parameter being summarized (e.g., variable name) or
#'       "full model" for fit indices}
#'     \item{n_decisions}{Number of specifications contributing to the summary}
#'     \item{mean, median, iqr, q05, q95}{Distributional summaries of the metric}
#'     \item{p_positive, p_negative, p_zero}{Proportion of specifications with
#'       positive, negative, or practically zero effects}
#'     \item{sign_entropy}{Shannon entropy of the sign distribution, measuring
#'       inconsistency in effect direction across specifications. Ranges from 0
#'       (perfect consistency) to ~1.58 (maximum inconsistency)}
#'   }
#'
#'   All numeric values are rounded to 5 decimal places.
#'
#' @export
#'
#' @examples
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
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE)
#'   )
#'
#' # Run a multiverse analysis
#' results <-
#'   the_data |>
#'   add_filters(include1 == 0, include2 != 3) |>
#'   add_variables("ivs", iv1, iv2) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_model("linear", lm({dvs} ~ {ivs})) |>
#'   expand_decisions() |>
#'   analyze_grid()
#'
#' # Assess robustness of standardized coefficients
#' assess_robustness(results, .estimand = std_coefficient)
#'
#' # Assess raw coefficients
#' assess_robustness(results, .estimand = coefficient)
#'
#' # Assess std_coef with custom zero threshold
#' assess_robustness(results, .estimand = std_coefficient, zero_threshold = .05)
#'
#' # Stratified assessment by model type
#' assess_robustness(results, .estimand = std_coefficient, .by = dvs)
assess_robustness <-
  function(.multi, .estimand, zero_threshold = .01, .by = NULL){

    estimand_summary <-
      .multi |>
      unpack_model_parameters() |>
      dplyr::rename(reference = parameter) |>
      dplyr::summarize(
        n_decisions = dplyr::n(),
        mean = mean({{.estimand}}),
        median = stats::median({{.estimand}}),
        iqr = stats::IQR({{.estimand}}),
        q05 = stats::quantile({{.estimand}}, p = .05),
        q95 = stats::quantile({{.estimand}}, p = .95),
        p_positive = sum({{.estimand}} >  zero_threshold)/n(),
        p_negative = sum({{.estimand}} < -zero_threshold)/n(),
        p_zero =
          sum(dplyr::between({{.estimand}}, -zero_threshold, zero_threshold))/
          dplyr::n(),
        sign_entropy =
          -sum(
            c(
              p_positive * log2(p_positive),
              p_negative * log2(p_negative),
              p_zero * log2(p_zero)
            ),
            na.rm = TRUE
          ),
        .by = c(reference, {{.by}})
      ) |>
      mutate(
        metric = dplyr::enexpr(.estimand) |> as.character(),
        metric_type = "parameter",

      )

    fit_summary <-
      .multi |>
      unpack_model_performance() |>
      tidyr::pivot_longer(
        -c(
          decision,
          dplyr::where(is.character)
        ),
        names_to = "metric"
      ) |>
      dplyr::select(dplyr::where(~dplyr::n_distinct(.x) > 1)) |>
      dplyr::summarize(
        n_decisions = dplyr::n(),
        mean = mean(value),
        median = stats::median(value),
        iqr = stats::IQR(value, na.rm = TRUE),
        q05 = stats::quantile(value, p = .05, na.rm = TRUE),
        q95 = stats::quantile(value, p = .95, na.rm = TRUE),
        .by = c({{.by}}, metric)
      ) |>
      dplyr::mutate(
        reference = "full model",
        metric_type = "fit index"
      )


    dplyr::bind_rows(estimand_summary, fit_summary) |>
      dplyr::relocate(metric, metric_type, reference) |>
      dplyr::mutate(
        dplyr::across(dplyr::where(is.numeric), ~round(.x, 5))
      )
  }

#' Decompose decision variance using Sobol sensitivity indices and variance
#' dispersal
#'
#' Quantifies how much each decision type (e.g., filters, variables, models)
#' contributes to the total variance in a focal estimand across all decision
#' specifications. Uses variance-based sensitivity analysis to partition
#' variance into main effects, interaction effects, and total effects for each
#' decision set.
#'
#' This function implements a Sobol-style decomposition where "decision sets"
#' (e.g., all filter decisions) are treated as factors whose combinations
#' produce different specifications. The decomposition reveals which analytical
#' choices have the strongest influence on results.
#'
#' @param .unpacked A \code{data.frame} with unpacked multiverse results,
#'   typically produced by \code{\link{unpack_model_parameters}} or
#'   \code{\link{unpack_model_performance}}. Must contain columns for each
#'   decision type (filters, variables, models, etc.) and the focal estimand.
#' @param .estimand The numeric outcome variable to decompose. Defaults to
#'   \code{std_coef} (standardized coefficients). Use unquoted column names with
#'   tidy evaluation.
#' @param .by Optional grouping variable(s) for stratified decomposition. The
#'   variance decomposition will be computed separately for each group. Useful
#'   for examining whether decision importance varies across different model
#'   variables or subgroups. Use unquoted column names.
#'
#' @return A \code{data.frame} with one row per decision set, containing:
#'   \describe{
#'     \item{decision_set}{Name of the decision type (e.g., "filters",
#'       "variables", "model")}
#'     \item{main_effect}{First-order Sobol index. Proportion of total variance
#'       explained by this decision set alone, averaging over all other
#'       decisions. Ranges from 0 (no effect) to 1 (explains all variance)}
#'     \item{total_effect}{Total Sobol index. Proportion of total variance
#'       explained by this decision set including all its interactions with
#'       other decisions. Always ≥ main_effect}
#'     \item{interaction_effect}{Total effect minus main effect. Proportion of
#'       variance due to interactions between this decision and others}
#'     \item{variance_reduction}{Proportion of variance eliminated by fixing
#'       this decision to a single option. Also called "expected reduction in
#'       variance" or EVPPI (Expected Value of Perfect Parameter Information)}
#'   }
#'
#'   If \code{.by} is specified, grouping columns appear first.
#'
#' @details The function computes four complementary variance measures:
#'
#'   \strong{Main effect (first-order Sobol):} How much does this decision
#'   matter on average, ignoring interactions? Computed by averaging the
#'   estimand over all combinations of other decisions, then computing the
#'   variance of those conditional means.
#'
#'   \strong{Total effect (total-order Sobol):} How much variance remains when
#'   we fix all decisions \emph{except} this one? Includes the decision's main
#'   effect plus all interactions involving it.
#'
#'   \strong{Interaction effect:} The gap between total and main effects,
#'   showing how much the decision's impact depends on other choices.
#'
#'   \strong{Variance reduction:} How much would total variance decrease if we
#'   picked one option for this decision? Useful for prioritizing which
#'   decisions to "fix" to reduce result instability.
#'
#'   Interpretation: A decision with high main effect drives results
#'   independently. A decision with high interaction effect matters, but
#'   differently depending on other choices. A decision with low total effect is
#'   relatively inconsequential.
#'
#' @export
#'
#' @examples
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
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE)
#'   )
#'
#' # Run a multiverse analysis
#' results <-
#'   the_data |>
#'   add_filters(include1 == 0, include2 != 3) |>
#'   add_variables("ivs", iv1, iv2) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_model("linear", lm({dvs} ~ {ivs})) |>
#'   expand_decisions() |>
#'   analyze_grid()
#'
#' # Decompose variance in standardized coefficients
#' unpacked <- unpack_model_parameters(results)
#' assess_decisions(unpacked, .estimand = std_coefficient)
#'
#' # Which decisions matter most for p-values?
#' assess_decisions(unpacked, .estimand = p)
#'
#' # Decompose separately for each parameter
#' assess_decisions(unpacked, .estimand = p, .by = dvs)
assess_decisions <-
  function(.unpacked, .estimand, .by = NULL){

    sobol_df <-
      .unpacked |>
      dplyr::select(decision:dplyr::ends_with("function"),{{.estimand}}) |>
      dplyr::select(-dplyr::matches("(model|args|perform|standardize|function)$")) |>
      dplyr::select(dplyr::where(~dplyr::n_distinct(.x) > 1)) |>
      dplyr::mutate(
        total_variance = sum(({{.estimand}}-mean({{.estimand}}))^2)/n(),
        .by = {{.by}}
      )

    sobol_first_order_df <-
      sobol_df |>
      tidyr::pivot_longer(
        -c(decision, {{.estimand}}, {{.by}}, total_variance),
        values_to = "value",
        names_to = "decision_set"
      ) |>
      dplyr::summarize(
        mean_output = mean({{.estimand}}),
        .by = c(decision_set, value, {{.by}}, total_variance)
      ) |>
      dplyr::summarize(
        mean_output_var = sum((mean_output-mean(mean_output))^2)/n(),
        .by = c(decision_set, {{.by}}, total_variance)
      ) |>
      dplyr::mutate(
        sobol_first_order = mean_output_var/total_variance
      )

    sobol_total_df <-
      sobol_df |>
      dplyr::select(-c(decision, {{.estimand}}, {{.by}}, total_variance)) |>
      names() |>
      purrr::map(function(sobol_var){

        sobol_df |>
          dplyr::select(-!!sobol_var, -decision) |>
          dplyr::summarize(
            var_output = sum(({{.estimand}}-mean({{.estimand}}))^2)/n(),
            .by = -{{.estimand}}
          ) |>
          dplyr::summarize(
            mean_var_output = mean(var_output),
            .by = c({{.by}}, total_variance)
          ) |>
          dplyr::mutate(
            sobol_total = mean_var_output/total_variance,
            decision_set = sobol_var
          )

      }) |>
      purrr::list_rbind()

    variance_dispersal_df <-
      sobol_df |>
      tidyr::pivot_longer(
        -c(decision, {{.estimand}}, {{.by}}, total_variance),
        values_to = "value",
        names_to = "decision_set"
      ) |>
      dplyr::summarize(
        conditional_variance = sum(({{.estimand}}-mean({{.estimand}}))^2)/n(),
        .by = c(decision_set, value, {{.by}}, total_variance)
      ) |>
      dplyr::summarize(
        expected_conditional_variance = mean(conditional_variance),
        .by = c(decision_set, {{.by}}, total_variance)
      ) |>
      dplyr::mutate(
        total_variance = total_variance,
        conditional_variance_ratio =
          expected_conditional_variance / total_variance,
        dispersal = 1 - conditional_variance_ratio
      ) |>
      dplyr::select(-dplyr::contains("variance"))

    dplyr::full_join(
      sobol_first_order_df,
      sobol_total_df
    ) |>
      dplyr::mutate(
        interaction_share = sobol_total - sobol_first_order
      ) |>
      dplyr::select(-dplyr::contains("output"), -total_variance) |>
      dplyr::relocate(
        {{.by}}
      ) |>
      dplyr::full_join(variance_dispersal_df) |>
      dplyr::rename(
        main_effect = sobol_first_order,
        total_effect = sobol_total,
        interaction_effect = interaction_share,
        variance_reduction = dispersal
      )

  }

assess_choices <-
  function(.unpacked){

    .unpacked |>
      dplyr::summarize(

      )

  }
