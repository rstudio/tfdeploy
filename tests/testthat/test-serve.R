context("Serve")

test_that("can serve mnist model", {
  model_dir <- system.file("models/tensorflow-mnist", package = "tfdeploy")

  handle <- serve_savedmodel(model_dir, daemonized = TRUE, port = 9090)
  Sys.sleep(3)

  expect_true(!is.null(handle))

  swagger_file <- tempfile(fileext = ".json")
  download.file("http://127.0.0.1:9090/swagger.json", swagger_file)
  swagger_contents <- readChar(swagger_file, file.info(swagger_file)$size)

  expect_true(grepl("serving_default", swagger_contents))

  httpuv::stopDaemonizedServer(handle)
})
