# Filter Grid -------------------------------------------------------------
create_filter_grid <- function(my_data, ..., print = T){
  filter_exprs <- enexprs(...)
  filter_exprs_chr <- as.character(filter_exprs)
  filter_vars <- str_extract(filter_exprs_chr, paste(names(my_data), collapse = "|"))
  
  filter_grid_summary1 <- 
    map2_df(filter_exprs_chr, filter_vars, function(x, y){
      
      tibble(
        expr        = x,
        expr_var    = y,
        expr_n      = my_data %>% filter(rlang::parse_expr(x) %>% rlang::eval_tidy()) %>% nrow(),
        expr_type   = "filter"
      )
      
    })
  
  filter_grid_summary2 <- 
    filter_grid_summary1 %>% 
    pull(expr_var) %>% 
    unique() %>% 
    map_df(function(x){
      
      filter_grid_summary1 %>% 
        filter(expr_var == x) %>% 
        add_row(
          expr        = glue::glue("{x} %in% unique({x})") %>% as.character(),
          expr_var    = x,
          expr_n      = my_data %>% filter(rlang::parse_expr(expr) %>% rlang::eval_tidy()) %>% nrow(),
          expr_type   = "do nothing"
        )
      
    })
  
  filter_grid_expand <- 
    df_to_expand_prep(filter_grid_summary2, expr_var, expr) %>% 
    df_to_expand() 
  
  if(print){
    print(filter_grid_summary2)
  }
  
  list(
    grid_summary  = filter_grid_summary2,
    grid          = filter_grid_expand
  )
}

# Variable Grids ----------------------------------------------------------
exp_create_iv_grid <- function(my_data, ...){
  vars <- enquos(..., .named = TRUE)
  var_groups <- names(vars)
  
  map2_df(vars, var_groups, function(x,y){
    tibble(
      iv_group = y,
      iv       = my_data %>% select(!!x) %>% names
    )
  })
}

exp_create_dv_grid <- function(my_data, ...){
  vars <- enquos(..., .named = TRUE)
  var_groups <- names(vars)
  
  map2_df(vars, var_groups, function(x,y){
    tibble(
      dv_group = y,
      dv       = my_data %>% select(!!x) %>% names
    )
  })
}

exp_create_covariate_grid <- function(my_data, ...){
  vars <- enquos(..., .named = TRUE)
  var_groups <- names(vars)
  
  map2_df(vars, var_groups, function(x,y){
    tibble(
      covariate_group = y,
      covariate       = my_data %>% select(!!x) %>% names
    )
  })
}

create_var_grid <- function(my_data, ..., print = T){
  vars_raw <- enquos(..., .named = TRUE)
  var_groups <- names(vars_raw)
  
  var_grid_summary <- 
    map2_df(vars_raw, var_groups, function(x,y){
      tibble(
        var_group = y,
        var       = my_data %>% select(!!x) %>% names
      )
    })
  
  var_grid <- 
    df_to_expand_prep(var_grid_summary, var_group, var) %>% 
    df_to_expand()
  
  if(print){
    print(var_grid_summary)
  }
  
  list(
    grid_summary = var_grid_summary,
    grid         = var_grid
  )
  
}

# Model Grid --------------------------------------------------------------
exp_create_model_grid <- function(formulas, models) {
  
  stopifnot("The list of formulas must be of the same length as the list of models."= length(formulas)==length(models))
  
  map2_df(formulas, models, function(f, m) {
    
    tibble(
      mod_formula = f,
      mod_type    = m[[1]],
      mod_args    = ifelse(length(m) == 2, list(m[[2]]), NA)
    )
  }) %>%
    mutate(mod_group = names(formulas)) %>%
    select(mod_group, everything())
}


create_model_grid <- function(...){
  model_formulas <- enexprs(..., .named = T)
  model_formulas_chr <- as.character(model_formulas) %>% str_remove_all("\n|    ")
  
  tibble(
    mod_group   = "models",
    mod_formula = model_formulas_chr
  )

}

post_filter_code <- function(grid, ...){
  code <- enexprs(..., .named = T)
  code_chr <- as.character(code) %>% str_remove_all("\n|    ")
  
  post_filter_code <- 
    grid %>% 
    unnest(everything()) %>% 
    glue::glue_data(code_chr)
  
  bind_cols(grid, post_filter_code = post_filter_code %>% as.character())
  
}

post_analysis_code <- function(grid, ...){
  code <- enexprs(..., .named = T)
  code_chr <- as.character(code) %>% str_remove_all("\n|    ")
  
  post_analysis_code <- 
    grid %>% 
    unnest(everything()) %>% 
    glue::glue_data(code_chr)
  
  bind_cols(grid, post_analysis_code = post_analysis_code %>% as.character())
  
}
