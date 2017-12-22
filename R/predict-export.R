#' @export
predict_savedmodel.export_predictionservice <- function(
  instances,
  model = NULL,
  signature_name = tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY,
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
