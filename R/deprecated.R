#' #' Add a set of descriptive statistics to compute over a set of variables
#' #'
#' #' @description `r lifecycle::badge("deprecated")` This function has been
#' #' deprecated; please use [add_model_descriptives()] instead.
#' #'
#' #' @param .df The original \code{data.frame}(e.g., base data set). If part of
#' #'   set of add_* decision functions in a pipeline, the base data will be passed
#' #'   along as an attribute.
#' #' @param var_set a character string. A name for the set of summary statistics
#' #' @param variables the variables for which you would like to compute summary
#' #'   statistics. You can also use tidyselect to select variables.
#' #' @param stats a character vector of stat names (e.g., \code{c("mean","sd")}).
#' #'   You are responsible for loading any packages that compute your preferred
#' #'   summary statistics. Summary statistic functions must work inside
#' #'   \code{\link[dplyr]{summarize}}.
#' #'
#' #' @return a \code{data.frame} with three columns: type, group, and code. Type
#' #'   indicates the decision type, group is a decision, and the code is the
#' #'   actual code that will be executed. If part of a pipe, the current set of
#' #'   decisions will be appended as new rows.
#' #' @export
#' #'
#' #' @examples
#' #'
#' #' library(tidyverse)
#' #' library(multitool)
#' #'
#' #' the_data <-
#' #'   data.frame(
#' #'     id   = 1:500,
#' #'     iv1  = rnorm(500),
#' #'     iv2  = rnorm(500),
#' #'     iv3  = rnorm(500),
#' #'     mod1 = rnorm(500),
#' #'     mod2 = rnorm(500),
#' #'     mod3 = rnorm(500),
#' #'     cov1 = rnorm(500),
#' #'     cov2 = rnorm(500),
#' #'     dv1  = rnorm(500),
#' #'     dv2  = rnorm(500),
#' #'     include1 = rbinom(500, size = 1, prob = .1),
#' #'     include2 = sample(1:3, size = 500, replace = TRUE),
#' #'     include3 = rnorm(500)
#' #'   )
#' #'
#' #' the_data |>
#' #'   add_filters(include1 == 0,include2 != 3,include2 != 2, include3 > -2.5) |>
#' #'   add_variables("ivs", iv1, iv2, iv3) |>
#' #'   add_variables("dvs", dv1, dv2) |>
#' #'   add_variables("mods", starts_with("mod")) |>
#' #'   add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#' #'   add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
#' #'   add_summary_stats("iv_stats", starts_with("iv"), c("mean", "sd")) |>
#' #'   add_summary_stats("dv_stats", starts_with("dv"), c("skewness", "kurtosis"))
#' add_summary_stats <- function(.df, var_set, variables, stats){
#'
#'   data_chr <- dplyr::enexpr(.df) |> as.character()
#'   data_attr <- attr(.df, "base_df")
#'
#'   if(!is.null(data_attr)){
#'     data_chr <- attr(.df, "base_df")
#'   }
#'
#'   base_df <-
#'     rlang::parse_expr(data_chr) |>
#'     rlang::eval_tidy(env = parent.frame())
#'
#'   variables <- dplyr::enexprs(variables) |> as.character()
#'
#'   stats_list <-
#'     purrr::map_chr(stats, function(x) glue::glue("{x} = ~ {x}(.x, na.rm = TRUE)")) |>
#'     paste(collapse = ", ") |> paste0("list(", ... = _, ")")
#'
#'   descriptives <-
#'     glue::glue(
#'       'select(c([variables])) |> summarize(across(everything(), [stats_list]))',
#'       .open = "[",
#'       .close = "]"
#'     ) |>
#'     as.character() |>
#'     stringr::str_remove_all("\n|  ")
#'
#'   grid_prep <-
#'     tibble::tibble(
#'       type  = "summary_stats",
#'       group = var_set,
#'       code  = descriptives
#'     )
#'
#'   if(!is.null(data_attr)){
#'     grid_prep <- dplyr::bind_rows(.df, grid_prep)
#'   } else{
#'     grid_prep <- grid_prep
#'   }
#'
#'   attr(grid_prep, "base_df") <- data_chr
#'   grid_prep
#'
#' }
#'
#' #' Add correlations from the \code{correlation} package in \code{easystats}
#' #'
#' #' @description `r lifecycle::badge("deprecated")` This function has been
#' #' deprecated; please use [add_model_descriptives()] instead.
#' #'
#' #' @param .df the original \code{data.frame}(e.g., base data set). If part of
#' #'   set of
#' #'   add_* decision functions in a pipeline, the base data will be passed along
#' #'   as an attribute.
#' #' @param var_set character string. Should be a descriptive name of the
#' #'   correlation matrix.
#' #' @param variables the variables for which you would like to correlations.
#' #'   These variables will be passed to \code{link[correlation]{correlation}}.
#' #'   You can also use tidyselect to select variables.
#' #' @param focus_set variables to focus one in a table. This produces a table
#' #'   where rows are each focused variables and columns are all other variables
#' #' @param method a valid method of correlation supplied to
#' #'   \code{link[correlation]{correlation}} (e.g., 'pearson' or 'kendall').
#' #'   Defaults to \code{'auto'}. See \code{link[correlation]{correlation}} for
#' #'   more details.
#' #' @param redundant logical, should the result include repeated correlations?
#' #'   Defaults to \code{TRUE} See \code{link[correlation]{correlation}} for
#' #'   details.
#' #' @param add_matrix logical, add a traditional correlation matrix to the
#' #'   output. Defaults to \code{TRUE}.
#' #'
#' #' @return a \code{data.frame}with three columns: type, group, and code. Type
#' #'   indicates the decision type, group is a decision, and the code is the
#' #'   actual code that will be executed. If part of a pipe, the current set of
#' #'   decisions will be appended as new rows.
#' #' @export
#' #'
#' #' @examples
#' #'
#' #' library(tidyverse)
#' #' library(multitool)
#' #'
#' #' the_data <-
#' #'   data.frame(
#' #'     id   = 1:500,
#' #'     iv1  = rnorm(500),
#' #'     iv2  = rnorm(500),
#' #'     iv3  = rnorm(500),
#' #'     mod1 = rnorm(500),
#' #'     mod2 = rnorm(500),
#' #'     mod3 = rnorm(500),
#' #'     cov1 = rnorm(500),
#' #'     cov2 = rnorm(500),
#' #'     dv1  = rnorm(500),
#' #'     dv2  = rnorm(500),
#' #'     include1 = rbinom(500, size = 1, prob = .1),
#' #'     include2 = sample(1:3, size = 500, replace = TRUE),
#' #'     include3 = rnorm(500)
#' #'   )
#' #'
#' #' the_data |>
#' #'   add_filters(include1 == 0,include2 != 3,include2 != 2, include3 > -2.5) |>
#' #'   add_variables("ivs", iv1, iv2, iv3) |>
#' #'   add_variables("dvs", dv1, dv2) |>
#' #'   add_variables("mods", starts_with("mod")) |>
#' #'   add_correlations("predictors", matches("iv|mod|cov"), focus_set = c(cov1,cov2))
#' add_correlations <-
#'   function(
#'     .df,
#'     var_set,
#'     variables,
#'     focus_set = NULL,
#'     method = 'auto',
#'     redundant = TRUE,
#'     add_matrix = TRUE
#'   ){
#'
#'     data_chr <- dplyr::enexpr(.df) |> as.character()
#'     data_attr <- attr(.df, "base_df")
#'
#'     if(!is.null(data_attr)){
#'       data_chr <- attr(.df, "base_df")
#'     }
#'
#'     base_df <-
#'       rlang::parse_expr(data_chr) |>
#'       rlang::eval_tidy(env = parent.frame())
#'
#'     variables <- dplyr::enexprs(variables) |> as.character()
#'     focus_set <- base_df |> dplyr::select({{focus_set}}) |> names()
#'     focus_set_chr <-
#'       focus_set |>
#'       paste0("\"", ... = _, "\"") |>
#'       paste0(collapse = ", ")
#'     focus <- length(focus_set) > 1
#'
#'     full_pairs <-
#'       glue::glue(
#'         'select({variables}) |> ',
#'         'correlation(method = "{method}", redundant = {redundant})'
#'       ) |>
#'       as.character() |>
#'       stringr::str_remove_all("\n|  ")
#'
#'
#'     grid_prep <-
#'       tibble::tibble(
#'         type  = "corrs",
#'         group = paste0(var_set,"_rs"),
#'         code  = full_pairs
#'       )
#'
#'     if(add_matrix){
#'       corrs_matrix <-
#'         glue::glue(
#'           'select({variables}) |> ',
#'           'correlation(method = "{method}", redundant = {redundant}) |> ',
#'           'select(1:3) |> ',
#'           'pivot_wider(names_from = Parameter2, values_from = r) |> ',
#'           'rename(variable = Parameter1)',
#'           .trim = FALSE
#'         ) |>
#'         as.character() |>
#'         stringr::str_remove_all("\n|  ")
#'
#'       grid_prep <-
#'         grid_prep |>
#'         dplyr::add_row(
#'           type = "corrs",
#'           group = paste0(var_set, "_matrix"),
#'           code = corrs_matrix
#'         )
#'     }
#'
#'     if(focus){
#'       corrs_focused <-
#'         glue::glue(
#'           'select({variables}) |> ',
#'           'correlation(method = "{method}", redundant = {redundant}) |> ',
#'           'select(1:3) |> ',
#'           'filter(',
#'           'Parameter1 %in% c({focus_set_chr}), ',
#'           'r!=1, ',
#'           '!Parameter2 %in% c({focus_set_chr})',
#'           ') |> ',
#'           'pivot_wider(names_from = Parameter1, values_from = r) |> ',
#'           'rename(variable = Parameter2)',
#'           .trim = FALSE
#'         ) |>
#'         as.character() |>
#'         stringr::str_remove_all("\n|  ")
#'
#'       grid_prep <-
#'         grid_prep |>
#'         dplyr::add_row(
#'           type = "corrs",
#'           group = paste0(var_set, "_focus"),
#'           code = corrs_focused
#'         )
#'     }
#'
#'     if(!is.null(data_attr)){
#'       grid_prep <- dplyr::bind_rows(.df, grid_prep)
#'     } else{
#'       grid_prep <- grid_prep
#'     }
#'
#'     attr(grid_prep, "base_df") <- data_chr
#'     grid_prep
#'   }
#'
#'
#' #' Add item reliabilities to a multiverse pipeline
#' #'
#' #' @description `r lifecycle::badge("deprecated")` This function has been
#' #' deprecated; please use [add_model_descriptives()] instead.
#' #'
#' #' @param .df the original \code{data.frame}(e.g., base data set). If part of
#' #'   set of add_* decision functions in a pipeline, the base data will be passed
#' #'   along as an attribute.
#' #' @param scale_name a character string. Indicates the name of the scale or
#' #'   measure measured by the items or indicators in \code{items}.
#' #' @param items the items (variables) that comprise a scale or measure. These
#' #'   variables will be passed to \code{link[performance]{cronbachs_alpha}},
#' #'   \code{link[performance]{item_intercor}}, and
#' #'   \code{link[performance]{item_reliability}}. You can also use tidyselect to
#' #'   select variables.
#' #'
#' #' @return a \code{data.frame}with three columns: type, group, and code. Type
#' #'   indicates the decision type, group is a decision, and the code is the
#' #'   actual code that will be executed. If part of a pipe, the current set of
#' #'   decisions will be appended as new rows.
#' #' @export
#' #'
#' #' @examples
#' #'
#' #' library(tidyverse)
#' #' library(multitool)
#' #'
#' #' the_data <-
#' #'   data.frame(
#' #'     id   = 1:500,
#' #'     iv1  = rnorm(500),
#' #'     iv2  = rnorm(500),
#' #'     iv3  = rnorm(500),
#' #'     mod1 = rnorm(500),
#' #'     mod2 = rnorm(500),
#' #'     mod3 = rnorm(500),
#' #'     cov1 = rnorm(500),
#' #'     cov2 = rnorm(500),
#' #'     dv1  = rnorm(500),
#' #'     dv2  = rnorm(500),
#' #'     include1 = rbinom(500, size = 1, prob = .1),
#' #'     include2 = sample(1:3, size = 500, replace = TRUE),
#' #'     include3 = rnorm(500)
#' #'   )
#' #'
#' #' the_data |>
#' #'   add_filters(include1 == 0,include2 != 3,include2 != 2, include3 > -2.5) |>
#' #'   add_variables("ivs", iv1, iv2, iv3) |>
#' #'   add_variables("dvs", dv1, dv2) |>
#' #'   add_variables("mods", starts_with("mod")) |>
#' #'   add_reliabilities("unp_scale", c(iv1,iv2,iv3))
#' add_reliabilities <- function(.df, scale_name, items){
#'
#'   data_chr <- dplyr::enexpr(.df) |> as.character()
#'   data_attr <- attr(.df, "base_df")
#'
#'   if(!is.null(data_attr)){
#'     data_chr <- attr(.df, "base_df")
#'   }
#'
#'   base_df <-
#'     rlang::parse_expr(data_chr) |>
#'     rlang::eval_tidy(env = parent.frame())
#'
#'   items <- dplyr::enexprs(items) |> as.character()
#'
#'   items_alpha <-
#'     glue::glue(
#'       'select({items}) |> cronbachs_alpha()'
#'     ) |>
#'     as.character() |>
#'     stringr::str_remove_all("\n|  ")
#'
#'   items_avg_intercorr <-
#'     glue::glue(
#'       'select({items}) |> item_intercor()'
#'     ) |>
#'     as.character() |>
#'     stringr::str_remove_all("\n|  ")
#'
#'   items_alpha_if_dropped <-
#'     glue::glue(
#'       'select({items}) |> item_reliability()'
#'     ) |>
#'     as.character() |>
#'     stringr::str_remove_all("\n|  ")
#'
#'   grid_prep <-
#'     tibble::tibble(
#'       type  = "reliabilities",
#'       group = paste0(scale_name,c("_alpha", "_inter_corr","_if_dropped")),
#'       code  = c(items_alpha, items_avg_intercorr, items_alpha_if_dropped)
#'     )
#'
#'   if(!is.null(data_attr)){
#'     grid_prep <- dplyr::bind_rows(.df, grid_prep)
#'   } else{
#'     grid_prep <- grid_prep
#'   }
#'
#'   attr(grid_prep, "base_df") <- data_chr
#'   grid_prep
#'
#' }
#'
#' show_code_summary_stats <- function(.grid, decision_num, summary_set = 1, copy = FALSE, console = TRUE, execute = FALSE, ...){
#'
#'   code <-
#'     run_universe_summary_stats(.grid, decision_num, run = FALSE)
#'
#'   if(is.null(code)){
#'     rlang::warn("You don't have any summary statistics specified in your pipeline...")
#'   } else{
#'     if(copy){
#'       suppressWarnings({clipr::write_clip(code[[summary_set]])})
#'       message("Summary stats pipeline copied!")
#'     }
#'     if(console){
#'       message("Showing summary stats set ", summary_set, " of ",  " labeled '", names(code)[[summary_set]], "'")
#'       message("Use the `summary_set` argument to see a different set of summary statistics")
#'       message("Hit enter to run the code:")
#'       rstudioapi::sendToConsole(code[[summary_set]], execute, ...)
#'     } else{
#'       message("Showing summary stats set ", summary_set, " of ",  " labeled '", names(code)[[summary_set]], "'")
#'       message("Use the `summary_set` argument to see a different set of summary statistics")
#'       cat(code[[summary_set]])
#'     }
#'   }
#' }
#'
#' show_code_corrs <- function(.grid, decision_num, corr_set = 1, copy = FALSE, console = TRUE, execute = FALSE, ...){
#'
#'   code <-
#'     run_universe_corrs(.grid, decision_num, run = FALSE)
#'
#'   if(is.null(code)){
#'     rlang::warn("You don't have any correlations specified in your pipeline...")
#'   } else{
#'     if(copy){
#'       suppressWarnings({clipr::write_clip(code[[corr_set]])})
#'       message("Correlation pipeline copied!")
#'     }
#'     if(console){
#'       message("Showing correlation set ", corr_set, " of ", length(code),  " labeled '", names(code)[[corr_set]], "'")
#'       message("Use the `corr_set` argument to see a different set of correlations")
#'       message("Hit enter to run the code:")
#'       rstudioapi::sendToConsole(code[[corr_set]], execute, ...)
#'     } else{
#'       message("Showing correlation set ", corr_set, " of ", length(code),  " labeled '", names(code)[[corr_set]], "'")
#'       message("Use the `corr_set` argument to see a different set of correlations")
#'       cat(code[[corr_set]])
#'     }
#'   }
#' }
#'
#' show_code_reliabilities <- function(.grid, decision_num, rel_set = 1, copy = FALSE, console = TRUE, execute = FALSE, ...){
#'
#'   code <-
#'     run_universe_reliabilities(.grid, decision_num, run = FALSE)
#'
#'   if(is.null(code)){
#'     rlang::warn("You don't have any reliabilities specified in your pipeline...")
#'   } else{
#'     if(copy){
#'       suppressWarnings({clipr::write_clip(code[[rel_set]])})
#'       message("Reliability pipeline copied!")
#'     }
#'     if(console){
#'       message("Showing reliability set ", rel_set, " of ", length(code),  " labeled '", names(code)[[rel_set]], "'")
#'       message("Use the `rel_set` argument to see a different set of reliabilities")
#'       message("Hit enter to run the code:")
#'       rstudioapi::sendToConsole(code[[rel_set]], execute, ...)
#'     } else{
#'       message("Showing reliability set ", rel_set, " of ", length(code),  " labeled '", names(code)[[rel_set]], "'")
#'       message("Use the `rel_set` argument to see a different set of reliabilities")
#'       cat(code[[rel_set]])
#'     }
#'   }
#' }
#'
#' run_descriptives <- function(.grid, show_progress = TRUE){
#'
#'   pipeline <-
#'     attr(.grid, "pipeline") |>
#'     rlang::eval_tidy(env = parent.frame())
#'
#'   filter_grid <-
#'     pipeline |>
#'     dplyr::filter(stringr::str_detect(type, "subgroups|filters|corrs|summary_stats|reliabilities")) |>
#'     expand_decisions()
#'
#'   multi_descriptives <-
#'     purrr::map(
#'       seq_len(nrow(filter_grid)),
#'       .progress = TRUE,
#'       function(x){
#'         multi_results <- list()
#'
#'         if("corrs" %in% names(filter_grid)){
#'           multi_results$corrs <-
#'             run_universe_corrs(
#'               .grid = filter_grid,
#'               decision_num =  filter_grid$decision[x]
#'             )
#'         }
#'
#'         if("summary_stats" %in% names(filter_grid)){
#'           multi_results$stats <-
#'             run_universe_summary_stats(
#'               .grid = filter_grid,
#'               decision_num = filter_grid$decision[x]
#'             )
#'         }
#'
#'         if("reliabilities" %in% names(filter_grid)){
#'           multi_results$reliabilities <-
#'             run_universe_reliabilities(
#'               .grid = filter_grid,
#'               decision_num = filter_grid$decision[x]
#'             )
#'         }
#'
#'         purrr::reduce(multi_results, dplyr::left_join, by = "decision")
#'
#'       }) |>
#'     purrr::list_rbind()
#'
#'   dplyr::full_join(
#'     filter_grid |>
#'       dplyr::select(-dplyr::contains("code")) |>
#'       mutate(decision = as.character(decision)),
#'     multi_descriptives,
#'     by = "decision"
#'   ) |>
#'     tidyr::nest(specifications = c(-decision, -dplyr::matches("fitted$|computed$"))) |>
#'     dplyr::select(decision, specifications, dplyr::everything())
#'
#' }
#'
#'
#' #' Reveal the contents of a multiverse analysis
#' #'
#' #' @description `r lifecycle::badge("deprecated")` This function has been
#' #' deprecated; please use [unpack_results()] instead.
#' #'
#' #' @param .multi a multiverse list-column \code{tibble} produced by
#' #'   \code{\link{run_multiverse}}.
#' #' @param .what the name of a list-column you would like to unpack
#' #' @param .which any sub-list columns you would like to unpack
#' #' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#' #'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#' #'   \code{wide} unnests specifications with each specification category as a
#' #'   column. \code{"long"} unnests specifications and stacks them into long
#' #'   format, which stacks specifications into a \code{decision_set} and
#' #'   \code{alternatives} columns. This is mainly useful for plotting.
#' #'
#' #' @return the unnested part of the multiverse requested. This usually contains
#' #'   the particular estimates or statistics you would like to analyze over the
#' #'   decision grid specified.
#' #' @export
#' #'
#' #' @examples
#' #'
#' #' library(tidyverse)
#' #' library(multitool)
#' #'
#' #' # Simulate some data
#' #' the_data <-
#' #'   data.frame(
#' #'     id   = 1:500,
#' #'     iv1  = rnorm(500),
#' #'     iv2  = rnorm(500),
#' #'     iv3  = rnorm(500),
#' #'     mod1 = rnorm(500),
#' #'     mod2 = rnorm(500),
#' #'     mod3 = rnorm(500),
#' #'     cov1 = rnorm(500),
#' #'     cov2 = rnorm(500),
#' #'     dv1  = rnorm(500),
#' #'     dv2  = rnorm(500),
#' #'     include1 = rbinom(500, size = 1, prob = .1),
#' #'     include2 = sample(1:3, size = 500, replace = TRUE),
#' #'     include3 = rnorm(500)
#' #'   )
#' #'
#' #' # Decision pipeline
#' #' full_pipeline <-
#' #'   the_data |>
#' #'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#' #'   add_variables("ivs", iv1, iv2, iv3) |>
#' #'   add_variables("dvs", dv1, dv2) |>
#' #'   add_variables("mods", starts_with("mod")) |>
#' #'   add_model("linear_model", lm({dvs} ~ {ivs} * {mods} + cov1))
#' #'
#' #' pipeline_grid <- expand_decisions(full_pipeline)
#' #'
#' #' # Run the whole multiverse
#' #' the_multiverse <- analyze_grid(pipeline_grid[1:10,])
#' #'
#' #' # Reveal results of the linear model
#' #' the_multiverse |> reveal(model_fitted, model_parameters)
#' reveal <- function(.multi, .what, .which = NULL, .unpack_specs = "no"){
#'
#'   which_sublist <- dplyr::enexprs(.which) |> as.character()
#'   which_sublist <- which_sublist != "NULL"
#'
#'   unpacked <-
#'     .multi |>
#'     tidyr::unnest({{.what}})
#'
#'   if(which_sublist){
#'     unpacked <-
#'       unpacked |>
#'       tidyr::unnest({{.which}})
#'   }
#'
#'   if(.unpack_specs == "wide"){
#'     unpacked <-
#'       unpacked |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models")))
#'   }
#'
#'   if(.unpack_specs == "long"){
#'     unpacked_and_stacked <-
#'       unpacked |>
#'       dplyr::select(decision, specifications) |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models"))) |>
#'       dplyr::select(-dplyr::any_of("model")) |>
#'       dplyr::rename_with(~ stringr::str_remove(.x, "_.*"), dplyr::any_of("model_meta")) |>
#'       tidyr::pivot_longer(-decision, names_to = "decision_set", values_to = "alternatives")
#'
#'     print(unpacked_and_stacked)
#'
#'     unpacked <-
#'       dplyr::left_join(
#'         unpacked_and_stacked,
#'         unpacked |> dplyr::select(-specifications),
#'         dplyr::join_by(decision == decision)
#'       )
#'
#'   }
#'
#'   unpacked
#' }
#'
#' #' Reveal the model parameters of a multiverse analysis
#' #'
#' #' @description `r lifecycle::badge("deprecated")` This function has been
#' #' deprecated; please use [unpack_model_parameters()] instead.
#' #'
#' #' @param .multi a multiverse list-column \code{tibble} produced by
#' #'   \code{\link{run_multiverse}}.
#' #' @param effect_key character, if you added parameter keys to your pipeline,
#' #'   you can specify if you would like filter the parameters using one of your
#' #'   parameter keys. This is useful when different variables are being switched
#' #'   out across the multiverse but represent the same effect of interest.
#' #' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#' #'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#' #'   \code{wide} unnests specifications with each specification category as a
#' #'   column. \code{"long"} unnests specifications and stacks them into long
#' #'   format, which stacks specifications into a \code{decision_set} and
#' #'   \code{alternatives} columns. This is mainly useful for plotting.
#' #'
#' #' @return the unnested model paramerters from the multiverse.
#' #' @export
#' #'
#' #' @examples
#' #'
#' #' library(tidyverse)
#' #' library(multitool)
#' #'
#' #' # Simulate some data
#' #' the_data <-
#' #'   data.frame(
#' #'     id   = 1:500,
#' #'     iv1  = rnorm(500),
#' #'     iv2  = rnorm(500),
#' #'     iv3  = rnorm(500),
#' #'     mod1 = rnorm(500),
#' #'     mod2 = rnorm(500),
#' #'     mod3 = rnorm(500),
#' #'     cov1 = rnorm(500),
#' #'     cov2 = rnorm(500),
#' #'     dv1  = rnorm(500),
#' #'     dv2  = rnorm(500),
#' #'     include1 = rbinom(500, size = 1, prob = .1),
#' #'     include2 = sample(1:3, size = 500, replace = TRUE),
#' #'     include3 = rnorm(500)
#' #'   )
#' #'
#' #' # Decision pipeline
#' #' full_pipeline <-
#' #'   the_data |>
#' #'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#' #'   add_variables("ivs", iv1, iv2, iv3) |>
#' #'   add_variables("dvs", dv1, dv2) |>
#' #'   add_variables("mods", starts_with("mod")) |>
#' #'   add_model("linear_model", lm({dvs} ~ {ivs} * {mods} + cov1))
#' #'
#' #' pipeline_grid <- expand_decisions(full_pipeline)
#' #'
#' #' # Run the whole multiverse
#' #' the_multiverse <- run_multiverse(pipeline_grid[1:10,])
#' #'
#' #' # Reveal results of the linear model
#' #' the_multiverse |>
#' #'   reveal_model_parameters()
#' reveal_model_parameters <- function(.multi, effect_key = NULL, .unpack_specs = "no"){
#'   unpacked <-
#'     .multi |>
#'     tidyr::unnest(model_fitted) |>
#'     tidyr::unnest(model_parameters)
#'
#'   if(!is.null(effect_key)){
#'     unpacked <-
#'       unpacked |>
#'       dplyr::filter(stringr::str_detect(parameter_key, effect_key))
#'   }
#'
#'   if(.unpack_specs == "wide"){
#'     unpacked <-
#'       unpacked |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models")))
#'   }
#'
#'   if(.unpack_specs == "long"){
#'     unpacked_and_stacked <-
#'       unpacked |>
#'       dplyr::select(decision, specifications) |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models"))) |>
#'       dplyr::select(-model, -model_args) |>
#'       dplyr::rename(model = model_meta) |>
#'       tidyr::pivot_longer(
#'         -decision,
#'         names_to = "decision_set",
#'         values_to = "alternatives"
#'       )
#'
#'     unpacked <-
#'       dplyr::left_join(
#'         unpacked_and_stacked,
#'         unpacked |> dplyr::select(-specifications),
#'         dplyr::join_by(decision == decision)
#'       )
#'
#'   }
#'
#'   unpacked
#' }
#'
#' #' Reveal the model performance/fit indices from a multiverse analysis
#' #'
#' #' @description `r lifecycle::badge("deprecated")` This function has been
#' #' deprecated; please use [unpack_model_performance()] instead.
#' #'
#' #' @param .multi a multiverse list-column \code{tibble} produced by
#' #'   \code{\link{run_multiverse}}.
#' #' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#' #'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#' #'   \code{wide} unnests specifications with each specification category as a
#' #'   column. \code{"long"} unnests specifications and stacks them into long
#' #'   format, which stacks specifications into a \code{decision_set} and
#' #'   \code{alternatives} columns. This is mainly useful for plotting.
#' #'
#' #' @return the unnested model performance/fit indices from a multiverse
#' #'   analysis.
#' #' @export
#' #'
#' #' @examples
#' #'
#' #' library(tidyverse)
#' #' library(multitool)
#' #'
#' #' # Simulate some data
#' #' the_data <-
#' #'   data.frame(
#' #'     id   = 1:500,
#' #'     iv1  = rnorm(500),
#' #'     iv2  = rnorm(500),
#' #'     iv3  = rnorm(500),
#' #'     mod1 = rnorm(500),
#' #'     mod2 = rnorm(500),
#' #'     mod3 = rnorm(500),
#' #'     cov1 = rnorm(500),
#' #'     cov2 = rnorm(500),
#' #'     dv1  = rnorm(500),
#' #'     dv2  = rnorm(500),
#' #'     include1 = rbinom(500, size = 1, prob = .1),
#' #'     include2 = sample(1:3, size = 500, replace = TRUE),
#' #'     include3 = rnorm(500)
#' #'   )
#' #'
#' #' # Decision pipeline
#' #' full_pipeline <-
#' #'   the_data |>
#' #'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#' #'   add_variables("ivs", iv1, iv2, iv3) |>
#' #'   add_variables("dvs", dv1, dv2) |>
#' #'   add_variables("mods", starts_with("mod")) |>
#' #'   add_model("linear_model", lm({dvs} ~ {ivs} * {mods} + cov1))
#' #'
#' #' pipeline_grid <- expand_decisions(full_pipeline)
#' #'
#' #' # Run the whole multiverse
#' #' the_multiverse <- run_multiverse(pipeline_grid[1:10,])
#' #'
#' #' # Reveal results of the linear model
#' #' the_multiverse |>
#' #'   reveal_model_performance()
#' reveal_model_performance <- function(.multi, .unpack_specs = "no"){
#'   unpacked <-
#'     .multi |>
#'     tidyr::unnest(model_fitted) |>
#'     tidyr::unnest(model_performance)
#'
#'   if(.unpack_specs == "wide"){
#'     unpacked <-
#'       unpacked |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models")))
#'   }
#'
#'   if(.unpack_specs == "long"){
#'     unpacked_and_stacked <-
#'       unpacked |>
#'       dplyr::select(decision, specifications) |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models"))) |>
#'       dplyr::select(-model, -model_args) |>
#'       dplyr::rename(model = model_meta) |>
#'       tidyr::pivot_longer(
#'         -decision,
#'         names_to = "decision_set",
#'         values_to = "alternatives"
#'       )
#'
#'     unpacked <-
#'       dplyr::left_join(
#'         unpacked_and_stacked,
#'         unpacked |> dplyr::select(-specifications),
#'         dplyr::join_by(decision == decision)
#'       )
#'   }
#'
#'   unpacked
#' }
#'
#' #' Reveal any warnings about your models during a multiverse analysis
#' #'
#' #' @description `r lifecycle::badge("deprecated")` This function has been
#' #' deprecated; please use [unpack_model_warnings()] instead.
#' #'
#' #' @param .multi a multiverse list-column \code{tibble} produced by
#' #'   \code{\link{run_multiverse}}.
#' #' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#' #'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#' #'   \code{wide} unnests specifications with each specification category as a
#' #'   column. \code{"long"} unnests specifications and stacks them into long
#' #'   format, which stacks specifications into a \code{decision_set} and
#' #'   \code{alternatives} columns. This is mainly useful for plotting.
#' #'
#' #' @return the unnested model warnings captured during analysis
#' #' @export
#' #'
#' #' @examples
#' #'
#' #' library(tidyverse)
#' #' library(multitool)
#' #'
#' #' # Simulate some data
#' #' the_data <-
#' #'   data.frame(
#' #'     id   = 1:500,
#' #'     iv1  = rnorm(500),
#' #'     iv2  = rnorm(500),
#' #'     iv3  = rnorm(500),
#' #'     mod1 = rnorm(500),
#' #'     mod2 = rnorm(500),
#' #'     mod3 = rnorm(500),
#' #'     cov1 = rnorm(500),
#' #'     cov2 = rnorm(500),
#' #'     dv1  = rnorm(500),
#' #'     dv2  = rnorm(500),
#' #'     include1 = rbinom(500, size = 1, prob = .1),
#' #'     include2 = sample(1:3, size = 500, replace = TRUE),
#' #'     include3 = rnorm(500)
#' #'   )
#' #'
#' #' # Decision pipeline
#' #' full_pipeline <-
#' #'   the_data |>
#' #'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#' #'   add_variables("ivs", iv1, iv2, iv3) |>
#' #'   add_variables("dvs", dv1, dv2) |>
#' #'   add_variables("mods", starts_with("mod")) |>
#' #'   add_model("linear_model", lm({dvs} ~ {ivs} * {mods} + cov1))
#' #'
#' #' pipeline_grid <- expand_decisions(full_pipeline)
#' #'
#' #' # Run the whole multiverse
#' #' the_multiverse <- run_multiverse(pipeline_grid[1:10,])
#' #'
#' #' # Reveal results of the linear model
#' #' the_multiverse |>
#' #'   reveal_model_warnings()
#' reveal_model_warnings <- function(.multi, .unpack_specs = "no"){
#'   unpacked <-
#'     .multi |>
#'     tidyr::unnest(model_fitted) |>
#'     tidyr::unnest(model_warnings)
#'
#'   if(.unpack_specs == "wide"){
#'     unpacked <-
#'       unpacked |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::everything())
#'   }
#'
#'   if(.unpack_specs == "long"){
#'     unpacked_and_stacked <-
#'       unpacked |>
#'       dplyr::select(decision, specifications) |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models"))) |>
#'       dplyr::select(-model, -model_args) |>
#'       dplyr::rename(model = model_meta) |>
#'       tidyr::pivot_longer(
#'         -decision,
#'         names_to = "decision_set",
#'         values_to = "alternatives"
#'       )
#'
#'     unpacked <-
#'       dplyr::left_join(
#'         unpacked_and_stacked,
#'         unpacked |> dplyr::select(-specifications),
#'         dplyr::join_by(decision == decision)
#'       )
#'
#'   }
#'
#'   unpacked
#' }
#'
#' #' Reveal any messages about your models during a multiverse analysis
#' #'
#' #' @description `r lifecycle::badge("deprecated")` This function has been
#' #' deprecated; please use [unpack_model_messages()] instead.
#' #'
#' #' @param .multi a multiverse list-column \code{tibble} produced by
#' #'   \code{\link{run_multiverse}}.
#' #' @param .unpack_specs character, options are \code{"no"}, \code{"wide"}, or
#' #'   \code{"long"}. \code{"no"} (default) keeps specifications in a list column,
#' #'   \code{wide} unnests specifications with each specification category as a
#' #'   column. \code{"long"} unnests specifications and stacks them into long
#' #'   format, which stacks specifications into a \code{decision_set} and
#' #'   \code{alternatives} columns. This is mainly useful for plotting.
#' #'
#' #' @return the unnested model messages captured during analysis.
#' #' @export
#' #'
#' #' @examples
#' #'
#' #' library(tidyverse)
#' #' library(multitool)
#' #'
#' #' # Simulate some data
#' #' the_data <-
#' #'   data.frame(
#' #'     id   = 1:500,
#' #'     iv1  = rnorm(500),
#' #'     iv2  = rnorm(500),
#' #'     iv3  = rnorm(500),
#' #'     mod1 = rnorm(500),
#' #'     mod2 = rnorm(500),
#' #'     mod3 = rnorm(500),
#' #'     cov1 = rnorm(500),
#' #'     cov2 = rnorm(500),
#' #'     dv1  = rnorm(500),
#' #'     dv2  = rnorm(500),
#' #'     include1 = rbinom(500, size = 1, prob = .1),
#' #'     include2 = sample(1:3, size = 500, replace = TRUE),
#' #'     include3 = rnorm(500)
#' #'   )
#' #'
#' #' # Decision pipeline
#' #' full_pipeline <-
#' #'   the_data |>
#' #'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#' #'   add_variables("ivs", iv1, iv2, iv3) |>
#' #'   add_variables("dvs", dv1, dv2) |>
#' #'   add_variables("mods", starts_with("mod")) |>
#' #'   add_model("linear_model", lm({dvs} ~ {ivs} * {mods} + cov1))
#' #'
#' #' pipeline_grid <- expand_decisions(full_pipeline)
#' #'
#' #' # Run the whole multiverse
#' #' the_multiverse <- run_multiverse(pipeline_grid[1:10,])
#' #'
#' #' # Reveal results of the linear model
#' #' the_multiverse |>
#' #'   reveal_model_messages()
#' reveal_model_messages <- function(.multi, .unpack_specs = "no"){
#'   unpacked <-
#'     .multi |>
#'     tidyr::unnest(model_fitted) |>
#'     tidyr::unnest(model_messages)
#'
#'   if(.unpack_specs == "wide"){
#'     unpacked <-
#'       unpacked |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::everything())
#'   }
#'
#'   if(.unpack_specs == "long"){
#'     unpacked_and_stacked <-
#'       unpacked |>
#'       dplyr::select(decision, specifications) |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models"))) |>
#'       dplyr::select(-model, -model_args) |>
#'       dplyr::rename(model = model_meta) |>
#'       tidyr::pivot_longer(
#'         -decision,
#'         names_to = "decision_set",
#'         values_to = "alternatives"
#'       )
#'
#'     unpacked <-
#'       dplyr::left_join(
#'         unpacked_and_stacked,
#'         unpacked |> dplyr::select(-specifications),
#'         dplyr::join_by(decision == decision)
#'       )
#'
#'   }
#'
#'   unpacked
#' }
#'
#' reveal_summary_stats <- function(.descriptives, .which, .unpack_specs = "no"){
#'   which_sublist <- dplyr::enexprs(.which) |> as.character()
#'   which_sublist <- which_sublist != "NULL"
#'
#'   unpacked <-
#'     .descriptives |>
#'     tidyr::unnest(summary_stats_computed) |>
#'     tidyr::unnest({{.which}})
#'
#'   if(.unpack_specs == "wide"){
#'     unpacked <-
#'       unpacked |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models")))
#'   }
#'
#'   if(.unpack_specs == "long"){
#'     unpacked_and_stacked <-
#'       unpacked |>
#'       dplyr::select(decision, specifications) |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models"))) |>
#'       dplyr::select(-dplyr::any_of("model")) |>
#'       dplyr::rename_with(~ stringr::str_remove(.x, "_.*"), dplyr::any_of("model_meta")) |>
#'       tidyr::pivot_longer(-decision, names_to = "decision_set", values_to = "alternatives")
#'
#'     unpacked <-
#'       dplyr::left_join(
#'         unpacked_and_stacked,
#'         unpacked |> dplyr::select(-specifications),
#'         dplyr::join_by(decision == decision)
#'       )
#'
#'   }
#'
#'   unpacked
#' }
#'
#' reveal_corrs <- function(.descriptives, .which, .unpack_specs = "no"){
#'   which_sublist <- dplyr::enexprs(.which) |> as.character()
#'   which_sublist <- which_sublist != "NULL"
#'
#'   unpacked <-
#'     .descriptives |>
#'     tidyr::unnest(corrs_computed) |>
#'     tidyr::unnest({{.which}})
#'
#'   if(.unpack_specs == "wide"){
#'     unpacked <-
#'       unpacked |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models")))
#'   }
#'
#'   if(.unpack_specs == "long"){
#'     unpacked_and_stacked <-
#'       unpacked |>
#'       dplyr::select(decision, specifications) |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models"))) |>
#'       dplyr::select(-dplyr::any_of("model")) |>
#'       dplyr::rename_with(~ stringr::str_remove(.x, "_.*"), dplyr::any_of("model_meta")) |>
#'       tidyr::pivot_longer(-decision, names_to = "decision_set", values_to = "alternatives")
#'
#'     unpacked <-
#'       dplyr::left_join(
#'         unpacked_and_stacked,
#'         unpacked |> dplyr::select(-specifications),
#'         dplyr::join_by(decision == decision)
#'       )
#'
#'   }
#'
#'   unpacked
#' }
#'
#' reveal_reliabilities <- function(.descriptives, .which, .unpack_specs = "no"){
#'   which_sublist <- dplyr::enexprs(.which) |> as.character()
#'   which_sublist <- which_sublist != "NULL"
#'
#'   unpacked <-
#'     .descriptives |>
#'     tidyr::unnest(reliabilities_computed) |>
#'     tidyr::unnest({{.which}})
#'
#'   if(.unpack_specs == "wide"){
#'     unpacked <-
#'       unpacked |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models")))
#'   }
#'
#'   if(.unpack_specs == "long"){
#'     unpacked_and_stacked <-
#'       unpacked |>
#'       dplyr::select(decision, specifications) |>
#'       tidyr::unnest(specifications) |>
#'       dplyr::select(
#'         -dplyr::any_of(
#'           c("preprocess","postprocess","corrs","summary_stats","reliabilities"))
#'       ) |>
#'       tidyr::unnest(dplyr::any_of(c("subgroups","variables","filters","models"))) |>
#'       dplyr::select(-dplyr::any_of("model")) |>
#'       dplyr::rename_with(~ stringr::str_remove(.x, "_.*"), dplyr::any_of("model_meta")) |>
#'       tidyr::pivot_longer(-decision, names_to = "decision_set", values_to = "alternatives")
#'
#'     unpacked <-
#'       dplyr::left_join(
#'         unpacked_and_stacked,
#'         unpacked |> dplyr::select(-specifications),
#'         dplyr::join_by(decision == decision)
#'       )
#'
#'   }
#'
#'   unpacked
#' }
#' #' Run a multiverse based on a complete decision grid
#' #'
#' #' @description `r lifecycle::badge("superseded")` `run_multiverse()`
#' #'   will still work  but I recommend using `analyze_grid()` instead,
#' #'   which is much faster especially with larger decision grids.
#' #'
#' #' @param .grid a \code{tibble} produced by \code{\link{expand_decisions}}
#' #' @param add_standardized logical. Whether to add standardized coefficients to
#' #'   the model output. Defaults to \code{TRUE}.
#' #' @param save_model logical, indicates whether to save the model object in its
#' #'   entirety. The default is \code{FALSE} because model objects are usually
#' #'   large and under the hood, \code{\link[parameters]{parameters}} and
#' #'   \code{\link[performance]{performance}} is used to summarize the most useful
#' #'   model information.
#' #' @param show_progress logical, whether to show a progress bar while running.
#' #'
#' #' @return a single \code{tibble} containing tidied results for the model and
#' #'   any post-processing tests/tasks. For each unique test (e.g., an \code{lm}
#' #'   or \code{aov} called on an \code{lm}), a list column with the function name
#' #'   is created with \code{\link[parameters]{parameters}} and
#' #'   \code{\link[performance]{performance}} and any warnings or messages printed
#' #'   while fitting the models. Internally, modeling and post-processing
#' #'   functions are checked to see if there are tidy or glance methods available.
#' #'   If not, \code{summary} will be called instead.
#' #' @export
#' #'
#' #' @examples
#' #' library(tidyverse)
#' #' library(multitool)
#' #'
#' #' # Simulate some data
#' #' the_data <-
#' #'   data.frame(
#' #'     id   = 1:500,
#' #'     iv1  = rnorm(500),
#' #'     iv2  = rnorm(500),
#' #'     iv3  = rnorm(500),
#' #'     mod1 = rnorm(500),
#' #'     mod2 = rnorm(500),
#' #'     mod3 = rnorm(500),
#' #'     cov1 = rnorm(500),
#' #'     cov2 = rnorm(500),
#' #'     dv1  = rnorm(500),
#' #'     dv2  = rnorm(500),
#' #'     include1 = rbinom(500, size = 1, prob = .1),
#' #'     include2 = sample(1:3, size = 500, replace = TRUE),
#' #'     include3 = rnorm(500)
#' #'   )
#' #'
#' #' # Decision pipeline
#' #' full_pipeline <-
#' #'   the_data |>
#' #'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#' #'   add_variables("ivs", iv1, iv2, iv3) |>
#' #'   add_variables("dvs", dv1, dv2) |>
#' #'   add_variables("mods", starts_with("mod")) |>
#' #'   add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#' #'   add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
#' #'   add_model("no covariates",lm({dvs} ~ {ivs} * {mods})) |>
#' #'   add_model("covariate", lm({dvs} ~ {ivs} * {mods} + cov1)) |>
#' #'   add_postprocess("aov", aov())
#' #'
#' #' pipeline_grid <- expand_decisions(full_pipeline)
#' #'
#' #' # Run the whole multiverse
#' #' the_multiverse <- run_multiverse(pipeline_grid[1:10,])
#' run_multiverse <- function(.grid, add_standardized = TRUE, save_model = FALSE, show_progress = TRUE){
#'
#'   multiverse <-
#'     purrr::map(
#'       seq_len(nrow(.grid)),
#'       .progress = show_progress,
#'       function(x){
#'         multi_results <- list()
#'
#'         if("models" %in% names(.grid)){
#'           multi_results$models <-
#'             run_universe_model(
#'               .grid = .grid,
#'               decision_num = .grid$decision[x],
#'               add_standardized = add_standardized,
#'               save_model = save_model
#'             )
#'         }
#'         purrr::reduce(multi_results, dplyr::left_join, by = "decision")
#'       }) |>
#'     purrr::list_rbind()
#'
#'   dplyr::full_join(
#'     .grid |>
#'       dplyr::select(-dplyr::contains("code")) |>
#'       mutate(decision = as.character(decision)),
#'     multiverse,
#'     by = "decision"
#'   ) |>
#'     dplyr::select(-dplyr::matches("^parameter_keys$")) |>
#'     tidyr::nest(specifications = c(-decision, -dplyr::matches("fitted$|computed$|code$"))) |>
#'     dplyr::select(decision, specifications, dplyr::everything())
#' }
#'
#' #' Run a multi-core, multiverse based on a complete decision grid
#' #'
#' #' @description `r lifecycle::badge("superseded")` `run_multiverse_furr()` will
#' #'   still work  but I recommend using `analyze_grid()` or
#' #'   `analyze_grid_parallel()` instead, which are much faster especially with
#' #'   larger decision grids.
#' #'
#' #' @param .grid a \code{tibble} produced by \code{\link{expand_decisions}}
#' #' @param add_standardized logical. Whether to add standardized coefficients to
#' #'   the model output. Defaults to \code{TRUE}.
#' #' @param save_model logical, indicates whether to save the model object in its
#' #'   entirety. The default is \code{FALSE} because model objects are usually
#' #'   large and under the hood, \code{\link[parameters]{parameters}} and
#' #'   \code{\link[performance]{performance}} is used to summarize the most useful
#' #'   model information.
#' #' @param show_progress logical, whether to show a progress bar while running.
#' #' @param furrr_globals any global objects to pass to \code{furrr_options}
#' #' @param furrr_packages character vector, any packages to load inside parallel
#' #'   environments
#' #'
#' #' @return a single \code{tibble} containing tidied results for the model and
#' #'   any post-processing tests/tasks. For each unique test (e.g., an \code{lm}
#' #'   or \code{aov} called on an \code{lm}), a list column with the function name
#' #'   is created with \code{\link[parameters]{parameters}} and
#' #'   \code{\link[performance]{performance}} and any warnings or messages printed
#' #'   while fitting the models. Internally, modeling and post-processing
#' #'   functions are checked to see if there are tidy or glance methods available.
#' #'   If not, \code{summary} will be called instead.
#' #' @export
#' #'
#' #' @examples
#' #' library(tidyverse)
#' #' library(multitool)
#' #' library(furrr)
#' #'
#' #' # Simulate some data
#' #' the_data <-
#' #'   data.frame(
#' #'     id   = 1:500,
#' #'     iv1  = rnorm(500),
#' #'     iv2  = rnorm(500),
#' #'     iv3  = rnorm(500),
#' #'     mod1 = rnorm(500),
#' #'     mod2 = rnorm(500),
#' #'     mod3 = rnorm(500),
#' #'     cov1 = rnorm(500),
#' #'     cov2 = rnorm(500),
#' #'     dv1  = rnorm(500),
#' #'     dv2  = rnorm(500),
#' #'     include1 = rbinom(500, size = 1, prob = .1),
#' #'     include2 = sample(1:3, size = 500, replace = TRUE),
#' #'     include3 = rnorm(500)
#' #'   )
#' #'
#' #' # Decision pipeline
#' #' full_pipeline <-
#' #'   the_data |>
#' #'   add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
#' #'   add_variables("ivs", iv1, iv2, iv3) |>
#' #'   add_variables("dvs", dv1, dv2) |>
#' #'   add_variables("mods", starts_with("mod")) |>
#' #'   add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
#' #'   add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
#' #'   add_model("no covariates",lm({dvs} ~ {ivs} * {mods})) |>
#' #'   add_model("covariate", lm({dvs} ~ {ivs} * {mods} + cov1)) |>
#' #'   add_postprocess("aov", aov())
#' #'
#' #' pipeline_grid <- expand_decisions(full_pipeline)
#' #'
#' #' # Run the whole multiverse
#' #' plan(multisession, workers = 4)
#' #' the_multiverse <- run_multiverse_furrr(pipeline_grid[4,])
#' #' plan(sequential)
#' run_multiverse_furrr <-
#'   function(
#'     .grid,
#'     add_standardized = TRUE,
#'     save_model = FALSE,
#'     show_progress = TRUE,
#'     furrr_globals = NULL,
#'     furrr_packages = c("multitool", "dplyr", "tidyr")
#'   ){
#'
#'     data_chr <- attr(.grid, "base_df")
#'     grid_chr <- dplyr::enexpr(.grid) |> as.character()
#'
#'     opts <-
#'       furrr::furrr_options(
#'         globals = c(data_chr, furrr_globals),
#'         packages = furrr_packages
#'       )
#'
#'     multiverse <-
#'       furrr::future_map(
#'         .options = opts,
#'         seq_len(nrow(.grid)),
#'         .progress = show_progress,
#'         function(x){
#'           multi_results <- list()
#'
#'           if("models" %in% names(.grid)){
#'             multi_results$models <-
#'               run_universe_model(
#'                 .grid = .grid,
#'                 decision_num = .grid$decision[x],
#'                 add_standardized = add_standardized,
#'                 save_model = save_model
#'               )
#'           }
#'           purrr::reduce(multi_results, dplyr::left_join, by = "decision")
#'         }) |>
#'       purrr::list_rbind()
#'
#'     dplyr::full_join(
#'       .grid |>
#'         dplyr::select(-dplyr::contains("code")) |>
#'         mutate(decision = as.character(decision)),
#'       multiverse,
#'       by = "decision"
#'     ) |>
#'       dplyr::select(-dplyr::matches("^parameter_keys$")) |>
#'       tidyr::nest(specifications = c(-decision, -dplyr::matches("fitted$|computed$|code$"))) |>
#'       dplyr::select(decision, specifications, dplyr::everything())
#'   }
#'show_result <-
#'  function(
#'    .multi,
#'    decision_num,
#'    type = "parameters",
#'    ...,
#'    .print_specs = TRUE
#'  ){
#'    results_slice <-
#'      .multi |>
#'      dplyr::filter(decision == decision_num)
#'
#'    if(type == "parameters"){
#'      result <-
#'        results_slice |>
#'        unpack_model_parameters(..., .unpack_specs = "no")
#'    }
#'
#'    if(type == "performance"){
#'      result <-
#'        results_slice |>
#'        unpack_model_performance(..., .unpack_specs = "no")
#'    }
#'
#'    if(type == "post_process"){
#'      result <-
#'        results_slice |>
#'        unpack_postprocess(..., .unpack_specs = "no")
#'    }
#'
#'    specs <-
#'      .multi |>
#'      unpack_specs(.how = "long") |>
#'      dplyr::select(dplyr::where(~!is.list(.x))) |>
#'      dplyr::mutate(
#'        n_dis = dplyr::n_distinct(decision_choice),
#'        .by = decision_set
#'      ) |>
#'      dplyr::filter(decision == 1, n_dis > 1) |>
#'      dplyr::transmute(
#'        decision,
#'        print_out = glue::glue("{decision_set}: {decision_choice} ({decision_type})")
#'      ) |>
#'      tidyr::pivot_longer(
#'        dplyr::everything(),
#'        values_transform = as.character
#'      ) |>
#'      dplyr::distinct() |>
#'      glue::glue_data(
#'        "{ifelse(name == 'decision', 'Decision: ', '')}{value}",
#'        .trim = FALSE
#'      )
#'
#'    if(print_specs){
#'      print(specs)
#'    }
#'    result
#'
#'  }
