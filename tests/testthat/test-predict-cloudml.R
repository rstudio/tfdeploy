context("Predict CloudML Model")

test_cloudml_predict <- function(instances, model, version) {
  results <- cloudml::cloudml_predict(
    instances,
    model,
    version)

  jsonlite::write_json(
    list(instances = instances),
    paste0("requests/", version, "_request.json")
  )

  jsonlite::write_json(
    results,
    paste0("requests/", version, "_response.json")
  )

  expect_true(!is.null(results$predictions))
  expect_true(!is.null(results$predictions[[1]]))
}

test_that("can predict tensorflow mnist model in cloudml", {
  test_cloudml_predict(
    list(list(images = rep(0, 784))),
    "tfdeploy",
    "tensorflow_mnist")
})

test_that("can predict keras mnist model in cloudml", {
  test_cloudml_predict(
    list(list(input = rep(0, 784))),
    "tfdeploy",
    "keras_mnist")
})

test_that("can predict tensorflow with multiple tensors model in cloudml", {
  test_cloudml_predict(
    list(
      list(i1 = "One", i2 = "Two"),
      list(i1 = "One", i2 = "Two")
    ),
    "tfdeploy",
    "tensorflow_multiple")
})
