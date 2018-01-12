#' Predict using a Web API
#'
#' Performs a prediction using a Web API providing a SavedModel.
#'
#' @export
predict_savedmodel.webapi_prediction <- function(
  instances,
  model = "http://127.0.0.1:8089/serving_default/predict/",
  signature_name = "serving_default",
  ...) {

  httr::POST(
    url = model,
    body = list(
      instances = instances
    ),
    encode = "json"
  ) %>% httr::content(as = "text") %>%
    jsonlite::fromJSON(simplifyDataFrame = FALSE) %>%
    append_predictions_class()

}
