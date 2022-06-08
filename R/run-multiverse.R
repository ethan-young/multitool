# Method 1 ----------------------------------------------------------------
exp_run_multiverse <- function(data, grid) {
  
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

# Method 2 ----------------------------------------------------------------
run_multiverse <- function(data, grid) {
  
  estimates <- 
    grid %>% 
    group_split(decision) %>% 
    map_df(function(x){
      
      filters <- 
        x %>% 
        pull(filters) %>% 
        unlist %>% 
        paste0(collapse = ", ")
      
      universe_data <- 
        glue::glue("filter(sim_data, {filters})") %>% 
        rlang::parse_expr() %>% 
        rlang::eval_tidy() 
      
      if("post_filter_code" %in% names(x)){
        universe_data <- 
          glue::glue("universe_data %>% {x$post_filter_code}") %>% 
          rlang::parse_expr() %>% 
          rlang::eval_tidy()
      }
      
      universe_analysis <- 
        x$model_syntax %>% 
        str_replace_all("\\)$", ", data = universe_data)") %>%
        rlang::parse_expr() %>%
        rlang::eval_tidy()
      
      if(str_detect(x$model_syntax, "lmer")){
        results <- broom.mixed::tidy(universe_analysis)
      } else{
        results <- broom::tidy(universe_analysis)
      }
      
      if("post_analysis_code" %in% names(x)){
        post_analysis_results <- 
          glue::glue("{x$post_analysis_code}") %>% 
          rlang::parse_expr() %>% 
          rlang::eval_tidy()
        
        results <- 
          tibble(
            decision              = x$decision,
            data                  = list(universe_data),
            results               = list(results),
            post_analysis_results = list(post_analysis_results)
          )
      } else{
        
        results <- 
          tibble(
            decision              = x$decision,
            data                  = list(universe_data),
            results               = list(results)
          )
      }
      
      message("decision ", x$decision, " executed")
      
      results 
    })
  
  
  full_join(grid, estimates, by = "decision")
  
}
