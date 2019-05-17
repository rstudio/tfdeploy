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

#' Load a SavedModel
#'
#' Loads a SavedModel using the given TensorFlow session and
#' returns the model's graph.
#'
#' Loading a model improves performance over multiple \code{predict_savedmodel()}
#' calls.
#'
#' @param sess The TensorFlow session. `NULL` if using Eager execution.
#'
#' @param model_dir The path to the exported model, as a string. Defaults to
#'   a "savedmodel" path or the latest training run.
#'
#' @seealso [export_savedmodel()], [predict_savedmodel()]
#'
#' @examples
#' \dontrun{
#' # start session
#' sess <- tensorflow::tf$Session()
#'
#' # preload an existing model into a TensorFlow session
#' graph <- tfdeploy::load_savedmodel(
#'   sess,
#'   system.file("models/tensorflow-mnist", package = "tfdeploy")
#' )
#'
#' # perform prediction based on a pre-loaded model
#' tfdeploy::predict_savedmodel(
#'   list(rep(9, 784)),
#'   graph
#' )
#'
#' # close session
#' sess$close()
#' }
#'
#' @importFrom tools file_ext
#' @importFrom utils untar
#' @export
load_savedmodel <- function(
  sess = NULL,
  model_dir = NULL
) {

  model_dir <- find_savedmodel(model_dir)

  if (identical(file_ext(model_dir), "tar")) {
    extracted_dir <- tempfile()
    untar(model_dir, exdir = extracted_dir)
    model_dir <- extracted_dir
  }

  if (tensorflow::tf_version() >= "2.0" && tf$executing_eagerly()) {
    saved_model <- tf$compat$v1$saved_model

    if (is.null(sess))
      sess <- tf$compat$v1$Session()

  } else {
    saved_model <- tf$saved_model
    tf$reset_default_graph()
  }

  graph <- saved_model$loader$load(
    sess,
    list(tf$python$saved_model$tag_constants$SERVING),
    model_dir
  )

  graph
}
