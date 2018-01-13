context("Compare Predictions")

test_relax_json <- function(e) {
  jsonlite::fromJSON(jsonlite::toJSON(e, auto_unbox = TRUE))
}

arrays_to_vectors <- function(e) {
  for (i in seq_along(e)) {
    if (data.class(e[[i]]) == "array")
      e[[i]] <- as.vector(e[[i]])
    else if (is.list(e[[i]])) {
      e[[i]] <- arrays_to_vectors(e[[i]])
    }
  }

  e
}

test_compare_services <- function(service_defs, instances_entries, relaxed = FALSE) {
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

      if (relaxed) {
        first_prediction <- test_relax_json(first_prediction)
        other_prediction <- test_relax_json(other_prediction)
      }

      all_equal <- all.equal(
        arrays_to_vectors(first_prediction),
        arrays_to_vectors(other_prediction),
        tolerance = 1e-3,
        check.attributes = FALSE
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
      model = system.file("models/tensorflow-mnist", package = "tfdeploy"),
      type = "export"
    ),
    serve = list(
      model = system.file("models/tensorflow-mnist", package = "tfdeploy"),
      type = "serve_test"
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
    ),
    serve = list(
      model = "models/keras-mnist",
      type = "serve_test"
    )
  )

  instances_entries <- list(
    tensorflow_mnist_simple = list(list(dense_1_input = rep(0, 784))),
    tensorflow_mnist_double = list(list(dense_1_input = rep(0, 784)), list(dense_1_input = rep(0, 784)))
  )

  test_compare_services(service_defs, instances_entries)
})

test_that("multiple tensorflow inputs and outputs model predictions across services are equivalent", {
  service_defs <- list(
    cloudml = list(
      model = "tfdeploy",
      version = "tensorflow_multiple",
      type = "cloudml"
    ),
    export = list(
      model = "models/tensorflow-multiple",
      type = "export"
    ),
    serve = list(
      model = "models/tensorflow-multiple",
      type = "serve_test"
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

test_that("multiple keras inputs and outputs model predictions across services are equivalent", {
  service_defs <- list(
    cloudml = list(
      model = "tfdeploy",
      version = "keras_multiple",
      type = "cloudml"
    ),
    export = list(
      model = "models/keras-multiple",
      type = "export"
    ),
    serve = list(
      model = "models/keras-multiple",
      type = "serve_test"
    )
  )

  instances_entries <- list(
    tensorflow_mnist_simple = list(
      list(input1 = 1, input2 = 2)
    ),
    tensorflow_mnist_double = list(
      list(input1 = 1, input2 = 2),
      list(input1 = 3, input2 = 4)
    )
  )

  test_compare_services(service_defs, instances_entries)
})

test_that("tfestimators model predictions across services are equivalent", {
  service_defs <- list(
    cloudml = list(
      model = "tfdeploy",
      version = "tfestimators_mtcars",
      type = "cloudml"
    ),
    export = list(
      model = "models/tfestimators-mtcars/1514949872/",
      type = "export",
      signature_name = "predict"
    ),
    serve = list(
      model = "models/tfestimators-mtcars/1514949872/",
      type = "serve_test",
      signature_name = "predict"
    )
  )

  instances_entries <- list(
    tensorflow_mnist_simple = list(
      list(disp = 100, cyl = 6)
    ),
    tensorflow_mnist_double = list(
      list(disp = 100, cyl = 6),
      list(disp = 100, cyl = 6)
    )
  )

  test_compare_services(service_defs, instances_entries)
})
