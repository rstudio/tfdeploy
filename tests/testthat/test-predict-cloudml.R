context("Predict CloudML Model")

test_that("can predict mnist model from cloudml", {
  skip_if_not(cloudml_tests_configured(), "CloudML account not correctly configured.")

  results <- cloudml::cloudml_predict(
    jsonlite::read_json(
      "requests/tensorflow-mnist.json",
      simplifyVector = TRUE),
    "cloudml",
    "tensorflow_mnist")

  expect_true(ncol(results[[1]]) == 10)

})
