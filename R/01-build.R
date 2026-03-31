#' Add filtering/exclusion criteria to a multiverse pipeline
#'
#' @param .df The original \code{data.frame}(e.g., base data set). If part of
#'   set of add_* decision functions in a pipeline, the base data will be passed
#'   along as an attribute.
#' @param ... logical expressions to be used with \code{\link[dplyr]{filter}}
#'   separated by commas. Expressions should not be quoted.
#' @param remove_do_nothing logical, \code{FALSE} by default. Indicates whether to
#'   include an specification where no filters are applied to the data.
#'   Typically this is desirable, but on a occasion you may wan to turn this
#'   functionally off.
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
  data_chr <- dplyr::enexpr(.df) |> as.character()
  data_attr <- attr(.df, "base_df")

  if(!is.null(data_attr)){
    data_chr <- attr(.df, "base_df")
  }

  base_df <-
    rlang::parse_expr(paste(data_chr, "|> dplyr::collect()")) |>
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

  if(remove_do_nothing){
    grid_prep <-
      grid_prep |>
      dplyr::filter(!stringr::str_detect(code, "\\%in\\% unique"))
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
    rlang::parse_expr(paste(data_chr, "|> dplyr::collect()")) |>
    rlang::eval_tidy(env = parent.frame())

  subgroups <-
    base_df |>
    dplyr::select(...) |>
    dplyr::distinct() |>
    dplyr::mutate(
      dplyr::across(
        dplyr::where(\(x) is.character(x) | is.factor(x)),
        ~paste0('"', .x, '"')
      )
    ) |>
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
    dplyr::distinct()
  #dplyr::arrange(group, code)

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
    rlang::parse_expr(paste(data_chr, "|> dplyr::collect()")) |>
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
    rlang::parse_expr(paste(data_chr, "|> dplyr::collect()")) |>
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
    code <- dplyr::enexprs(code)
    code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

    model_coefs <- dplyr::enexprs(model_coefs) |> as.character()
    model_fit <- dplyr::enexprs(model_fit) |> as.character()
    model_standardize <- dplyr::enexprs(model_standardize) |> as.character()

    data_chr <- dplyr::enexpr(.df) |> as.character()
    data_attr <- attr(.df, "base_df")

    if(!is.null(data_attr)){
      data_chr <- attr(.df, "base_df")
    }

    base_df <-
      rlang::parse_expr(paste(data_chr, "|> dplyr::collect()")) |>
      rlang::eval_tidy(env = parent.frame())

    grid_prep <-
      tibble::tibble(
        type  = "models",
        group = model_desc,
        code  = code_chr,
        model_coefs_fn       = ifelse(model_coefs == "NULL", NA, model_coefs),
        model_fit_fn         = ifelse(model_fit == "NULL", NA, model_fit),
        model_standardize_fn = ifelse(model_standardize == "NULL", NA, model_standardize)
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
      group = desc_name,
      code  = glue::glue("model.frame() |> {code_chr}")
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

    grid_components <-
      .pipeline |>
      dplyr::mutate(
        group =
          ifelse(
            !type %in% c("subgroups", "filters"),
            stringr::str_replace_all(group, " ", "_") |> tolower(),
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
      .pipeline |>
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
          .pipeline |>
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
      ) |>
      mutate(
        decision = as.numeric(decision)
      )

    attr(pipeline_expanded, "base_df") <- data_chr
    attr(pipeline_expanded, "pipeline_object") <- pipeline_chr
    attr(pipeline_expanded, "pipeline") <- .pipeline
    attr(pipeline_expanded, "where_to_collect") <- .collect_after
    attr(pipeline_expanded, "pointer_path") <- .pointer_path
    attr(pipeline_expanded, "subgroup_in_path") <- .subgroup_in_path

    grid_elements <- paste(names(pipeline_expanded), collapse = " ")

    pipeline_expanded
  }
