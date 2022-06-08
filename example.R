# Setup -------------------------------------------------------------------
## Packages ----
library(tidyverse)
walk(list.files("R/", pattern = ".R$", full.names = T), source)

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
    ex_att == 0, 
    ex_imp == 0, 
    ex_sped == 0,
    scale(dv_std_sc) > -2.25,
    print = F
  ) 

sim_filter_grid$grid_summary
sim_filter_grid$grid

## Create variable grid ----
sim_var_grid <- 
  create_var_grid(
    my_data = sim_data, 
    iv1       = c(iv_unp1, iv_unp2, iv_vio1, iv_vio2),
    iv2       = c(iv_anx1, iv_anx2, iv_stress1, iv_stress2),
    covariate = c(cov_ses1, cov_ses2),
    dv        = c(dv_std_up, dv_eco_up, dv_std_sc, dv_eco_sc)
  )

sim_var_grid$grid_summary
sim_var_grid$grid

## Create a model grid ----
sim_mod_grid <- 
  create_model_grid(
    formulas = list(
      mod1 = "{dv} ~ {iv1} * test_type + control1 + control2 + (1|id)", 
      mod2 = "{dv} ~ {iv1} * test_type + control1 + (1|id)"
    ),
    models = list(
      mod1    = "lmer",
      mod2    = list("lmer", args = list(REML = FALSE, verbose = 0.5))
    )
  )

sim_mod_grid

## Create a model grid - method 2 ----
sim_mod_grid2 <- 
  create_model_grid2(
    lm({dv} ~ {iv1} * {iv2} + {covariate})
    lm({dv} ~ {iv1} * {iv2} + {covariate}), 
    lmer({dv} ~ {iv1} * {iv2} + {covariate} + (1|id))
  )

sim_mod_grid

## Combine grids ----
sim_all_grids <- 
  combine_all_grids(
    filter_grid = sim_filter_grid, 
    var_grid = sim_var_grid, 
    model_grid = sim_mod_grid
  )

sim_all_grids

# Combine Grids - Method 2 ------------------------------------------------
sim_all_grids2 <- 
  combine_all_grids2(sim_filter_grid, sim_var_grid, sim_mod_grid2)

sim_all_grids2



# Run analyses ------------------------------------------------------------

results <- 
  run_multiverse(data = sim_data, grid = sim_all_grids2)

