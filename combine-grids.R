# Combine variable grids --------------------------------------------------
combine_var_grids <- function(grid1, grid2){
  
  grid1 %>% 
    rownames_to_column(var = "row_split") %>% 
    group_by(row_split) %>% 
    group_split() %>% 
    map_df(function(x) bind_cols(x, grid2)) %>% 
    select(-row_split)
  
}

# Method 1 ----------------------------------------------------------------
combine_all_grids <- function(filter_grid = NULL, iv_grids = NULL, dv_grid = NULL, covariate_grids = NULL, model_grid = NULL){
  
  all_grids <- 
    list(
      filters    = NULL,
      ivs        = NULL,
      dvs        = NULL,
      covariates = NULL,
      models     = NULL
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
  
  if(!is.null(model_grid)) {
    
    all_grids$models <- model_grid
  }
  
  all_grids <- all_grids %>% 
    discard(is.null) %>% 
    reduce(combine_var_grids) %>% 
    mutate(
      decision = 1:n()
    ) %>% 
    select(decision, starts_with("dv"), starts_with("iv"), starts_with("covari"), starts_with("filter"), starts_with("mod"))
  
  
  if("mod_formula" %in% names(all_grids)) {
    all_grids <- all_grids %>%
      nest(data = c(starts_with("dv"), starts_with("iv"), starts_with("covari"), mod_formula)) %>%
      mutate(
        dynamic_formula = map_chr(data, function(x) glue::glue_data(x, x$mod_formula))
      ) %>%
      unnest(data) %>%
      select(-mod_formula) %>%
      rename(mod_formula = dynamic_formula) %>%
      select(decision, starts_with("dv"), starts_with("iv"), starts_with("covari"), starts_with("filter"), starts_with("mod"))
  }
  
  all_grids
}

# Method 2 ----------------------------------------------------------------
combine_all_grids2 <- function(filter_grid = NULL, var_grid = NULL, model_grid = NULL){
  
  all_grids <- 
    list(
      filters    = NULL,
      variables  = NULL,
      models     = NULL
    )
  
  if(!is.null(filter_grid)){
    all_grids$filters <- df_to_expand_prep(filter_grid$grid_summary, expr_var, expr)
  }
  
  if(!is.null(var_grid)){
    all_grids$variables <- df_to_expand_prep(var_grid$grid_summary, var_group, var)
  }
  
  if(!is.null(model_grid)) {
    all_grids$models <- df_to_expand_prep(model_grid, mod_group, mod_formula)
  }
  
  all_grids <- 
    all_grids %>% 
    discard(is.null) %>% 
    flatten() %>% 
    df_to_expand() %>% 
    mutate(
      decision = 1:n()
    ) %>% 
    select(decision, everything()) %>% 
    nest(data = c(-decision)) %>%
    mutate(
      model_syntax = map_chr(data, function(x) glue::glue_data(x, x$models)),
    ) %>%
    unnest(data) %>% 
    select(-models) %>% 
    rename_with(~ paste0("filter_", .x), matches(paste0(names(filter_grid$grid), collapse = "|"))) %>% 
    rename_with(~ paste0("var_", .x), matches(paste0(names(var_grid$grid), collapse = "|"))) 
  
  all_grids
}

