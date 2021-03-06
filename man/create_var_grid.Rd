% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/create-grids.R
\name{create_var_grid}
\alias{create_var_grid}
\title{Create a grid of all combinations of variables}
\usage{
create_var_grid(.df, ...)
}
\arguments{
\item{.df}{the actual data as a \code{data.frame} with the variables to
include in a grid}

\item{...}{named vectors with the names indicating a category of variable.
For example, you want to test if self esteem affects happiness but you may
have two variables that measure self-esteem. You could add these variables
to a multiverse to explore which variable matters (alongside other
decisions). In this case, you could add \code{self_esteem = c(self_esteem1,
  self_esteem2)} to create a grid of these variables. In practice, you can
add any kind of general variable categories e.g., ivs, dvs, covariates etc.}
}
\value{
\ a list with four components:

\describe{
\item{summary}{a summary \code{tibble} of the variables chosen.}
\item{combinations}{a summary of the number of alternatives variables for
each variable group}
\item{n_combinations}{the total number of variable combinations}
\item{grid}{the actual variable grid, the number of rows = n_combinations.
}
}
}
\description{
Create a grid of all combinations of variables
}
\examples{
library(tidyverse)
library(multitool)

the_data <-
  data.frame(
   id   = 1:500,
   iv1  = rnorm(500),
   iv2  = rnorm(500),
   iv3  = rnorm(500),
   covariate1 = rnorm(500),
   covariate2 = rnorm(500),
   dv1 = rnorm(500),
   dv2 = rnorm(500),
   filter1   = sample(1:3, size = 500, replace = TRUE),
   filter2   = rnorm(500),
   filter3   = rbinom(500, size = 1, prob = .1),
   filter4   = rbinom(500, size = 1, prob = .1)
  )

my_var_grid <-
 create_var_grid(
   .df = the_data,
   iv = c(iv1, iv2, iv3),
   dv = c(dv1, dv2),
   covariates = c(covariate1, covariate2)
 )
}
