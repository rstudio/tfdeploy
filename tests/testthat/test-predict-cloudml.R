context("Predict CloudML Model")

test_that("can predict mnist model from cloudml", {
  skip_if_not(cloudml_tests_configured(), "CloudML account not correctly configured.")

  results <- cloudml::cloudml_predict(
    jsonlite::read_json(
      "requests/tensorflow-mnist-request.json",
      simplifyVector = TRUE),
    "tfdeploy",
    "tensorflow_mnist")

  jsonlite::write_json(results, "requests/tensorflow-mnist-response.json")

  expect_true(!is.null(results$predictions))
  expect_true(!is.null(results$predictions$scores))

  scores <- results$predictions$scores
  expect_true(length(scores[[1]]) == 10)

})
