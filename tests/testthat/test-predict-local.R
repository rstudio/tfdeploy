context("Predict Local")

test_that("can predict mnist model from a local file", {
  results <- predict_savedmodel(
    list(images = list(rep(0, 784))),
    location = model_dir,
    service = "local"
  )

  expect_true(ncol(results[[1]]) == 10)
})
