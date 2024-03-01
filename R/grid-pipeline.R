#' Add filtering/exclusion criteria to a multiverse pipeline
#'
#' @param .df The original \code{data.frame}(e.g., base data set). If part of
#'   set of add_* decision functions in a pipeline, the base data will be passed
#'   along as an attribute.
#' @param ... logical expressions to be used with \code{\link[dplyr]{filter}}
#'   separated by commas. Expressions should not be quoted.
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
add_filters <- function(.df, ...){
  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <-
    rlang::parse_expr(data_chr) |>
    rlang::eval_tidy(env = parent.frame())

  filter_exprs <- dplyr::enexprs(...)
  filter_exprs_chr <- as.character(filter_exprs)
  filter_vars <-
    stringr::str_extract(
      filter_exprs_chr,
      paste(
        base_df|> names(),
        collapse = "|"
      )
    )

  grid_prep1 <-
    purrr::map2_df(filter_exprs_chr, filter_vars, function(x, y){

      tibble::tibble(
        type  = "filters",
        group = y,
        code  = x
      )

    })

  grid_prep2 <-
    grid_prep1 |>
    dplyr::pull(group) |>
    unique() |>
    purrr::map(function(x){

      grid_prep1 |>
        dplyr::filter(group == x) |>
        tibble::add_row(
          type  = "filters",
          group = x,
          code  = glue::glue("{x} %in% unique({x})") |> as.character()
        )

    }) |>
    purrr::list_rbind()

  if(!is.null(data_attr)){
    grid_prep <- dplyr::bind_rows(.df, grid_prep2)
  } else{
    grid_prep <- grid_prep2
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep

}

#' Add sub groups to the multiverse pipeline
#'
#' @param .df The original \code{data.frame}(e.g., base data set). If part of
#'   set of add_* decision functions in a pipeline, the base data will be passed
#'   along as an attribute.
#' @param ... sub group variable(s) in your data whose values specify groupings.
#' @param .only a character vector of sub group values to include. The default
#'   includes all sub group values for each sub group variable.
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
#'
#' the_data |>
#'   add_subgroups(group, .only = c(1,3))
add_subgroups <- function(.df, ..., .only = NULL){
  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <-
    rlang::parse_expr(data_chr) |>
    rlang::eval_tidy(env = parent.frame())

  subgroups <-
    base_df |>
    dplyr::select(...) |>
    dplyr::distinct() |>
    tidyr::pivot_longer(
      dplyr::everything(),
      names_to = "group",
      values_to = "code",
      values_transform = as.character
    ) |>
    dplyr::mutate(
      type = "subgroups"
    ) |>
    dplyr::relocate(type, .before = group) |>
    dplyr::distinct() |>
    dplyr::arrange(group, code)

  if(is.null(.only)){
    grid_prep <-
      subgroups
  } else{
    grid_prep <-
      subgroups |>
      dplyr::filter(
        code %in% .only
      )
  }

  if(!is.null(data_attr)){
    grid_prep <- dplyr::bind_rows(.df, grid_prep)
  } else{
    grid_prep <- grid_prep
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep
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
  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <-
    rlang::parse_expr(data_chr) |>
    rlang::eval_tidy(env = parent.frame())

  grid_prep <-
    tibble::tibble(
      type  = "variables",
      group = var_group,
      code  = base_df |> dplyr::select(...) |> names()
    )

  if(!is.null(data_attr)){
    grid_prep <- dplyr::bind_rows(.df, grid_prep)
  } else{
    grid_prep <- grid_prep
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep

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
  code <- dplyr::enexprs(code)
  code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <-
    rlang::parse_expr(data_chr) |>
    rlang::eval_tidy(env = parent.frame())

  grid_prep <-
    tibble::tibble(
      type  = "preprocess",
      group = process_name,
      code  = code_chr
    )

  if(!is.null(data_attr)){
    grid_prep <- dplyr::bind_rows(.df, grid_prep)
  } else{
    grid_prep <- grid_prep
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep

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
add_model <- function(.df, model_desc, code){
  code <- dplyr::enexprs(code)
  code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <-
    rlang::parse_expr(data_chr) |>
    rlang::eval_tidy(env = parent.frame())

  grid_prep <-
    tibble::tibble(
      type  = "models",
      group = model_desc,
      code  = code_chr
    )

  if(!is.null(data_attr)){
    grid_prep <- dplyr::bind_rows(.df, grid_prep)
  } else{
    grid_prep <- grid_prep
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep

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
  code <- dplyr::enexprs(parameter_name)
  code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <-
    rlang::parse_expr(data_chr) |>
    rlang::eval_tidy(env = parent.frame())

  grid_prep <-
    tibble::tibble(
      type  = "parameter_key",
      group = parameter_group,
      code  = code_chr
    )

  if(!is.null(data_attr)){
    grid_prep <- dplyr::bind_rows(.df, grid_prep)
  } else{
    grid_prep <- grid_prep
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep
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

  code <- dplyr::enexprs(code)
  code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <-
    rlang::parse_expr(data_chr) |>
    rlang::eval_tidy(env = parent.frame())

  grid_prep <-
    tibble::tibble(
      type  = "postprocess",
      group = postprocess_name,
      code  = code_chr
    )

  if(!is.null(data_attr)){
    grid_prep <- dplyr::bind_rows(.df, grid_prep)
  } else{
    grid_prep <- grid_prep
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep

}

#' Add a set of descriptive statistics to compute over a set of variables
#'
#' @param .df The original \code{data.frame}(e.g., base data set). If part of
#'   set of add_* decision functions in a pipeline, the base data will be passed
#'   along as an attribute.
#' @param var_set a character string. A name for the set of summary statistics
#' @param variables the variables for which you would like to compute summary
#'   statistics. You can also use tidyselect to select variables.
#' @param stats a character vector of stat names (e.g., \code{c("mean","sd")}).
#'   You are responsible for loading any packages that compute your preferred
#'   summary statistics. Summary statistic functions must work inside
#'   \code{\link[dplyr]{summarize}}.
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
#'   add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#'   add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
#'   add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#'   add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis"))
add_summary_stats <- function(.df, var_set, variables, stats){

  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <-
    rlang::parse_expr(data_chr) |>
    rlang::eval_tidy(env = parent.frame())

  variables <- dplyr::enexprs(variables) |> as.character()

  stats_list <-
    purrr::map_chr(stats, function(x) glue::glue("{x} = ~ {x}(.x, na.rm = TRUE)")) |>
    paste(collapse = ", ") |> paste0("list(", ... = _, ")")

  descriptives <-
    glue::glue(
      'select(c([variables])) |> summarize(across(everything(), [stats_list]))',
      .open = "[",
      .close = "]"
    ) |>
    as.character() |>
    stringr::str_remove_all("\n|  ")

  grid_prep <-
    tibble::tibble(
      type  = "summary_stats",
      group = var_set,
      code  = descriptives
    )

  if(!is.null(data_attr)){
    grid_prep <- dplyr::bind_rows(.df, grid_prep)
  } else{
    grid_prep <- grid_prep
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep

}

#' Add correlations from the \code{correlation} package in \code{easystats}
#'
#' @param .df the original \code{data.frame}(e.g., base data set). If part of
#'   set of
#'   add_* decision functions in a pipeline, the base data will be passed along
#'   as an attribute.
#' @param var_set character string. Should be a descriptive name of the
#'   correlation matrix.
#' @param variables the variables for which you would like to correlations.
#'   These variables will be passed to \code{link[correlation]{correlation}}.
#'   You can also use tidyselect to select variables.
#' @param focus_set variables to focus one in a table. This produces a table
#'   where rows are each focused variables and columns are all other variables
#' @param method a valid method of correlation supplied to
#'   \code{link[correlation]{correlation}} (e.g., 'pearson' or 'kendall').
#'   Defaults to \code{'auto'}. See \code{link[correlation]{correlation}} for
#'   more details.
#' @param redundant logical, should the result include repeated correlations?
#'   Defaults to \code{TRUE} See \code{link[correlation]{correlation}} for
#'   details.
#' @param add_matrix logical, add a traditional correlation matrix to the
#'   output. Defaults to \code{TRUE}.
#'
#' @return a \code{data.frame}with three columns: type, group, and code. Type
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
#'   add_correlations("predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2))
add_correlations <-
  function(
    .df,
    var_set,
    variables,
    focus_set = NULL,
    method = 'auto',
    redundant = TRUE,
    add_matrix = TRUE
  ){

    data_chr <- dplyr::enexpr(.df) |> as.character()
    data_attr <- attr(.df, "base_df")

    if(!is.null(data_attr)){
      data_chr <- attr(.df, "base_df")
    }

    base_df <-
      rlang::parse_expr(data_chr) |>
      rlang::eval_tidy(env = parent.frame())

    variables <- dplyr::enexprs(variables) |> as.character()
    focus_set <- base_df |> dplyr::select({{focus_set}}) |> names()
    focus_set_chr <-
      focus_set |>
      paste0("\"", ... = _, "\"") |>
      paste0(collapse = ", ")
    focus <- length(focus_set) > 1

    full_pairs <-
      glue::glue(
        'select({variables}) |> ',
        'correlation(method = "{method}", redundant = {redundant})'
      ) |>
      as.character() |>
      stringr::str_remove_all("\n|  ")


    grid_prep <-
      tibble::tibble(
        type  = "corrs",
        group = paste0(var_set,"_rs"),
        code  = full_pairs
      )

    if(add_matrix){
      corrs_matrix <-
        glue::glue(
          'select({variables}) |> ',
          'correlation(method = "{method}", redundant = {redundant}) |> ',
          'select(1:3) |> ',
          'pivot_wider(names_from = Parameter2, values_from = r) |> ',
          'rename(variable = Parameter1)',
          .trim = FALSE
        ) |>
        as.character() |>
        stringr::str_remove_all("\n|  ")

      grid_prep <-
        grid_prep |>
        dplyr::add_row(
          type = "corrs",
          group = paste0(var_set, "_matrix"),
          code = corrs_matrix
        )
    }

    if(focus){
      corrs_focused <-
        glue::glue(
          'select({variables}) |> ',
          'correlation(method = "{method}", redundant = {redundant}) |> ',
          'select(1:3) |> ',
          'filter(',
          'Parameter1 %in% c({focus_set_chr}), ',
          'r!=1, ',
          '!Parameter2 %in% c({focus_set_chr})',
          ') |> ',
          'pivot_wider(names_from = Parameter1, values_from = r) |> ',
          'rename(variable = Parameter2)',
          .trim = FALSE
        ) |>
        as.character() |>
        stringr::str_remove_all("\n|  ")

      grid_prep <-
        grid_prep |>
        dplyr::add_row(
          type = "corrs",
          group = paste0(var_set, "_focus"),
          code = corrs_focused
        )
    }

    if(!is.null(data_attr)){
      grid_prep <- dplyr::bind_rows(.df, grid_prep)
    } else{
      grid_prep <- grid_prep
    }

    attr(grid_prep, "base_df") <- data_chr
    grid_prep
  }


#' Add item reliabilities to a multiverse pipeline
#'
#' @param .df the original \code{data.frame}(e.g., base data set). If part of
#'   set of add_* decision functions in a pipeline, the base data will be passed
#'   along as an attribute.
#' @param scale_name a character string. Indicates the name of the scale or
#'   measure measured by the items or indicators in \code{items}.
#' @param items the items (variables) that comprise a scale or measure. These
#'   variables will be passed to \code{link[performance]{cronbachs_alpha}},
#'   \code{link[performance]{item_intercor}}, and
#'   \code{link[performance]{item_reliability}}. You can also use tidyselect to
#'   select variables.
#'
#' @return a \code{data.frame}with three columns: type, group, and code. Type
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
#'   add_reliabilities("unp_scale", c(iv1,iv2,iv3))
add_reliabilities <- function(.df, scale_name, items){

  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <-
    rlang::parse_expr(data_chr) |>
    rlang::eval_tidy(env = parent.frame())

  items <- dplyr::enexprs(items) |> as.character()

  items_alpha <-
    glue::glue(
      'select({items}) |> cronbachs_alpha()'
    ) |>
    as.character() |>
    stringr::str_remove_all("\n|  ")

  items_avg_intercorr <-
    glue::glue(
      'select({items}) |> item_intercor()'
    ) |>
    as.character() |>
    stringr::str_remove_all("\n|  ")

  items_alpha_if_dropped <-
    glue::glue(
      'select({items}) |> item_reliability()'
    ) |>
    as.character() |>
    stringr::str_remove_all("\n|  ")

  grid_prep <-
    tibble::tibble(
      type  = "reliabilities",
      group = paste0(scale_name,c("_alpha", "_inter_corr","_if_dropped")),
      code  = c(items_alpha, items_avg_intercorr, items_alpha_if_dropped)
    )

  if(!is.null(data_attr)){
    grid_prep <- dplyr::bind_rows(.df, grid_prep)
  } else{
    grid_prep <- grid_prep
  }

  attr(grid_prep, "base_df") <- data_chr
  grid_prep

}

#' Expand a set of multiverse decisions into all possible combinations
#'
#' @param .pipeline a \code{data.frame} produced by calling a series of add_*
#'   functions.
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
#'   add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#'   add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis")) |>
#'   add_correlations("predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2)) |>
#'   add_correlations("outcomes", matches("dv|mod"), focus_set = matches("dv")) |>
#'   add_reliabilities("unp_scale", c(iv1,iv2,iv3)) |>
#'   add_model("no covariates", lm({dvs} ~ {ivs} * {mods})) |>
#'   add_model("with covariates", lm({dvs} ~ {ivs} * {mods} + cov1)) |>
#'   add_postprocess("aov", aov())
#'
#' pipeline_expanded <- expand_decisions(full_pipeline)
expand_decisions <- function(.pipeline){

  pipeline_chr <- dplyr::enexpr(.pipeline)
  data_chr <- attr(.pipeline, "base_df")

  grid_components <-
    .pipeline |>
    dplyr::mutate(
      group = stringr::str_replace_all(group, " ", "_") |> tolower()
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
    .pipeline |>
    dplyr::mutate(
      group = stringr::str_replace_all(group, " ", "_") |> tolower()
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
        .pipeline |>
          dplyr::filter(type == "models") |>
          dplyr::transmute(
            model_meta = group,
            model = code
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
          dplyr::select(decision, x, model_meta) |>
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
      }else{
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
    )

  attr(pipeline_expanded, "base_df") <- data_chr
  attr(pipeline_expanded, "pipeline") <- pipeline_chr
  pipeline_expanded
}
