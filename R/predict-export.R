#' @export
predict_savedmodel.export_predictionservice <- function(
  instances,
  model = NULL,
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
