context("Predict CloudML")

test_that("can predict mnist model from cloudml", {
  if (!cloudml_tests_configured()) skip()

  results <- cloudml::cloudml_predict(
    jsonlite::read_json(
      "requests/tensorflow-mnist.json",
      simplifyVector = TRUE),
    "cloudml",
    "tensorflow_mnist")

  expect_true(ncol(results[[1]]) == 10)

})
