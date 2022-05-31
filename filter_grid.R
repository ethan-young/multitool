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
    select(starts_with("decision"), everything())
  
  if(print){
    print(filter_grid_summary2)
  }
  
  list(
    grid_summary  = filter_grid_summary2,
    grid          = filter_grid_expand
  )
}
