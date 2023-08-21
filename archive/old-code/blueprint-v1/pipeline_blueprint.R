pipeline_blueprint <- function(.grid){

  decision_types <-
    .grid |> pull(type) |> unique()

  data_combos <-
    .grid |>
    dplyr::filter(type %in% c("filters","variables")) |>
    dplyr::group_by(group) |>
    dplyr::count() |>
    dplyr::pull(n) |>
    purrr::accumulate(`*`) |>
    max()

  model_combos <-
    .grid |>
    dplyr::filter(type %in% c("filters","variables", "models")) |>
    dplyr::mutate(group = ifelse(type=="models", "model", group)) |>
    dplyr::group_by(group) |>
    dplyr::count() |>
    dplyr::pull(n) |>
    purrr::accumulate(`*`) |>
    max()

  pipeline_nodes <-
    .grid |>
    filter(!str_detect(group, "focus$|matrix$")) |>
    add_row(type = "base_df", group = "base_df", .before = 1) |>
    add_row(type = "total_dfs", group = "total_dfs", code = glue::glue("{4} datasets")) |>
    add_row(type = "total_models", group = "total_models", code = glue::glue("{4} models")) |>
    group_by(group) |>
    mutate(n_steps = n()) |>
    ungroup() |>
    mutate(
      code = ifelse(type %in% c("preprocess","postprocess","cron_alphas","summary_stats","corrs","base_df"), "", code),
      original_type = type,
      type = ifelse(type %in% c("cron_alphas","summary_stats","corrs"), "descriptive", type)
    ) |>
    group_split(type) |>
    map(function(x){

      if(unique(x$type) %in% c("base_df", "total_dfs", "total_models")){
        my_nodes <-
          x |>
          transmute(
            type = type,
            description = case_when(type == "base_df" ~ "Base Dataset",
                                    type == "total_dfs" ~ as.character(data_combos),
                                    type == "total_models" ~ as.character(model_combos),
                                    T~"")

          )
      }

      if(unique(x$type) %in% c("filters", "variables")){
        my_nodes <-
          bind_rows(
            x |>
              dplyr::group_by(type,group) |>
              dplyr::count() |>
              ungroup() |>
              dplyr::summarize(
                type        = unique(type),
                description = glue::glue("{type} - {n()} sets")
              ),
            x |>
              group_by(group) |>
              summarize(
                type =  unique(type),
                description = glue::glue( "{code}") |> paste(collapse = ", ")
              ) |>
              summarize(
                type = glue::glue("{unique(type)}_set"),
                description = glue::glue( "{group}\n{description}") |> paste(collapse = "\n ")
              )
          )
      }

      if(unique(x$type == "models")){
        my_nodes <-
          x |>
          group_by(code) |>
          dplyr::summarize(
            type = glue::glue("model"),
            description = glue::glue("{group}\n{code}") |> paste(collapse = "\n")
          ) |>
          select(type,description) |>
          mutate(
            type = glue::glue("{type}_{1:n()}")
          )
      }

      if(unique(x$type) %in% c("preprocess","postprocess")){
        my_nodes <-
          x |>
          dplyr::summarize(
            type = unique(type),
            description = glue::glue(" - {group}") |> paste(collapse = "\n")
          ) |>
          mutate(description = glue::glue("{type}\n{description}"))
      }

      if(unique(x$type) == "descriptive"){
        my_nodes <-
          x |>
          group_by(original_type) |>
          summarize(
            type =  unique(type),
            description = glue::glue( "{group}") |> paste(collapse = ", ")
          ) |>
          summarize(
            type = glue::glue("{unique(type)}"),
            description = glue::glue( "{original_type}\n{description}") |> paste(collapse = "\n")
          )
      }
      my_nodes
    }) |>
    list_rbind() |>
    transmute(
      id = 1:n(),
      nodes = type,
      label = description
    ) |>
    mutate(order = case_when(nodes == "base_df" ~ 1,
                             nodes %in% c("filters","variables","filters_set","variables_set") ~ 2,
                             nodes == "preprocess" ~ 3,
                             nodes == "total_dfs" ~ 4,
                             str_detect(nodes, "model_") ~ 5,
                             nodes == "descriptive" ~ 6,
                             nodes == "total_models" ~ 7,
                             nodes == "postprocess" ~ 8),
           rank = order,
    ) |>
    as.data.frame()

  possible_edges <-
    tribble(
      ~my_from,        ~my_to,
      "base_df",       "filters",
      "base_df",       "variables",
      "variables_set", "variables",
      "filters",       "filters_set",
      "variables",     "preprocess",
      "filters",       "preprocess",
      "preprocess",    "total_dfs",
      "total_dfs",     "descriptive",
      "total_models",  "postprocess"
    )

  if(pipeline_nodes |> filter(str_detect(nodes,"model_\\d")) |> nrow() > 0){

    model_from <-
      pipeline_nodes |>
      filter(str_detect(nodes,"model_\\d")) |>
      transmute(
        my_from = "total_dfs",
        my_to = nodes
      )

    model_to <-
      pipeline_nodes |>
      filter(str_detect(nodes,"model_\\d")) |>
      transmute(
        my_from = nodes,
        my_to = "total_models"
      )

    possible_edges <-
      bind_rows(
        possible_edges,
        model_from,
        model_to
      )
  }

  if(!"preprocess" %in% unique(pipeline_nodes$nodes)){
    possible_edges <-
      possible_edges |>
      add_row(my_from = c("variables","filters"), my_to = c("total_dfs","total_dfs"))
  }

  pipeline_edges <-
    possible_edges |>
    left_join(
      pipeline_nodes |> select(nodes, id),
      by = c("my_from" = "nodes")
    ) |>
    rename(from = id) |>
    left_join(
      pipeline_nodes |> select(nodes, id),
      by = c("my_to" = "nodes")
    ) |>
    rename(to = id) |>
    drop_na() |>
    as.data.frame()

  a_graph <-
    create_graph() |>
    add_node_df(pipeline_nodes)

  if("filters" %in% decision_types & "variables" %in% decision_types){
    invis_nodes <-
      a_graph |>
      select_nodes(conditions = str_detect(nodes, "filters|variables")) |>
      get_node_df_ws() |>
      mutate(
        new_order = case_when(nodes == "variables_set" ~ 1,
                              nodes == "variables" ~ 2,
                              nodes == "filters" ~ 3,
                              nodes == "filters_set" ~ 4)
      ) |>
      arrange(new_order) |>
      pull(id)

    invis_edges <-
      invis_nodes |>
      tibble(
        v1 = _
      ) |>
      mutate(
        v2 = lead(v1)
      ) |>
      drop_na() |>
      rename(from = v1, to = v2) |>
      mutate(
        color = "purple",
        style = "invis"
      )
  }

  the_graph <-
    a_graph |>
    add_edge_df(invis_edges) |>
    add_edge_df(pipeline_edges) |>
    add_global_graph_attrs("layout", "dot", "graph") |>
    add_global_graph_attrs("overlap", "false", "graph") |>
    add_global_graph_attrs("fixedsize", "false", "node") |>
    add_global_graph_attrs("shape", "rect", "node") |>
    add_global_graph_attrs("tailport", "s", "edge") |>
    add_global_graph_attrs("headport", "n", "edge") |>
    add_global_graph_attrs("concentrate", "false", "edge") |>
    select_edges(my_to == "filters_set") |>
    set_edge_attrs_ws("arrowhead", "none") |>
    set_edge_attrs_ws("arrowtail", "none") |>
    set_edge_attrs_ws("style", "solid") |>
    set_edge_attrs_ws("headport", "w") |>
    set_edge_attrs_ws("tailport", "e") |>
    clear_selection() |>
    select_edges(my_from == "variables_set") |>
    set_edge_attrs_ws("arrowhead", "none") |>
    set_edge_attrs_ws("arrowtail", "none") |>
    set_edge_attrs_ws("style", "solid") |>
    set_edge_attrs_ws("headport", "w") |>
    set_edge_attrs_ws("tailport", "e") |>
    clear_selection()

  the_graph
}

pipeline_blueprint(stm_pipeline) |> render_graph()
pipeline_blueprint(stm_pipeline) |> generate_dot() |> cat()

get_node_df(pipeline_blueprint(stm_pipeline))
get_edge_df(pipeline_blueprint(stm_pipeline))
