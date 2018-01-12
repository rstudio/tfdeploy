#' Predict using a SavedModel
#'
#' Runs a prediction over a saved model file, local service or cloudml model.
#'
#' @param instances A list of prediction instances to be passed as input tensors
#'   to the service. Even for single predictions, a list with one entry is expected.
#'
#' @param model The model as a local path, REST url, CloudML name or graph object.
#'
#' @param type The type of object performing the prediction. Valid values
#'   are \code{cloudml}, \code{export}, \code{webapi} and \code{graph}.
#'
#' @param signature_name The named entry point to use in the model for prediction.
#'
#' @param ... Additional arguments. See \code{?predict_savedmodel.cloudml_prediction}
#'   and \code{?predict_savedmodel.graph_prediction} for additional options.
#'
#' @export
predict_savedmodel <- function(
  instances,
  model = NULL,
  type = c("export", "cloudml", "webapi", "graph"),
  signature_name = "serving_default",
  ...) {
  class(instances) <- paste0(type, "_prediction")
  UseMethod("predict_savedmodel", instances)
}

#' @export
print.savedmodel_predictions <- function(x, ...) {
  predictions <- x$predictions
  for (index in seq_along(predictions)) {
    prediction <- predictions[[index]]
    if (length(predictions) > 1)
      message("Prediction ", index, ":")

    print(prediction)
  }
}
