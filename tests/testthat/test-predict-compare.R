context("Compare Predictions")

test_compare_services <- function(service_defs, instances_entries) {
  for (instances_index in length(instances_entries)) {
    services_results <- lapply(service_defs, function(service_def) {
      service_def$instances <- instances_entries[[instances_index]]
      do.call("predict_savedmodel", service_def)
    })

    all_equal <- do.call("all.equal", services_results)

    if (!all_equal) {
      fail(
        "Results across ",
        paste(service_defs, collapse = " and "),
        " for entry ",
        instances_index,
        "/",
        length(instances_entrie),
        " don't match: ",
        jsonlite::toJSON(services_results)
      )
    }
  }

  success()
}

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

  instances_entries <- list(
    tensorflow_mnist_simple = list(list(images = rep(0, 784))),
    tensorflow_mnist_double = list(list(images = rep(0, 784)), list(images = rep(0, 784)))
  )

  test_compare_services(service_defs, instances_entries)
})
