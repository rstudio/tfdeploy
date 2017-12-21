context("Predict Exported SavedModel")

test_that("can predict mnist model from a local file", {
  results <- predict_savedmodel(
    list(list(images = rep(0, 784))),
    location = model_dir,
    service = "export"
  )

  expect_equal(
    length(results$predictions$scores[[1]]),
    10
  )
})
