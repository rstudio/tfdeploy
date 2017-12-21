#' Predicts over a Saved Model
#'
#' Runs a prediction over a saved model file, local service or cloudml model.
#'
#' @param instances A list of prediction instances to be passed as input tensors
#'   to the service. Even for single predictions, a list with one entry is expected.
#' @param location The location as a local path, REST url or CloudML name.
#' @param service The type of service, valid values are \code{cloudml},
#'   \code{export}, \code{webapi}.
#' @param signature_name The named entry point to use in the model for prediction.
#' @param ... Additional arguments, currently not in use.
#'
#' @export
predict_savedmodel <- function(
  instances,
  location,
  service = c("export", "cloudml", "webapi"),
  signature_name = tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY,
  ...) {
  class(instances) <- paste0(service, "_predictionservice")
  UseMethod("predict_savedmodel", instances)
}
