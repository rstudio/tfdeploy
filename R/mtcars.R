#' @import tfestimators
#' @export
tfserve_mtcars_train <- function () {
  mtcars_input_fn <- function(data) {
    input_fn(data,
             features = c("disp", "cyl"),
             response = "mpg")
  }

  cols <- feature_columns(
    column_numeric("disp"),
    column_numeric("cyl")
  )

  model <- linear_regressor(feature_columns = cols)

  indices <- sample(1:nrow(mtcars), size = 0.80 * nrow(mtcars))
  train <- mtcars[indices, ]
  test  <- mtcars[-indices, ]

  model %>% train(mtcars_input_fn(train))

  model
}
