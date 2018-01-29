context("Predict Exported SavedModel")

test_that("can predict mnist model from a local file", {
  skip_if_no_tensorflow()

  model_dir <- system.file("models/tensorflow-mnist", package = "tfdeploy")

  results <- predict_savedmodel(
    list(list(images = rep(0, 784))),
    model = model_dir,
    service = "export"
  )

  expect_equal(
    length(results$predictions[[1]]$scores),
    10
  )
})

test_that("can predict mtcars model from a local tar", {
  skip_if_no_tensorflow()

  model_dir <- "models/tfestimators-mtcars.tar"

  results <- predict_savedmodel(
    list(list(cyl = 0, disp = 0)),
    model = model_dir,
    signature_name = "predict"
  )

  expect_gt(
    results$predictions[[1]]$predictions,
    0
  )
})
