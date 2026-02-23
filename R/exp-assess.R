# decision_sobol <-
#   function(.unpacked, model_output = std_coef, .by = NULL){
#
#     sobol_df <-
#       .unpacked |>
#       select(decision:ends_with("function"),{{model_output}}) |>
#       select(-matches("(model|args|perform|standardize|function)$")) |>
#       select(where(~n_distinct(.x) > 1)) |>
#       mutate(
#         total_variance = sum(({{model_output}}-mean({{model_output}}))^2)/n(),
#         .by = {{.by}}
#       )
#
#     sobol_first_order_df <-
#       sobol_df |>
#       pivot_longer(
#         -c(decision, {{model_output}}, {{.by}}, total_variance),
#         values_to = "value",
#         names_to = "decision_set"
#       ) |>
#       summarize(
#         mean_output = mean({{model_output}}),
#         .by = c(decision_set, value, {{.by}}, total_variance)
#       ) |>
#       summarize(
#         mean_output_var = sum((mean_output-mean(mean_output))^2)/n(),
#         .by = c(decision_set, {{.by}}, total_variance)
#       ) |>
#       mutate(
#         sobol_first_order = mean_output_var/total_variance
#       )
#
#     sobol_total_df <-
#       sobol_df |>
#       select(-c(decision, {{model_output}}, {{.by}}, total_variance)) |>
#       names() |>
#       map(function(sobol_var){
#
#         sobol_df |>
#           select(-!!sobol_var, -decision) |>
#           summarize(
#             var_output = sum(({{model_output}}-mean({{model_output}}))^2)/n(),
#             .by = -{{model_output}}
#           ) |>
#           summarize(
#             mean_var_output = mean(var_output),
#             .by = c({{.by}}, total_variance)
#           ) |>
#           mutate(
#             sobol_total = mean_var_output/total_variance,
#             decision_set = sobol_var
#           )
#
#       }) |>
#       list_rbind()
#
#     full_join(
#       sobol_first_order_df,
#       sobol_total_df
#     ) |>
#       mutate(
#         interaction_share = sobol_total - sobol_first_order
#       ) |>
#       select(-contains("output")) |>
#       relocate(
#         {{.by}}
#       )
#
#   }
#
# decision_sign_stability <-
#   function(
#     .unpacked,
#     model_output = std_coef,
#     zero_threshold = .01,
#     zero_handling = "include",
#     .by = NULL
#   ){
#
#     decisions_df <-
#       .unpacked |>
#       select(decision:ends_with("function"), {{model_output}}) |>
#       select(
#         -c(
#           decision,
#           matches("(model|args|perform|standardize|function)$")
#         )
#       ) |>
#       select(where(~n_distinct(.x) > 1))
#
#     if(zero_handling == "include"){
#       my_zero <- 0
#     } else{
#       my_zero <- zero_threshold
#     }
#
#     sign_df <-
#       decisions_df |>
#       mutate(
#         positive = {{model_output}} >  my_zero,
#         negative = {{model_output}} < -my_zero,
#         zero = between({{model_output}}, -zero_threshold, zero_threshold)
#       ) |>
#       pivot_longer(
#         -c(
#           {{.by}},
#           {{model_output}},
#           positive,
#           negative,
#           zero
#         ),
#         names_to = "decision_set",
#         values_to = "value"
#       ) |>
#       summarize(
#         across(c(positive, negative, zero), ~sum(.x)),
#         .by = c({{.by}}, decision_set, value)
#       ) |>
#       pivot_longer(
#         c(positive, negative, zero), names_to = "sign", values_to = "n"
#       )
#
#     zero_mass <-
#       decisions_df |>
#       mutate(
#         positive = {{model_output}} >  zero_threshold,
#         negative = {{model_output}} < -zero_threshold,
#         zero = between({{model_output}}, -zero_threshold, zero_threshold)
#       ) |>
#       pivot_longer(
#         -c(
#           {{.by}},
#           {{model_output}},
#           positive,
#           negative,
#           zero
#         ),
#         names_to = "decision_set",
#         values_to = "value"
#       ) |>
#       summarize(
#         across(c(positive, negative, zero), ~sum(.x)),
#         .by = c({{.by}}, decision_set, value)
#       ) |>
#       pivot_longer(
#         c(positive, negative, zero), names_to = "sign", values_to = "n"
#       ) |>
#       mutate(
#         prop = n/sum(n),
#         .by = c({{.by}}, decision_set, value)
#       ) |>
#       filter(sign == "zero") |>
#       summarize(
#         zero_mass = max(prop),
#         .by = c({{.by}}, decision_set)
#       )
#
#     stability <-
#       sign_df |>
#       filter(sign != "zero") |>
#       mutate(
#         prop = n/sum(n),
#         .by = c({{.by}}, decision_set, value)
#       ) |>
#       summarize(
#         overlap = min(prop),
#         dominant_level = max(prop),
#         .by = c({{.by}}, decision_set, sign)
#       ) |>
#       summarize(
#         sign_stability = sum(overlap),
#         dominant_sign  =
#           sum(
#             case_when(
#               dominant_level == max(dominant_level) & sign == "negative" ~ -1,
#               dominant_level == max(dominant_level) & sign == "positive" ~  1,
#               T ~ NA
#             ),
#             na.rm = TRUE
#           ),
#         dominant_level = max(dominant_level),
#         .by = c({{.by}}, decision_set)
#       ) |>
#       mutate(
#         dominant_sign =
#           case_when(
#             dominant_sign == 1 ~ "positive",
#             dominant_sign == -1 ~ "negative",
#             T ~ "no dominant sign"
#           )
#       )
#
#     reduce(list(stability, zero_mass), full_join)
#   }
#
# assess_param_robustness <-
#   function(
#     .multi,
#     .estimand = std_coef,
#     .use_param_key = FALSE,
#     zero_threshold = .01,
#     drop_intercept = TRUE,
#     .by = NULL
#   ){
#
#     unpacked <-
#       .multi |>
#       unpack_model_parameters()
#
#     if(.use_param_key){
#       unpacked <-
#         unpacked |>
#         filter(!is.na(parameter_key)) |>
#         mutate(
#           parameter = parameter_key
#         )
#     }
#
#     if(drop_intercept){
#       unpacked <-
#         unpacked |>
#         filter(parameter != "(Intercept)")
#     }
#
#     global_summary <-
#       unpacked |>
#       summarize(
#         n_decisions = n(),
#         mean = mean({{.estimand}}),
#         median = median({{.estimand}}),
#         iqr = IQR({{.estimand}}),
#         q05 = quantile({{.estimand}}, p = .05),
#         q95 = quantile({{.estimand}}, p = .95),
#         p_positive = sum({{.estimand}} >  zero_threshold)/n(),
#         p_negative = sum({{.estimand}} < -zero_threshold)/n(),
#         p_zero =
#           sum(between({{.estimand}}, -zero_threshold, zero_threshold))/n(),
#         sign_entropy =
#           -sum(
#             c(
#               p_positive * log2(p_positive),
#               p_negative * log2(p_negative),
#               p_zero * log2(p_zero)
#             ),
#             na.rm = TRUE
#           ),
#         .by = c(parameter, {{.by}})
#       )
#
#     decision_summary <-
#       unpacked |>
#       group_split(parameter) |>
#       map(function(x){
#         parameter_name <- distinct(x, parameter) |> pull(parameter)
#
#         x |>
#           assess_decision_sets({{.estimand}}, .by = {{.by}}) |>
#           mutate(parameter = parameter_name) |>
#           relocate(parameter)
#
#       }) |>
#       list_rbind()
#
#
#     tibble(
#       estimand = enexpr(.estimand) |> as.character(),
#       global = list(global_summary),
#       decision_dimensions = list(decision_summary)
#     )
#
#   }
#
# assess_robustness_exp <-
#   function(
#     .multi,
#     .estimand = std_coef,
#     .use_param_key = FALSE,
#     zero_threshold = .01,
#     drop_intercept = TRUE,
#     .by = NULL
#   ){
#
#     unpacked <-
#       .multi |>
#       unpack_model_parameters()
#
#     if(.use_param_key){
#       unpacked <-
#         unpacked |>
#         filter(!is.na(parameter_key)) |>
#         mutate(
#           parameter = parameter_key
#         )
#     }
#
#     if(drop_intercept){
#       unpacked <-
#         unpacked |>
#         filter(parameter != "(Intercept)")
#     }
#
#     global_summary <-
#       unpacked |>
#       summarize(
#         n_decisions = n(),
#         mean = mean({{.estimand}}),
#         median = median({{.estimand}}),
#         iqr = IQR({{.estimand}}),
#         q05 = quantile({{.estimand}}, p = .05),
#         q95 = quantile({{.estimand}}, p = .95),
#         p_positive = sum({{.estimand}} >  zero_threshold)/n(),
#         p_negative = sum({{.estimand}} < -zero_threshold)/n(),
#         p_zero =
#           sum(between({{.estimand}}, -zero_threshold, zero_threshold))/n(),
#         sign_entropy =
#           -sum(
#             c(
#               p_positive * log2(p_positive),
#               p_negative * log2(p_negative),
#               p_zero * log2(p_zero)
#             ),
#             na.rm = TRUE
#           ),
#         .by = c(parameter, {{.by}})
#       )
#
#     decision_summary <-
#       unpacked |>
#       group_split(parameter) |>
#       map(function(x){
#         parameter_name <- distinct(x, parameter) |> pull(parameter)
#
#         x |>
#           decision_set_sobol({{.estimand}}, .by = {{.by}}) |>
#           mutate(parameter = parameter_name) |>
#           relocate(parameter)
#
#       }) |>
#       list_rbind()
#
#
#     tibble(
#       estimand = enexpr(.estimand) |> as.character(),
#       global = list(global_summary),
#       decision_dimensions = list(decision_summary)
#     )
#
#   }
#
# inspect_model_iccs <- function(.multiverse, .part, .type, .estimate, term_filter = NULL){
#
#   zoomed_multi <-
#     .multiverse |>
#     reveal({{.part}}, {{.type}}) |>
#     dplyr::select(specifications, dplyr::any_of("term"), {{.estimate}})
#
#   outcome <- zoomed_multi |> dplyr::select({{.estimate}}) |> names()
#
#   if(!is.null(term_filter)){
#     zoomed_multi <-
#       zoomed_multi |>
#       dplyr::filter(stringr::str_detect(term, ":"))
#   }
#
#   multi_icc_data <-
#     zoomed_multi |>
#     tidyr::unnest(c(specifications)) |>
#     dplyr::select(dplyr::any_of(c("variables", "filters")), {{.estimate}}) |>
#     tidyr::unnest(dplyr::everything())
#
#   multi_icc_formula <-
#     multi_icc_data |>
#     dplyr::select(!{{.estimate}}) |>
#     names() |>
#     paste0("(1|", ... = _, ")", collapse = " + ")
#
#   icc_formula <- glue::glue("lme4::lmer({outcome} ~ 1 + {multi_icc_formula}, data = multi_icc_data)")
#
#   rlang::parse_expr(icc_formula) |>
#     rlang::eval_tidy() |>
#     lme4::VarCorr() |>
#     as.data.frame() |>
#     dplyr::mutate(
#       sum_var = sum(vcov),
#       icc     = vcov/sum_var,
#       icc_per = icc * 100
#     ) |>
#     dplyr::select(
#       grp, vcov, icc, icc_per
#     ) |>
#     dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~round(.x, 4)))
#
# }
#
# inspect_corr_iccs <- function(.corrs, .set, .var1, .var2){
#
#   zoomed_multi <-
#     .corrs |>
#     reveal(corrs_computed, {{.set}}) |>
#     filter(r != 1, Parameter1 == .var1, Parameter2 == .var2)
#
#   outcome <- "r"
#
#   multi_icc_data <-
#     zoomed_multi |>
#     tidyr::unnest(c(specifications)) |>
#     dplyr::select(dplyr::any_of(c("variables", "filters")), r) |>
#     tidyr::unnest(dplyr::everything())
#
#   multi_icc_formula <-
#     multi_icc_data |>
#     dplyr::select(-r) |>
#     names() |>
#     paste0("(1|", ... = _, ")", collapse = " + ")
#
#   icc_formula <- glue::glue("lme4::lmer({outcome} ~ {multi_icc_formula}, data = multi_icc_data)")
#
#   rlang::parse_expr(icc_formula) |>
#     rlang::eval_tidy() |>
#     lme4::VarCorr() |>
#     as.data.frame() |>
#     dplyr::mutate(
#       sum_var = sum(vcov),
#       icc     = vcov/sum_var,
#       icc_per = icc * 100
#     ) |>
#     dplyr::select(
#       grp, vcov, icc, icc_per
#     ) |>
#     dplyr::mutate(dplyr::across(dplyr::where(is.numeric), ~round(.x, 4)))
#
# }
#
