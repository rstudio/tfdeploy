#' @import tensorflow
with_new_session <- function(f) {

  if (tensorflow::tf_version() >= "2.0")
    sess <- tf$compat$v1$Session()
  else
    sess <- tf$Session()

  on.exit(sess$close(), add = TRUE)

  f(sess)
}

append_predictions_class <- function(x) {
  class(x) <- c(class(x), "savedmodel_predictions")
  x
}

#' @importFrom reticulate import_builtins
py_dict_get_keys <- function(x) {
  py_builtins <- import_builtins()
  keys <- x$keys()

  # python 3 returns keys as KeysView not list
  if (!is.list(keys) && !is.character(keys)) {
    keys <- as.list(py_builtins$list(x$keys()))
  }

  keys
}
