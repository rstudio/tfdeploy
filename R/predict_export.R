#' Predict using an Exported SavedModel
#'
#' Performs a prediction using a locally exported SavedModel.
#'
#' @inheritParams predict_savedmodel
#'
#' @param signature_name The named entry point to use in the model for prediction.
#'
#' @export
predict_savedmodel.export_prediction <- function(
  instances,
  model,
  signature_name = "serving_default",
  ...) {
  with_new_session(function(sess) {

    graph <- load_savedmodel(sess, model)
    predict_savedmodel(
      instances = instances,
      model = graph,
      type = "graph",
      signature_name = signature_name,
      sess = sess
    )

  })
}
