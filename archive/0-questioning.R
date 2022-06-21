#' Add a model summary function to the grid
#'
#' @param ... the literal code (unquoted) you would like to execute on the model
#'   object. This usually \code{\link[broom]{tidy}} but could be other
#'   functions.
#'
#'   The code should be written to work with pipes (i.e., \code{|>} or
#'   \code{\%>\%}) because the model object will be passed directly to the
#'   summary function of choice.
#'
#'   So if you fit a simple linear model like: \code{lm(y ~ x1 + x2)}, and you
#'   want to save a summary instead of the entire \code{lm} object, would simply
#'   pass \code{summary()} to \code{model_summary_code()}. The underlying code
#'   would be:
#'
#'   \code{data |> filters |> lm(y ~ x1 + x2, data = _) |> summary()}
#'
#' @return a \code{tibble} with  two columns, "summary_code" and "code".
#'
#' @export
#'
#' @examples
#'
#' library(tidyverse)
#' library(multitool)
#'
#' my_model_summary_code <- model_summary_code(tidy())
model_summary_code <- function(...){
  code <- dplyr::enexprs(..., .named = T)
  code_chr <- as.character(code) |> stringr::str_remove_all("\n|    ")

  model_summary_code <-
    purrr::imap_dfr(code_chr, function(x, y){
      tibble::tibble(
        summary = paste0("summary",y),
        code = x
      )
    })

  if(nrow(model_summary_code) ==1){
    model_summary_code |> mutate(summary = str_remove(summary, "\\d"))
  } else{
    model_summary_code
  }

}
