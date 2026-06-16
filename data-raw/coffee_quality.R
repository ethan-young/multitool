## data-raw/coffee_quality.R
## ----------------------------------------------------------------------------
## Prepares the `coffee_quality` dataset shipped with multitool.
##
## Source: Coffee Quality Institute review pages (January 2018), collected by
##   James LeDoux (https://github.com/jldbc/coffee-quality-database), MIT License.
##   Also distributed via the R4DS TidyTuesday project (2020-07-07).
##
## Design rationale: this script performs only NON-JUDGMENTAL cleaning —
##   selection, renaming, type/whitespace consistency. It intentionally
##   PRESERVES the analytic decision space (altitude outliers + ft/m unit
##   errors, missing variety/processing values, defect counts), because those
##   are choices meant to be made inside a multitool pipeline via add_filters()
##   and add_preprocess(), not baked in here. Pre-cleaning them would erase the
##   robustness demonstration this dataset is built to support.
## ----------------------------------------------------------------------------

library(tidyverse)

# Vendored raw source — frozen in data-raw/ so provenance does not depend on a
# live URL that may rot.
raw <- readr::read_csv("data-raw/coffee-df.csv")

coffee_quality <-
  raw |>
  dplyr::select(
    total_cup_points,
    cupper_points,
    aroma,
    flavor,
    aftertaste,
    acidity,
    body,
    balance,
    uniformity,
    clean_cup,
    sweetness,
    species,
    country_of_origin,
    variety,
    processing_method,
    moisture,
    category_one_defects,
    category_two_defects,
    quakers,
    unit_of_measurement,
    altitude_low_meters,
    altitude_high_meters,
    altitude_mean_meters
  ) |>
  dplyr::mutate(
    dplyr::across(
      c(species, country_of_origin, variety, processing_method),
      stringr::str_squish
    ),
    continent_of_origin = dplyr::case_when(
      country_of_origin %in% c(
        "Brazil", "Colombia", "Costa Rica", "Ecuador", "El Salvador",
        "Guatemala", "Haiti", "Honduras", "Mexico", "Nicaragua", "Panama",
        "Peru", "United States", "United States (Hawaii)",
        "United States (Puerto Rico)"
      ) ~ "Americas",
      country_of_origin %in% c(
        "Burundi", "Cote d?Ivoire", "Ethiopia", "Kenya", "Malawi",
        "Mauritius", "Rwanda", "Tanzania, United Republic Of", "Uganda",
        "Zambia"
      ) ~ "Africa",
      country_of_origin %in% c(
        "China", "India", "Indonesia", "Japan", "Laos", "Myanmar",
        "Philippines", "Taiwan", "Thailand", "Vietnam", "Papua New Guinea"
      ) ~ "Asia",
      .default = NA_character_
    )
  ) |>
  drop_na(country_of_origin)

usethis::use_data(coffee_quality, overwrite = TRUE)

