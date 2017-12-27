context("Predict Exported SavedModel")

test_that("can predict mnist model from a local file", {
  model_dir <- system.file("models/tensorflow-mnist", package = "tfdeploy")

  results <- predict_savedmodel(
    list(list(images = rep(0, 784))),
    model = model_dir,
    service = "export"
  )

  expect_equal(
    length(results$predictions$scores[[1]]),
    10
  )
})
