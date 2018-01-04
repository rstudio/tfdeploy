#' @export
predict_savedmodel.cloudml_predictionservice <- function(
  instances,
  model = NULL,
  signature_name = "serving_default",
  version = NULL,
  gcloud = NULL,
  ...) {
  cloudml::cloudml_predict(instances, name = model, version = version, gcloud = gcloud)
}
