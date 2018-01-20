predict_savedmodel.cloudml_prediction <- function(
  instances,
  model,
  version = NULL,
  ...) {
  cloudml::cloudml_predict(instances, name = model, version = version) %>%
    append_predictions_class()
}
