context("Predict Serve Model")

test_serve_predict <- function(instances, model) {
  full_path <- normalizePath(model)

  output_log <- tempfile()

  process <- processx::process$new(
    command = "RScript",
    args = c(
      "-e",
      paste0(
        "library(tfdeploy); ",
        "serve_savedmodel('",
        full_path,
        "')"
      ),
      "--vanilla"
    ),
    stdout = output_log
  )

  on.exit(expr = process$kill(), add = TRUE)

  Sys.sleep(5)

  results <- predict_savedmodel(
    instances,
    type = "webapi")

  expect_true(!is.null(results$predictions))
  expect_true(!is.null(results$predictions[[1]]))
}

test_that("can predict tensorflow mnist model in local serve", {
  test_serve_predict(
    list(
      list(images = rep(0, 784))
    ),
    system.file("models/tensorflow-mnist", package = "tfdeploy")
  )
})

test_that("can predict keras mnist model in local serve", {
  test_serve_predict(
    list(
      list(dense_1_input = rep(0, 784))
    ),
    "models/keras-mnist"
  )
})

test_that("can predict tensorflow with multiple tensors model in local serve", {
  test_serve_predict(
    list(
      list(i1 = "One", i2 = "Two"),
      list(i1 = "One", i2 = "Two")
    ),
    "models/tensorflow-multiple")
})

test_that("can predict keras with multiple tensors model in local serve", {
  test_serve_predict(
    list(
      list(input1 = "a", input2 = "b"),
      list(input1 = "a", input2 = "b")
    ),
    "models/keras-multiple")
})
