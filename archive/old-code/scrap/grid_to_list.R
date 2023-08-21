grid_to_list <- function(my_grid, type){
  
    map(1:nrow(my_grid), function(x){
      
      grid_list <-
        my_grid %>%
        filter(row_number() == x) %>%
        pivot_longer(everything()) %>% 
        pull(value)

      names(grid_list) <- names(my_grid)
      
      grid_list
      
    }) %>%
    set_names(paste0(type, "_", 1:nrow(my_grid)))
  
}
