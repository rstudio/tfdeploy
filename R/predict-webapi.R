#' @export
predict_savedmodel.webapi_predictionservice <- function(
  instances,
  model,
  signature_name = tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY,
  url = "http://127.0.0.1:8089/api/serving_default/predict/",
  ...) {

  httr::POST(
    url = url,
    body = list(
      instances = instances
    ),
    encode = "json"
  ) %>% httr::content(as = "text") %>% jsonlite::fromJSON()

}
