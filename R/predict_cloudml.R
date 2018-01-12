#' Predict using a CloudML SavedModel
#'
#' Performs a prediction using a CloudML model.
#'
#' @inheritParams predict_savedmodel
#'
#' @param version The version of the CloudML model.
#'
#' @export
predict_savedmodel.cloudml_prediction <- function(
  instances,
  model = NULL,
  signature_name = "serving_default",
  version = NULL,
  tidy = TRUE,
  ...) {
  cloudml::cloudml_predict(instances, name = model, version = version) %>%
    jsonlite::toJSON() %>%
    parse_predictions(tidy)
}
