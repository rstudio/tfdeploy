context("Predict Serve Model")

test_that("can predict tensorflow mnist model in local serve", {
  predict_savedmodel(
    instances = list(
      list(images = rep(0, 784))
    ),
    model = system.file("models/tensorflow-mnist", package = "tfdeploy"),
    type = "serve_test"
  )
})

test_that("can predict keras mnist model in local serve", {
  predict_savedmodel(
    instances = list(
      list(dense_1_input = rep(0, 784))
    ),
    model = "models/keras-mnist",
    type = "serve_test"
  )
})

test_that("can predict tensorflow with multiple tensors model in local serve", {
  predict_savedmodel(
    instances = list(
      list(i1 = "One", i2 = "Two"),
      list(i1 = "One", i2 = "Two")
    ),
    model = "models/tensorflow-multiple",
    type = "serve_test"
  )
})

test_that("can predict keras with multiple tensors model in local serve", {
  predict_savedmodel(
    instances = list(
      list(input1 = "a", input2 = "b"),
      list(input1 = "a", input2 = "b")
    ),
    model = "models/keras-multiple",
    type = "serve_test"
  )
})
