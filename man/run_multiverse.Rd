% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run-multiverse.R
\name{run_multiverse}
\alias{run_multiverse}
\title{Run a multiverse based on a complete decision grid}
\usage{
run_multiverse(
  .grid,
  add_standardized = TRUE,
  save_model = FALSE,
  show_progress = TRUE
)
}
\arguments{
\item{.grid}{a \code{tibble} produced by \code{\link{expand_decisions}}}

\item{add_standardized}{logical. Whether to add standardized coefficients to
the model output. Defaults to \code{TRUE}.}

\item{save_model}{logical, indicates whether to save the model object in its
entirety. The default is \code{FALSE} because model objects are usually
large and under the hood, \code{\link[parameters]{parameters}} and
\code{\link[performance]{performance}} is used to summarize the most useful
model information.}

\item{show_progress}{logical, whether to show a progress bar while running.}
}
\value{
a single \code{tibble} containing tidied results for the model and
any post-processing tests/tasks. For each unique test (e.g., an \code{lm}
or \code{aov} called on an \code{lm}), a list column with the function name
is created with \code{\link[parameters]{parameters}} and
\code{\link[performance]{performance}} and any warnings or messages printed
while fitting the models. Internally, modeling and post-processing
functions are checked to see if there are tidy or glance methods available.
If not, \code{summary} will be called instead.
}
\description{
Run a multiverse based on a complete decision grid
}
\examples{
library(tidyverse)
library(multitool)

# Simulate some data
the_data <-
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

# Decision pipeline
full_pipeline <-
  the_data |>
  add_filters(include1 == 0,include2 != 3,include2 != 2,scale(include3) > -2.5) |>
  add_variables("ivs", iv1, iv2, iv3) |>
  add_variables("dvs", dv1, dv2) |>
  add_variables("mods", starts_with("mod")) |>
  add_preprocess(process_name = "scale_iv", 'mutate({ivs} = scale({ivs}))') |>
  add_preprocess(process_name = "scale_mod", mutate({mods} := scale({mods}))) |>
  add_model("no covariates",lm({dvs} ~ {ivs} * {mods})) |>
  add_model("covariate", lm({dvs} ~ {ivs} * {mods} + cov1)) |>
  add_postprocess("aov", aov())

pipeline_grid <- expand_decisions(full_pipeline)

# Run the whole multiverse
the_multiverse <- run_multiverse(pipeline_grid[1:10,])
}
