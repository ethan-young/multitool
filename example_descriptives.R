## Packages ----
library(tidyverse)
library(faux)
source("create-grids.R")
source("grid-helpers.R")
source("combine-grids.R")

## Seed ----
set.seed(12345)

sim_data <- rnorm_multi(500, 10, r = 0.8, varnames = str_c("unp", seq(1:10))) %>%
  mutate(
    id = 1:500,
    ex_group = sample(c("A", "B"), size = 500, replace = T, prob = c(0.9, 0.1))
  ) %>%
  mutate(
    unp8 = ifelse(ex_group == "B", unp8 + rnorm(500, 0, 2), unp8)
  ) %>%
  mutate(
    ex_sped     = rbinom(500, size = 1, prob = .9),
    ex_att      = rbinom(500, size = 1, prob = .9),
    ex_imp      = rbinom(500, size = 1, prob = .05)
  ) %>%
  select(id, starts_with("unp"), starts_with("ex"))



# Create Grids ------------------------------------------------------------

## Create Filter grid ----
sim_filter_grid <- 
  create_filter_grid(
    my_data = sim_data, 
    ex_group == "A", 
    ex_group == "B", 
  #  ex_att == 1, 
    ex_imp == 0, 
    ex_sped == 1,
    print = F
  ) 

### Look at a summary ----
sim_filter_grid$grid_summary

### Full grid ----
sim_filter_grid$grid


## Create Model grid ----
sim_mod_grid <- 
  create_model_grid2(
    reliability = psych::alpha(data)
  )


sim_all_grids <- 
  combine_all_grids2(
    filter_grid     = sim_filter_grid,
    model_grid      = sim_mod_grid
  ) 


# Calculate reliabilities over the multiverse -----------------------------

sim_all_grids %>%
  pmap(function(c(names(sim_all_grids))){
    
  })
