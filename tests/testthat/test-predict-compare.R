context("Compare Predictions")

test_that("mnist model predictions across services are equivalent", {
  service_defs <- list(
    cloudml = list(
      location = "tfdeploy",
      version = "tensorflow_mnist",
      service = "cloudml"
    ),
    export = list(
      location = model_dir,
      service = "export"
    )
  )

  inputs <- jsonlite::read_json(
    "requests/tensorflow-mnist-request.json",
    simplifyVector = TRUE
  )

  services_results <- lapply(service_defs, function(service_def) {
    service_def$input <- inputs

    do.call("predict_savedmodel", service_def)
  })

  all_equal <- do.call("all.equal", services_results)

  if (!all_equal) {
    fail(
      "Results across ",
      paste(service_defs, collapse = " and "),
      " do not match: ",
      jsonlite::toJSON(services_results)
    )
  }

  success()
})
