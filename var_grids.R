create_iv_grid <- function(my_data, effect = "predictor", ...){
  vars <- enquos(..., .named = TRUE)
  var_groups <- names(vars)
  
  map2_df(vars, var_groups, function(x,y){
    tibble(
      effect         = effect,
      decision_type  = "iv",
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
      decision_type = "dv",
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
      decision_type   = "covariate",
      covariate_group = y,
      covariate       = my_data %>% select(!!x) %>% names
    )
  })
}


linear_reg = "dv ~ unp1 + control1 + control2"




