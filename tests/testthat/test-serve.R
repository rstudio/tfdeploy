context("Serve")

test_that("can serve mnist model", {
  skip_if_no_tensorflow()

  model_dir <- system.file("models/tensorflow-mnist", package = "tfdeploy")
  serve_savedmodel_async(model_dir, function() {
    swagger_file <- tempfile(fileext = ".json")
    download.file("http://127.0.0.1:9000/swagger.json", swagger_file)
    swagger_contents <- readChar(swagger_file, file.info(swagger_file)$size)

    expect_true(grepl("serving_default", swagger_contents))
  })
})
