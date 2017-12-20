context("Serve")

test_that("can predict mnist model from file", {
  skip()
  results <- predict_savedmodel(
    list(images = list(rep(0, 784))),
    location = model_dir,
    service = "file"
  )

  expect_true(ncol(results[[1]]) == 10)
})
