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

py_dict_get_keys <- function(x) {
  py_builtins <- reticulate::import_builtins()

  # python 3 returns keys as KeysView not list
  py_builtins$list(x$keys())
}
