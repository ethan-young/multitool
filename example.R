# Setup -------------------------------------------------------------------
## Packages ----
library(tidyverse)
source("create-grids.R")
source("grid-helpers.R")
source("combine-grids.R")

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
    ex_att == 1, 
    ex_imp == 0, 
    ex_sped == 1,
    scale(dv_std_sc) > -2.25,
    print = F
  ) 

### Look at a summary ----
sim_filter_grid$grid_summary

### Full grid ----
sim_filter_grid$grid

## Create an IV grid ----
sim_iv1_grid <- 
  create_iv_grid(
    my_data = sim_data, 
    Unpredictability = c(iv_unp1, iv_unp2), 
    Violence = c(iv_vio1, iv_vio2)
  )

sim_iv1_grid

## Create a second IV grid ----
sim_iv2_grid <- 
  create_iv_grid(
    my_data = sim_data, 
    Anxiety = c(iv_anx1, iv_anx2),
    Stress  = c(iv_stress1, iv_stress2)
  )

sim_iv2_grid

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

# Combine Grids -----------------------------------------------------------
sim_all_grids <- 
  combine_all_grids(
    filter_grid     = sim_filter_grid,
    iv_grids        = list(sim_iv1_grid, sim_iv2_grid),
    dv_grid         = sim_dv_grid,
    covariate_grids = list(sim_cov_grid)
  ) 

sim_all_grids
