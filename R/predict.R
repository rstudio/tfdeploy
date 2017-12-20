#' Predicts over a Saved Model
#'
#' Runs a prediction over a saved model file, local service or cloudml model.
#'
#' @param input The prediction input to be passed as input tensors to the service.
#' @param location The location as a local path, REST url or CloudML name.
#' @param service The type of service, valid values are \code{cloudml},
#'   \code{file}, \code{api}.
#' @param signature_name The named entry point to use in the model for prediction.
#'
#' @export
predict_savedmodel <- function(
  input,
  location,
  service = c("cloudml", "file", "api"),
  signature_name = tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY) {
  class(input) <- paste0(service, "_predictionservice")
  UseMethod("predict_savedmodel", input)
}

#' @export
predict_savedmodel.cloudml_predictionservice <- function(
  input,
  location,
  service,
  signature_name = tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY,
  ...) {

}

#' @export
predict_savedmodel.file_predictionservice <- function(
  input,
  location,
  service,
  signature_name = tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY,
  ...) {
  sess <- tf$Session()
  on.exit(sess$close(), add = TRUE)

  graph <- load_savedmodel(sess, location)
  signature_def <- graph$signature_def

  predict_savedmodel_file(
    input = input,
    sess = sess,
    signature_def = signature_def,
    signature_name = signature_name
  )
}

#' @export
predict_savedmodel.api_predictionservice <- function(
  input,
  location,
  service,
  signature_name = tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY,
  ...) {

}
