#' @export
predict_savedmodel.cloudml_predictionservice <- function(
  instances,
  model = NULL,
  signature_name = tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY,
  version = NULL,
  gcloud = NULL,
  ...) {
  cloudml::cloudml_predict(instances, name = model, version = version, gcloud = gcloud)
}
