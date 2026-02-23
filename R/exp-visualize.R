# visualize_pipeline1 <- function(.pipeline){
#
#   is_pipeline <- is.null(attr(.pipeline, "pipeline"))
#
#   curr_pipeline <-
#     if(is_pipeline){
#       .pipeline
#     } else{
#       attr(.pipeline, "pipeline")
#     }
#
#   fct_stypes <- c(
#     "Define Subgroups" = "subgroups",
#     "Apply Filters" = "filters",
#     "Choose Variables" = "variables",
#     "Preprocessing" = "preprocess",
#     "Modeling" = "models",
#     "Postprocessing" = "postprocess"
#   )
#
#   fct_steps <-
#     c(
#       "Define Subgroups",
#       "Apply Filters",
#       "Choose Variables",
#       "Modeling Pipeline"
#     )
#
#   operator_map <- c(
#     "(.*)>="  = "≥",
#     "(.*)<="  = "≤",
#     "(.*) > " = " > ",
#     "(.*) < " = " < ",
#     "(.*)=="  = "=",
#     "(.*)!="  = "≠",
#     "(.*) %in% unique(.*)$" = " no filter"
#   )
#
#   cleaned_pipeline <-
#     student01_pipeline |>
#     select(-additional_args, -add_standardized, -add_performance) |>
#     mutate(
#       step = case_when(
#         type %in% c("subgroups", "filters") ~ "Build Datasets",
#         type %in% c("variables") ~ "Setup Models",
#         type %in% c("preprocess", "models", "postprocess") ~ "Modeling Pipeline"
#       ),
#       step = factor(step, c(
#         "Build Datasets",
#         "Setup Models",
#         "Modeling Pipeline"
#       ))
#     ) |>
#     mutate(
#       type_human = factor(type, fct_stypes, names(fct_stypes)),
#       code = case_when(
#         type == "preprocess" ~ group,
#         type == "postprocess" ~ group,
#         T ~ code
#       ),
#       group = case_when(
#         type == "preprocess" ~ "Steps",
#         type == "models" ~ "Fit",
#         type == "postprocess" ~ "Run",
#         T ~ group
#       )
#     ) |>
#     arrange(step, type_human, group) |>
#     mutate(
#       code =
#         ifelse(
#           type != "models",
#           str_replace_all(code, operator_map),
#           glue::glue("<span style='font-family: Monaco'>{code}</span>")
#         ),
#       #tree_pos  = ifelse(code == last(code), "└─", "├─"),
#       tree_pos = "•",
#       .by       = group
#     ) |>
#     mutate(
#       n_alternatives = n_distinct(code),
#       .by = c(type_human, group)
#     ) |>
#     summarize(
#       set_options = paste(
#         glue::glue("{tree_pos} {code}"),
#         collapse = "<br>"
#       ),
#       .by = c(step, type_human, group, n_alternatives)
#     ) |>
#     summarize(
#       set_options =
#         ifelse(
#           step != "Modeling Pipeline",
#           paste(
#             glue::glue("**{group}**<br>{set_options}"),
#             collapse = "<br>"
#           ),
#           paste(
#             glue::glue("**{type_human}**<br>*{group}*<br>{set_options}"),
#             collapse = "<br>"
#           )
#         ),
#       .by = c(step, type_human, group, n_alternatives)
#     ) |>
#     mutate(
#       type_human = ifelse(step != "Modeling Pipeline", as.character(type_human), as.character(step)),
#       type_human = factor(type_human, fct_steps)
#     ) |>
#     mutate(
#       n_sets = n_distinct(group),
#       .by = type_human
#     ) |>
#     mutate(
#       x_sub = seq_len(n()),
#       .by   = type_human
#     ) |>
#     mutate(
#       y_sub = as.numeric(fct_rev(type_human))
#     ) |>
#     mutate(
#       y = max(y_sub),
#       .by = step
#     )
#
#   cleaned_pipeline |>
#     ggplot(aes(x = 0, y = y_sub)) +
#     geom_segment(
#       data =
#         ~.x |>
#         summarize(
#           xmax = max(x_sub),
#           .by = c(type_human, y_sub)
#         ) |>
#         distinct() |>
#         mutate(
#           y_sub = ifelse(type_human == "Modeling Pipeline", y_sub - 1, y_sub),
#           xmax = ifelse(type_human == "Modeling Pipeline", (xmax-1) * 3, xmax)
#         ),
#       aes(x = 0, xend = xmax, y = y_sub, yend = y_sub),
#       color = "gray"
#     ) +
#     geom_segment(
#       data = \(.x) {
#         .x |>
#           summarize(x_sub = 0, .by = c(type_human, y_sub)) |>
#           arrange(desc(y_sub)) |>
#           mutate(
#             y_next  = lead(y_sub),
#             x_next  = lead(x_sub)
#           ) |>
#           drop_na()
#       },
#       aes(
#         x     = x_sub,
#         xend  = x_next,
#         y     = y_sub - .25,
#         yend  = y_next + .25
#       ),
#       arrow = arrow(length = unit(5, "pt")),
#       color = "gray"
#     ) +
#     geom_segment(
#       data =
#         ~.x |>
#         summarize(
#           y_sub = min(y_sub)
#         ) |>
#         mutate(x = 0),
#       aes(
#         x     = x,
#         xend  = x,
#         y     = y_sub,
#         yend  = y_sub - .75
#       ),
#       arrow = arrow(length = unit(5, "pt")),
#       color = "gray"
#     ) +
#     ggtext::geom_textbox(
#       data =
#         ~.x |>
#         summarize(
#           y_sub = max(y_sub),
#           n_alternatives = paste(n_alternatives, collapse = "*"),
#           .by = c(type_human, n_sets, y_sub)
#         ) |>
#         mutate(
#           total = map_dbl(n_alternatives, \(x) rlang::eval_tidy(rlang::parse_expr(x))),
#           p_unit =
#             case_when(
#               str_detect(type_human, "Sub|Var|Filt") ~ "sets",
#               T ~ "steps"
#             ),
#           p_unit = ifelse(n_sets == 1, str_remove(p_unit, "s$"), p_unit),
#           p_total =
#             case_when(
#               str_detect(type_human, "Sub|Filt") ~ "datasets",
#               str_detect(type_human, "Var") ~ "combinations",
#               T ~ "analyses"
#             ),
#           total = ifelse(type_human == "Modeling Pipeline", prod(total), total),
#           p_total = ifelse(total == 1, str_remove(p_total, "s$"), p_total),
#           label =
#             glue::glue(
#               "**{type_human}**<br>{n_sets} {p_unit}<br>{total} {p_total}"
#             )
#         ),
#       aes(label = label),
#       fill = "white",
#       size  = 3,
#       vjust = .5,
#       hjust = 0.5,
#       halign = .5,
#       valign = .5,
#       minheight = unit(40, "pt"),
#       maxwidth = unit(100, "pt"),
#       box.padding = unit(0, "pt"),
#       box.color = "gray",
#     ) +
#     ggtext::geom_richtext(
#       data =
#         ~.x |>
#         filter(step!="Modeling Pipeline"),
#       aes(x = x_sub, label = set_options, y = y_sub),
#       size  = 3,
#       vjust = .5,
#       hjust = 0,
#       label.color = "gray"
#     ) +
#     ggtext::geom_textbox(
#       data =
#         ~.x |>
#         filter(
#           step == "Modeling Pipeline"
#         ) |>
#         mutate(
#           n = (1:n())-1,
#           y_sub = y_sub - 1,
#           # x_sub = (x_sub - mean(x_sub)) * 3
#           x_sub = (x_sub - 1) * 3
#         ),
#       aes(x = x_sub, label = set_options, y = y_sub),
#       size  = 3,
#       vjust = .5,
#       hjust = 0.5,
#       box.color = "gray"
#     ) +
#
#     scale_x_continuous(
#       limits = \(range) c(min(range) - .75, max(range) + .75)
#     ) +
#     scale_y_continuous(
#       limits = \(range) c(min(range) - .25, max(range) + .25)
#     ) +
#     theme_void()
# }
#
# visualize_pipeline2 <- function(.pipeline){
#
#   is_pipeline <- is.null(attr(.pipeline, "pipeline"))
#
#   curr_pipeline <-
#     if(is_pipeline){
#       .pipeline
#     } else{
#       attr(.pipeline, "pipeline")
#     }
#
#   operator_map <- c(
#     "(.*)>="  = "≥",
#     "(.*)<="  = "≤",
#     "(.*)>"   = ">",
#     "(.*)<"   = "<",
#     "(.*)=="  = "=",
#     "(.*)!="  = "≠",
#     "(.*) %in% unique(.*)$" = "no filter"
#   )
#
#   stage_key <-
#     tribble(
#       ~stage,           ~type,
#       "Select Variables", "variables",
#       "Filter Observations", "subgroups",
#       "Filter Observations", "filters",
#       "Execute", "preprocess",
#       "Execute", "models",
#       "Execute", "postprocess"
#     )
#
#   verb_key <-
#     c(
#       "Build Dataset" = "using",
#       "Setup Modeling" = "from",
#       "Model Pipeline" = "by"
#     )
#
#   type_key <-
#     c(
#       "Define Subgroups" = "subgroups",
#       "Apply Filters" = "filters",
#       "Variables" = "variables",
#       "Pre-process" = "preprocess",
#       "Model" = "models",
#       "Post-process" = "postprocess",
#       "Effect of Interest" = "parameter_key"
#     )
#
#   alt_txt <-
#     c(
#       "subgroups" = "groups",
#       "filters" = "alternatives",
#       "variables" = "variables",
#       "preprocess" = "steps",
#       "models" = "model types",
#       "postprocess" = "steps"
#     )
#
#   pipeline_raw <-
#     curr_pipeline |>
#     select(type, group, code)
#
#   pipeline_stages <-
#     inner_join(
#       stage_key,
#       pipeline_raw |> filter(!str_detect(type, "process")),
#       join_by(type)
#     ) |>
#     summarize(
#       combinations = n(),
#       .by = c(stage, type, group)
#     ) |>
#     summarize(
#       stage = unique(stage),
#       n_steps = n_distinct(type),
#       n_sets = n_distinct(group),
#       n_alts_txt = paste(combinations, collapse = "\\*"),
#       n_alts_tot = unique(ifelse(type != "models", prod(combinations), sum(combinations))),
#       .by = type
#     ) |>
#     mutate(
#       type = factor(type, type_key, names(type_key)),
#       n_cumlative = cumprod(n_alts_tot),
#       n_added = n_cumlative - lag(n_cumlative, default = 0),
#       n_sum = cumsum(n_added),
#       set_string = ifelse(n_sets > 1, "sets", "set"),
#       set_type =
#         case_when(
#           stage == "Select Variables" ~ "sets",
#           stage == "Filter Observations" ~ "datasets",
#           T ~ "models"
#         )
#     ) |>
#     mutate(
#       stage_prod = prod(n_alts_tot),
#       .by = stage
#     ) |>
#     summarize(
#       grid_combos_detail =
#         paste(
#           glue::glue("**{type}**:<br>{n_sets} {set_string} with {n_alts_tot} alternatives"),
#           collapse = "<br>"
#         ),
#       grid_explosion = unique(stage_prod),
#       grid_combos_overview = glue::glue("{grid_explosion} {unique(set_type)}"),
#       .by = stage
#     ) |>
#     mutate(
#       grid_mult = cumprod(grid_explosion)
#     )
#
#   print(pipeline_stages)
#
#   pipeline_summary <-
#     inner_join(
#       stage_key,
#       pipeline_raw |> filter(!str_detect(type, "process")),
#       join_by(type)
#     ) |>
#     summarize(
#       combinations = n(),
#       .by = c(type, group)
#     ) |>
#     summarize(
#       n_steps = n_distinct(type),
#       n_sets = n_distinct(group),
#       n_alts_txt = paste(combinations, collapse = "*"),
#       n_alts_tot = prod(combinations),
#       .by = stage
#     ) |>
#     summarize(
#       n_alts_txt =
#         paste(
#           ifelse(
#             stage == 'Model Pipeline',
#             n_sets,
#             n_alts_tot
#           ),
#           collapse = "*"
#         ),
#       stage = "Result",
#       n_alts_tot = rlang::eval_tidy(rlang::parse_expr(n_alts_txt))
#     )
#
#   setup_data <-
#     pipeline_raw |>
#     inner_join(stage_key) |>
#     filter(
#       stage %in% c("Select Variables", "Filter Observations")
#     ) |>
#     mutate(
#       code = str_replace_all(code, operator_map),
#     ) |>
#     mutate(
#       n_alts = n(),
#       type_text = str_replace_all(type, alt_txt),
#       type_text = ifelse(n_alts == 1, str_remove(type_text, "s$"), type_text),
#       type = factor(type, type_key, names(type_key)),
#       .by = c(stage, type, group)
#     ) |>
#     summarize(
#       overview = paste(glue::glue("{unique(n_alts)} {unique(type_text)}"), collapse = "<br>"),
#       detail = paste(glue::glue("  • {unique(code)}"), collapse = "<br>"),
#       .by = c(stage, type, group)
#     ) |>
#     summarize(
#       overview_box =
#         paste(
#           glue::glue("• {group} ({overview})"),
#           collapse = "<br>"
#         ),
#       overview_box_detail =
#         paste(
#           glue::glue("*{group}* ({overview})<br>{detail}"),
#           collapse = "<br><br>"
#         ),
#       .by = c(stage, type)
#     ) |>
#     summarize(
#       overview = paste(glue::glue("**{type}**<br>{overview_box}"), collapse = "<br><br>"),
#       detail = paste(glue::glue("**{type}**<br>{overview_box_detail}"), collapse = "<br><br>"),
#       .by = stage
#     )
#
#   execute_analysis <-
#     pipeline_raw |>
#     inner_join(stage_key) |>
#     filter(
#       stage %in% c("Execute")
#     ) |>
#     mutate(
#       code =
#         case_when(
#           type == "preprocess" ~ group,
#           type == "models" ~ glue::glue("run {group} {str_remove(code, '\\\\(.*\\\\)')}()"),
#           type == "postprocess" ~  glue::glue("run {str_remove(code, '\\\\(.*\\\\)')}()")
#         ),
#       group = ifelse(type == "models", "focal model", group)
#     ) |>
#     mutate(
#       n_alts = n(),
#       type_text = str_replace_all(type, alt_txt),
#       type_text = ifelse(n_alts == 1, str_remove(type_text, "s$"), type_text),
#       type = factor(type, type_key, names(type_key)),
#       .by = c(stage, type, group)
#     ) |>
#     summarize(
#       overview = paste(glue::glue("{unique(n_alts)} {unique(type_text)}"), collapse = "<br>"),
#       detail = paste(glue::glue("• {unique(code)}"), collapse = "<br>"),
#       .by = c(stage, type)
#     ) |>
#     summarize(
#       overview_box =
#         paste(
#           glue::glue("**{type}** ({overview})"),
#           collapse = "<br>"
#         ),
#       overview_box_detail =
#         paste(
#           glue::glue("**{type}** ({overview})<br>{detail}"),
#           collapse = "<br>"
#         ),
#       .by = c(stage, type)
#     ) |>
#     summarize(
#       overview = paste(glue::glue("{overview_box}"), collapse = "<br><br>"),
#       detail = paste(glue::glue("{overview_box_detail}"), collapse = "<br><br>"),
#       .by = stage
#     )
#
#   bind_rows(
#     setup_data,
#     execute_analysis
#   ) |>
#     inner_join(
#       pipeline_stages
#     ) |>
#     mutate(
#       stage = factor(stage, c("Select Variables", "Filter Observations", "Execute")),
#       stage = fct_rev(stage)
#     ) |>
#     ggplot(aes(y = stage, x = 0)) +
#     geom_point() +
#     geom_segment(
#       data =
#         ~.x |>
#         distinct(stage) |>
#         arrange(stage) |>
#         mutate(
#           to_stage = lead(stage)
#         ) |>
#         drop_na(),
#       aes(y = as.numeric(stage) + .35, yend = as.numeric(to_stage), xend = 0),
#       arrow =
#         arrow(
#           angle = 20,
#           length = unit(10, "pt"),
#           ends = "first",
#           type = "closed"
#         ),
#       color = "black",
#     ) +
#     geom_segment(
#       aes(x = ifelse(as.numeric(stage) %in% c(2,4), 2, -2), xend = 0),
#       color = "black",
#     ) +
#     ggtext::geom_textbox(
#       aes(
#         label = glue::glue("**{stage}**<br>{grid_combos_overview}")
#       ),
#       size = 4,
#       vjust = .5,
#       halign = .5,
#       valign = .5,
#       fill = "white",
#       color = "black",
#       box.color = "black",
#       box.r = unit(.6, "in"),
#       width = unit(1.2, "in"),
#       height = unit(1.2, "in")
#     ) +
#     ggtext::geom_textbox(
#       aes(
#         x = ifelse(as.numeric(stage) %in% c(2,4), 2, -2),
#         hjust = ifelse(as.numeric(stage) %in% c(2,4), 0, 1),
#         label = detail
#       ),
#       box.colour = "black",
#       fill = "white",
#       color = "black",
#       size = 3
#     ) +
#     ggtext::geom_richtext(
#       aes(
#         y = as.numeric(stage) - .45,
#         #hjust = ifelse(as.numeric(stage) %in% c(2,4), 1, 0),
#         label = glue::glue("{grid_mult} analyses")
#       ),
#       label.color = NA,
#       fill = "white",
#       color = "black",
#       size = 3,
#       fontface = "bold"
#     ) +
#     scale_x_continuous(expand = expansion(add = c(5,5))) +
#     theme_void()
#
# }
