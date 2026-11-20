# stored pipeline code uses dplyr verbs without namespaces, as analyze_grid()'s workers expect
library(dplyr)

make_data <- function(){

  data.frame(
    id   = 1:500,
    iv1  = rnorm(500),
    iv2  = rnorm(500),
    iv3  = rnorm(500),
    mod1 = rnorm(500),
    mod2 = rnorm(500),
    mod3 = rnorm(500),
    cov1 = rnorm(500),
    cov2 = rnorm(500),
    dv1  = rnorm(500),
    dv2  = rnorm(500),
    include1 = rbinom(500, size = 1, prob = .1),
    include2 = sample(1:3, size = 500, replace = TRUE),
    include3 = rnorm(500)
  )

}

make_pipeline <- function(the_data){

  the_data |>
    add_filters(include1 == 0, include2 != 3, include2 != 2, include3 > -2.5) |>
    add_variables("ivs", iv1, iv2, iv3) |>
    add_variables("dvs", dv1, dv2) |>
    add_variables("mods", starts_with("mod"))

}

# results with completed and skipped decisions, two postprocessing steps, and
# optionally a parameter key, for testing the unpack_* functions
make_results <- function(with_keys = TRUE){
  unpack_data <-
    tibble::tibble(
      x        = rnorm(30),
      z        = rnorm(30),
      y_varies = rnorm(30),
      y_flat   = 5,
      keep     = rep(c(0, 1), 15)
    )

  a_pipeline <-
    unpack_data |>
    add_filters(keep == 1) |>
    add_variables("dvs", y_varies, y_flat) |>
    add_condition("dv varies", with(var({dvs}) > 0), on_fail = "skip") |>
    add_model("linear", lm({dvs} ~ x + z))

  if(with_keys){
    a_pipeline <- a_pipeline |> add_parameter_keys("slope", "x")
  }

  a_pipeline |>
    add_postprocess("anova", anova()) |>
    add_postprocess("coefficients", coef()) |>
    expand_pipeline() |>
    analyze_grid(show_progress = FALSE)
}
