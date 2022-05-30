# Load relevant libraries
library(tidyverse)
library(lmerTest)
library(broom.mixed)
library(tidymodels)
library(ggeffects)
library(interactions)
library(effectsize)
library(showtext)
library(furrr)

# Custom font for ggplot
font_add_google("Lato")
showtext_auto()

# Set the ggplot2 theme
theme_set(
  theme_bw() +
    theme(
      text = element_text(family="Lato"),
      panel.grid = element_blank()
    )
)

# Set the seed for reproducibility
set.seed(12345)

# detect cores for parrallel processing
cores <- parallel::detectCores()

# Create some data
sim_data <- 
  tibble(
    id          = 1:500,
    intercept   = rnorm(500, mean = 0, sd = 3),
    iv_unp      = rnorm(500, mean = 0, sd = 1),
    ex_sample   = sample(1:3, size = 500, replace = T),
    ex_csd      = rnorm(500, mean = 0, sd = 1) + iv_unp * (.15) + rnorm(500, mean = 0, 1),
    ex_sped     = rbinom(500, size = 1, prob = .1),
    ex_att      = rbinom(500, size = 1, prob = .1),
    ex_imp      = rbinom(500, size = 1, prob = .05)
  ) %>% 
  mutate(
    intercept   = ifelse(ex_sped == 1, intercept - rnorm(1,.5,.25), intercept),
    intercept   = ifelse(ex_imp == 1, intercept - rnorm(1,.5,.25), intercept),
    intercept   = ifelse(ex_att == 1, intercept - rnorm(1,.25,.25), intercept),
    dv_std      = intercept + iv_unp * -(.2) + rnorm(500, mean = 0, 2),
    dv_eco      = intercept + iv_unp *  (.1) + rnorm(500, mean = 0, 2)
  )

decision_grid <- 
  expand_grid(
    ex_sample    = c("ex_sample %in% c(0,1)", "ex_sample == 0"),
    ex_att       = c("ex_att %in% c(0,1)",    "ex_att == 0"),
    ex_imp       = c("ex_imp %in% c(0,1)",    "ex_imp == 0"),
    ex_sped      = c("ex_sped %in% c(0,1)",   "ex_sped == 0"),
    dv_std       = c("scale(dv_std) > -10", "scale(dv_std) > -3", "scale(dv_std) > -2.5"),
    dv_eco       = c("scale(dv_eco) > -10", "scale(dv_eco) > -3", "scale(dv_eco) > -2.5"),
    ex_csd       = c("0", "1", "2")
  )

create_filter_grid <- function(data, ...){
  filter_exprs <- enexprs(...)
  filter_exprs_chr <- as.character(filter_exprs)
  filter_vars <- str_extract(filter_exprs_chr, paste(names(data), collapse = "|"))
  
  expr_data1 <-
    tibble(
      exprs_var  = str_extract(filter_exprs_chr, paste(names(data), collapse = "|")),
      exprs_chr  = filter_exprs_chr
    )
  
  expr_grid_prep <- 
    expr_data1 %>% 
    distinct(exprs_var) %>%
    pull() %>% 
    map(function(x){
      vect <- 
        expr_data1 %>% 
        filter(exprs_var == x) %>% 
        pull(exprs_chr) %>% 
        paste0("'", ., "'", collapse=",")
      new_vect <- glue::glue("{x} = c({paste0(vect)}, 'T')") %>% as.character()
    })
  
  expand_prep <- glue::glue("expand_grid({paste(expr_grid_prep, collapse = ', ')})")
  filter_grid <- rlang::parse_expr(expand_prep) %>% rlang::eval_tidy()
  filter_grid
}

create_filter_grid(
  data = sim_data, 
  ex_sample == 1, 
  ex_sample == 2, 
  ex_sample == 3,
  ex_att == 1, 
  ex_imp == 0, 
  ex_sped == 1
) 

p_n <- tibble(
  p  = runif(500),
  b = runif(500),
  n  = sample(300:500, size = 500, replace = T) 
)

p_n %>% 
  mutate(
    p_cut   = cut(p, breaks = 20),
    p_label = as.character(p_cut) %>% str_extract(",.*]") %>% str_remove_all(",|]") %>% as.numeric()
  ) %>% 
  group_by(p_label) %>% 
  mutate(p_ns = n() , n = n/5) %>% 
  arrange(p_label) %>% 
  ggplot(aes(x = p_label)) +
  geom_bar() +
  stat_summary(aes(y = n), fun.data = "median_hilow", geom = "pointrange") +
  scale_x_continuous("P-value") +
  scale_y_continuous("Count", sec.axis = sec_axis(trans=~.*5, name="N"), expand = c(0,0)) +
  labs(
    title = "Histogram of p-values with median sample size"
  ) +
  theme(
    axis.line = element_line(),
    panel.border = element_blank(),
  )

p_n %>% 
  ggplot(aes(x = b, y = p)) +
  geom_point() +
  scale_y_log10()
