
test_that("show_code shows the same code for a grid and its results, one step at a time", {
  the_data <- tibble::tibble(x = rnorm(30), y = rnorm(30))

  grid <-
    the_data |>
    add_variables("ivs", x) |>
    add_condition("minimum n", nrow() >= 10) |>
    add_condition("y varies", with(var(y) > 0)) |>
    add_model("linear", lm(y ~ {ivs})) |>
    add_postprocess("anova", anova()) |>
    add_postprocess("coefficients", coef()) |>
    expand_pipeline()

  results <- analyze_grid(grid, show_progress = FALSE)

  # one source of code: grid and results agree
  expect_output(grid_code <- show_code(grid, 1, .step = "postprocess", .which = "coefficients"))
  expect_output(results_code <- show_code(results, 1, .step = "postprocess", .which = "coefficients"))
  expect_identical(grid_code, results_code)

  # no step named: the first is shown, and the others are listed
  expect_output(
    expect_message(show_code(results, 1, .step = "conditions"), "Also available: y_varies")
  )

  expect_error(show_code(grid, 1, .step = "conditions", .which = "nope"), "Available: minimum_n, y_varies")
})
