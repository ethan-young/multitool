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
  
  filter_grid_prep <- 
    filter_grid_summary2 %>% 
    distinct(expr_var) %>%
    pull() %>% 
    map(function(x){
      
      vect <- 
        filter_grid_summary2 %>% 
        filter(expr_var == x) %>% 
        pull(expr) %>% 
        paste0("'", ., "'", collapse=",")
      
      new_vect <- glue::glue("{x} = c({paste0(vect)})") %>% as.character()
    })
  
  filter_grid_expand <- 
    glue::glue("expand_grid({paste(filter_grid_prep, collapse = ', ')})") %>% 
    rlang::parse_expr() %>% 
    rlang::eval_tidy() %>% 
    as_tibble() %>% 
    rownames_to_column(var = "decision") %>% 
    rename_with(~paste0("filter_", .x)) %>% 
    select(matches("decision"), everything())
  
  if(print){
    print(filter_grid_summary2)
  }
  
  list(
    grid_summary  = filter_grid_summary2,
    grid          = filter_grid_expand
  )
}

# Variable Grids ----------------------------------------------------------
create_iv_grid <- function(my_data, ...){
  vars <- enquos(..., .named = TRUE)
  var_groups <- names(vars)
  
  map2_df(vars, var_groups, function(x,y){
    tibble(
      iv_group = y,
      iv       = my_data %>% select(!!x) %>% names
    )
  })
}

create_dv_grid <- function(my_data, ...){
  vars <- enquos(..., .named = TRUE)
  var_groups <- names(vars)
  
  map2_df(vars, var_groups, function(x,y){
    tibble(
      dv_group = y,
      dv       = my_data %>% select(!!x) %>% names
    )
  })
}

create_covariate_grid <- function(my_data, ...){
  vars <- enquos(..., .named = TRUE)
  var_groups <- names(vars)
  
  map2_df(vars, var_groups, function(x,y){
    tibble(
      covariate_group = y,
      covariate       = my_data %>% select(!!x) %>% names
    )
  })
}



# Model Grid --------------------------------------------------------------

create_model_grid <- function(formulas, models) {
  
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


