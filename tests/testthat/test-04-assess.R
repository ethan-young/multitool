test_that("condense summarizes estimates, optionally keeping the raw values", {
  unpacked <-
    tibble::tibble(
      decision = 1:6,
      group    = rep(c("a", "b"), 3),
      estimate = c(1, 2, 3, 4, 5, 6)
    )

  summarized <- condense(unpacked, estimate, list(mean = mean, max = max))

  expect_identical(names(summarized), c("estimate_mean", "estimate_max", "estimate_list"))
  expect_equal(summarized$estimate_mean, 3.5)
  expect_equal(summarized$estimate_list[[1]], unpacked$estimate)

  grouped <-
    condense(unpacked, estimate, list(mean = mean), .group = group, list_cols = FALSE)

  expect_identical(names(grouped), c("group", "estimate_mean"))
  expect_equal(grouped$estimate_mean, c(3, 4))

  expect_error(condense(unpacked, estimate, list(mean, max)), "named list")
})

test_that("organize ranks and sorts estimates, within groups when given", {
  unpacked <-
    tibble::tibble(
      decision = 1:6,
      group    = rep(c("a", "b"), 3),
      estimate = c(3, -1, 2, 5, -2, 5)
    )

  ranked <- organize(unpacked, estimate)

  expect_identical(names(ranked), c("decision", "rank", "estimate"))
  expect_identical(ranked$estimate, sort(unpacked$estimate))
  expect_identical(ranked$rank, c(1L, 2L, 3L, 4L, 5L, 5L))

  grouped <- organize(unpacked, estimate, .group = group)

  # group a: decisions 1, 3, 5 (3, 2, -2); group b: decisions 2, 4, 6 (-1, 5, 5)
  expect_identical(grouped$decision, c(5L, 3L, 1L, 2L, 4L, 6L))
  expect_identical(grouped$rank, c(1L, 2L, 3L, 1L, 2L, 2L))

  unfocused <- organize(unpacked, estimate, focused = FALSE)

  expect_true(all(c("group", "estimate", "rank") %in% names(unfocused)))
  expect_identical(unfocused$rank, sort(unfocused$rank))
})

test_that("assess_decisions recovers known main and total effects", {
  make_unpacked <- function(estimate_fn){
    tidyr::expand_grid(a = c("a1", "a2"), b = c("b1", "b2")) |>
      dplyr::mutate(
        decision = dplyr::row_number(),
        status = "completed",
        model_meta = "linear",
        estimate = estimate_fn(a, b)
      ) |>
      dplyr::relocate(decision, status)
  }

  # only a matters
  a_only <- assess_decisions(make_unpacked(\(a, b) as.numeric(a == "a2")), estimate)

  expect_equal(a_only$main_effect[a_only$decision_set == "a"], 1)
  expect_equal(a_only$total_effect[a_only$decision_set == "b"], 0)

  # only the combination matters: each main effect 1/3, each total effect 2/3
  combined <- assess_decisions(make_unpacked(\(a, b) as.numeric(a == "a2" & b == "b2")), estimate)

  expect_equal(combined$main_effect, c(1/3, 1/3))
  expect_equal(combined$total_effect, c(2/3, 2/3))
  expect_equal(combined$interaction_effect, c(1/3, 1/3))

  # one row per decision, and no missing estimates
  doubled <- dplyr::bind_rows(make_unpacked(\(a, b) 1), make_unpacked(\(a, b) 2))
  expect_error(assess_decisions(doubled, estimate), "one row per decision")

  missing <- make_unpacked(\(a, b) c(1, NA, 2, 3))
  expect_error(assess_decisions(missing, estimate), "missing")
})

test_that("assess_choices compares each choice with the decision's other choices", {
  make_unpacked <- function(grid, estimates){
    grid |>
      dplyr::mutate(
        decision = dplyr::row_number(),
        status = "completed",
        model_meta = "linear",
        estimate = estimates
      ) |>
      dplyr::relocate(decision, status)
  }

  # 2 x 2: a1 averages 1.5, a2 averages 3.5; b1 averages 2, b2 averages 3
  two_by_two <-
    make_unpacked(
      tidyr::expand_grid(a = c("a1", "a2"), b = c("b1", "b2")),
      c(1, 2, 3, 4)
    ) |>
    assess_choices(estimate)

  a_rows <- two_by_two |> dplyr::filter(decision_set == "a")
  expect_equal(a_rows$conditional_mean, c(1.5, 3.5))
  expect_equal(a_rows$shift, c(-2, 2))
  expect_true(all(two_by_two$n_specs == 2))

  # three choices: each reference is the mean of the other two
  three_choices <-
    make_unpacked(
      tibble::tibble(a = c("a1", "a2", "a3"), b = c("b1", "b2", "b1")),
      c(1, 2, 6)
    ) |>
    assess_choices(estimate) |>
    dplyr::filter(decision_set == "a")

  expect_equal(three_choices$reference_mean, c(4, 3.5, 1.5))
  expect_equal(three_choices$shift, c(-3, -1.5, 4.5))

  missing <- make_unpacked(tidyr::expand_grid(a = c("a1", "a2")), c(1, NA))
  expect_error(assess_choices(missing, estimate), "missing")
})
