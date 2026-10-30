# capture_base_data and append_decisions ----------------------------------

# [Claude]
test_that("capture_base_data uses the data itself first, then looks it up by name", {
  the_data <- make_data()

  first_verb <- capture_base_data(the_data, quote(the_data), environment())

  expect_identical(first_verb$name, "the_data")
  expect_identical(first_verb$data, the_data)

  a_pipeline <- the_data |> add_filters(include1 == 0)
  later_verb <- capture_base_data(a_pipeline, quote(a_pipeline), environment())

  # the name comes from the pipeline's attribute, not the expression
  expect_identical(later_verb$name, "the_data")
  expect_identical(later_verb$data, the_data)

  expect_error(data.frame(x = 1:3) |> add_variables("xs", x), "named data object")
})

# [Claude]
test_that("append_decisions adds rows only to an existing pipeline", {
  the_data <- make_data()
  new_rows <- tibble::tibble(type = "variables", group = "ivs", code = "iv1")
  base <- list(name = "the_data", data = the_data)

  # first verb: .df is the data, so only the new rows come back
  first_verb <- append_decisions(the_data, new_rows, base)

  expect_equal(nrow(first_verb), 1)
  expect_identical(attr(first_verb, "base_df"), "the_data")

  # later verb: .df is the pipeline, so rows are added to it
  later_verb <- append_decisions(first_verb, new_rows, base)

  expect_equal(nrow(later_verb), 2)
  expect_identical(attr(later_verb, "base_df"), "the_data")
})

# df_to_expand_prep and df_to_expand --------------------------------------

# [Ethan]
test_that("df_to_expand_prep creates a list and its the correct length", {

  the_data <- make_data()
  full_pipeline <- the_data |> make_pipeline()

  expect_true(is.list(df_to_expand_prep(full_pipeline, group, code)))
  expect_equal(length(df_to_expand_prep(full_pipeline, group, code)), nrow(dplyr::distinct(full_pipeline, type, group)))

})

# [Claude, edited] from Ethan's "expanded grid is the right size", which
# rebuilt the old expansion steps inside the test; the expand_pipeline()
# version of that test is now in test-01-build.R
test_that("df_to_expand crosses every group's alternatives", {
  the_data <- make_data()
  full_pipeline <- the_data |> make_pipeline()

  expanded <-
    full_pipeline |>
    df_to_expand_prep(group, code) |>
    df_to_expand()

  # filters: include1 2 x include2 3 x include3 2; ivs 3; dvs 2; mods 3
  expect_equal(nrow(expanded), 216)
  expect_setequal(names(expanded), unique(full_pipeline$group))
})

# [Claude]
test_that("df_to_expand keeps code exactly as stored", {
  # an apostrophe broke the old parsed version; a backslash was silently altered
  tricky <-
    tibble::tibble(
      group = "g",
      code  = c('"O\'Brien"', 'str_detect(x, "\\\\d")')
    )

  expanded <-
    tricky |>
    df_to_expand_prep(group, code) |>
    df_to_expand()

  expect_identical(expanded$g, tricky$code)
})

# list_to_pipeline and get_code -------------------------------------------

# [Ethan]
test_that("list_to_pipline creates the correct length baseR piped function call", {

  fake_list <- list("this()","is_not()", "a_real()", "pipe()")
  fake_pipeline1 <- list_to_pipeline(fake_list)
  fake_pipeline2 <- list_to_pipeline(fake_list, for_print = TRUE)

  expect_equal(length(fake_list)-1, stringr::str_count(fake_pipeline1, "(\\|>)"))
  expect_equal(length(fake_list)-1, stringr::str_count(fake_pipeline2, "(\\n)"))

})

# [Claude]
test_that("list_to_pipeline leaves braces in code untouched", {
  code <- list(original_data = "the_data", preprocess = "mutate(x = purrr::map_dbl(y, \\(v) {v + 1}))")

  expect_identical(
    as.character(list_to_pipeline(code)),
    "the_data |> mutate(x = purrr::map_dbl(y, \\(v) {v + 1}))"
  )
})

# [Claude]
test_that("get_code names a missing step", {
  pipeline_list <- list(original_data = "the_data", model = "lm(y ~ x, data = _)")

  expect_error(get_code(pipeline_list, "subgroups"), "no `subgroups` step")
})

# build_pipeline_code -----------------------------------------------------

# [Claude]
test_that("build_pipeline_code places collect() after the chosen step", {
  the_data <- make_data()

  a_pipeline <-
    the_data |>
    add_filters(include1 == 0) |>
    add_model("linear", lm(dv1 ~ iv1))

  default_code <- build_pipeline_code(expand_pipeline(a_pipeline), 1)$pipeline
  expect_identical(names(default_code), c("original_data", "collect", "filters", "model"))

  late_code <- build_pipeline_code(expand_pipeline(a_pipeline, .collect_after = "filters"), 1)$pipeline
  expect_identical(names(late_code), c("original_data", "filters", "collect", "model"))
})

# [Claude]
test_that("subgroup code handles missing values and requires a pointer for path subgroups", {
  the_data <- tibble::tibble(grp = c("a", "b", NA), x = rnorm(3), y = rnorm(3))

  grid <-
    the_data |>
    add_subgroups(grp) |>
    add_model("linear", lm(y ~ x)) |>
    expand_pipeline()

  missing_decision <-
    grid |>
    tidyr::unnest(subgroups) |>
    dplyr::filter(grp == "NA") |>
    dplyr::pull(decision)

  expect_match(
    as.character(build_pipeline_code(grid, missing_decision)$pipeline$subgroups),
    "is.na(grp)",
    fixed = TRUE
  )

  attr(grid, "subgroup_in_path") <- TRUE
  expect_error(build_pipeline_code(grid, 1), "no `pointer_path`")
})

# [Claude]
test_that("build_pipeline_code opens subgroup directories on the path route", {
  the_data <- tibble::tibble(grp = c("a", NA), x = rnorm(2), y = rnorm(2))

  grid <-
    the_data |>
    add_subgroups(grp) |>
    add_model("linear", lm(y ~ x)) |>
    expand_pipeline(.pointer_path = "data/root", .subgroup_in_path = TRUE)

  opened <-
    purrr::map_chr(grid$decision, \(decision_num){
      as.character(build_pipeline_code(grid, decision_num)$pipeline$original_data)
    })

  expect_setequal(
    opened,
    c(
      "open_dataset('data/root/grp=a/')",
      "open_dataset('data/root/grp=__HIVE_DEFAULT_PARTITION__/')"
    )
  )
})

# [Claude]
test_that("build_pipeline_code returns conditions beside the pipeline, not in it", {
  the_data <- make_data()

  grid <-
    the_data |>
    add_filters(include1 == 0) |>
    add_condition("minimum n", nrow() >= 100) |>
    add_model("linear", lm(dv1 ~ iv1)) |>
    expand_pipeline()

  built <- build_pipeline_code(grid, 1)

  expect_false("conditions" %in% names(built$pipeline))
  expect_identical(built$conditions$test, "nrow() >= 100")
})

# Arrow partitions --------------------------------------------------------

# [Claude]
test_that("partition and column routes give identical subgroups", {
  skip_if_not_installed("arrow")

  dataset_dir <- tempfile()

  tibble::tibble(
    grade  = c(3L, 3L, 4L, 4L),
    school = c("A", "B", "A", NA),
    score  = c(1.2, 0.4, -0.3, 2.1)
  ) |>
    arrow::write_dataset(dataset_dir, partitioning = c("grade", "school"))

  arrow_ds <- arrow::open_dataset(dataset_dir)

  from_partitions <-
    arrow_ds |>
    add_subgroups(grade, school, .use_partitions = TRUE) |>
    dplyr::arrange(group, code)

  from_columns <-
    arrow_ds |>
    add_subgroups(grade, school) |>
    dplyr::arrange(group, code)

  expect_identical(from_partitions, from_columns)

  expect_error(arrow_ds |> add_subgroups(score, .use_partitions = TRUE), "must be a hive partition")

  the_data <- make_data()
  expect_error(the_data |> add_subgroups(include2, .use_partitions = TRUE), "requires a dataset opened")

  unlink(dataset_dir, recursive = TRUE)
})
