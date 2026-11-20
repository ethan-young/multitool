#' Summarize an estimate across decisions
#'
#' @param .unpacked unpacked results, from one of the \code{unpack_*}
#'   functions.
#' @param .what the column or columns to summarize, such as a model estimate
#'   or a fit statistic.
#' @param .how a named list of summary functions to compute over the
#'   estimates, e.g. \code{list(mean = mean, median = median)}. Add
#'   \code{na.rm = TRUE} (e.g., \code{\(x) mean(x, na.rm = TRUE)}) if
#'   \code{.what} can be missing.
#' @param .group optional column or columns to summarize within, passed to
#'   the \code{.by} argument of \code{dplyr::summarize()}.
#' @param list_cols logical, \code{TRUE} by default. Whether to add list
#'   columns holding the raw values of each summarized column, which are
#'   useful for plots and tables.
#'
#' @return a \code{tibble} with, for each column in \code{.what}, one column
#'   per summary function in \code{.how}, named \code{<column>_<function>},
#'   followed by \code{<column>_list} when \code{list_cols = TRUE}. Grouping
#'   columns from \code{.group} come first.
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
#'   add_model("linear_model", lm({dvs} ~ {ivs} * {mods} + cov1))
#'
#' pipeline_grid <- expand_pipeline(full_pipeline)
#'
#' # Run the whole multiverse
#' the_multiverse <- analyze_grid(pipeline_grid[1:10,])
#'
#' # Reveal and condense
#' the_multiverse |>
#'   unpack_model_parameters() |>
#'   filter(str_detect(parameter, "iv")) |>
#'   condense(coefficient, list(mean = mean, median = median))
condense <- function(.unpacked, .what, .how, .group = NULL, list_cols = TRUE){

  if(!rlang::is_list(.how) || !rlang::is_named(.how)){
    rlang::abort(
      c(
        "`.how` must be a named list of summary functions.",
        i = "For example, `list(mean = mean, median = median)`."
      )
    )
  }

  # the raw values are kept as one more "summary": a list column
  summary_fns <- if(list_cols) c(.how, list = list) else .how

  .unpacked |>
    dplyr::summarize(
      dplyr::across(
        .cols = {{.what}},
        .fns = summary_fns,
        .names = "{.col}_{.fn}"
      ),
      .by = {{.group}}
    )
}

#' @describeIn condense Rank decisions by an estimate and sort them, within
#'   groups if \code{.group} is given. Rank 1 is the smallest (most negative)
#'   value, tied values share a rank, and missing values have no rank and
#'   sort last. When results have several rows per decision, such as one per
#'   model parameter, filter to one parameter or group by it.
#' @param focused logical, \code{TRUE} by default. Return only
#'   \code{decision}, any grouping columns, the rank, and the estimate. Set to
#'   \code{FALSE} to keep all columns. The results are sorted either way.
#' @export
organize <- function(.unpacked, .what, .group = NULL, focused = TRUE){

  # rank 1 is the smallest (most negative) estimate; ties share a rank
  organized <-
    .unpacked |>
    dplyr::mutate(
      rank = dplyr::dense_rank({{.what}}),
      .by = {{.group}}
    )

  if(focused){
    organized <-
      organized |>
      dplyr::select(decision, {{.group}}, rank, {{.what}})
  }

  if(rlang::quo_is_null(rlang::enquo(.group))){
    organized |>
      dplyr::arrange(rank)
  } else{
    organized |>
      dplyr::arrange(dplyr::pick({{.group}}), rank)
  }
}

#' Assess the robustness of multiverse analysis results
#'
#' Summarizes the distribution of a particular model parameter, fit statistics,
#' or any other values returned by the focal modeling process or a
#' post-processing step. The summaries are computed over all specifications in
#' the analysis grid. This function helps evaluate whether results are robust to
#' analytical decisions by computing key distributional properties and sign
#' consistency metrics.
#'
#' @param .multi results from \code{\link{analyze_grid}}. The model
#'   parameters and fit statistics are unpacked here, so unlike
#'   \code{\link{assess_decisions}} this function takes results directly.
#' @param .estimand the model parameter column to assess, such as
#'   \code{std_coefficient}, \code{coefficient}, or \code{p}. Use an unquoted
#'   column name. Fit statistics are always summarized as well.
#' @param zero_threshold the size below which an effect counts as practically
#'   zero: estimates between \code{-zero_threshold} and \code{zero_threshold}
#'   are classified as zero. Defaults to \code{.01}.
#' @param .by optional specification columns to summarize within, such as
#'   \code{dvs}. Use unquoted column names.
#' @param .reference the column naming each effect. By default the
#'   \code{parameter} (or \code{term}) column, so each parameter is
#'   summarized separately. When variables vary across decisions, use
#'   \code{.reference = parameter_key} to summarize one effect across all of
#'   its variables (see \code{\link{add_parameter_keys}}).
#'
#' @details Only completed decisions are summarized. Decisions that were
#'   skipped, halted, or errored have no model results; unpacking leaves them
#'   out and reports how many.
#'
#' @return a \code{tibble} with one row per effect (and per fit statistic),
#'   with columns:
#'   \describe{
#'     \item{metric}{the summarized column, e.g. \code{"std_coefficient"} or
#'       \code{"aic"}}
#'     \item{metric_type}{\code{"parameter"} or \code{"fit index"}}
#'     \item{reference}{the effect, or \code{"full model"} for fit
#'       statistics}
#'     \item{n_decisions}{decisions with a non-missing value}
#'     \item{n_missing}{decisions where the value is missing}
#'     \item{mean, median, iqr, q05, q95}{the distribution across decisions}
#'     \item{p_positive, p_negative, p_zero}{the share of decisions with a
#'       positive, negative, or practically zero estimate (parameters only)}
#'     \item{sign_entropy}{Shannon entropy of the sign distribution: 0 when
#'       every decision agrees in sign, up to about 1.58 when positive,
#'       negative, and zero are equally common (parameters only)}
#'   }
#'   Numeric values are rounded to 5 decimal places.
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
#'   expand_pipeline() |>
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
#'
#' # Assess one effect across the iv choices, using a parameter key
#' results_keyed <-
#'   the_data |>
#'   add_filters(include1 == 0, include2 != 3) |>
#'   add_variables("ivs", iv1, iv2) |>
#'   add_model("linear", lm(dv1 ~ {ivs})) |>
#'   add_parameter_keys("focal slope", "{ivs}") |>
#'   expand_pipeline() |>
#'   analyze_grid()
#'
#' assess_robustness(results_keyed, std_coefficient, .reference = parameter_key)
assess_robustness <-
  function(.multi, .estimand, zero_threshold = .01, .by = NULL, .reference = NULL){

    unpacked_params <- unpack_model_parameters(.multi)

    # the column naming each effect: parameter (or term) by default
    reference_col <-
      if(rlang::quo_is_null(rlang::enquo(.reference))){
        intersect(c("parameter", "term"), names(unpacked_params))[1]
      } else{
        rlang::as_name(rlang::enquo(.reference))
      }

    if(is.na(reference_col) || !reference_col %in% names(unpacked_params)){
      rlang::abort(
        c(
          "Couldn't find the column naming each parameter.",
          i = "Name it with `.reference`, e.g. `.reference = parameter_key`."
        )
      )
    }

    estimand_summary <-
      unpacked_params |>
      dplyr::rename(reference = dplyr::all_of(reference_col)) |>
      dplyr::summarize(
        n_decisions = sum(!is.na({{ .estimand }})),
        n_missing   = sum(is.na({{ .estimand }})),
        mean   = mean({{ .estimand }}, na.rm = TRUE),
        median = stats::median({{ .estimand }}, na.rm = TRUE),
        iqr    = stats::IQR({{ .estimand }}, na.rm = TRUE),
        q05    = stats::quantile({{ .estimand }}, probs = .05, na.rm = TRUE, names = FALSE),
        q95    = stats::quantile({{ .estimand }}, probs = .95, na.rm = TRUE, names = FALSE),
        p_positive = sum({{ .estimand }} >  zero_threshold, na.rm = TRUE) / n_decisions,
        p_negative = sum({{ .estimand }} < -zero_threshold, na.rm = TRUE) / n_decisions,
        p_zero =
          sum(dplyr::between({{ .estimand }}, -zero_threshold, zero_threshold), na.rm = TRUE) /
          n_decisions,
        sign_entropy =
          -sum(
            c(
              p_positive * log2(p_positive),
              p_negative * log2(p_negative),
              p_zero * log2(p_zero)
            ),
            na.rm = TRUE
          ),
        .by = c(reference, {{ .by }})
      ) |>
      dplyr::mutate(
        metric = rlang::as_label(rlang::enquo(.estimand)),
        metric_type = "parameter"
      )

    # every numeric fit statistic, summarized the same way
    fit_summary <-
      unpack_model_performance(.multi) |>
      suppressMessages() |>
      dplyr::select(decision, {{ .by }}, dplyr::where(is.numeric)) |>
      tidyr::pivot_longer(-c(decision, {{ .by }}), names_to = "metric") |>
      dplyr::summarize(
        n_decisions = sum(!is.na(value)),
        n_missing   = sum(is.na(value)),
        mean   = mean(value, na.rm = TRUE),
        median = stats::median(value, na.rm = TRUE),
        iqr    = stats::IQR(value, na.rm = TRUE),
        q05    = stats::quantile(value, probs = .05, na.rm = TRUE, names = FALSE),
        q95    = stats::quantile(value, probs = .95, na.rm = TRUE, names = FALSE),
        .by = c({{ .by }}, metric)
      ) |>
      dplyr::mutate(
        reference = "full model",
        metric_type = "fit index"
      )

    dplyr::bind_rows(estimand_summary, fit_summary) |>
      dplyr::relocate(metric, metric_type, reference) |>
      dplyr::mutate(
        dplyr::across(dplyr::where(is.numeric), \(x) round(x, 5))
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
#' @param .unpacked unpacked results with wide specifications, typically from
#'   \code{\link{unpack_model_parameters}} or
#'   \code{\link{unpack_model_performance}} with the default \code{.unpack_specs
#'   = "wide"}.
#' @param .estimand the numeric column to decompose, such as
#'   \code{std_coefficient} or \code{p}. Use an unquoted column name.
#' @param .by optional columns to decompose within, such as \code{parameter} or
#'   \code{dvs}. Use unquoted column names.
#'
#' @return a \code{tibble} with one row per decision set (and per \code{.by}
#'   group, whose columns come first):
#'   \describe{
#'     \item{decision_set}{a specification column, such as a filtered
#'       variable, a variable group, or \code{model_meta}}
#'     \item{main_effect}{the share of the estimate's variance explained by
#'       this decision alone: the variance of its choice means, divided by
#'       the total variance}
#'     \item{total_effect}{the share explained by this decision including its
#'       interactions with every other decision: the variance left when all
#'       other decisions are held fixed, averaged over those combinations}
#'     \item{interaction_effect}{\code{total_effect} minus
#'       \code{main_effect}: the share that depends on how this decision
#'       combines with others}
#'   }
#'
#' @details Each specification column with more than one choice is treated as a
#'   factor, and the decomposition is computed exactly from the grid rather than
#'   by simulation. Averages are weighted by the number of decisions behind
#'   them, so the indices remain correct when skipped or halted decisions leave
#'   some combinations empty. Total effects are most reliable when the grid is
#'   complete: a combination with only one remaining decision has nothing to
#'   vary within it.
#'
#'   The function needs one row per decision within \code{.by}. Unpacked
#'   parameters have one row per parameter, so filter to one parameter or add
#'   \code{parameter} to \code{.by}. Every row needs a value for
#'   \code{.estimand}; missing estimates stop the function. Decisions that
#'   didn't complete are already left out by unpacking.
#'
#'   A decision with a high main effect moves the estimate on its own. One with
#'   a high interaction effect matters, but in ways that depend on other
#'   choices. One with a low total effect makes little difference. Use
#'   \code{\link{assess_choices}} to see which choices within a decision are
#'   responsible.
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
#'   expand_pipeline() |>
#'   analyze_grid()
#'
#' # Decompose variance in standardized coefficients
#' unpacked <- unpack_model_parameters(results)
#' assess_decisions(unpacked, .estimand = std_coefficient, .by = parameter)
#'
#' # Which decisions matter most for p-values?
#' assess_decisions(unpacked, .estimand = p, .by = parameter)
#'
#' # Decompose separately for each parameter
#' assess_decisions(unpacked, .estimand = p, .by = c(parameter, dvs))
assess_decisions <-
  function(.unpacked, .estimand, .by = NULL){

    estimand_name <- rlang::as_label(rlang::enquo(.estimand))
    by_cols <- .unpacked |> dplyr::select({{ .by }}) |> names()

    n_missing <- sum(is.na(dplyr::pull(.unpacked, {{ .estimand }})))

    if(n_missing > 0){
      rlang::abort(
        c(
          glue::glue("{n_missing} row(s) have a missing `{estimand_name}`."),
          i = "Every decision needs an estimate; filter or resolve missing values first."
        )
      )
    }

    # the specification columns: from decision through model_meta
    decision_df <-
      .unpacked |>
      dplyr::select(decision:dplyr::ends_with("meta"), {{ .estimand }}, {{ .by }}) |>
      dplyr::select(
        -dplyr::matches("(model|args|perform|standardize|function)$"),
        -dplyr::any_of("status")
      )

    rows_per_decision <-
      decision_df |>
      dplyr::summarize(n = dplyr::n(), .by = dplyr::all_of(c("decision", by_cols)))

    if(any(rows_per_decision$n > 1)){
      rlang::abort(
        c(
          "`assess_decisions()` needs one row per decision (within `.by`).",
          i = "Unpacked parameters have one row per parameter: filter to one, or add `parameter` to `.by`."
        )
      )
    }

    # decision sets with more than one choice; the rest have nothing to decompose
    decision_sets <-
      decision_df |>
      dplyr::select(-decision, -{{ .estimand }}, -dplyr::all_of(by_cols)) |>
      dplyr::select(dplyr::where(\(choices) dplyr::n_distinct(choices) > 1)) |>
      names()

    sobol_df <-
      decision_df |>
      dplyr::select(
        decision,
        dplyr::all_of(c(decision_sets, by_cols)),
        estimate = {{ .estimand }}
      ) |>
      dplyr::mutate(
        grand_mean = mean(estimate),
        total_variance = mean((estimate - grand_mean)^2),
        .by = dplyr::all_of(by_cols)
      )

    # main effect: variance of the choice means, weighted by decisions per choice
    main_effects <-
      sobol_df |>
      tidyr::pivot_longer(
        dplyr::all_of(decision_sets),
        names_to = "decision_set",
        values_to = "choice"
      ) |>
      dplyr::summarize(
        choice_n = dplyr::n(),
        choice_mean = mean(estimate),
        .by = dplyr::all_of(c(by_cols, "decision_set", "choice", "grand_mean", "total_variance"))
      ) |>
      dplyr::summarize(
        main_effect =
          sum(choice_n * (choice_mean - grand_mean)^2) / sum(choice_n) /
          dplyr::first(total_variance),
        .by = dplyr::all_of(c(by_cols, "decision_set"))
      )

    # total effect: variance left when every other decision is held fixed,
    # averaged over those fixed combinations, weighted by their size
    total_effects <-
      purrr::map(decision_sets, \(focal_set){
        sobol_df |>
          dplyr::summarize(
            group_n = dplyr::n(),
            group_variance = mean((estimate - mean(estimate))^2),
            .by = dplyr::all_of(c(by_cols, setdiff(decision_sets, focal_set), "total_variance"))
          ) |>
          dplyr::summarize(
            total_effect =
              sum(group_n * group_variance) / sum(group_n) /
              dplyr::first(total_variance),
            .by = dplyr::all_of(by_cols)
          ) |>
          dplyr::mutate(decision_set = focal_set)
      }) |>
      purrr::list_rbind()

    main_effects |>
      dplyr::left_join(total_effects, by = c(by_cols, "decision_set")) |>
      dplyr::mutate(interaction_effect = total_effect - main_effect) |>
      dplyr::select(
        dplyr::all_of(by_cols),
        decision_set,
        main_effect,
        total_effect,
        interaction_effect
      )
  }

#' Attribute results to individual choices
#'
#' For each choice within each decision set, compares the estimate when that
#' choice is made with the estimate across the other choices for the same
#' decision. Where \code{\link{assess_decisions}} shows how much each
#' decision set matters, \code{assess_choices()} shows which particular
#' choices are responsible.
#'
#' @param .unpacked unpacked results with wide specifications, typically from
#'   \code{\link{unpack_model_parameters}} with the default
#'   \code{.unpack_specs = "wide"}.
#' @param .estimand the numeric column to summarize, such as
#'   \code{std_coefficient}. Use an unquoted column name.
#' @param zero_threshold the size below which an effect counts as practically
#'   zero: estimates between \code{-zero_threshold} and \code{zero_threshold}
#'   are classified as zero. Defaults to \code{.01}.
#' @param .by optional columns to summarize within, such as \code{parameter}
#'   or \code{dvs}. Use unquoted column names.
#'
#' @details Each choice's \code{reference_mean} leaves that choice out: it is
#'   the mean estimate over the other choices for the same decision, weighted
#'   by the number of decisions behind each. A \code{shift} far from zero
#'   means the results move noticeably when that choice is made. When a
#'   decision has two choices, their shifts mirror each other.
#'
#'   In a complete grid, every choice is compared over the same combinations
#'   of other decisions. When skipped or halted decisions leave some
#'   combinations empty, a choice's mean averages over whichever combinations
#'   remain, so its shift can partly reflect other decisions.
#'
#'   The function needs one row per decision within \code{.by}. Unpacked
#'   parameters have one row per parameter, so filter to one parameter or add
#'   \code{parameter} to \code{.by}. Every row needs a value for
#'   \code{.estimand}; missing estimates stop the function. Decisions that
#'   didn't complete are already left out by unpacking.
#'
#'   The sign measures are meant for signed effects on a standardized scale,
#'   where \code{zero_threshold} has a consistent meaning.
#'
#' @return a \code{tibble} with one row per choice, with columns:
#'   \describe{
#'     \item{decision_set}{the decision, such as a filtered variable or a
#'       variable group}
#'     \item{choice_value}{the choice made for that decision}
#'     \item{n_specs}{decisions that made this choice}
#'     \item{conditional_mean}{the mean estimate when this choice is made}
#'     \item{reference_mean}{the mean estimate over the other choices}
#'     \item{shift}{\code{conditional_mean} minus \code{reference_mean}}
#'     \item{conditional_median, conditional_iqr}{the median and
#'       interquartile range when this choice is made}
#'     \item{p_positive, p_negative, p_zero}{the share of these decisions
#'       with a positive, negative, or practically zero estimate}
#'     \item{sign_consistency}{the largest of the three shares: 1 when every
#'       decision with this choice agrees in sign}
#'   }
#'   Grouping columns from \code{.by} appear first.
#'
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#'
#' the_data <-
#'   data.frame(
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     dv1  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE)
#'   )
#'
#' unpacked <-
#'   the_data |>
#'   add_filters(include1 == 0, include2 != 3) |>
#'   add_variables("ivs", iv1, iv2) |>
#'   add_model("linear", lm(dv1 ~ {ivs})) |>
#'   expand_pipeline() |>
#'   analyze_grid() |>
#'   unpack_model_parameters() |>
#'   filter(parameter != "(Intercept)")
#'
#' # which choices move the standardized slope?
#' assess_choices(unpacked, .estimand = std_coefficient)
assess_choices <-
  function(.unpacked, .estimand, zero_threshold = .01, .by = NULL){

    estimand_name <- rlang::as_label(rlang::enquo(.estimand))
    by_cols <- .unpacked |> dplyr::select({{ .by }}) |> names()

    n_missing <- sum(is.na(dplyr::pull(.unpacked, {{ .estimand }})))

    if(n_missing > 0){
      rlang::abort(
        c(
          glue::glue("{n_missing} row(s) have a missing `{estimand_name}`."),
          i = "Every decision needs an estimate; filter or resolve missing values first."
        )
      )
    }

    # the specification columns: from decision through model_meta
    decision_df <-
      .unpacked |>
      dplyr::select(decision:dplyr::ends_with("meta"), {{ .estimand }}, {{ .by }}) |>
      dplyr::select(
        -dplyr::matches("(model|args|perform|standardize|function)$"),
        -dplyr::any_of("status")
      )

    rows_per_decision <-
      decision_df |>
      dplyr::summarize(n = dplyr::n(), .by = dplyr::all_of(c("decision", by_cols)))

    if(any(rows_per_decision$n > 1)){
      rlang::abort(
        c(
          "`assess_choices()` needs one row per decision (within `.by`).",
          i = "Unpacked parameters have one row per parameter: filter to one, or add `parameter` to `.by`."
        )
      )
    }

    # decision sets with more than one choice
    decision_sets <-
      decision_df |>
      dplyr::select(-decision, -{{ .estimand }}, -dplyr::all_of(by_cols)) |>
      dplyr::select(dplyr::where(\(choices) dplyr::n_distinct(choices) > 1)) |>
      names()

    decision_df |>
      dplyr::select(
        decision,
        dplyr::all_of(c(decision_sets, by_cols)),
        estimate = {{ .estimand }}
      ) |>
      tidyr::pivot_longer(
        dplyr::all_of(decision_sets),
        names_to = "decision_set",
        values_to = "choice_value"
      ) |>
      dplyr::summarize(
        n_specs = dplyr::n(),
        choice_sum = sum(estimate),
        conditional_mean = mean(estimate),
        conditional_median = stats::median(estimate),
        conditional_iqr = stats::IQR(estimate),
        p_positive = sum(estimate >  zero_threshold) / n_specs,
        p_negative = sum(estimate < -zero_threshold) / n_specs,
        p_zero = sum(dplyr::between(estimate, -zero_threshold, zero_threshold)) / n_specs,
        .by = dplyr::all_of(c(by_cols, "decision_set", "choice_value"))
      ) |>
      dplyr::mutate(
        # leave-one-out: the mean over this decision's other choices
        reference_mean = (sum(choice_sum) - choice_sum) / (sum(n_specs) - n_specs),
        shift = conditional_mean - reference_mean,
        sign_consistency = pmax(p_positive, p_negative, p_zero),
        .by = dplyr::all_of(c(by_cols, "decision_set"))
      ) |>
      dplyr::select(
        dplyr::all_of(by_cols),
        decision_set,
        choice_value,
        n_specs,
        conditional_mean,
        reference_mean,
        shift,
        conditional_median,
        conditional_iqr,
        p_positive,
        p_negative,
        p_zero,
        sign_consistency
      )
  }
