context("Compare Predictions")

test_compare_services <- function(service_defs, instances_entries) {
  for (instances_index in length(instances_entries)) {
    services_results <- lapply(service_defs, function(service_def) {
      service_def$instances <- instances_entries[[instances_index]]
      do.call("predict_savedmodel", service_def)
    })

    first <- services_results[[1]]
    for (i in length(services_results) - 1) {
      all_equal <- all.equal(
        first$predictions$scores,
        services_results[i]$scores
      )

      if (!identical(all_equal, TRUE)) {
        fail(
          "Results across ",
          names(service_defs)[[1]],
          " and ",
          names(service_defs)[[i]],
          " for ",
          names(instances_entries)[[instances_index]],
          " do not match: ",
          all_equal
        )
      }
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
