# Libraries ---------------------------------------------------------------
library(tidyverse)

# theme -------------------------------------------------------------------
theme_set(
  theme_bw() +
    theme(
      panel.grid = element_blank()
    )
)

# Pvalue histogram with sample sizes --------------------------------------
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



