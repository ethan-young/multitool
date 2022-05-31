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

    iv_grids_prep <- 
      map2(seq_along(iv_grids), iv_grids, function(x, y){
        
        y %>% rename_with(~str_replace(.x, "iv", paste0("iv", x)))
        
      })
    
    iv_grid <- reduce(iv_grids_prep, combine_var_grids)
    
    all_grids$ivs <-  iv_grid
    
  }
  
  if(!is.null(dv_grid)){
    all_grids$dvs <-  dv_grid
  }
  
  if(!is.null(covariate_grids)){
    
    covariate_grids_prep <- 
      map2(seq_along(covariate_grids), covariate_grids, function(x, y){
        
        y %>% rename_with(~str_replace(.x, "covariate", paste0("covariate", x)))
        
      })
    
    covariate_grid <- reduce(covariate_grids_prep, combine_var_grids)
    
    all_grids$covariates <-  covariate_grids
  }
  
  all_grids %>% 
    discard(is.null) %>% 
    reduce(combine_var_grids) %>% 
    mutate(
      decision = 1:n()
    ) %>% 
    select(decision, starts_with("dv"), starts_with("iv"), starts_with("covari"), starts_with("filter"))
}
