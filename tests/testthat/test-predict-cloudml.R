context("Predict CloudML Model")

test_cloudml_predict <- function(instances, model, version) {

  results <- cloudml::cloudml_predict(
    instances,
    model,
    version)

  asjson <- getOption("cloudml.prediction.diagnose")
  options(cloudml.prediction.diagnose = TRUE)
  on.exit(options(cloudml.prediction.diagnose = asjson))

  diagnose_result <- cloudml::cloudml_predict(
    instances,
    model,
    version)

  writeLines(
    paste(diagnose_result$request, collapse = "\n"),
    paste0("requests/", version, "_request.json")
  )

  writeLines(
    diagnose_result$response,
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
    list(list(dense_1_input = rep(0, 784))),
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

test_that("can predict keras with multiple tensors model in cloudml", {
  test_cloudml_predict(
    list(
      list(input1 = 1, input2 = 2),
      list(input1 = 3, input2 = 4)
    ),
    "tfdeploy",
    "keras_multiple")
})

test_that("can predict tfestimators model in cloudml", {
  test_cloudml_predict(
    list(
      list(disp = 100, cyl = 6)
    ),
    "tfdeploy",
    "tfestimators_mtcars")
})
