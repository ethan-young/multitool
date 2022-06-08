create_iv_grid <- function(my_data, ...){
  vars <- enquos(..., .named = TRUE)
  var_groups <- names(vars)
  print(vars)
  print(var_groups)
  map2_df(vars, var_groups, function(x,y){
    tibble(
      iv_group       = y,
      iv             = my_data %>% select(!!x) %>% names
    )
  })
}

create_dv_grid <- function(my_data, ...){
  vars <- enquos(..., .named = TRUE)
  var_groups <- names(vars)
  
  map2_df(vars, var_groups, function(x,y){
    tibble(
      dv_group      = y,
      dv            = my_data %>% select(!!x) %>% names
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
