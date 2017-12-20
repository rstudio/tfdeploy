context("Predict")

test_that("can predict mnist model from file", {
  results <- predict_savedmodel(
    list(images = list(rep(0, 784))),
    location = model_dir,
    service = "file",
    signature_name = "predict_images"
  )

  expect_true(ncol(results[[1]]) == 10)
})
