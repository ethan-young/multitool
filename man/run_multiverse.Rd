% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/run-multiverse.R
\name{run_multiverse}
\alias{run_multiverse}
\title{Run a multiverse based on a complete decision grid}
\usage{
run_multiverse(.grid, save_model = FALSE, ncores = 1)
}
\arguments{
\item{.grid}{a \code{tibble} produced by \code{\link{combine_all_grids}}}

\item{save_model}{logical, indicates whether to save the model object in its
entirety. The default is \code{FALSE} because model objects are usually
large and under the hood, \code{\link[broom]{tidy}} and
\code{\link[broom]{glance}} is used to summarize the most useful model
information.}

\item{ncores}{numeric. The number of cores you want to use for parallel
processing.}
}
\value{
a single \code{tibble} containing tidied results for the model and
any post-processing tests/tasks. For each unique test (e.g., an \code{lm}
or \code{aov} called on an \code{lm}), a list column with the function name
is created with \code{\link[broom]{tidy}} and \code{\link[broom]{glance}}
and any warnings or messages printed while fitting the models. Internally,
modeling and post-processing functions are checked to see if there are tidy
or glance methods available. If not, \code{summary} will be called instead.
}
\description{
Run a multiverse based on a complete decision grid
}
\examples{

\dontrun{
run_multiverse(data, grid)
}
}
