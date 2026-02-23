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
#' assess_robustness(results)
#'
#' # Assess raw coefficients
#' assess_robustness(results, .estimand = unstd_coef)
#'
#' # Assess std_coef with custom zero threshold
#' assess_robustness(results, .estimand = std_coef, zero_threshold = .05)
#'
#' # Stratified assessment by model type
#' assess_robustness(results, .estimand = std_coef, .by = dvs)
assess_robustness <-
  function(.multi, .estimand = std_coef, zero_threshold = .01, .by = NULL){

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

decomp_decision_variance <-
  function(.unpacked, .estimand = std_coef, .by = NULL){

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

compare_choices <-
  function(.unpacked){

    .unpacked |>
      dplyr::summarize(

      )

  }


