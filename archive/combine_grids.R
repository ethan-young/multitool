# Combine variable grids --------------------------------------------------
combine_var_grids <- function(grid1, grid2){
  
  grid1 %>% 
    rownames_to_column(var = "row_split") %>% 
    group_by(row_split) %>% 
    group_split() %>% 
    map_df(function(x) bind_cols(x, grid2)) %>% 
    select(-row_split)
  
}

# Combine all grids -------------------------------------------------------
combine_all_grids <- function(filter_grid = NULL, iv_grids = NULL, dv_grid = NULL, covariate_grids = NULL){
  
  print(length(filter_grid))
  print(length(iv_grids))
  print(length(dv_grid))
  print(length(covariate_grids))
  
  all_grids <- 
    list(
      filters    = NULL,
      ivs        = NULL,
      dvs        = NULL,
      covariates = NULL
    )
  
  if(!is.null(filter_grid)){
    all_grids$filters <- filter_grid$grid
  }
  
  if(!is.null(iv_grids)){
    
    all_grids$ivs <-  iv_grids
    
  }else if(!is.null(iv_grids) & length(iv_grids) > 1){
    
    iv_grids <- 
      map2(seq_along(iv_grids), iv_grids, function(x, y){
        
        y %>% rename_with(~str_replace(.x, "iv", paste0("iv", x)))
        
      })
    
    iv_grids <- reduce(iv_grids, combine_var_grids)
    
    all_grids$ivs <-  iv_grids
    
  }
  
  if(!is.null(dv_grid)){
    all_grids$dvs <-  dv_grid
  }
  
  if(!is.null(covariate_grids)){
    
    all_grids$covariates <-  covariate_grids
    
  }else if(!is.null(covariate_grids) & length(covariate_grids) > 1){
    
    covariate_grids <- 
      map2(seq_along(covariate_grids), covariate_grids, function(x, y){
        
        y %>% rename_with(~str_replace(.x, "covariate", paste0("covariate", x)))
        
      })
    
    covariate_grids <- reduce(covariate_grids, combine_var_grids)
    
    all_grids$covariates <-  covariate_grids
  }
  
  all_grids %>% 
    discard(is.null) %>% 
    reduce(combine_var_grids) %>% 
    mutate(
      decision = 1:n()
    )
}
