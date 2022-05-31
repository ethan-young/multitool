# Setup -------------------------------------------------------------------
## Packages ----
library(tidyverse)
source("filter_grid.R")
source("var_grids.R")
source("grid_to_list.R")

## Seed ----
set.seed(12345)

## Simulated Data ----
sim_data <- 
  tibble(
    id          = 1:500,
    intercept   = rnorm(500, mean = 0, sd = 3),
    iv_unp1     = rnorm(500, mean = 0, sd = 1),
    iv_unp2     = rnorm(500, mean = 0, sd = 1),
    iv_unp3     = rnorm(500, mean = 0, sd = 1),
    iv_vio1     = rnorm(500, mean = 0, sd = 1),
    iv_vio2     = rnorm(500, mean = 0, sd = 1),
    iv_vio3     = rnorm(500, mean = 0, sd = 1),
    iv_stress1  = rnorm(500, mean = 0, sd = 1),
    iv_stress2  = rnorm(500, mean = 0, sd = 1),
    iv_anx1     = rnorm(500, mean = 0, sd = 1),
    iv_anx2     = rnorm(500, mean = 0, sd = 1),
    cov_ses1    = rnorm(500, mean = 0, sd = 1),
    cov_ses2    = rnorm(500, mean = 0, sd = 1),
    cov_ses3    = rnorm(500, mean = 0, sd = 1),
    ex_sample   = sample(1:3, size = 500, replace = T),
    ex_csd      = rnorm(500, mean = 0, sd = 1) + iv_unp1 * (.15) + rnorm(500, mean = 0, 1),
    ex_sped     = rbinom(500, size = 1, prob = .1),
    ex_att      = rbinom(500, size = 1, prob = .1),
    ex_imp      = rbinom(500, size = 1, prob = .05)
  ) %>% 
  mutate(
    intercept   = ifelse(ex_sped == 1, intercept - rnorm(1,.5,.25), intercept),
    intercept   = ifelse(ex_imp == 1, intercept - rnorm(1,.5,.25), intercept),
    intercept   = ifelse(ex_att == 1, intercept - rnorm(1,.25,.25), intercept),
    dv_std_sc   = intercept + iv_unp1 * -(.2) + rnorm(500, mean = 0, 2),
    dv_eco_sc   = intercept + iv_unp1 *  (.1) + rnorm(500, mean = 0, 2),
    dv_std_up   = intercept + iv_unp1 * -(.2) + rnorm(500, mean = 0, 2),
    dv_eco_up   = intercept + iv_unp1 *  (.1) + rnorm(500, mean = 0, 2)
  )

# Create some grids -------------------------------------------------------
## Create a filtering grid ----
sim_filter_grid <- 
  create_filter_grid(
    my_data = sim_data, 
    ex_sample == 1, 
    ex_sample == 2, 
    ex_sample == 3,
    ex_att == 1, 
    ex_imp == 0, 
    ex_sped == 1,
    scale(dv_std_sc) > -2.25,
    scale(dv_std_sc) > -3,
    print = F
  ) 

### Look at a summary ----
sim_filter_grid$grid_summary

### Full grid ----
sim_filter_grid$grid

# ### Create datasets based on the grid ----
# map(sim_filter_grid$grid, function(x){
#   
#   filter_expr <- glue::glue("filter(sim_data, {paste(x, collapse = ', ')})") %>% as.character()
#   data <- rlang::parse_expr(filter_expr) %>% rlang::eval_tidy()
#   
#   list(
#     decisions = x,
#     data      = data
#   )
#   
# })

## Create an IV grid ----
sim_iv_grid <- 
  create_iv_grid(
    my_data = sim_data, 
    Unpredictability = c(iv_unp1, iv_unp2), 
    Violence = c(iv_vio1, iv_vio2)
  )

sim_iv_grid

## Create an DV grid ----
sim_dv_grid <- 
  create_dv_grid(
    my_data  = sim_data, 
    Shifting = c(dv_std_sc, dv_eco_sc), 
    Updating = c(dv_std_up, dv_eco_up)
  )

sim_dv_grid

## Create a covariate grid ----
sim_cov_grid <- 
  create_covariate_grid(
    my_data  = sim_data, 
    SES = c(cov_ses1, cov_ses2)
  )

sim_cov_grid

# Change grids to lists ---------------------------------------------------
grid_to_list(sim_filter_grid$grid, type = "filter")
grid_to_list(sim_iv_grid, type = "iv")

# Combine Grids -----------------------------------------------------------
filter_iv_grid <- 
  sim_iv_grid %>% 
  group_by(iv) %>% 
  group_split() %>% 
  map_df(function(x) bind_cols(sim_filter_grid$grid, x))

filter_iv_dv_grid <- 
  sim_dv_grid %>% 
  group_by(dv) %>% 
  group_split() %>% 
  map_df(function(x) bind_cols(filter_iv_grid, x))


grid_to_formulas <- function(grid, glue_string){
  grid %>% 
    glue::glue_data(glue_string)
}

grid_to_formulas(filter_iv_dv_grid, "{dv} ~ {iv} * test_type + control1 + control2")
