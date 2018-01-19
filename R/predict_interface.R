#' Predict using a SavedModel
#'
#' Runs a prediction over a saved model file, web API or graph object.
#'
#' @inheritParams predict_savedmodel
#'
#' @param instances A list of prediction instances to be passed as input tensors
#'   to the service. Even for single predictions, a list with one entry is expected.
#'
#' @param model The model as a local path, a REST url or graph object.
#'
#'   A local path can be exported using \code{export_savedmodel()}, a REST URL
#'   can be created using \code{serve_savedmodel()} and a graph object loaded using
#'   \code{load_savedmodel()}.
#'
#'   A \code{type} parameter can be specified to explicitly choose the type model
#'   performing the prediction. Valid values are \code{export}, \code{webapi} and
#'   \code{graph}.
#'
#' @param ... See [predict_savedmodel.export_prediction()],
#'   [predict_savedmodel.graph_prediction()],
#'   [predict_savedmodel.webapi_prediction()] for additional options.
#'
#' #' @section Implementations:
#'
#'   - [predict_savedmodel.export_prediction()]
#'   - [predict_savedmodel.graph_prediction()]
#'   - [predict_savedmodel.webapi_prediction()]]
#'
#' @seealso [export_savedmodel()], [serve_savedmodel()], [load_savedmodel()]
#'
#' @examples
#' \dontrun{
#' # perform prediction based on an existing model
#' tfdeploy::predict_savedmodel(
#'   list(rep(9, 784)),
#'   system.file("models/tensorflow-mnist", package = "tfdeploy")
#' )
#' }
#'
#' @export
predict_savedmodel <- function(
  instances,
  model,
  ...) {

  params <- list(...)

  if (!is.null(params$type))
    type <- params$type
  else if (any(grepl("MetaGraphDef", class(model))))
    type <- "graph"
  else if (grepl("https?://", model))
    type <- "webapi"
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
