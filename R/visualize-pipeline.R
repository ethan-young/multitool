#' Create a Analysis Pipeline diagram
#'
#' @param .pipeline a \code{data.frame} produced by calling a series of add_*
#'   functions.
#' @param splines options for how to draw edges (lines) for a grViz diagram
#' @param render whether to render the graph or just output grViz code
#' @param show_code whether to show the code that generated the diagram
#' @param ... additional options passed to \code{DiagrammeR::grViz()}
#'
#' @return grViz graph of your pipeline
#' @export
#'
#' @examples
#' library(tidyverse)
#' library(multitool)
#'
#' # create some data
#' the_data <-
#'   data.frame(
#'     id  = 1:500,
#'     iv1 = rnorm(500),
#'     iv2 = rnorm(500),
#'     iv3 = rnorm(500),
#'     mod = rnorm(500),
#'     dv1 = rnorm(500),
#'     dv2 = rnorm(500),
#'     include1 = rbinom(500, size = 1, prob = .1),
#'     include2 = sample(1:3, size = 500, replace = TRUE),
#'     include3 = rnorm(500)
#'   )
#'
#' # create a pipeline blueprint
#' full_pipeline <-
#'   the_data |>
#'   add_filters(include1 == 0, include2 != 3, scale(include3) > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' create_blueprint_graph(full_pipeline)
create_blueprint_graph <- function(.pipeline, splines = "line", render = TRUE, show_code = FALSE, ...){

  decision_types <-
    .pipeline |> dplyr::pull(type) |> unique()

  grid_ndf <- create_pipeline_ndf(.pipeline)

  possible_edges <-
    tribble(
      ~my_from,        ~my_to,
      "base_df",       "filters",
      "base_df",       "variables",
      "variables_set", "variables",
      "filters",       "filters_set",
      "variables",     "total_dfs",
      "filters",       "total_dfs",
      "total_dfs",     "preprocess",
      "filters_set",   "cron_alphas",
      "filters_set",   "summary_stats",
      "filters_set",   "corrs",
      "total_models",  "postprocess"
    )

  if(grid_ndf |> dplyr::filter(stringr::str_detect(nodes,"model_\\d")) |> nrow() > 0){

    model_from <-
      grid_ndf |>
      dplyr::filter(stringr::str_detect(nodes,"model_\\d")) |>
      dplyr::transmute(
        my_from = ifelse("preprocess" %in% unique(grid_ndf$nodes), "preprocess", "total_dfs"),
        my_to = nodes
      )

    model_to <-
      grid_ndf |>
      dplyr::filter(stringr::str_detect(nodes,"model_\\d")) |>
      dplyr::transmute(
        my_from = nodes,
        my_to = "total_models"
      )

    possible_edges <-
      dplyr::bind_rows(
        possible_edges,
        model_from,
        model_to
      )
  }

  # if(!"preprocess" %in% unique(grid_ndf$nodes)){
  #   possible_edges <-
  #     possible_edges |>
  #     dplyr::add_row(my_from = c("variables","filters"), my_to = c("total_dfs","total_dfs"))
  # }

  pipeline_edges <-
    possible_edges |>
    dplyr::left_join(
      grid_ndf |> dplyr::select(nodes, id),
      by = c("my_from" = "nodes")
    ) |>
    dplyr::rename(from = id) |>
    dplyr::left_join(
      grid_ndf |> dplyr::select(nodes, id),
      by = c("my_to" = "nodes")
    ) |>
    dplyr::rename(to = id) |>
    tidyr::drop_na() |>
    as.data.frame()

  a_graph <-
    DiagrammeR::create_graph() |>
    DiagrammeR::add_node_df(grid_ndf)

  if("filters" %in% decision_types & "variables" %in% decision_types){
    invis_nodes <-
      a_graph |>
      DiagrammeR::select_nodes(conditions = stringr::str_detect(nodes, "filters|variables")) |>
      DiagrammeR::get_node_df_ws() |>
      dplyr::mutate(
        new_order = dplyr::case_when(nodes == "variables_set" ~ 1,
                                     nodes == "variables" ~ 2,
                                     nodes == "filters" ~ 3,
                                     nodes == "filters_set" ~ 4)
      ) |>
      dplyr::arrange(new_order) |>
      dplyr::pull(id)

    invis_edges <-
      invis_nodes |>
      tibble::tibble(
        v1 = _
      ) |>
      dplyr::mutate(
        v2 = dplyr::lead(v1)
      ) |>
      tidyr::drop_na() |>
      dplyr::rename(from = v1, to = v2) |>
      dplyr::mutate(
        color = "purple",
        style = "invis"
      )
  }

  the_graph <-
    a_graph |>
    DiagrammeR::add_edge_df(invis_edges) |>
    DiagrammeR::add_edge_df(pipeline_edges) |>
    DiagrammeR::add_global_graph_attrs("splines", splines, "graph") |>
    DiagrammeR::add_global_graph_attrs("layout", "dot", "graph") |>
    DiagrammeR::add_global_graph_attrs("overlap", "false", "graph") |>
    DiagrammeR::add_global_graph_attrs("fixedsize", "false", "node") |>
    DiagrammeR::add_global_graph_attrs("fontcolor", "black", "node") |>
    DiagrammeR::add_global_graph_attrs("color", "gray", "node") |>
    DiagrammeR::add_global_graph_attrs("shape", "rect", "node") |>
    DiagrammeR::add_global_graph_attrs("style", "rounded", "node") |>
    DiagrammeR::add_global_graph_attrs("margin", ".25, 0", "node") |>
    DiagrammeR::add_global_graph_attrs("tailport", "s", "edge") |>
    DiagrammeR::add_global_graph_attrs("headport", "n", "edge") |>
    DiagrammeR::add_global_graph_attrs("concentrate", "false", "edge") |>
    DiagrammeR::add_global_graph_attrs("constraint", "true", "edge") |>
    DiagrammeR::select_edges(my_to == "filters_set") |>
    DiagrammeR::set_edge_attrs_ws("arrowhead", "none") |>
    DiagrammeR::set_edge_attrs_ws("arrowtail", "none") |>
    DiagrammeR::set_edge_attrs_ws("style", "solid") |>
    DiagrammeR::set_edge_attrs_ws("headport", "w") |>
    DiagrammeR::set_edge_attrs_ws("tailport", "e") |>
    DiagrammeR::clear_selection() |>
    DiagrammeR::select_edges(my_from == "variables_set") |>
    DiagrammeR::set_edge_attrs_ws("arrowhead", "none") |>
    DiagrammeR::set_edge_attrs_ws("arrowtail", "none") |>
    DiagrammeR::set_edge_attrs_ws("style", "solid") |>
    DiagrammeR::set_edge_attrs_ws("headport", "w") |>
    DiagrammeR::set_edge_attrs_ws("tailport", "e") |>
    DiagrammeR::clear_selection()

  graph_text <-
    the_graph |>
    DiagrammeR::generate_dot() |>
    stringr::str_replace_all("(\\[label = '(.*)'\\])", "[label = <<BR/>\\2 >]") |>
    stringr::str_replace_all("( --\\| )", "<BR/><BR/>") |>
    stringr::str_replace_all("( -\\| )", "<BR/>") |>
    stringr::str_replace_all("( -- )", "<BR ALIGN='LEFT'/><BR ALIGN='LEFT'/>") |>
    stringr::str_replace_all("( - )", "<BR ALIGN='LEFT'/>") |>
    stringr::str_replace_all("( __ )", "</B>") |>
    stringr::str_replace_all("( _ )", "<B>")

  if(show_code){
    cat(graph_text)
  }

  if(render){
    DiagrammeR::grViz(graph_text, ...)
  }

}


