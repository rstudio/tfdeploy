#' @import tensorflow
with_new_session <- function(f) {
  sess <- tf$Session()
  on.exit(sess$close(), add = TRUE)

  f(sess)
}

parse_predictions <- function(json, parse = TRUE) {
  data <- jsonlite::fromJSON(json, simplifyDataFrame = FALSE)

  if (!parse) return(data)

  tryCatch({
    if (length(data$predictions) == 1) {
      as.data.frame(data$predictions)
    }
    else {
      nested <- lapply(data$predictions, function(prediction, index) {
        as.data.frame(
          c(
            list(prediction = index),
            prediction
          )
        )
      }, seq_along(data$predictions))

      do.call("rbind", nested)
    }
  }, error = function(e) {
    data
  })
}
