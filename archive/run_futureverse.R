#' Run a multiverse based on a complete decision grid using parallel processing
#' from \code{\link{furrr}}
#'
#' @param my_grid a \code{tibble} produced by \code{\link{combine_all_grids}}
#' @param my_data a \code{data.frame} representing the the original data.

#' @param save_model logical, indicates whether to save the model object in its
#'   entirety. The default is \code{FALSE} because model objects are usually
#'   large and under the hood, \code{\link[broom]{tidy}} and
#'   \code{\link[broom]{glance}} is used to summarize the most useful model
#'   information.
#'
#' @return a single \code{tibble} containing tidied results for the model and
#'   any post-processing tests/tasks. For each unique test (e.g., an \code{lm}
#'   or \code{aov} called on an \code{lm}), a list column with the function name
#'   is created with \code{\link[broom]{tidy}} and \code{\link[broom]{glance}}
#'   and any warnings or messages printed while fitting the models. Internally,
#'   modeling and post-processing functions are checked to see if there are tidy
#'   or glance methods available. If not, \code{summary} will be called instead.
#'
#' @examples
#'
#' \dontrun{
#' run_multiverse(data, grid)
#' }
run_futureverse <-function(my_grid, my_data, workers, save_model = FALSE){
  data_chr <- dplyr::enexpr(my_data)|> as.character()
  future::plan(future::multisession, workers = workers)

  multiverse <-
    furrr::future_map_dfr(
      1:nrow(my_grid),
      function(x){
        run_universe(
          my_grid = my_grid,
          my_data = data_chr,
          decision_num = x,
          save_model = save_model
        )
      })

  future::plan(future::sequential)

  dplyr::full_join(
    my_grid |> dplyr::select(-dplyr::contains("code")),
    multiverse,
    by = "decision"
  )

}
