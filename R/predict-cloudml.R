#' @export
predict_savedmodel.cloudml_predictionservice <- function(
  instances,
  location = NULL,
  service,
  signature_name = tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY,
  version = NULL,
  gcloud = NULL,
  ...) {
  cloudml::cloudml_predict(instances, name = location, version = version, gcloud = gcloud)
}
