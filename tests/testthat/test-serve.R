context("Serve")


test_can_serve_model <- function(model) {

  test_that(paste0("can serve model:", model), {

    skip_if_no_tensorflow()
    serve_savedmodel_async(paste0(model, "/"), function() {

      if (grepl("multiple", model)) {
        instances <- list(
          instances = list(
            list(
              input1 = list(1),
              input2 = list(1)
            )
          )
        )
      } else {
        instances <- list(instances = list(list(images = rep(0, 784),
                                                dense_input = rep(0, 784))))
      }

      cont <- httr::POST(
        url = "http://127.0.0.1:9000/serving_default/predict/",
        body = instances,
        httr::content_type_json(),
        encode = "json"
      )

      pred <- unlist(httr::content(cont))

      expect_true(is.numeric(pred))

      swg <- httr::GET("http://127.0.0.1:9000/swagger.json")

      expect_equal(swg$status_code, 200)

    })

  })

}

models <- list.files("models", full.names = TRUE)
for (i in seq_along(models))
  test_can_serve_model(models[i])

