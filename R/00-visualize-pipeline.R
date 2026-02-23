#' Visualize an analysis pipeline workflow
#'
#' @param .pipeline a \code{data.frame} produced by calling a series of add_*
#'   functions.
#' @param layout the orientation of the diagram, can be "horizontal" or
#'   "vertical"
#' @param decision_details logical, whether to provide finer grained details
#'   pipeline decisions and their alternatives. Defaults to `FALSE`.
#' @param combinations_detail logical, whether to add details on how the
#'   analysis space expand given the cross products of pipeline steps and their
#'   alternatives. Defaults to `FALSE`.
#' @param text_sizing numeric. when not `NULL`, multiplies default text sizing
#'   to increase or decrease text sizing
#' @param node_space numeric. when not `NULL`, determines the spacing between
#'   the major nodes of the graph.
#' @param arrow_spacing numeric. when not `NULL`, determines the length of arrow
#'   segments between the nodes.
#' @param box_space numeric. when not `NULL`, determines the length of line
#'   segments between the nodes and their detail boxes.
#' @param h_space numeric vector of length 2. when not `NULL`, determines how
#'   much space to add horizontally to the graph. This is helpful when nodes
#'   and/or detail boxes overlap. The first number sets the left hand spacing
#'   and the second sets the right hand.
#' @param v_space numeric vector of length 2. when not `NULL`, determines how
#'   much space to add horizontally to the graph. This is helpful when nodes
#'   and/or detail boxes overlap. The first number sets the bottom spacing
#'   sizing and the second sets the top.
#'
#' @return ggplot2 object visualizing your analysis pipeline
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
#'   add_filters(include1 == 0, include2 != 3, include3 > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' visualize_pipeline(full_pipeline)
visualize_pipeline <-
  function(
    .pipeline,
    layout = "vertical",
    decision_details = FALSE,
    combinations_detail = FALSE,
    text_sizing = NULL,
    node_space = NULL,
    arrow_spacing = NULL,
    box_space = NULL,
    h_space = NULL,
    v_space = NULL
  ){

    is_pipeline <- is.null(attr(.pipeline, "pipeline"))

    curr_pipeline <-
      if(is_pipeline){
        .pipeline
      } else{
        attr(.pipeline, "pipeline")
      }

    operator_map <- c(
      "(.*)>="  = ">=",
      "(.*)<="  = "<=",
      "(.*)>"   = ">",
      "(.*)<"   = "<",
      "(.*)=="  = "=",
      "(.*)!="  = "!=",
      "(.*) %in% unique(.*)$" = "no filter"
    )

    stage_key <-
      tibble::tribble(
        ~stage,           ~type,
        "Select Variables", "variables",
        "Filter Observations", "subgroups",
        "Filter Observations", "filters",
        "Execute", "preprocess",
        "Execute", "models",
        "Execute", "postprocess"
      )

    verb_key <-
      c(
        "Build Dataset" = "using",
        "Setup Modeling" = "from",
        "Model Pipeline" = "by"
      )

    type_key <-
      c(
        "Define Subgroups" = "subgroups",
        "Apply Filters" = "filters",
        "Variables" = "variables",
        "Pre-process" = "preprocess",
        "Model" = "models",
        "Post-process" = "postprocess",
        "Effect of Interest" = "parameter_key"
      )

    alt_txt <-
      c(
        "subgroups" = "groups",
        "filters" = "alternatives",
        "variables" = "variables",
        "preprocess" = "steps",
        "models" = "model types",
        "postprocess" = "steps"
      )

    pipeline_raw <-
      curr_pipeline |>
      dplyr::select(type, group, code)

    pipeline_stages <-
      dplyr::inner_join(
        stage_key,
        pipeline_raw |> dplyr::filter(!stringr::str_detect(type, "process")),
        dplyr::join_by(type)
      ) |>
      dplyr::summarize(
        combinations = dplyr::n(),
        .by = c(stage, type, group)
      ) |>
      dplyr::summarize(
        stage = unique(stage),
        n_steps = dplyr::n_distinct(type),
        n_sets = dplyr::n_distinct(group),
        n_alts_txt = paste(combinations, collapse = "\\*"),
        n_alts_tot = unique(ifelse(type != "models", prod(combinations), sum(combinations))),
        .by = type
      ) |>
      dplyr::mutate(
        type = factor(type, type_key, names(type_key)),
        n_cumlative = cumprod(n_alts_tot),
        n_added = n_cumlative - dplyr::lag(n_cumlative, default = 0),
        n_sum = cumsum(n_added),
        set_string = ifelse(n_sets > 1, "sets", "set"),
        set_type =
          dplyr::case_when(
            stage == "Select Variables" ~ "variables",
            stage == "Filter Observations" ~ "datasets",
            T ~ "models"
          )
      ) |>
      dplyr::mutate(
        stage_prod = prod(n_alts_tot),
        .by = stage
      ) |>
      dplyr::summarize(
        grid_explosion = unique(stage_prod),
        grid_combos_overview =
          glue::glue("{grid_explosion} {unique(set_type)}"),
        grid_combos_detail =
          paste(
            glue::glue(
              "**{stringr::str_remove(type, 'Define |Apply ')}**<br>",
              "{n_alts_tot} alternatives ({n_alts_txt})"
            ),
            collapse = "<br><br>"
          ),
        .by = stage
      ) |>
      dplyr::mutate(
        grid_mult = cumprod(grid_explosion),
        grid_combos_detail =
          ifelse(
            stage == "Execute",
            glue::glue("{grid_combos_detail}") |>
              stringr::str_remove('\\(.*\\)'),
            glue::glue("{grid_combos_detail}")
          )
      )

    setup_data <-
      pipeline_raw |>
      dplyr::inner_join(stage_key,by = dplyr::join_by(type)) |>
      dplyr::filter(
        stage %in% c("Select Variables", "Filter Observations")
      ) |>
      dplyr::mutate(
        code = stringr::str_replace_all(code, operator_map),
      ) |>
      dplyr::mutate(
        n_alts = dplyr::n(),
        type_text = stringr::str_replace_all(type, alt_txt),
        type_text =
          ifelse(
            n_alts == 1,
            stringr::str_remove(type_text, "s$"),
            type_text
          ),
        type = factor(type, type_key, names(type_key)),
        .by = c(stage, type, group)
      ) |>
      dplyr::summarize(
        overview =
          paste(
            glue::glue("{unique(n_alts)} {unique(type_text)}"),
            collapse = "<br>"
          ),
        detail = paste(glue::glue("  - {unique(code)}"), collapse = "<br>"),
        .by = c(stage, type, group)
      ) |>
      dplyr::summarize(
        overview_box =
          paste(
            glue::glue("- {group} ({overview})"),
            collapse = "<br>"
          ),
        overview_box_detail =
          paste(
            glue::glue("*{group}* ({overview})<br>{detail}"),
            collapse = "<br><br>"
          ),
        .by = c(stage, type)
      ) |>
      dplyr::summarize(
        overview =
          paste(
            glue::glue("**{type}**<br>{overview_box}"),
            collapse = "<br><br>"
          ),
        detail =
          paste(
            glue::glue("**{type}**<br>{overview_box_detail}"),
            collapse = "<br><br>"
          ),
        .by = stage
      )

    execute_analysis <-
      pipeline_raw |>
      dplyr::inner_join(stage_key, by = dplyr::join_by(type)) |>
      dplyr::filter(
        stage %in% c("Execute")
      ) |>
      dplyr::mutate(
        code =
          dplyr::case_when(
            type == "preprocess" ~
              group,
            type == "models" ~
              glue::glue("run {group} {stringr::str_remove(code, '\\\\(.*\\\\)')}()"),
            type == "postprocess" ~
              glue::glue("run {stringr::str_remove(code, '\\\\(.*\\\\)')}()")
          ),
        group = ifelse(type == "models", "focal model", group)
      ) |>
      dplyr::mutate(
        n_alts = dplyr::n(),
        type_text = stringr::str_replace_all(type, alt_txt),
        type_text =
          ifelse(
            n_alts == 1,
            stringr::str_remove(type_text, "s$"),
            type_text
          ),
        type = factor(type, type_key, names(type_key)),
        .by = c(stage, type, group)
      ) |>
      dplyr::summarize(
        overview =
          paste(
            glue::glue("{unique(n_alts)} {unique(type_text)}"),
            collapse = "<br>"
          ),
        detail =
          paste(
            glue::glue("- {unique(code)}"),
            collapse = "<br>"
          ),
        .by = c(stage, type)
      ) |>
      dplyr::summarize(
        overview_box =
          paste(
            glue::glue("**{type}** ({overview})"),
            collapse = "<br>"
          ),
        overview_box_detail =
          paste(
            glue::glue("**{type}** ({overview})<br>{detail}"),
            collapse = "<br>"
          ),
        .by = c(stage, type)
      ) |>
      dplyr::summarize(
        overview =
          paste(
            glue::glue("{overview_box}"),
            collapse = "<br><br>"
          ),
        detail =
          paste(
            glue::glue("{overview_box_detail}"),
            collapse = "<br><br>"
          ),
        .by = stage
      )

    ## Spacing Setup ----
    h_space <- if(is.null(h_space)){c(1,1)}else{h_space}
    v_space <- if(is.null(v_space)){c(1,1)}else{v_space}
    box_space <- if(is.null(box_space)){2}else{box_space}
    node_space <- if(is.null(node_space)){1}else{node_space}
    arrow_spacing <- if(is.null(arrow_spacing)){.2}else{arrow_spacing}
    text_sizing <- if(is.null(text_sizing)){1}else{text_sizing}

    ## Vertical ----
    if(layout == "vertical"){
      pipeline_plot <-
        dplyr::bind_rows(
          setup_data,
          execute_analysis
        ) |>
        dplyr::inner_join(
          pipeline_stages,
          by = dplyr::join_by(stage)
        ) |>
        dplyr::mutate(
          stage =
            factor(
              stage,
              c("Select Variables", "Filter Observations", "Execute")
            ),
          stage = forcats::fct_rev(stage),
          stage_y = (as.numeric(stage)-1) * node_space
        ) |>
        ggplot2::ggplot(ggplot2::aes(y = stage_y, x = 0)) +
        ggplot2::geom_point() +
        ggplot2::geom_segment(
          data =
            ~.x |>
            dplyr::distinct(stage_y) |>
            dplyr::arrange(stage_y) |>
            dplyr::mutate(
              to_stage = dplyr::lead(stage_y)
            ) |>
            tidyr::drop_na(),
          ggplot2::aes(
            y = as.numeric(stage_y) + (node_space*arrow_spacing),
            yend = as.numeric(to_stage) - (node_space*arrow_spacing),
            xend = 0
          ),
          arrow =
            ggplot2::arrow(
              angle = 20,
              length = ggplot2::unit(10, "pt"),
              ends = "first",
              type = "closed"
            ),
          color = "black",
        ) +
        ggplot2::geom_segment(
          ggplot2::aes(
            x =
              ifelse(
                as.numeric(stage) %in% c(2,4),
                box_space, -box_space
              ),
            xend = 0
          ),
          linewidth = .25,
          color = "black",
        ) +
        ggtext::geom_textbox(
          data =
            ~.x |>
            dplyr::mutate(
              label =
                ifelse(
                  stage == "Execute",
                  glue::glue("**{stage}**<br>{grid_mult} analyses"),
                  glue::glue("**{stage}**")
                )
            ),
          ggplot2::aes(
            label = label
          ),
          size = 4*text_sizing,
          vjust = .5,
          halign = .5,
          valign = .5,
          fill = "white",
          color = "black",
          box.color = "black",
          box.r = ggplot2::unit(.6*text_sizing, "in"),
          width = ggplot2::unit(1.2*text_sizing, "in"),
          height = ggplot2::unit(1.2*text_sizing, "in")
        )

      if(decision_details){
        pipeline_plot <-
          pipeline_plot +
          ggtext::geom_textbox(
            ggplot2::aes(
              x = ifelse(as.numeric(stage) %in% c(2,4), box_space, -box_space),
              hjust = ifelse(as.numeric(stage) %in% c(2,4), 0, 1),
              label = detail
            ),
            box.colour = "black",
            fill = "white",
            color = "black",
            size = 3*text_sizing
          )
      }else{
        pipeline_plot <-
          pipeline_plot +
          ggtext::geom_textbox(
            ggplot2::aes(
              x = ifelse(as.numeric(stage) %in% c(2,4), box_space, -box_space),
              hjust = ifelse(as.numeric(stage) %in% c(2,4), 0, 1),
              label = overview
            ),
            box.colour = "black",
            fill = "white",
            color = "black",
            size = 3*text_sizing
          )
      }

      if(combinations_detail){
        pipeline_plot <-
          pipeline_plot +
          ggtext::geom_textbox(
            data = ~.x |> dplyr::filter(stage != "Execute"),
            ggplot2::aes(
              x =
                ifelse(
                  as.numeric(stage) %in% c(2,4),
                  -box_space,
                  box_space
                ),
              hjust = ifelse(as.numeric(stage) %in% c(1,3), 2, 4),
              label = glue::glue("{grid_combos_detail}")
            ),
            box.color = NA,
            fill = "white",
            color = "black",
            box.margin = ggplot2::unit(5, "pt"),
            size = 3*text_sizing
          )

      }

      pipeline_plot <-
        pipeline_plot +
        ggtext::geom_richtext(
          ggplot2::aes(
            x =
              ifelse(
                as.numeric(stage) %in% c(2,4),
                -box_space,
                box_space
              ),
            hjust = ifelse(as.numeric(stage) %in% c(2,4), 1, 0),
            y = stage_y,
            label = grid_combos_overview
          ),
          label.color = NA,
          fill = "white",
          color = "black",
          size = 3.5*text_sizing,
          fontface = "bold"
        ) +
        ggplot2::scale_x_continuous(
          expand = ggplot2::expansion(add = c(h_space[1], h_space[2]))
        ) +
        ggplot2::scale_y_continuous(
          expand = ggplot2::expansion(add = c(v_space[1], v_space[2]))
        ) +
        ggplot2::theme_void()

    }

    ## Horizontal ----
    if(layout == "horizontal"){
      pipeline_plot <-
        dplyr::bind_rows(
          setup_data,
          execute_analysis
        ) |>
        dplyr::inner_join(
          pipeline_stages,
          by = dplyr::join_by(stage)
        ) |>
        dplyr::mutate(
          stage =
            factor(
              stage,
              c("Select Variables", "Filter Observations", "Execute")
            ),
          stage = stage,
          stage_x = (as.numeric(stage)-1) * node_space
        ) |>
        ggplot2::ggplot(ggplot2::aes(x = stage_x, y = 0)) +
        ggplot2::geom_point() +
        ggplot2::geom_segment(
          data =
            ~.x |>
            dplyr::distinct(stage_x) |>
            dplyr::arrange(stage_x) |>
            dplyr::mutate(
              to_stage = dplyr::lead(stage_x)
            ) |>
            tidyr::drop_na(),
          ggplot2::aes(
            x = as.numeric(stage_x) + (node_space*arrow_spacing),
            xend = as.numeric(to_stage) - (node_space*arrow_spacing),
            yend = 0
          ),
          arrow =
            ggplot2::arrow(
              angle = 20,
              length = ggplot2::unit(10, "pt"),
              ends = "last",
              type = "closed"
            ),
          color = "black",
        ) +
        ggplot2::geom_segment(
          ggplot2::aes(
            y =
              ifelse(
                as.numeric(stage) %in% c(1,3),
                -node_space,
                -node_space),
            yend = 0
          ),
          linewidth = .25,
          color = "black",
        ) +
        ggtext::geom_textbox(
          ggplot2::aes(
            label = glue::glue("**{stage}**")
          ),
          size = 4*text_sizing,
          vjust = .5,
          halign = .5,
          valign = .5,
          fill = "white",
          color = "black",
          box.color = "black",
          box.r = ggplot2::unit(.6*text_sizing, "in"),
          width = ggplot2::unit(1.2*text_sizing, "in"),
          height = ggplot2::unit(1.2*text_sizing, "in")
        )

      if(decision_details){
        pipeline_plot <-
          pipeline_plot +
          ggtext::geom_textbox(
            ggplot2::aes(
              y = -node_space,
              vjust = 1,
              label = detail
            ),
            box.colour = "black",
            fill = "white",
            color = "black",
            size = 3*text_sizing
          )
      }else{
        pipeline_plot <-
          pipeline_plot +
          ggtext::geom_textbox(
            ggplot2::aes(
              y = -node_space,
              vjust = 1,
              label = overview
            ),
            box.colour = "black",
            fill = "white",
            color = "black",
            size = 3
          )
      }

      if(combinations_detail){
        pipeline_plot <-
          pipeline_plot +
          ggtext::geom_textbox(
            data = ~.x |> dplyr::filter(stage != "Execute"),
            ggplot2::aes(
              y = node_space*.75,
              vjust = 0,
              label = glue::glue("{grid_combos_detail}")
            ),
            box.color = NA,
            hjust = .5,
            halign = 0.5,
            vjust = 0,
            fill = "white",
            color = "black",
            box.margin = ggplot2::unit(5, "pt"),
            size = 3*text_sizing
          )
      }

      pipeline_plot <-
        pipeline_plot +
        ggtext::geom_richtext(
          ggplot2::aes(
            y = node_space*.75,
            x = stage_x,
            label = grid_combos_overview
          ),
          label.color = NA,
          fill = "white",
          color = "black",
          hjust = 0.5,
          size = 3.5*text_sizing,
          fontface = "bold"
        ) +
        ggplot2::scale_x_continuous(
          expand = ggplot2::expansion(add = c(h_space[1], h_space[2]))
        ) +
        ggplot2::scale_y_continuous(
          expand = ggplot2::expansion(add = c(v_space[1], v_space[2]))
        ) +
        ggplot2::theme_void()

    }

    pipeline_plot

  }

#' Create a Analysis Pipeline diagram
#'
#' @description `r lifecycle::badge("superseded")` `create_blueprint_graph()`
#'   will still work  but I recommend using `visualize_pipeline()` instead,
#'   which has more options and outputs ggplot2 objects instead of grViz graphs
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
#'   add_filters(include1 == 0, include2 != 3, include3 > -2.5) |>
#'   add_variables(var_group = "ivs", iv1, iv2, iv3) |>
#'   add_variables(var_group = "dvs", dv1, dv2) |>
#'   add_model("linear model", lm({dvs} ~ {ivs} * mod))
#'
#' create_blueprint_graph(full_pipeline)
create_blueprint_graph <- function(.pipeline, splines = "line", render = TRUE, show_code = FALSE, ...){

  decision_types <-
    .pipeline |> dplyr::pull(type) |> unique()

  grid_ndf <- create_pipeline_ndf(.pipeline)

  if("subgroups" %in% decision_types){
    if("filters" %in% decision_types){
      possible_edges <-
        tibble::tribble(
          ~my_from,        ~my_to,
          "base_df",       "subgroups",
          "subgroups_set", "subgroups",
          "subgroups",     "variables",
          "subgroups",     "filters",
          "variables_set", "variables",
          "filters",       "filters_set",
          "variables",     "total_dfs",
          "filters",       "total_dfs",
          "total_dfs",     "preprocess",
          "filters_set",   "reliabilities",
          "filters_set",   "summary_stats",
          "filters_set",   "corrs",
          "total_models",  "postprocess"
        )
    } else{
      possible_edges <-
        tibble::tribble(
          ~my_from,        ~my_to,
          "base_df",       "subgroups",
          "subgroups_set", "subgroups",
          "subgroups",     "variables",
          "subgroups",     "filters",
          "variables_set", "variables",
          "filters",       "filters_set",
          "variables",     "total_dfs",
          "filters",       "total_dfs",
          "total_dfs",     "preprocess",
          "subgroups_set", "reliabilities",
          "subgroups_set", "summary_stats",
          "subgroups_set", "corrs",
          "total_models",  "postprocess"
        )
    }
  } else{
    possible_edges <-
      tibble::tribble(
        ~my_from,        ~my_to,
        "base_df",       "filters",
        "base_df",       "variables",
        "variables_set", "variables",
        "filters",       "filters_set",
        "variables",     "total_dfs",
        "filters",       "total_dfs",
        "total_dfs",     "preprocess",
        "filters_set",   "reliabilities",
        "filters_set",   "summary_stats",
        "filters_set",   "corrs",
        "total_models",  "postprocess"
      )
  }

  if(grid_ndf |> dplyr::filter(stringr::str_detect(nodes,"model_\\d")) |> nrow() > 0){

    model_from <-
      grid_ndf |>
      dplyr::filter(stringr::str_detect(nodes,"model_\\d")) |>
      dplyr::transmute(
        my_from =
          ifelse(
            "preprocess" %in% unique(grid_ndf$nodes),
            "preprocess",
            "total_dfs"
          ),
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

  pipeline_edges <-
    possible_edges |>
    dplyr::inner_join(
      grid_ndf |> dplyr::select(nodes, id),
      by = c("my_from" = "nodes")
    ) |>
    dplyr::rename(from = id) |>
    dplyr::inner_join(
      grid_ndf |> dplyr::select(nodes, id),
      by = c("my_to" = "nodes")
    ) |>
    dplyr::rename(to = id) |>
    tidyr::drop_na() |>
    as.data.frame()

  a_graph <-
    DiagrammeR::create_graph() |>
    DiagrammeR::add_node_df(grid_ndf)

  if("filters" %in% decision_types | "variables" %in% decision_types | "subgroups" %in% decision_types){
    invis_nodes <-
      a_graph |>
      DiagrammeR::select_nodes(
        conditions = stringr::str_detect(nodes, "subgroups|filters|variables")
      ) |>
      DiagrammeR::get_node_df_ws() |>
      dplyr::mutate(
        new_order =
          dplyr::case_when(
            nodes == "subgroups" ~ 1,
            nodes == "subgroups_set" ~ 2,
            nodes == "variables_set" ~ 3,
            nodes == "variables" ~ 4,
            nodes == "filters" ~ 5,
            nodes == "filters_set" ~ 6
          )
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
        style = "invis"
      )
  }

  the_graph <- a_graph

  if("filters" %in% decision_types | "variables" %in% decision_types | "subgroups" %in% decision_types){
    the_graph <-
      the_graph |>
      DiagrammeR::add_edge_df(invis_edges)
  }

  the_graph <-
    the_graph |>
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
    DiagrammeR::add_global_graph_attrs("constraint", "true", "edge")

  if("subgroups" %in% decision_types){
    the_graph <-
      the_graph |>
      DiagrammeR::select_edges(my_to == "subgroups") |>
      DiagrammeR::set_edge_attrs_ws("arrowhead", "none") |>
      DiagrammeR::set_edge_attrs_ws("arrowtail", "none") |>
      DiagrammeR::set_edge_attrs_ws("style", "solid") |>
      DiagrammeR::set_edge_attrs_ws("headport", "e") |>
      DiagrammeR::set_edge_attrs_ws("tailport", "w") |>
      DiagrammeR::clear_selection() |>
      DiagrammeR::select_edges(my_from == "base_df") |>
      DiagrammeR::set_edge_attrs_ws("headport", "n") |>
      DiagrammeR::set_edge_attrs_ws("tailport", "s") |>
      DiagrammeR::clear_selection()
  }

  if("filters" %in% decision_types){
    the_graph <-
      the_graph |>
      DiagrammeR::select_edges(my_to == "filters_set") |>
      DiagrammeR::set_edge_attrs_ws("arrowhead", "none") |>
      DiagrammeR::set_edge_attrs_ws("arrowtail", "none") |>
      DiagrammeR::set_edge_attrs_ws("style", "solid") |>
      DiagrammeR::set_edge_attrs_ws("headport", "w") |>
      DiagrammeR::set_edge_attrs_ws("tailport", "e") |>
      DiagrammeR::clear_selection()
  }

  if("variables" %in% decision_types){
    the_graph <-
      the_graph |>
      DiagrammeR::select_edges(my_from == "variables_set") |>
      DiagrammeR::set_edge_attrs_ws("arrowhead", "none") |>
      DiagrammeR::set_edge_attrs_ws("arrowtail", "none") |>
      DiagrammeR::set_edge_attrs_ws("style", "solid") |>
      DiagrammeR::set_edge_attrs_ws("headport", "w") |>
      DiagrammeR::set_edge_attrs_ws("tailport", "e") |>
      DiagrammeR::clear_selection()
  }

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


