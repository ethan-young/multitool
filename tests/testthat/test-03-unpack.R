# unpack_specs ----------------------------------------------------------------
test_that("unpack_specs presents specifications four ways and leaves out constant steps", {
  results <- make_results()

  wide <- unpack_specs(results)

  expect_equal(nrow(wide), 4)
  expect_true(all(c("status", "keep", "dvs") %in% names(wide)))
  expect_false(any(c("specifications", "conditions", "postprocess") %in% names(wide)))

  long <- unpack_specs(results, "long")

  expect_true(all(c("decision_type", "decision_set", "decision_choice") %in% names(long)))
  expect_false("status" %in% long$decision_set)

  expect_identical(unpack_specs(results, "no"), results)
  expect_false("specifications" %in% names(unpack_specs(results, "drop")))
  expect_error(unpack_specs(results, "nope"))
})

# unpack_results and its wrappers ----------------------------------------------
test_that("unpack_results returns decision, status, specifications, and the output only", {
  results <- make_results()

  expect_message(
    params <- unpack_model_parameters(results),
    "2 decision\\(s\\) have no `model_fitted`"
  )

  expect_identical(unique(params$status), "completed")
  expect_false(
    any(c("data_logs", "run_logs", "pipeline_code", "model_performance") %in% names(params))
  )

  dropped <- suppressMessages(unpack_model_parameters(results, .unpack_specs = "drop"))

  expect_identical(names(dropped)[1:2], c("decision", "status"))
  expect_false("keep" %in% names(dropped))

  nested <- suppressMessages(unpack_model_parameters(results, .unpack_specs = "no"))
  expect_true("specifications" %in% names(nested))
})

test_that("unfinished decisions are kept as empty rows when requested", {
  results <- make_results()

  all_decisions <- unpack_model_parameters(results, .include_unfinished = TRUE)

  expect_setequal(unique(all_decisions$status), c("completed", "skipped"))
  expect_true(all(is.na(all_decisions$coefficient[all_decisions$status == "skipped"])))
})

test_that("effect_key filters on parameter keys and says so when there are none", {
  keyed <- suppressMessages(unpack_model_parameters(make_results(), effect_key = "slope"))

  expect_true(nrow(keyed) > 0)
  expect_true(all(keyed$parameter_key == "slope"))

  expect_error(
    suppressMessages(unpack_model_parameters(make_results(with_keys = FALSE), effect_key = "slope")),
    "needs parameter keys"
  )
})

# unpack_postprocess ------------------------------------------------------------
test_that("unpack_postprocess selects a step by column name, step name, or default", {
  results <- make_results()

  expect_message(unpack_postprocess(results), "Also available: coefficients_fitted")

  by_column <- suppressMessages(unpack_postprocess(results, anova_fitted))
  by_step   <- suppressMessages(unpack_postprocess(results, "anova"))
  by_default <- suppressMessages(unpack_postprocess(results))

  expect_identical(by_column, by_step)
  expect_identical(by_column, by_default)

  # only the step's output, not its function name or logs
  expect_false(any(c("postprocess_function", "postprocess_warnings") %in% names(by_column)))

  expect_error(
    unpack_postprocess(results, nope),
    "Available: anova_fitted, coefficients_fitted"
  )
})

# unpack_logs -------------------------------------------------------------------
test_that("unpack_logs has one row per decision and every requested source", {
  results <- make_results()

  logs <- unpack_logs(results, .unpack_specs = "drop")

  expect_equal(nrow(logs), 4)
  expect_setequal(unique(logs$status), c("completed", "skipped"))
  expect_true(
    all(c("failed_step", "data_rows", "model_warnings", "anova_warnings", "coefficients_warnings") %in% names(logs))
  )

  # skipped decisions never fit a model or ran postprocessing
  skipped <- logs |> dplyr::filter(status == "skipped")
  expect_true(all(is.na(skipped$model_warnings)))
  expect_identical(unique(skipped$failed_step), "conditions")

  only_run <- unpack_logs(results, .which = "run", .unpack_specs = "drop")
  expect_false(any(c("data_rows", "model_warnings") %in% names(only_run)))

  expect_error(unpack_logs(results, .which = "nope"))
})

# compose_view ------------------------------------------------------------------
test_that("compose_view keeps every decision, shows status once, and rejects repeated prefixes", {
  results <- make_results()

  view <- compose_view(results, model_parameters, anova_fitted)

  expect_setequal(unique(view$decision), results$decision)
  expect_identical(sum(names(view) == "status"), 1L)
  expect_true(all(is.na(view$params_coefficient[view$status == "skipped"])))
  expect_true(any(startsWith(names(view), "anova_")))

  run_view <- compose_view(results, run_logs)
  expect_true("run_failed_step" %in% names(run_view))

  expect_error(
    compose_view(results, a = anova_fitted, a = coefficients_fitted),
    "needs its own prefix"
  )
})
