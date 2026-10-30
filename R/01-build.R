#' Add filtering/exclusion criteria to a multiverse pipeline
#'
#' @param .df The original \code{data.frame}(e.g., base data set). If part of
#'   set of add_* decision functions in a pipeline, the base data will be passed
#'   along as an attribute.
#' @param ... logical expressions to be used with \code{\link[dplyr]{filter}}
#'   separated by commas. Expressions should not be quoted.
#' @param remove_do_nothing logical, \code{FALSE} by default. Indicates whether
#'   to remove a specification where no filters are applied to the data.
#'   Typically, a 'no filter' specification is desirable, but on a occasion you
#'   may wan to turn this functionally off.
#'
#' @return a \code{data.frame} with three columns: type, group, and code. Type
#'   indicates the decision type, group is a decision, and the code is the
#'   actual code that will be executed. If part of a pipe, the current set of
#'   decisions will be appended as new rows.
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
#' the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2, include3 > -2.5)
add_filters <- function(.df, ..., remove_do_nothing = FALSE){
  base <- capture_base_data(.df, rlang::enexpr(.df), rlang::caller_env())

  filter_exprs <- dplyr::enexprs(...)

  if(length(filter_exprs) == 0){
    rlang::abort("Supply at least one filter expression, e.g. `add_filters(include1 == 0)`.")
  }

  if(any(rlang::have_name(filter_exprs))){
    rlang::abort(
      c(
        "Filter expressions must not be named.",
        x = glue::glue("Named: {stringr::str_flatten_comma(names(filter_exprs)[rlang::have_name(filter_exprs)])}"),
        i = "Did you use `=` instead of `==`?"
      )
    )
  }

  data_columns <- names(base$data)
  filter_code <- as.character(filter_exprs)

  # each filter's decision is the first whole word in it that names a data column
  filter_groups <-
    filter_code |>
    stringr::str_extract_all("[[:alpha:].][[:alnum:]._]*") |>
    purrr::map_chr(\(words) purrr::detect(words, \(word) word %in% data_columns, .default = NA_character_))

  if(any(is.na(filter_groups))){
    rlang::abort(
      c(
        "Each filter must refer to a column in the data.",
        x = glue::glue("No column found in: {stringr::str_flatten_comma(filter_code[is.na(filter_groups)])}")
      )
    )
  }

  grid_prep <-
    tibble::tibble(
      type  = "filters",
      group = filter_groups,
      code  = filter_code
    )

  # the "no filter" alternative for each filtered variable
  if(!remove_do_nothing){
    filter_names <- unique(filter_groups)

    grid_prep <-
      grid_prep |>
      dplyr::bind_rows(
        tibble::tibble(
          type  = "filters",
          group = filter_names,
          code = glue::glue("is.na({filter_names}) | !is.na({filter_names})") |> as.character()
        )
      ) |>
      dplyr::arrange(factor(group, levels = filter_names))
  }

  append_decisions(.df, grid_prep, base)
}

#' Add sub groups to the multiverse pipeline
#'
#' @param .df The original \code{data.frame}(e.g., base data set). If part of
#'   set of add_* decision functions in a pipeline, the base data will be passed
#'   along as an attribute.
#' @param ... sub group variable(s) in your data whose values specify groupings.
#' @param .use_partitions whether or not to search an arrow pointer table's
#'   partitioning for subgroup names and values. Defaults to `FALSE`.
#'
#' @return a \code{data.frame} with three columns: type, group, and code. Type
#'   indicates the decision type, group is a decision, and the code is the
#'   actual code that will be executed. If part of a pipe, the current set of
#'   decisions will be appended as new rows.
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
#'     include3 = rnorm(500),
#'     group    = sample(1:3, size = 500, replace = TRUE)
#'   )
#'
#' the_data |>
#'   add_subgroups(group)
add_subgroups <- function(.df, ..., .use_partitions = FALSE){
  base <- capture_base_data(.df, rlang::enexpr(.df), rlang::caller_env())

  if(.use_partitions){
    check_partition_source(base$data)

    subgroup_names <- base$data |> dplyr::select(...) |> names()
    partition_tbl  <- detect_partitions(base$data)

    check_subgroups_partitioned(subgroup_names, partition_tbl)

    subgroup_source <-
      partition_tbl |>
      dplyr::select(dplyr::all_of(subgroup_names)) |>
      type_partitions(base$data)
  } else {
    subgroup_source <- base$data
  }

  subgroup_values <-
    subgroup_source |>
    dplyr::select(...) |>
    dplyr::distinct() |>
    dplyr::collect()

  # `var == value` can only be written for these types; a Date would become arithmetic
  unsupported_vars <-
    subgroup_values |>
    dplyr::select(!dplyr::where(\(x) is.character(x) | is.factor(x) | is.numeric(x) | is.logical(x))) |>
    names()

  if(length(unsupported_vars) > 0){
    rlang::abort(
      c(
        "Subgroup variables must be character, factor, numeric, or logical.",
        x = glue::glue("Unsupported: {stringr::str_flatten_comma(unsupported_vars)}"),
        i = "Convert dates to character or a factor before using them as subgroups."
      )
    )
  }

  grid_prep <-
    subgroup_values |>
    dplyr::mutate(
      dplyr::across(
        dplyr::where(\(x) is.character(x) | is.factor(x)),
        \(x) dplyr::if_else(is.na(x), NA_character_, paste0('"', x, '"'))
      )
    ) |>
    tidyr::pivot_longer(
      dplyr::everything(),
      names_to = "group",
      values_to = "code",
      values_transform = as.character
    ) |>
    dplyr::mutate(
      type = "subgroups",
      code = dplyr::coalesce(code, "NA"),
      .before = group
    ) |>
    dplyr::distinct()

  append_decisions(.df, grid_prep, base)
}

#' Add a set of variable alternatives to a multiverse pipeline
#'
#' @param .df The original \code{data.frame}(e.g., base data set). If part of
#'   set of add_* decision functions in a pipeline, the base data will be passed
#'   along as an attribute.
#' @param var_group a character string. Indicates the name of the current set.
#'   For example, "primary_iv" could indicate this set are alternatives of the
#'   main predictor in an analysis.
#' @param ... the bare unquoted names of the variables to include as alternative
#'   options for this variable set. You can also use tidyselect to select
#'   variables.
#'
#' @return a \code{data.frame} with three columns: type, group, and code. Type
#'   indicates the decision type, group is a decision, and the code is the
#'   actual code that will be executed. If part of a pipe, the current set of
#'   decisions will be appended as new rows.
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
#' the_data |>
#'  add_variables("ivs", iv1, iv2, iv3) |>
#'  add_variables("dvs", dv1, dv2) |>
#'  add_variables("mods", starts_with("mod"))
add_variables <- function(.df, var_group, ...){
  base <- capture_base_data(.df, rlang::enexpr(.df), rlang::caller_env())

  syntactic_name <- "^[[:alpha:].][[:alnum:]._]*$"

  # the group name is used as written in templates like lm({dvs} ~ {ivs})
  if(!rlang::is_string(var_group) || !stringr::str_detect(var_group, syntactic_name)){
    rlang::abort(
      c(
        "`var_group` must be a single name that can be used in code, like \"ivs\".",
        x = glue::glue("Got: {var_group}"),
        i = "It's referenced as {{var_group}} in model and preprocessing code, so use letters, numbers, `.`, and `_`, starting with a letter."
      )
    )
  }

  variable_names <- base$data |> dplyr::select(...) |> names()

  if(length(variable_names) == 0){
    rlang::abort(glue::glue("No variables were selected for '{var_group}'."))
  }

  grid_prep <-
    tibble::tibble(
      type  = "variables",
      group = var_group,
      # column names that aren't valid R names are backticked
      code  =
        dplyr::if_else(
          stringr::str_detect(variable_names, syntactic_name),
          variable_names,
          paste0("`", variable_names, "`")
        )
    )

  append_decisions(.df, grid_prep, base)
}

#' Add arbitrary preprocessing code to a multiverse analysis pipeline
#'
#' @param .df The original \code{data.frame}(e.g., base data set). If part of
#'   set of add_* decision functions in a pipeline, the base data will be passed
#'   along as an attribute.
#' @param process_name a character string. A descriptive name for what the
#'   preprocessing step accomplishes.
#' @param code the literal code you would like to execute after data are
#'   filtered. \code{\link[glue]{glue}} syntax is allowed. An example might be
#'   centering or scaling a predictor after the appropriate filters are applied
#'   to the data.
#'
#'   The code should be written to work with pipes (i.e., \code{|>} or
#'   \code{\%>\%}). Pre-processing code will eventually take the base data along
#'   with any filters applied to the data. This means
#'   \code{\link[dplyr]{mutate}} calls are the most natural but other functions
#'   that take a \code{data.frame} as the first argument should work as well (as
#'   long as they also return a \code{data.frame}).
#'
#' @return a \code{data.frame} with three columns: type, group, and code. Type
#'   indicates the decision type, group is a decision, and the code is the
#'   actual code that will be executed. If part of a pipe, the current set of
#'   decisions will be appended as new rows.
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
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
#' the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2, include3 > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_preprocess("scale_iv", 'mutate({ivs} = scale({ivs}))')
add_preprocess <- function(.df, process_name, code){
  rlang::check_required(process_name)
  rlang::check_required(code)

  base <- capture_base_data(.df, rlang::enexpr(.df), rlang::caller_env())

  if(!rlang::is_string(process_name)){
    rlang::abort("`process_name` must be a single string, e.g. \"standardize ivs\".")
  }

  code_chr <-
    dplyr::enexprs(code) |>
    as.character() |>
    stringr::str_replace_all("\\s*\n\\s*", " ")

  grid_prep <-
    tibble::tibble(
      type  = "preprocess",
      group = process_name,
      code  = code_chr
    )

  append_decisions(.df, grid_prep, base)
}

#' Add a run condition to a multiverse pipeline
#'
#' @param .df The original \code{data.frame} (e.g., base data set). If part of
#'   a set of add_* decision functions in a pipeline, the base data will be
#'   passed along as an attribute.
#' @param condition_name a short name for the condition, e.g. "minimum n".
#' @param test a partial pipe chain that reduces the analysis data to a single
#'   \code{TRUE} or \code{FALSE}, e.g. \code{nrow() >= 100}. Just before the
#'   model runs, the data is piped into the front of the chain. Variable
#'   templates such as \code{{dvs}} are filled in for each decision. Write
#'   negations at the end of the chain (e.g., \code{anyNA() == FALSE}) and
#'   give each test its own \code{add_condition()} call rather than joining
#'   tests with \code{&} or \code{|}.
#' @param on_fail what a failed test means. \code{"halt"} (default): the
#'   test is an alarm for something that should never happen, so the
#'   decision stops and is recorded as halted. \code{"skip"}: the decision
#'   is out of scope by design, so it isn't analyzed and is recorded as
#'   skipped. Whether a halt stops the whole run is set by the
#'   \code{.on_break} argument of \code{analyze_grid()}.
#'
#' @return the pipeline with a new conditions row. The failure mode is stored
#'   in the \code{settings} column.
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
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
#' the_data |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_condition("minimum n", nrow() >= 100) |>
#'   add_condition("dv varies", pull({dvs}) |> var() > 0, on_fail = "skip")
add_condition <- function(.df, condition_name, test, on_fail = c("halt", "skip")){
  rlang::check_required(condition_name)
  rlang::check_required(test)
  on_fail <- rlang::arg_match(on_fail)

  base <- capture_base_data(.df, rlang::enexpr(.df), rlang::caller_env())

  if(!rlang::is_string(condition_name)){
    rlang::abort("`condition_name` must be a single string, e.g. \"minimum n\".")
  }

  # the data is piped into the front of the test, so the test must be one chain
  test_expr <- rlang::enexpr(test)

  if(rlang::is_call(test_expr, c("!", "&", "|", "&&", "||"))){
    rlang::abort(
      c(
        "A condition test must be a single chain the data can be piped into.",
        x = glue::glue("This test starts with `{rlang::call_name(test_expr)}`: {rlang::expr_text(test_expr)}"),
        i = "Put negations at the end, e.g. `pull(x) |> anyNA() == FALSE`.",
        i = "Split tests joined by `&` or `|` into separate `add_condition()` calls.",
        i = "For tests that don't fit a chain, start the chain with an anonymous function, e.g. `(\\(d) var(d$x) > 0)()`."
      )
    )
  }

  grid_prep <-
    tibble::tibble(
      type     = "conditions",
      group    = condition_name,
      code     =
        dplyr::enexprs(test) |>
        as.character() |>
        stringr::str_replace_all("\\s*\n\\s*", " "),
      settings = list(tibble::tibble(on_fail = on_fail))
    )

  append_decisions(.df, grid_prep, base)
}

#' Add a model and formula to a multiverse pipeline
#'
#' @param .df The original \code{data.frame}(e.g., base data set). If part of
#'   set of add_* decision functions in a pipeline, the base data will be passed
#'   along as an attribute.
#' @param model_desc a human readable name you would like to give the model.
#' @param code literal model syntax you would like to run. You can use
#'   \code{glue} inside formulas to dynamically generate variable names based on
#'   a variable grid. For example, if you make variable grid with two versions
#'   of your IVs (e.g., \code{iv1} and \code{iv2}), you can write your formula
#'   like so: \code{lm(happiness ~ {iv} + control_var)}. The only requirement is
#'   that the variables written in the formula actually exist in the underlying
#'   data. You are also responsible for loading any packages that run a
#'   particular model (e.g., \code{lme4} for mixed-models)
#' @param model_coefs a function to extract coefficients from the model object.
#'   The default is to use \code{parameters::parameters()} but this could be
#'   also be \code{broom::tidy()} or any other function that summarizes model
#'   output. Whichever function you choose must take a model object as the first
#'   argument and return a \code{data.frame}.
#' @param model_fit a function to summarize model fit statistics. The default is
#'   to use \code{performance::performance()} but this could be also be
#'   \code{broom::glance()} or any other function that summarizes model output.
#'   Whichever function you choose must take a model object as the first
#'   argument and return a \code{data.frame}.
#' @param model_standardize a function to calculate standardized coefficients
#'   from the model object. The default is to use
#'   \code{parameters::standardize_parameters()} but this could be also be some
#'   other function that standardizes model output. Whichever function you
#'   choose must take a model object as the first argument and return a
#'   \code{data.frame}.
#'
#' @return a \code{data.frame} with three columns: type, group, and code. Type
#'   indicates the decision type, group is a decision, and the code is the
#'   actual code that will be executed. If part of a pipe, the current set of
#'   decisions will be appended as new rows.
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
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
#' the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2, include3 > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_preprocess("scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * {mods}))
add_model <-
  function(
    .df,
    model_desc,
    code,
    model_coefs = parameters::parameters(),
    model_fit = performance::performance(),
    model_standardize = parameters::standardize_parameters()
  ){
    rlang::check_required(model_desc)
    rlang::check_required(code)

    base <- capture_base_data(.df, rlang::enexpr(.df), rlang::caller_env())

    if(!rlang::is_string(model_desc)){
      rlang::abort("`model_desc` must be a single string, e.g. \"linear model\".")
    }

    # multitool supplies the data (`data = _`) when the model runs
    model_expr <- rlang::enexpr(code)

    if(rlang::is_call(model_expr) && "data" %in% rlang::call_args_names(model_expr)){
      rlang::abort(
        c(
          "Leave `data` out of the model code; multitool supplies it for each decision.",
          x = glue::glue("Model code: {rlang::expr_text(model_expr)}")
        )
      )
    }

    # code to run on each fitted model; NULL means don't extract, stored as ""
    extraction_fns <-
      list(
        model_coefs_fn       = rlang::enexpr(model_coefs),
        model_fit_fn         = rlang::enexpr(model_fit),
        model_standardize_fn = rlang::enexpr(model_standardize)
      ) |>
      purrr::map_chr(\(fn_expr) if(is.null(fn_expr)) "" else rlang::expr_text(fn_expr))

    grid_prep <-
      tibble::tibble(
        type     = "models",
        group    = model_desc,
        code     =
          dplyr::enexprs(code) |>
          as.character() |>
          stringr::str_replace_all("\\s*\n\\s*", " "),
        settings = list(tibble::as_tibble_row(extraction_fns))
      )

    append_decisions(.df, grid_prep, base)
  }

#' Add parameter keys names for later use in summarizing model effects
#'
#' @param .df The original \code{data.frame}(e.g., base data set). If part of
#'   set of add_* decision functions in a pipeline, the base data will be passed
#'   along as an attribute.
#' @param parameter_group character, a name for the parameter of interest
#' @param parameter_name quoted or unquoted names of variables involved in a
#'   particular parameter of interest. Usually this is just a variable in your
#'   model (e.g., a main effect of your iv). However, it could also be an
#'   interaction term or some other term. You can use \code{glue} syntax to
#'   specify an effect that might use alternative versions of the same variable.
#'
#' @return a \code{data.frame} with three columns: type, group, and code. Type
#'   indicates the decision type, group is a decision, and the code is the
#'   actual code that will be executed. If part of a pipe, the current set of
#'   decisions will be appended as new rows.
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
#' the_data |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * {mods})) |>
#'   add_parameter_keys("my_interaction", "{ivs}:{mods}") |>
#'   add_parameter_keys("my_main_effect", {ivs})
add_parameter_keys <- function(.df, parameter_group, parameter_name){
  rlang::check_required(parameter_group)
  rlang::check_required(parameter_name)

  base <- capture_base_data(.df, rlang::enexpr(.df), rlang::caller_env())

  if(!rlang::is_string(parameter_group)){
    rlang::abort("`parameter_group` must be a single string, e.g. \"interaction\".")
  }

  grid_prep <-
    tibble::tibble(
      type  = "parameter_key",
      group = parameter_group,
      code  =
        dplyr::enexprs(parameter_name) |>
        as.character() |>
        stringr::str_replace_all("\\s*\n\\s*", " ")
    )

  append_decisions(.df, grid_prep, base)
}

#' Add arbitrary summary statistics to a multiverse pipeline
#'
#' @param .df The original \code{data.frame}(e.g., base data set). If part of
#'   set of add_* decision functions in a pipeline, the base data will be passed
#'   along as an attribute.
#' @param desc_name a character string. A descriptive name for what the summary
#'   statistics you want to compute over the data passed to your model.
#' @param code the literal code you would like to execute. For summary
#'   statistics, \code{model.frame()} will be called on the model object fit in
#'   the prior step. Your code should thus work with the variables that are used
#'   in your model.
#'
#' @return a \code{data.frame} with three columns: type, group, and code. Type
#'   indicates the decision type, group is a decision, and the code is the
#'   actual code that will be executed. If part of a pipe, the current set of
#'   decisions will be appended as new rows.
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
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
#' the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2, include3 > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_preprocess("scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * {mods})) |>
#'   add_model_descriptives(
#'     "descriptives",
#'     summarize(body_mass_mean = mean({dvs}), .by = c(include2))
#'   )
add_model_descriptives <- function(.df, desc_name, code){
  rlang::check_required(desc_name)
  rlang::check_required(code)

  base <- capture_base_data(.df, rlang::enexpr(.df), rlang::caller_env())

  if(!rlang::is_string(desc_name)){
    rlang::abort("`desc_name` must be a single string, e.g. \"summary stats\".")
  }

  code_chr <-
    dplyr::enexprs(code) |>
    as.character() |>
    stringr::str_replace_all("\\s*\n\\s*", " ")

  grid_prep <-
    tibble::tibble(
      type  = "postprocess",
      group = desc_name,
      # descriptives run on the data the model was actually fit to
      code  = glue::glue("model.frame() |> {code_chr}") |> as.character()
    )

  append_decisions(.df, grid_prep, base)
}

#' Add arbitrary postprocessing code to a multiverse pipeline
#'
#' @param .df The original \code{data.frame}(e.g., base data set). If part of
#'   set of add_* decision functions in a pipeline, the base data will be passed
#'   along as an attribute.
#' @param postprocess_name a character string. A descriptive name for what the
#'   postprocessing step accomplishes.
#' @param code the literal code you would like to execute after each analysis.
#'
#'   The code should be written to work with pipes (i.e., \code{|>} or
#'   \code{\%>\%}). Because the post-processing code comes last in each
#'   multiverse analysis step, the chosen model object will be passed to the
#'   post-processing code.
#'
#'   For example, if you fit a simple linear model like: \code{lm(y ~ x1 + x2)},
#'   and your post-processing code executes a call to \code{anova}, you would
#'   simply pass \code{anova()} to \code{add_postprocess()}. The underlying code
#'   would be:
#'
#'   \code{data |> filters |> lm(y ~ x1 + x2, data = _) |> anova()}
#'
#' @return a \code{data.frame} with three columns: type, group, and code. Type
#'   indicates the decision type, group is a decision, and the code is the
#'   actual code that will be executed. If part of a pipe, the current set of
#'   decisions will be appended as new rows.
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
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
#' the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2, include3 > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_preprocess("scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * {mods})) |>
#'   add_postprocess("analysis of variance", aov())
add_postprocess <- function(.df, postprocess_name, code){
  rlang::check_required(postprocess_name)
  rlang::check_required(code)

  base <- capture_base_data(.df, rlang::enexpr(.df), rlang::caller_env())

  if(!rlang::is_string(postprocess_name)){
    rlang::abort("`postprocess_name` must be a single string, e.g. \"anova\".")
  }

  grid_prep <-
    tibble::tibble(
      type  = "postprocess",
      group = postprocess_name,
      code  =
        dplyr::enexprs(code) |>
        as.character() |>
        stringr::str_replace_all("\\s*\n\\s*", " ")
    )

  append_decisions(.df, grid_prep, base)
}

#' Expand a set of multiverse decisions into all possible combinations
#'
#' @param .pipeline a \code{data.frame} produced by calling a series of add_*
#'   functions.
#'
#' @param .collect_after default is NULL. Most of the time you will not use this
#'   argument. However, if your data come from a database, you can use this
#'   argument to call \code{dplyr::collect()} from \code{dbplyr} after a simple
#'   filter statements to speed up computations. Valid options are
#'   \code{"subgroups"}, \code{"filters"}, or \code{"preprocess"}. Note that
#'   \code{dbplyr} does not support all expressions.
#'
#' @param .pointer_path a string specifying a path to create a external pointer
#'   object. This is only necessary if you are using data from an external
#'   source. Defaults to NULL.
#'
#' @param .subgroup_in_path logical, whether to place the subgroup filters in a
#'   file path. This is only relevant if you are using an external pointer
#'   (e.g., an Arrow filesystem database). Placing the subgroup filter in the
#'   path itself might provide a performance boost over reading the entire
#'   filesystem and then performing subgoup filtering.
#'
#' @return a nested \code{data.frame} containing all combinations of arbitrary
#'   decisions for a multiverse analysis. Decision types will become list
#'   columns matching the type of decisions called along the pipeline (e.g.,
#'   filters, variables, etc.). Any decisions containing
#'   \code{\link[glue]{glue}} syntax will be populated with the relevant
#'   information.
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
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
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0,include2 != 3,include2 != 2, include3 > -2.5) |>
#'   add_variables("ivs", iv1, iv2, iv3) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_variables("mods", starts_with("mod")) |>
#'   add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#'   add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
#'   add_model("no covariates", lm({dvs} ~ {ivs} * {mods})) |>
#'   add_model("with covariates", lm({dvs} ~ {ivs} * {mods} + cov1)) |>
#'   add_postprocess("aov", aov())
#'
#' pipeline_expanded <- expand_decisions(full_pipeline)
expand_decisions <-
  function(
    .pipeline,
    .collect_after = NULL,
    .pointer_path = NULL,
    .subgroup_in_path = FALSE
  ){

    pipeline_chr <- dplyr::enexpr(.pipeline)
    data_chr <- attr(.pipeline, "base_df")

    if("conditions" %in% .pipeline$type){
      rlang::abort("Conditions are only supported by `expand_pipeline()`.")
    }

    pipeline_wide <-
      if("settings" %in% names(.pipeline)) tidyr::unnest_wider(.pipeline, settings) else .pipeline

    grid_components <-
      pipeline_wide |>
      dplyr::mutate(
        group =
          ifelse(
            !type %in% c("subgroups", "filters"),
            stringr::str_replace_all(stringr::str_squish(group), " ", "_") |> tolower(),
            group
          )
      ) |>
      dplyr::group_split(type) |>
      purrr::map(function(x) {
        if(x |> dplyr::pull(type) |> unique() == "models"){
          list(
            models = c("model")
          )
        } else{
          curr_name <- x |> dplyr::pull(type) |> unique()
          curr_set <- x |> dplyr::pull(group) |> unique()
          the_set <- list(curr_set) |> purrr::set_names(curr_name)
          the_set
        }
      }) |>
      purrr::flatten()

    full_grid <-
      pipeline_wide |>
      dplyr::mutate(
        group =
          ifelse(
            !type %in% c("subgroups", "filters"),
            stringr::str_replace_all(group, " ", "_") |> tolower(),
            group
          )
      ) |>
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
      df_to_expand() |>
      dplyr::mutate(decision = 1:dplyr::n()) |>
      dplyr::select(decision, dplyr::everything())

    if(!is.null(grid_components$model)){
      full_grid <-
        full_grid |>
        dplyr::left_join(
          pipeline_wide |>
            dplyr::filter(type == "models") |>
            dplyr::transmute(
              model_meta = group,
              model = code,
              model_coefs_fn = model_coefs_fn,
              model_fit_fn = model_fit_fn,
              model_standardize_fn = model_standardize_fn
            ),
          by = "model"
        )
    }

    if(!is.null(grid_components$variables)){
      full_grid <-
        full_grid |>
        tidyr::nest(
          data = dplyr::any_of(
            dplyr::matches(paste0("^",grid_components$variables,"$"))
          )
        ) |>
        dplyr::mutate(
          dplyr::across(
            c(-data),
            ~purrr::map2_chr(data, .x, function(x, y) glue::glue_data(x, y))
          )
        ) |>
        tidyr::unnest(data)
    }

    if(!is.null(grid_components$parameter_key)){
      full_grid <-
        full_grid |>
        tidyr::nest(
          data = dplyr::any_of(
            dplyr::matches(paste0("^",grid_components$parameter_key,"$"))
          )
        ) |>
        dplyr::mutate(
          dplyr::across(
            c(-data),
            ~purrr::map2_chr(data, .x, function(x, y) glue::glue_data(x, y))
          )
        ) |>
        tidyr::unnest(data)
    }

    pipeline_expanded <-
      purrr::map2(grid_components, names(grid_components), function(x, y) {
        if(y == "models"){
          full_grid |>
            dplyr::select(decision, x, dplyr::starts_with("model")) |>
            dplyr::mutate(
              model_coefs_fn       = stringr::str_replace(model_coefs_fn, "NA", ""),
              model_fit_fn         = stringr::str_replace(model_fit_fn, "NA", ""),
              model_standardize_fn = stringr::str_replace(model_standardize_fn, "NA", "")
            ) |>
            tidyr::nest("{y}" := -decision)
        }else if(y == "parameter_key"){
          full_grid |>
            dplyr::select(decision, x) |>
            tidyr::pivot_longer(
              -decision,
              names_to = "parameter_key",
              values_to =  "parameter"
            ) |>
            tidyr::nest(parameter_keys = -decision)
        } else{
          full_grid |>
            dplyr::select(decision, x) |>
            tidyr::nest("{y}" := -decision)
        }
      }) |>
      purrr::reduce(dplyr::left_join, "decision") |>
      dplyr::select(
        decision,
        dplyr::any_of(
          c(
            "subgroups",
            "variables",
            "filters",
            "preprocess",
            "models",
            "postprocess",
            "corrs",
            "summary_stats",
            "reliabilities",
            "parameter_keys"
          )
        )
      ) |>
      dplyr::mutate(
        decision = as.numeric(decision)
      )

    attr(pipeline_expanded, "base_df") <- data_chr
    attr(pipeline_expanded, "pipeline_object") <- pipeline_chr
    attr(pipeline_expanded, "pipeline") <- .pipeline
    attr(pipeline_expanded, "where_to_collect") <- .collect_after
    attr(pipeline_expanded, "pointer_path") <- .pointer_path
    attr(pipeline_expanded, "subgroup_in_path") <- .subgroup_in_path

    pipeline_expanded
  }

#' Expand a pipeline into a grid of analysis decisions
#'
#' Takes a pipeline built with the \code{add_*} functions and crosses every
#' alternative into a grid with one row per decision, ready for
#' \code{\link{analyze_grid}}. Before expanding, the pipeline is checked as a
#' whole, so problems that only appear when steps are combined are caught here
#' rather than during analysis.
#'
#' @param .pipeline a pipeline built with the \code{add_*} functions.
#' @param .collect_after where in each decision's code the data is pulled into
#'   memory with \code{collect()}: \code{"subgroups"}, \code{"filters"}, or
#'   \code{"preprocess"}. The default, \code{NULL}, collects right after the
#'   base data is read. Collecting later lets lazy data, such as an Arrow
#'   dataset, apply subgroups and filters before anything is loaded, as long
#'   as every step before the collect point can run on that data.
#' @param .pointer_path optional path to the data (e.g., a local directory or
#'   S3 URI) that each decision opens with \code{arrow::open_dataset()} when it
#'   runs, in place of the base data object. Use it for large Arrow datasets
#'   and for parallel analysis, where each worker opens the data itself.
#' @param .subgroup_in_path logical, \code{FALSE} by default. If \code{TRUE},
#'   each decision opens only its subgroup's directory,
#'   \code{<.pointer_path>/<variable>=<value>/}, instead of filtering on the
#'   subgroup. Requires \code{.pointer_path}, and the subgroup variables must
#'   be hive partitions nested directly under it, in the order they were given
#'   to \code{add_subgroups()}.
#'
#' @details
#' \strong{What adds decisions.} Subgroups, filters, variables, and models add
#' rows: every alternative of each is crossed with every alternative of the
#' others. Each model is a single alternative, so a pipeline with two models
#' has twice as many decisions as one with a single model, and each decision
#' runs exactly one model. Preprocessing, conditions, postprocessing, and
#' parameter keys are the same in every decision and add no rows.
#'
#' \strong{Templates.} Any code containing a variable group's name in braces,
#' such as \code{lm({dvs} ~ {ivs})}, has the name replaced by that decision's
#' variable. This applies to all steps. Braces that are part of the code
#' itself, such as the body of an anonymous function, must be doubled
#' (\code{{{ }}}) or avoided.
#'
#' \strong{Names.} Subgroup, filter, variable, and model names are kept exactly
#' as written. Preprocessing, condition, postprocessing, and parameter key
#' names are lowercased, with spaces replaced by underscores.
#'
#' \strong{Checks.} Exact repeats of a decision, such as the same filter added
#' in two \code{add_filters()} calls, are removed with a message.
#' \code{expand_pipeline()} stops with an error when:
#' \itemize{
#'   \item a name is used by more than one decision type, for example a column
#'     used as both a filter and a subgroup;
#'   \item two preprocessing, condition, postprocessing, or parameter key steps
#'     share a name;
#'   \item two models share a name;
#'   \item a step uses a name multitool reserves for its own columns
#'     (\code{decision}, \code{model}, \code{model_meta}, and the model
#'     extraction settings);
#'   \item the pipeline has no subgroups, filters, or variables to vary;
#'   \item the pipeline has no model.
#' }
#'
#' \strong{Decision numbers} identify rows and stay the same for a given
#' pipeline. They are not a ranking.
#'
#' @return a \code{tibble} with one row per decision. The \code{decision}
#'   column numbers each row. Every other column is a list column holding one
#'   step of that decision's pipeline. A step's column is present only if the
#'   pipeline uses that step.
#' \describe{
#'   \item{\code{subgroups}}{a one-row tibble with a column per subgroup
#'     variable holding that decision's value. Character and factor values are
#'     quoted; missing values are \code{NA}.}
#'   \item{\code{variables}}{a one-row tibble with a column per variable group
#'     holding the variable used in that decision.}
#'   \item{\code{filters}}{a one-row tibble with a column per filtered
#'     variable holding that decision's filter expression. The no-filter
#'     alternative is \code{is.na(x) | !is.na(x)}, which keeps every row.}
#'   \item{\code{preprocess}}{a one-row tibble with a column per preprocessing
#'     step, in the order the steps were added.}
#'   \item{\code{conditions}}{a tibble with one row per condition, in the
#'     order they were added, and the columns \code{condition}, \code{test},
#'     and \code{on_fail}.}
#'   \item{\code{models}}{a one-row tibble: \code{model} (the model code,
#'     without its data argument), \code{model_meta} (the model's name), and
#'     \code{model_coefs_fn}, \code{model_fit_fn}, and
#'     \code{model_standardize_fn} (code run on the fitted model, or
#'     \code{""} for none).}
#'   \item{\code{postprocess}}{a one-row tibble with a column per
#'     postprocessing step.}
#'   \item{\code{parameter_keys}}{a tibble with one row per key and the
#'     columns \code{parameter_key} and \code{parameter}.}
#' }
#' All code in these columns has its templates filled in for that decision.
#' The grid also carries attributes used when decisions are run:
#' \code{base_df} (the base data's name), \code{pipeline} (the checked
#' pipeline), \code{where_to_collect}, \code{pointer_path}, and
#' \code{subgroup_in_path}.
#'
#' @seealso \code{\link{analyze_grid}} to run the decisions,
#'   \code{\link{show_code}} to see the code for one decision, and
#'   \code{\link{expand_decisions}} for the earlier expansion function.
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#'
#' the_data <-
#'   data.frame(
#'     id   = 1:500,
#'     iv1  = rnorm(500),
#'     iv2  = rnorm(500),
#'     cov1 = rnorm(500),
#'     dv1  = rnorm(500),
#'     dv2  = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE)
#'   )
#'
#' # 2 filtered variables x 2 alternatives, 2 ivs, 2 dvs, 1 model = 16 decisions
#' the_grid <-
#'   the_data |>
#'   add_filters(include1 == 0, include2 != 3) |>
#'   add_variables("ivs", iv1, iv2) |>
#'   add_variables("dvs", dv1, dv2) |>
#'   add_preprocess("standardize ivs", 'mutate({ivs} = scale({ivs}))') |>
#'   add_condition("minimum n", nrow() >= 100) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} + cov1)) |>
#'   expand_pipeline()
#'
#' the_grid
#'
#' # the steps of the first decision
#' the_grid$filters[[1]]
#' the_grid$models[[1]]
#' the_grid$conditions[[1]]
expand_pipeline <-
  function(
    .pipeline,
    .collect_after = NULL,
    .pointer_path = NULL,
    .subgroup_in_path = FALSE
  ){

    if(!is.null(.collect_after)){
      .collect_after <- rlang::arg_match(.collect_after, c("subgroups", "filters", "preprocess"))
    }

    if(.subgroup_in_path && is.null(.pointer_path)){
      rlang::abort(
        c(
          "`.subgroup_in_path = TRUE` requires `.pointer_path`.",
          i = "Supply the directory that holds the subgroup partitions."
        )
      )
    }

    pipeline_chr <- dplyr::enexpr(.pipeline)
    data_chr <- attr(.pipeline, "base_df")

    # Validate the pipeline
    # an exact repeat (e.g., the same filter added in two calls) is one alternative
    pipeline_unique <-
      .pipeline |>
      dplyr::distinct()

    n_repeats <- nrow(.pipeline) - nrow(pipeline_unique)

    if(n_repeats > 0){
      rlang::inform(glue::glue("Removed {n_repeats} repeated decision(s) from the pipeline."))
    }

    pipeline_tbl <-
      pipeline_unique |>
      dplyr::mutate(
        group =
          dplyr::if_else(
            type %in% c("subgroups", "filters", "variables", "models"),
            group,
            group |>
              stringr::str_squish() |>
              stringr::str_replace_all(" ", "_") |>
              tolower()
          )
      )

    # every name becomes one grid column, so it can belong to only one decision type
    shared_names <-
      pipeline_tbl |>
      dplyr::filter(type != "models") |>
      dplyr::distinct(type, group) |>
      dplyr::summarise(types = stringr::str_flatten_comma(type), n_types = dplyr::n(), .by = group) |>
      dplyr::filter(n_types > 1)

    if(nrow(shared_names) > 0){
      rlang::abort(
        c(
          "Each name can belong to only one decision type.",
          x = glue::glue_data(shared_names, "'{group}' is used as: {types}"),
          i = "A column can't be both a filter and a subgroup."
        )
      )
    }

    # steps that don't add alternatives can have only one version per name
    repeated_constants <-
      pipeline_tbl |>
      dplyr::filter(type %in% c("preprocess", "conditions", "postprocess", "parameter_key")) |>
      dplyr::count(type, group) |>
      dplyr::filter(n > 1)

    if(nrow(repeated_constants) > 0){
      rlang::abort(
        c(
          "Preprocessing, conditions, postprocessing, and parameter keys need a unique name for each step.",
          x = glue::glue_data(repeated_constants, "'{group}' ({type}) has {n} versions"),
          i = "Rename one of them, or combine them into a single step."
        )
      )
    }

    repeated_model_names <-
      pipeline_tbl |>
      dplyr::filter(type == "models") |>
      dplyr::count(group) |>
      dplyr::filter(n > 1)

    if(nrow(repeated_model_names) > 0){
      rlang::abort(
        c(
          "Each model needs a unique name.",
          x = glue::glue("Used more than once: {stringr::str_flatten_comma(repeated_model_names$group)}")
        )
      )
    }

    # names the grid uses for its own columns
    reserved_names <-
      c(
        "decision",
        "model",
        "model_meta",
        "model_coefs_fn",
        "model_fit_fn",
        "model_standardize_fn"
      )

    reserved_used <-
      pipeline_tbl |>
      dplyr::filter(type != "models", group %in% reserved_names) |>
      dplyr::distinct(type, group)

    if(nrow(reserved_used) > 0){
      rlang::abort(
        c(
          "These names are reserved by multitool:",
          x = glue::glue_data(reserved_used, "'{group}' ({type})"),
          i = "Rename these steps."
        )
      )
    }

    # Components of the pipeline
    pipeline_components <-
      pipeline_tbl |>
      dplyr::distinct(type) |>
      dplyr::pull(type)

    if(!any(c("filters", "variables", "subgroups") %in% .pipeline$type)){
      rlang::abort(
        c(
          "Your pipeline does not have any alternatives.",
          "Use `add_variables()` to build pipelines with different versions of a variable",
          "Use `add_subgroups()` to build pipelines that analyze different subgroups",
          "Use `add_filters()` to apply different filters to the data.",
          i = "You can also use any combination of the above"
        )
      )
    }

    # Grid components empty list
    grid_components <- list()

    # All normal components
    grid_components$expansion <-
      pipeline_tbl |>
      dplyr::filter(
        !type %in% c("models", "conditions")
      ) |>
      dplyr::group_split(type) |>
      purrr::map(\(x) df_to_expand_prep(x, group, code)) |>
      purrr::list_flatten() |>
      df_to_expand()

    # Modeling component
    if("models" %in% pipeline_components){
      grid_components$models <-
        pipeline_tbl |>
        dplyr::filter(type == "models") |>
        dplyr::transmute(
          model = code,
          model_meta = group,
          settings
        ) |>
        tidyr::unnest_wider(settings)
    } else{
      rlang::abort(
        glue::glue(
          "Your pipeline doesn't have any models.",
          "Use `add_model()` in your pipeline to add one",
          .sep = "\n"
        )
      )
    }

    # Conditions component
    if("conditions" %in% pipeline_components){
      grid_components$conditions <-
        pipeline_tbl |>
        dplyr::filter(type == "conditions") |>
        dplyr::select(group, code) |>
        tidyr::pivot_wider(names_from = group, values_from = code)
    }

    # Fully expanded grid, no nesting yet
    full_grid <-
      purrr::reduce(grid_components, dplyr::cross_join) |>
      dplyr::mutate(decision = 1:dplyr::n())

    # Variable name glue injection
    if("variables" %in% pipeline_components){
      glue_vars <-
        pipeline_tbl |>
        dplyr::filter(type == "variables") |>
        dplyr::pull(group)

      full_grid <-
        full_grid |>
        tidyr::nest(.variable_values = dplyr::any_of(glue_vars)) |>
        dplyr::mutate(
          dplyr::across(
            -c(decision, .variable_values),
            ~purrr::map2_chr(.variable_values, .x, function(x, y) glue::glue_data(x, y))
          )
        ) |>
        tidyr::unnest(.variable_values)
    }

    # Nest grid by the pipeline components
    pipeline_expanded <-
      purrr::map(pipeline_components, function(component){

        step_columns <-
          if(component %in% names(grid_components)){
            names(grid_components[[component]])
          } else{
            pipeline_tbl |>
              dplyr::filter(type == component) |>
              dplyr::pull(group) |>
              unique()
          }

        if(component == "parameter_key"){
          full_grid |>
            dplyr::select(decision, dplyr::all_of(step_columns)) |>
            tidyr::pivot_longer(
              -decision,
              names_to = "parameter_key",
              values_to =  "parameter"
            ) |>
            tidyr::nest(parameter_keys = -decision)
        } else if(component == "conditions"){
          condition_fail_modes <-
            pipeline_tbl |>
            dplyr::filter(type == "conditions") |>
            tidyr::unnest_wider(settings) |>
            dplyr::select(condition = group, on_fail)

          full_grid |>
            dplyr::select(decision, dplyr::all_of(step_columns)) |>
            tidyr::pivot_longer(-decision, names_to = "condition", values_to = "test") |>
            dplyr::left_join(condition_fail_modes, by = "condition") |>
            tidyr::nest(conditions = -decision)
        } else{
          full_grid |>
            dplyr::select(decision, dplyr::all_of(step_columns)) |>
            tidyr::nest("{component}" := -decision)
        }

      }) |>
      purrr::reduce(dplyr::left_join, by = "decision") |>
      dplyr::select(
        decision,
        dplyr::any_of(
          c(
            "subgroups",
            "variables",
            "filters",
            "preprocess",
            "conditions",
            "models",
            "postprocess",
            "parameter_keys"
          )
        )
      ) |>
      dplyr::mutate(
        decision = as.numeric(decision)
      )

    attr(pipeline_expanded, "base_df") <- data_chr
    attr(pipeline_expanded, "pipeline_object") <- pipeline_chr
    attr(pipeline_expanded, "pipeline") <- pipeline_unique
    attr(pipeline_expanded, "where_to_collect") <- .collect_after
    attr(pipeline_expanded, "pointer_path") <- .pointer_path
    attr(pipeline_expanded, "subgroup_in_path") <- .subgroup_in_path

    pipeline_expanded

  }
