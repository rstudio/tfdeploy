#' Predicts over a Saved Model
#'
#' Runs a prediction over a saved model file, local service or cloudml model.
#'
#' @param input The prediction input to be passed as input tensors to the service.
#' @param location The location as a local path, REST url or CloudML name.
#' @param service The type of service, valid values are \code{cloudml},
#'   \code{export}, \code{webapi}.
#' @param signature_name The named entry point to use in the model for prediction.
#'
#' @export
predict_savedmodel <- function(
  input,
  location,
  service = c("export", "cloudml", "webapi"),
  signature_name = tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY,
  ...) {
  class(input) <- paste0(service, "_predictionservice")
  UseMethod("predict_savedmodel", input)
}
