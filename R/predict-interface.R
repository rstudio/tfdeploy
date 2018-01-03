#' Predict using a SavedModel
#'
#' Runs a prediction over a saved model file, local service or cloudml model.
#'
#' @param instances A list of prediction instances to be passed as input tensors
#'   to the service. Even for single predictions, a list with one entry is expected.
#' @param model The model as a local path, REST url, CloudML name or graph object.
#' @param type The type of object performing the prediction. Valid values
#'   are \code{cloudml}, \code{export}, \code{webapi} and \code{graph}.
#' @param signature_name The named entry point to use in the model for prediction.
#' @param ... Additional arguments, currently not in use.
#'
#' @export
predict_savedmodel <- function(
  instances,
  model = NULL,
  type = c("export", "cloudml", "webapi", "graph"),
  signature_name = tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY,
  ...) {
  class(instances) <- paste0(type, "_predictionservice")
  UseMethod("predict_savedmodel", instances)
}
