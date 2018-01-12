#' @import tensorflow
with_new_session <- function(f) {
  sess <- tf$Session()
  on.exit(sess$close(), add = TRUE)

  f(sess)
}

append_predictions_class <- function(x) {
  class(x) <- c(class(x), "savedmodel_predictions")
  x
}
