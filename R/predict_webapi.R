#' Predict using a Web API
#'
#' Performs a prediction using a Web API providing a SavedModel.
#'
#' @inheritParams predict_savedmodel
#'
#' @export
predict_savedmodel.webapi_prediction <- function(
  instances,
  model,
  ...) {

  text_response <- httr::POST(
    url = model,
    body = list(
      instances = instances
    ),
    encode = "json"
  ) %>% httr::content(as = "text")

  tryCatch({
    text_response %>%
      jsonlite::fromJSON(simplifyDataFrame = FALSE) %>%
      append_predictions_class()
  }, error = function(e) {
    stop(text_response)
  })
}
