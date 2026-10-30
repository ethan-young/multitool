# add_filters ---------------------------------------------------------------

# [Claude, edited] from Ethan's "creates a data.frame with base_df attribute";
# now checks the stored name, not just that one exists
test_that("add_filters records the base data's name", {
  the_data <- make_data()

  a_pipeline <- the_data |> add_filters(include1 == 0)

  expect_true(is.data.frame(a_pipeline))
  expect_identical(attr(a_pipeline, "base_df"), "the_data")
})

# [Claude, edited] from Ethan's "correct number of rows"; the original
# compared nrow() with a sum of counts, which is always equal, and looked for
# the old no-filter text
test_that("add_filters adds each filter plus one no-filter alternative per variable", {
  the_data <- make_data()

  a_pipeline <-
    the_data |>
    add_filters(include1 == 0, include2 != 3, include2 != 2, scale(include3) > -2.5)

  # 4 filters + 3 no-filter rows
  expect_equal(nrow(a_pipeline), 7)

  # the group is the column, even when a function comes first
  expect_setequal(unique(a_pipeline$group), c("include1", "include2", "include3"))

  no_filter_rows <-
    a_pipeline |>
    dplyr::filter(code == glue::glue("is.na({group}) | !is.na({group})"))

  expect_setequal(no_filter_rows$group, c("include1", "include2", "include3"))

  without_no_filter <-
    the_data |>
    add_filters(include1 == 0, include2 != 3, remove_do_nothing = TRUE)

  expect_equal(nrow(without_no_filter), 2)
})

# [Claude]
test_that("add_filters finds the right column and rejects malformed filters", {
  prefix_data <- data.frame(iv = 1:5, iv1 = 1:5)

  # `iv` is a prefix of `iv1`; the filter belongs to iv1
  expect_identical(unique((prefix_data |> add_filters(iv1 > 2))$group), "iv1")

  expect_error(prefix_data |> add_filters(iv1 = 2), "instead of `==`")
  expect_error(prefix_data |> add_filters(5 > 2), "refer to a column")
  expect_error(prefix_data |> add_filters(), "at least one filter")
})

# add_subgroups -------------------------------------------------------------

# [Claude]
test_that("add_subgroups quotes text values, keeps missing values as NA, and rejects dates", {
  sub_data <-
    data.frame(
      grp  = c("a", "b", NA, "a"),
      num  = c(1, 2, 2, NA),
      when = as.Date(c("2024-01-01", "2024-01-02", "2024-01-03", "2024-01-04"))
    )

  a_pipeline <- sub_data |> add_subgroups(grp, num)

  expect_setequal(a_pipeline$code[a_pipeline$group == "grp"], c('"a"', '"b"', "NA"))
  expect_setequal(a_pipeline$code[a_pipeline$group == "num"], c("1", "2", "NA"))
  expect_true(all(a_pipeline$type == "subgroups"))

  expect_error(sub_data |> add_subgroups(when), "character, factor, numeric, or logical")
})

# add_variables -------------------------------------------------------------

# [Claude, edited] from Ethan's "creates a data.frame with correct rows"; the
# row check had the same always-equal comparison
test_that("add_variables adds one row per selected variable", {
  the_data <- make_data()

  a_pipeline <-
    the_data |>
    add_variables("ivs", iv1, iv2, iv3) |>
    add_variables("dvs", dv1, dv2) |>
    add_variables("mods", starts_with("mod"))

  # 3 + 2 + 3
  expect_equal(nrow(a_pipeline), 8)
  expect_identical(a_pipeline$code[a_pipeline$group == "mods"], c("mod1", "mod2", "mod3"))
})

# [Ethan]
test_that("add_variables creates variables from the base_df", {

  the_data <- make_data()

  a_pipeline_true <-
    the_data |>
    add_variables("ivs", iv1, iv2, iv3) |>
    add_variables("dvs", dv1, dv2) |>
    add_variables("mods", starts_with("mod"))


  vars_in_data <- a_pipeline_true$code

  expect_equal(length(vars_in_data), sum(vars_in_data %in% names(the_data)))
  expect_error(the_data |> add_variables("ivs", random_iv))

})

# [Claude]
test_that("add_variables checks its group name and selection", {
  the_data <- make_data()

  expect_error(the_data |> add_variables("my ivs", iv1), "single name")
  expect_error(the_data |> add_variables("ivs", starts_with("zzz")), "No variables")

  odd_data <- data.frame(`Pre Score` = 1:3, check.names = FALSE)
  expect_identical((odd_data |> add_variables("pre", `Pre Score`))$code, "`Pre Score`")
})

# add_preprocess ------------------------------------------------------------

# [Claude]
test_that("preprocessing steps keep the order they were added", {
  the_data <- data.frame(dv1 = rnorm(10), iv1 = rnorm(10), iv2 = rnorm(10))

  grid <-
    the_data |>
    add_variables("ivs", iv1, iv2) |>
    add_preprocess("trim", filter(dv1 < 2)) |>
    add_preprocess("standardize", mutate(dv1 = scale(dv1))) |>
    add_model("linear", lm(dv1 ~ {ivs})) |>
    expand_pipeline()

  expect_identical(names(grid$preprocess[[1]]), c("trim", "standardize"))
})

# [Claude]
test_that("add_preprocess keeps a piped chain intact when given as a string", {
  the_data <- make_data()

  a_pipeline <- the_data |> add_preprocess("trim then scale", "filter(dv1 < 2) |> mutate(dv1 = scale(dv1))")

  expect_identical(a_pipeline$code, "filter(dv1 < 2) |> mutate(dv1 = scale(dv1))")
  expect_error(the_data |> add_preprocess("trim"), "absent")
})

# add_condition -------------------------------------------------------------

# [Claude]
test_that("add_condition stores the test and its failure mode", {
  the_data <- make_data()

  a_pipeline <-
    the_data |>
    add_condition("minimum n", nrow() >= 100) |>
    add_condition("dv varies", "pull(dv1) |> var() > 0", on_fail = "skip")

  expect_identical(a_pipeline$code, c("nrow() >= 100", "pull(dv1) |> var() > 0"))
  expect_identical(a_pipeline$settings[[1]]$on_fail, "halt")
  expect_identical(a_pipeline$settings[[2]]$on_fail, "skip")

  expect_error(the_data |> add_condition("typo", nrow() > 1, on_fail = "brake"))
})

# [Claude]
test_that("add_condition rejects tests the data can't be piped into", {
  the_data <- make_data()

  expect_error(the_data |> add_condition("negated", !anyNA(iv1)), "single chain")
  expect_error(the_data |> add_condition("joined", nrow() > 1 & ncol() > 1), "single chain")
})

# add_model -----------------------------------------------------------------

# [Claude]
test_that("add_model stores extraction code, with NULL stored as an empty string", {
  the_data <- make_data()

  a_pipeline <- the_data |> add_model("linear", lm(dv1 ~ iv1), model_fit = NULL)
  model_settings <- a_pipeline$settings[[1]]

  expect_identical(a_pipeline$code, "lm(dv1 ~ iv1)")
  expect_identical(model_settings$model_coefs_fn, "parameters::parameters()")
  expect_identical(model_settings$model_fit_fn, "")

  expect_error(the_data |> add_model("linear", lm(dv1 ~ iv1, data = the_data)), "Leave `data` out")
})

# add_parameter_keys, add_postprocess, add_model_descriptives -------------

# [Claude]
test_that("parameter keys and postprocessing steps store their code", {
  the_data <- make_data()

  a_pipeline <-
    the_data |>
    add_parameter_keys("interaction", "{ivs}:{mods}") |>
    add_postprocess("anova", anova()) |>
    add_model_descriptives("summary", summarise(m = mean(dv1)))

  expect_identical(a_pipeline$type, c("parameter_key", "postprocess", "postprocess"))
  expect_identical(a_pipeline$code[1], "{ivs}:{mods}")
  expect_identical(a_pipeline$code[3], "model.frame() |> summarise(m = mean(dv1))")
})

# expand_pipeline -----------------------------------------------------------

# [Claude, edited] from Ethan's "expanded grid is the right size" in
# test-utils.R, which rebuilt the old expansion steps inside the test; it now
# tests expand_pipeline() against a hand-counted total. Delete the original
# from test-utils.R.
test_that("expand_pipeline crosses every alternative into one row per decision", {
  the_data <- make_data()

  grid <-
    the_data |>
    make_pipeline() |>
    add_model("linear", lm({dvs} ~ {ivs} * {mods})) |>
    expand_pipeline()

  # filters: include1 2 x include2 3 x include3 2; ivs 3; dvs 2; mods 3; one model
  expect_equal(nrow(grid), 216)
  expect_identical(grid$decision, as.numeric(1:216))
})

# [Claude]
test_that("expand_pipeline removes exact repeats and says so", {
  the_data <- make_data()

  a_pipeline <-
    the_data |>
    add_filters(include1 == 0) |>
    add_filters(include1 == 0) |>
    add_model("linear", lm(dv1 ~ iv1))

  # the second call repeats both the filter and its no-filter row
  expect_message(expand_pipeline(a_pipeline), "Removed 2 repeated")
  expect_equal(nrow(suppressMessages(expand_pipeline(a_pipeline))), 2)
})

# [Claude]
test_that("expand_pipeline stops on pipelines it can't expand", {
  the_data <- make_data()

  expect_error(
    the_data |> add_filters(include1 == 0) |> add_subgroups(include1) |> add_model("linear", lm(dv1 ~ iv1)) |> expand_pipeline(),
    "only one decision type"
  )

  expect_error(
    the_data |> add_filters(include1 == 0) |> add_preprocess("trim", filter(iv1 < 2)) |> add_preprocess("trim", filter(iv1 < 3)) |> add_model("linear", lm(dv1 ~ iv1)) |> expand_pipeline(),
    "unique name for each step"
  )

  expect_error(
    the_data |> add_filters(include1 == 0) |> add_model("linear", lm(dv1 ~ iv1)) |> add_model("linear", lm(dv2 ~ iv1)) |> expand_pipeline(),
    "Each model needs a unique name"
  )

  expect_error(
    the_data |> add_model("linear", lm(dv1 ~ iv1)) |> expand_pipeline(),
    "does not have any alternatives"
  )

  expect_error(
    the_data |> add_filters(include1 == 0) |> expand_pipeline(),
    "any models"
  )
})

# [Claude]
test_that("expand_pipeline nests conditions one row per condition, with templates filled", {
  the_data <- make_data()

  grid <-
    the_data |>
    add_variables("dvs", dv1, dv2) |>
    add_condition("minimum n", nrow() >= 100) |>
    add_condition("dv varies", "pull({dvs}) |> var() > 0", on_fail = "skip") |>
    add_model("linear", lm({dvs} ~ iv1)) |>
    expand_pipeline()

  first_conditions <- grid$conditions[[1]]

  expect_identical(names(first_conditions), c("condition", "test", "on_fail"))
  expect_identical(first_conditions$condition, c("minimum_n", "dv_varies"))
  expect_identical(first_conditions$test, c("nrow() >= 100", "pull(dv1) |> var() > 0"))
  expect_identical(first_conditions$on_fail, c("halt", "skip"))
})

# [Claude]
test_that("expand_pipeline rejects names multitool reserves", {
  the_data <- make_data()

  # "Model" is normalized to "model", the grid's own model column
  expect_error(
    the_data |>
      add_filters(include1 == 0) |>
      add_preprocess("Model", mutate(x = 1)) |>
      add_model("linear", lm(dv1 ~ iv1)) |>
      expand_pipeline(),
    "reserved by multitool"
  )
})

# [Claude]
test_that("expand_pipeline checks its collect and path arguments", {
  the_data <- make_data()

  a_pipeline <-
    the_data |>
    add_filters(include1 == 0) |>
    add_model("linear", lm(dv1 ~ iv1))

  expect_error(expand_pipeline(a_pipeline, .collect_after = "filter"), "must be one of")
  expect_error(expand_pipeline(a_pipeline, .subgroup_in_path = TRUE), "requires `.pointer_path`")

  expect_identical(
    attr(expand_pipeline(a_pipeline, .collect_after = "filters"), "where_to_collect"),
    "filters"
  )
})

# [Claude]
test_that("a variables group can be named 'variables'", {
  the_data <- make_data()

  # the substitution step's temporary column no longer uses this name
  grid <-
    the_data |>
    add_variables("variables", iv1, iv2) |>
    add_model("linear", lm(dv1 ~ {variables})) |>
    expand_pipeline()

  expect_identical(grid$models[[1]]$model, "lm(dv1 ~ iv1)")
})
