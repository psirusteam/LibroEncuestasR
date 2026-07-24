tabla_fmt <- function(x, digits = getOption("digits", 3), ...) {
  if (!requireNamespace("knitr", quietly = TRUE)) {
    return(x)
  }

  knitr::kable(x, digits = digits, ...)
}
