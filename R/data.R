#' Professional coffee quality ratings
#'
#' Cupping scores for batches of green coffee beans, professionally rated by the
#' Coffee Quality Institute, alongside the growing and processing
#' characteristics of each batch. The dataset is included to demonstrate two
#' `multitool` workflows: assessing the robustness of a focal effect against
#' arbitrary analytic decisions, and systematically modeling predictors against
#' outcomes across subgroups.
#'
#' @details Real-world data-quality issues are deliberately preserved rather
#'   than cleaned away, because resolving them is meant to be an explicit
#'   decision made inside a pipeline (via [add_filters()] and
#'   [add_preprocess()]) rather than a hidden one baked into the data. In
#'   particular:
#'
#' \itemize{
#'   \item \code{altitude_mean_meters} retains implausibly large values and
#'     metre/foot unit mismatches, so that altitude cleaning becomes a
#'     demonstrable fork.
#'   \item \code{variety} and \code{processing_method} contain missing values,
#'     supporting missing-data and filtering decisions.
#'   \item \code{species} is heavily imbalanced toward Arabica, so it is best
#'     used as a restriction decision (Arabica-only vs. all) rather than a
#'     balanced subgroup.
#'   \item One row has a \code{total_cup_points} of 0, a clear recording error,
#'     retained so that excluding it can itself be shown as a defensible filter.
#'   \item \code{total_cup_points} is the deterministic sum of the ten sensory
#'     scores and should not be modeled as an outcome of its own components; use
#'     \code{cupper_points} as a non-composite outcome instead.
#' }
#'
#' @format A data frame with 1,339 rows and 20 variables:
#' \describe{
#'   \item{total_cup_points}{Overall quality score (0-100); the sum of the ten sensory ratings.}
#'   \item{cupper_points}{The cupper's holistic overall rating (0-10); a non-composite outcome.}
#'   \item{aroma}{Aroma rating (0-10).}
#'   \item{flavor}{Flavor rating (0-10).}
#'   \item{aftertaste}{Aftertaste rating (0-10).}
#'   \item{acidity}{Acidity rating (0-10).}
#'   \item{body}{Body rating (0-10).}
#'   \item{balance}{Balance rating (0-10).}
#'   \item{uniformity}{Cup uniformity rating (0-10)}
#'   \item{clean_cup}{Clean cup rating (0-10)}
#'   \item{sweetness}{Sweetness rating (0-10)}
#'   \item{species}{Coffee species, "Arabica" or "Robusta" (heavily imbalanced toward Arabica).}
#'   \item{country_of_origin}{Country where the beans were grown.}
#'   \item{continent_of_origin}{Countries grouped into their respective continents.}
#'   \item{variety}{Cultivar (e.g., "Bourbon", "Typica", "Caturra"); contains missing values.}
#'   \item{processing_method}{Post-harvest processing (e.g., "Washed / Wet", "Natural / Dry"); contains missing values.}
#'   \item{moisture}{Moisture content of the green beans, as a proportion; some entries are 0.}
#'   \item{category_one_defects}{Count of category-one (primary) green-bean defects.}
#'   \item{category_two_defects}{Count of category-two (secondary) green-bean defects.}
#'   \item{quakers}{Count of quakers (unripe beans that fail to roast).}
#'   \item{unit_of_measurement}{Original unit in which altitude was reported, "m" or "ft"; the source of the unit-conversion errors in the altitude columns.}
#'   \item{altitude_low_meters}{Lower bound of reported growing altitude, in meters.}
#'   \item{altitude_high_meters}{Upper bound of reported growing altitude, in meters.}
#'   \item{altitude_mean_meters}{Mean reported growing altitude, in meters; contains missing values and known unit/entry errors (see Details).}
#' }
#'
#' @source Coffee Quality Institute review pages (January 2018), collected by
#'   James LeDoux under the MIT License
#'   (\url{https://github.com/jldbc/coffee-quality-database}) and distributed
#'   via the R for Data Science TidyTuesday project, 2020-07-07
#'   (\url{https://github.com/rfordatascience/tidytuesday/tree/master/data/2020/2020-07-07}).
#'   See the package's \code{LICENSE.note} for the bundled data's copyright and
#'   license.
#'
#' @examples
#' # A small robustness blueprint: does growing altitude predict cup quality,
#' # and how sensitive is that to altitude-cleaning and exclusion choices?
#' coffee_quality |>
#'   add_filters(altitude_mean_meters < 3000, category_two_defects < 5) |>
#'   add_variables("altitude", altitude_low_meters, altitude_mean_meters, altitude_high_meters) |>
#'   add_model("altitude effect", lm(cupper_points ~ {altitude} + moisture))
#' # pipe on to expand_decisions() |> analyze_grid() to run the full grid
#'
#' @keywords datasets
"coffee_quality"
