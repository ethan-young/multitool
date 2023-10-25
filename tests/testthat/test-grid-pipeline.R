
test_that("add_filters creates a data.frame with base_df attribute",{

  the_data <- make_data()

  a_pipeline <-
    the_data |>
    add_filters(include1 == 0, include2 != 3, include2 != 2, include3 > -2.5)

  expect_true(is.data.frame(a_pipeline))
  expect_true(!is.null(attr(a_pipeline, "base_df")))

})

test_that("add_filters creates a data.frame with correct number of rows", {

  the_data <- make_data()

  a_pipeline1 <-
    the_data |>
    add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5)

  n_decisions1 <-
    a_pipeline1 |>
    dplyr::count(group) |>
    dplyr::pull(n) |>
    sum()

  a_pipeline2 <-
    the_data |>
    add_filters(include1 == 0,include2 != 3, scale(include3) > -2.5)

  n_decisions2 <-
    a_pipeline2 |>
    dplyr::count(group) |>
    dplyr::pull(n) |>
    sum()

  n_vars1 <-
    a_pipeline1 |>
    dplyr::distinct(group) |>
    nrow()

  n_uniques1 <-
    a_pipeline1 |>
    dplyr::filter(stringr::str_detect(code, "unique")) |>
    nrow()

  n_vars2 <-
    a_pipeline2 |>
    dplyr::distinct(group) |>
    nrow()

  n_uniques2 <-
    a_pipeline2 |>
    dplyr::filter(stringr::str_detect(code, "unique")) |>
    nrow()

  expect_equal(nrow(a_pipeline1),  n_decisions1)
  expect_equal(nrow(a_pipeline2),  n_decisions2)
  expect_equal(n_vars1, n_uniques1)
  expect_equal(n_vars2, n_uniques2)

})

test_that("add_variables creates a data.frame with correct rows", {

  the_data <- make_data()

  a_pipeline <-
    the_data |>
    add_variables("ivs", iv1, iv2, iv3) |>
    add_variables("dvs", dv1, dv2) |>
    add_variables("mods", starts_with("mod"))

  n_vars <-
    a_pipeline |>
    dplyr::count(group) |>
    dplyr::pull(n) |>
    sum()

  n_var_groups <-
    a_pipeline |>
    dplyr::distinct(group) |>
    nrow()

  expect_equal(nrow(a_pipeline), n_vars)
  expect_equal(n_var_groups, 3)

})

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

