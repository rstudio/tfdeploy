#' @import tensorflow
with_new_session <- function(f) {
  sess <- tf$Session()
  on.exit(sess$close(), add = TRUE)

  f(sess)
}
