run_multiverse <- function(data, grid) {
  
  model_output <- grid %>%
    select(matches("^filter_"), model_syntax) %>%
    grid_to_list() %>%
    map_df(function(universe){
      
      # Filter data
      filtered_data <- data %>%
        filter(rlang::parse_expr(universe[str_detect(names(universe), "^filter_")] %>% str_c(collapse = " & ")) %>% rlang::eval_tidy())
      
      # Fit model
      mod <- universe[str_detect(names(universe), "^model_syntax")] %>%
        str_replace_all("\\)$", ", data = data_filtered)") %>%
        rlang::parse_expr() %>%
        rlang::eval_tidy()
      
      
      # Return results
      tibble(
        data = list(filtered_data),
        model = list(mod)
      )
    })
  
  grid %>%
    bind_cols(model_output)
}

