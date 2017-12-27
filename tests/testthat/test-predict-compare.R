context("Compare Predictions")

test_compare_services <- function(service_defs, instances_entries) {
  for (instances_index in seq_along(instances_entries)) {
    services_results <- lapply(service_defs, function(service_def) {
      service_def$instances <- instances_entries[[instances_index]]
      do.call("predict_savedmodel", service_def)
    })

    first <- services_results[[1]]
    for (idx_result in 2:length(services_results)) {

      first_prediction <- first$predictions
      other_prediction <- services_results[[idx_result]]$predictions

      first_prediction <- first_prediction[order(colnames(first_prediction))]
      other_prediction <- other_prediction[order(colnames(other_prediction))]

      all_equal <- all.equal(
        first_prediction,
        other_prediction,
        tolerance = 1e-3
      )

      if (!identical(all_equal, TRUE)) {
        fail(
          paste0(
            "Results across '",
            names(service_defs)[[1]],
            "' and '",
            names(service_defs)[[idx_result]],
            "' for '",
            names(instances_entries)[[instances_index]],
            "' do not match: ",
            all_equal,
            ".",
            "\n   ",
            names(services_results)[[1]],
            ": ",
            as.character(jsonlite::toJSON(first_prediction)),
            "\n   ",
            names(services_results)[[idx_result]],
            ": ",
            as.character(jsonlite::toJSON(other_prediction)),
            "."
          )
        )
      }
    }
  }

  succeed()
}

test_that("mnist tensorflow model predictions across services are equivalent", {
  service_defs <- list(
    cloudml = list(
      model = "tfdeploy",
      version = "tensorflow_mnist",
      type = "cloudml"
    ),
    export = list(
      model = model_dir,
      type = "export"
    )
  )

  instances_entries <- list(
    tensorflow_mnist_simple = list(list(images = rep(0, 784))),
    tensorflow_mnist_double = list(list(images = rep(0, 784)), list(images = rep(0, 784)))
  )

  test_compare_services(service_defs, instances_entries)
})

test_that("mnist keras model predictions across services are equivalent", {
  service_defs <- list(
    cloudml = list(
      model = "tfdeploy",
      version = "keras_mnist",
      type = "cloudml"
    ),
    export = list(
      model = "models/keras-mnist",
      type = "export"
    )
  )

  instances_entries <- list(
    tensorflow_mnist_simple = list(list(input = rep(0, 784))),
    tensorflow_mnist_double = list(list(input = rep(0, 784)), list(input = rep(0, 784)))
  )

  test_compare_services(service_defs, instances_entries)
})

test_that("multiple inputs and outputs model predictions across services are equivalent", {
  service_defs <- list(
    cloudml = list(
      model = "tfdeploy",
      version = "tensorflow_multiple",
      type = "cloudml"
    ),
    export = list(
      model = "models/tensorflow-multiple",
      type = "export"
    )
  )

  instances_entries <- list(
    tensorflow_mnist_simple = list(list(i1 = "One", i2 = "Two")),
    tensorflow_mnist_double = list(
      list(i1 = "One", i2 = "Two"),
      list(i1 = "One", i2 = "Two"))
  )

  test_compare_services(service_defs, instances_entries)
})
