
test_that("df_to_expand_prep creates a list and its the correct length", {

  the_data <- make_data()
  full_pipeline <- the_data |> make_pipeline()

  expect_true(is.list(df_to_expand_prep(full_pipeline, group, code)))
  expect_equal(length(df_to_expand_prep(full_pipeline, group, code)), nrow(dplyr::distinct(full_pipeline, type, group)))

})

test_that("expanded grid is the right size",{

  the_data <- make_data()
  full_pipeline <- the_data |> make_pipeline()

  expanded_prep <-
    full_pipeline |>
    dplyr::mutate(group = stringr::str_replace_all(group, " ", "_") |> tolower()) |>
    dplyr::group_split(type) |>
    purrr::map(function(x){
      if(x |> dplyr::pull(type) |> unique() == "models"){
        model_tibble <-
          dplyr::bind_rows(
            tibble::tibble(
              type = "models",
              group = "model",
              code = x |> dplyr::pull(code)
            )
          )
        df_to_expand_prep(model_tibble, group, code)
      } else{
        df_to_expand_prep(x, group, code)
      }
    }) |>
    purrr::flatten() |>
    df_to_expand()

  n_decisions <-
    full_pipeline |>
    dplyr::count(group) |>
    dplyr::pull(n) |>
    cumprod() |>
    dplyr::last()

  expect_equal(nrow(expanded_prep), n_decisions)

})

test_that("list_to_pipline creates the correct length baseR piped function call", {

  fake_list <- list("this()","is_not()", "a_real()", "pipe()")
  fake_pipeline1 <- list_to_pipeline(fake_list)
  fake_pipeline2 <- list_to_pipeline(fake_list, for_print = TRUE)

  expect_equal(length(fake_list)-1, stringr::str_count(fake_pipeline1, "(\\|>)"))
  expect_equal(length(fake_list)-1, stringr::str_count(fake_pipeline2, "(\\n)"))

})

