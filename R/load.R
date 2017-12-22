find_savedmodel <- function(path) {
  if (is.null(path)) path <- getwd()

  if (file.exists(file.path(path, "saved_model.pb")))
    path
  else if (file.exists(file.path(path, "runs"))) {
    runs <- dir(file.path(path, "runs"))
    ordered <- runs[order(runs, decreasing = T)]
    output <- file.path(path, "runs", ordered[[1]])
    model <- dir(output, recursive = T, full.names = T, pattern = "saved_model.pb")
    if (length(model) == 1)
      dirname(model)
    else
      path
  }
  else
    path
}

#' @export
load_savedmodel <- function(sess, model_dir = NULL) {
  model_dir <- find_savedmodel(model_dir)

  tf$reset_default_graph()

  graph <- tf$saved_model$loader$load(
    sess,
    list(tf$python$saved_model$tag_constants$SERVING),
    model_dir)

  graph
}
