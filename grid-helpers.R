grid_to_list <- function(my_grid){
  
  map(1:nrow(my_grid), function(x){
    
    my_grid <- my_grid %>% select(-filter_decision)
    
    grid_list <-
      my_grid %>%
      filter(row_number() == x) %>%
      pivot_longer(everything()) %>% 
      pull(value)
    
    names(grid_list) <- names(my_grid)
    
    grid_list
    
  }) %>%
    set_names(paste0("decision_", 1:nrow(my_grid)))
  
}

list_to_grid <- function(list_grid){
  
  if(!is.list(list_grid)){
    list_grid <- list(list_grid)
  }
  
  list_grid %>% 
    map_df(function(x) x %>% as.list() %>% as_tibble())
  
}

grid_to_formulas <- function(grid, glue_string){
  grid %>% 
    glue::glue_data(glue_string)
}

generate_multi_data <- function(my_data, filter_grid){
  
  filter_list <- grid_to_list(filter_grid$grid)
  
  multi_data_list <- 
    map(filter_list, function(x){
      
      filter_expr <- glue::glue("filter(my_data, {paste(x, collapse = ', ')})") %>% as.character()
      data <- rlang::parse_expr(filter_expr) %>% rlang::eval_tidy()
      
      list(
        decisions = x,
        data      = my_data
      )
    })
  
  multi_data_list
}
