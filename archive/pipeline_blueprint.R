pipeline_blueprint <- function(.grid, y_scale = 1, x_scale = 1){

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
    mutate(order = case_when(nodes == "base_df" ~ 0,
                             nodes %in% c("filters","variables","filters_set","variables_set") ~ 1,
                             nodes == "preprocess" ~ 2,
                             nodes == "total_dfs" ~ 3,
                             str_detect(nodes, "model_") ~ 4,
                             nodes == "descriptive" ~ 4,
                             nodes == "total_models" ~ 5,
                             nodes == "postprocess" ~ 6)
    ) |>
    arrange(order) |>
    group_by(order) |>
    mutate(
      n_steps = n(),
      y = cur_group_id() * -1,
    ) |>
    ungroup() |>
    mutate(
      x = case_when(nodes %in% c("base_df", "total_dfs") ~ 0,
                    n_steps > 1 & nodes == "filters" ~ 1,
                    n_steps > 1 & nodes == "variables" ~ -1,
                    n_steps == 1 & nodes %in% c("filters", "variables") ~ 0,
                    nodes == "preprocess" ~ 0,
                    nodes == "descriptive" ~ 1,
                    n_steps == 1 & nodes == "descriptive" ~ 0,
                    TRUE~ -99),
      x = ifelse(nodes == "model_1", -1, x),
      x = ifelse(str_detect(nodes, "model_[2-9]") , lag(x) - 1, x),
      x = ifelse(nodes == "total_models", lag(x), x),
      x = ifelse(nodes == "postprocess", lag(x), x),
      x = ifelse(nodes == "filters_set", lag(x) + 1, x),
      x = ifelse(nodes == "variables_set", lag(x) - 1, x),
      id = 1:n(),
      x = x*x_scale,
      y = y*y_scale
    ) |>
    as.data.frame()

  print(pipeline_nodes |> as_tibble() |> mutate(across(everything(), ~as.character(.x))), n = 50)

  possible_edges <-
    tribble(
      ~my_from,        ~my_to,
      "base_df",       "filters",
      "base_df",       "variables",
      "variables_set", "variables",
      "variables",     "preprocess",
      "filters_set",   "filters",
      "filters",       "preprocess",
      "preprocess",    "total_dfs",
      "total_dfs",     "descriptive",
      "total_models",  "postprocess"
    )
  print(pipeline_nodes |> filter(str_detect(nodes,"model_\\d")) |> nrow() > 0)

  if(pipeline_nodes |> filter(str_detect(nodes,"model_\\d")) |> nrow() > 0){

    model_from <-
      pipeline_nodes |>
      filter(str_detect(nodes,"model_\\d")) |>
      transmute(
        my_from = "total_dfs",
        my_to = nodes
      )

    print(model_from)

    model_to <-
      pipeline_nodes |>
      filter(str_detect(nodes,"model_\\d")) |>
      transmute(
        my_from = nodes,
        my_to = "total_models"
      )
    print(model_to)

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

  the_graph <-
    create_graph() |>
    add_node_df(pipeline_nodes) |>
    add_edge_df(pipeline_edges) |>
    add_global_graph_attrs("overlap", "false", "graph") |>
    add_global_graph_attrs("fixedsize", 'false', 'node') |>
    add_global_graph_attrs("shape", 'rect', 'node') |>
    add_global_graph_attrs("tailport", "s", "edge") |>
    add_global_graph_attrs("headport", "n", "edge")

  print(pipeline_nodes |> as_tibble() |> mutate(across(everything(),~as.character(.x))), n = 50)
  the_graph
}

d <- full_pipeline |>
  pipeline_blueprint(y_scale = 1.5, x_scale = 2)

d |>
  set_edge_attrs(edge_attr = "tailport", values = "e", from = c(5), to = c(4)) |>
  set_edge_attrs(edge_attr = "headport", values = "w", from = c(5), to = c(4)) |>
  set_edge_attrs(edge_attr = "tailport", values = "w", from = c(3), to = c(2)) |>
  set_edge_attrs(edge_attr = "headport", values = "e", from = c(3), to = c(2)) |>
  render_graph()

