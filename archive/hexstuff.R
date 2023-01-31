library(tidyverse)
library(sysfonts)
library(showtext)

font_add_google("Roboto Mono")
font_add_google("Courier Prime")
showtext_auto()

hexstick <- hexSticker::sticker(
  "../../../../../Downloads/multiool/Slide1.jpeg",
  filename = "multitool.png",
  package = "multitool",
  h_color = "#3C525C",
  h_fill = "white",
  p_color = "#3C525C",
  p_x = 1,
  p_y = .4,
  p_family = "Courier Prime",
  asp = 1,
  p_size = 0,
  p_fontface = "bold",
  s_x = 1,
  s_y = 1,
  dpi = 2000,
  white_around_sticker = T
  )

plot(hexstick)
