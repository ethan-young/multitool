# process_conditions --------------------------------------------------------

test_that("process_conditions returns one action, with halt taking priority", {
  the_data <- tibble::tibble(x = c(1, 2, 3), y = c(5, 5, 5))

  make_conditions <- function(n_test){
    tibble::tibble(
      condition = c("minimum n", "y varies"),
      test      = c(n_test, "dplyr::pull(y) |> var() > 0"),
      on_fail   = c("halt", "skip")
    )
  }

  # only the skip condition fails
  only_skip_fails <- process_conditions(the_data, make_conditions("nrow() >= 3"))

  expect_identical(only_skip_fails$condition_results$implied_action, c("proceed", "skip"))
  expect_identical(only_skip_fails$action, "skip")

  # both fail: halt wins
  both_fail <- process_conditions(the_data, make_conditions("nrow() >= 4"))

  expect_identical(both_fail$condition_results$implied_action, c("halt", "skip"))
  expect_identical(both_fail$action, "halt")

  # nothing fails
  all_pass <- process_conditions(the_data, make_conditions("nrow() >= 3") |> dplyr::slice(1))

  expect_identical(all_pass$condition_results$implied_action, "proceed")
  expect_identical(all_pass$action, "proceed")

  # the data is returned unchanged
  expect_identical(all_pass$data, the_data)
})

test_that("process_conditions treats NA as failed and rejects tests that aren't TRUE/FALSE", {
  one_row <- tibble::tibble(y = 5)

  # var() of one value is NA, so the test can't confirm the condition
  na_condition <-
    tibble::tibble(
      condition = "y varies",
      test      = "dplyr::pull(y) |> var() > 0",
      on_fail   = "skip"
    )

  na_checked <- process_conditions(one_row, na_condition)

  expect_true(is.na(na_checked$condition_results$result))
  expect_identical(na_checked$condition_results$implied_action, "skip")
  expect_identical(na_checked$action, "skip")

  # nrow() returns a count, not TRUE/FALSE
  count_condition <-
    tibble::tibble(
      condition = "row count",
      test      = "nrow()",
      on_fail   = "halt"
    )

  expect_error(process_conditions(one_row, count_condition), "single TRUE or FALSE")
})

# execute_universe_model ----------------------------------------------------
test_that("each postprocess step's stored code runs on the model, not the previous step", {
  the_data <- tibble::tibble(x = rnorm(30), y = rnorm(30), g = rep(c("a", "b"), 15))

  results <-
    the_data |>
    add_subgroups(g) |>
    add_model("linear", lm(y ~ x)) |>
    add_postprocess("anova", anova()) |>
    add_postprocess("coefficients", coef()) |>
    expand_pipeline() |>
    analyze_grid()

  stored_code <- results$pipeline_code[[1]]

  expect_match(stored_code$coefficients, "lm\\(.*\\) \\|> coef\\(\\)$")
  expect_no_match(stored_code$coefficients, "anova")
})

test_that("running data and model separately matches running the full chain", {
  # stored code finds the base data in the global environment, as in analyze_grid()'s workers
  assign(
    "split_test_data",
    tibble::tibble(x = rnorm(50), y = rnorm(50), keep = rbinom(50, 1, .8)),
    envir = globalenv()
  )

  grid <-
    split_test_data |>
    add_filters(keep == 1) |>
    add_model("linear", lm(y ~ x)) |>
    expand_pipeline()

  purrr::walk(grid$decision, \(decision_num){
    split_result <- execute_universe_model(grid, decision_index = decision_num)

    full_chain_model <-
      build_pipeline_code(grid, decision_num)$pipeline |>
      get_code("model") |>
      rlang::parse_expr() |>
      rlang::eval_tidy()

    expect_equal(
      split_result$model_fitted[[1]]$model_parameters[[1]]$coefficient,
      unname(coef(full_chain_model))
    )

    expect_identical(split_result$data_logs[[1]]$data_rows, nrow(model.frame(full_chain_model)))
    expect_identical(split_result$status, "completed")
  })

  rm("split_test_data", envir = globalenv())
})

test_that("execute_universe_model checks each decision's own conditions and skips on failure", {
  assign(
    "conditions_test_data",
    tibble::tibble(x = rnorm(20), y_varies = rnorm(20), y_flat = 5),
    envir = globalenv()
  )

  grid <-
    conditions_test_data |>
    add_variables("dvs", y_varies, y_flat) |>
    add_condition("dv varies", with(var({dvs}) > 0), on_fail = "skip") |>
    add_model("linear", lm({dvs} ~ x)) |>
    expand_pipeline()

  # decision 1 uses y_varies, decision 2 uses y_flat
  passed  <- execute_universe_model(grid, decision_index = 1)
  skipped <- execute_universe_model(grid, decision_index = 2)

  expect_identical(passed$status, "completed")
  expect_identical(passed$condition_results[[1]]$implied_action, "proceed")
  expect_true("model_fitted" %in% names(passed))

  expect_identical(skipped$status, "skipped")
  expect_identical(skipped$condition_results[[1]]$implied_action, "skip")
  expect_false("model_fitted" %in% names(skipped))
  expect_true(all(c("specifications", "data_logs", "pipeline_code") %in% names(skipped)))

  rm("conditions_test_data", envir = globalenv())
})

test_that("execute_universe_model stops on a failed halt condition and names the decision", {
  assign(
    "conditions_test_data",
    tibble::tibble(x = rnorm(20), y_varies = rnorm(20), y_flat = 5),
    envir = globalenv()
  )

  grid <-
    conditions_test_data |>
    add_variables("dvs", y_varies, y_flat) |>
    add_condition("dv varies", with(var({dvs}) > 0)) |>
    add_model("linear", lm({dvs} ~ x)) |>
    expand_pipeline()

  expect_error(execute_universe_model(grid, decision_index = 2), "Decision 2", class = "multitool_condition_halt")
  expect_no_error(execute_universe_model(grid, decision_index = 1))

  rm("conditions_test_data", envir = globalenv())
})

test_that("in record mode, each kind of failure becomes a status row naming the step", {
  assign("break_test_data", tibble::tibble(x = rnorm(20), y = rnorm(20)), envir = globalenv())

  run_one <- function(grid) execute_universe_model(grid, decision_index = 1, .on_break = "record")

  # the model can't find its variable
  model_error <-
    break_test_data |>
    add_variables("ivs", x) |>
    add_model("broken", lm(y ~ not_a_column)) |>
    expand_pipeline() |>
    run_one()

  expect_identical(model_error$status, "error")
  expect_identical(model_error$failed_step, "model")
  expect_true("data_logs" %in% names(model_error))

  # preprocessing refers to a missing column
  data_error <-
    break_test_data |>
    add_variables("ivs", x) |>
    add_preprocess("bad", mutate(z = not_a_column + 1)) |>
    add_model("linear", lm(y ~ {ivs})) |>
    expand_pipeline() |>
    run_one()

  expect_identical(data_error$failed_step, "data")

  # the model runs, then a postprocessing step fails
  postprocess_error <-
    break_test_data |>
    add_variables("ivs", x) |>
    add_model("linear", lm(y ~ {ivs})) |>
    add_postprocess("bad", stop("broken postprocess")) |>
    expand_pipeline() |>
    run_one()

  expect_identical(postprocess_error$failed_step, "postprocess (bad)")
  expect_true("model_fitted" %in% names(postprocess_error))

  # a halt condition fails
  halted <-
    break_test_data |>
    add_variables("ivs", x) |>
    add_condition("enough rows", nrow() > 1000) |>
    add_model("linear", lm(y ~ {ivs})) |>
    expand_pipeline() |>
    run_one()

  expect_identical(halted$status, "halted")
  expect_identical(halted$run_message, "enough_rows")

  rm("break_test_data", envir = globalenv())
})

test_that("in stop mode, an error names the decision and step and keeps the original error", {
  assign("break_test_data", tibble::tibble(x = rnorm(20), y = rnorm(20)), envir = globalenv())

  grid <-
    break_test_data |>
    add_variables("ivs", x) |>
    add_model("broken", lm(y ~ not_a_column)) |>
    expand_pipeline()

  expect_error(
    execute_universe_model(grid, decision_index = 1),
    "Decision 1 failed at the model step",
    class = "multitool_decision_error"
  )

  expect_warning(analyze_grid(grid, .on_break = "record"), "1 decision\\(s\\) had errors")

  rm("break_test_data", envir = globalenv())
})
