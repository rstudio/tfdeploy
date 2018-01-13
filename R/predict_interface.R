#' Predict using a SavedModel
#'
#' Runs a prediction over a saved model file, local service or cloudml model.
#'
#' @param instances A list of prediction instances to be passed as input tensors
#'   to the service. Even for single predictions, a list with one entry is expected.
#'
#' @param model The model as a local path, a REST url, CloudML name or graph object.
#'
#'   A local path can be exported using \code{export_savedmodel()}, a REST URL
#'   can be created using \code{serve_savedmodel()}, a CloudML model can be deployed
#'   usin \code{cloudml::cloudml_deploy()} and a graph object loaded using
#'   \code{load_savedmodel()}.
#'
#'   Notice that predicting over a CloudML model requires a \code{version}
#'   parameter to identify the model.
#'
#'   A \code{type} parameter can be specified to explicitly choose the type model
#'   performing the prediction. Valid values are \code{cloudml}, \code{export},
#'   \code{webapi} and \code{graph}.
#'
#' @param signature_name The named entry point to use in the model for prediction.
#'
#' @param ... See [predict_savedmodel.export_prediction()],
#'   [predict_savedmodel.graph_prediction()],
#'   [predict_savedmodel.webapi_prediction()]
#'   and [predict_savedmodel.cloudml_prediction()] for additional options.
#'
#' @seealso [export_savedmodel()], [serve_savedmodel()], [load_savedmodel()]
#'
#' @export
predict_savedmodel <- function(
  instances,
  model,
  signature_name = "serving_default",
  ...) {

  params <- list(...)

  if (!is.null(params$type))
    type <- params$type
  else if (any(grepl("MetaGraphDef", class(model))))
    type <- "graph"
  else if (grepl("https?://", model))
    type <- "webapi"
  else if ("version" %in% names(params))
    type <- "cloudml"
  else
    type <- "export"

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
