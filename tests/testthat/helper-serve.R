server_success <- function(url) {
  tryCatch({
    httr::GET(url)
    TRUE
  }, error = function(e) {
    FALSE
  })
}

retry <- function(do, times = 1, message = NULL, sleep = 1) {
  if (!is.function(do))
    stop("The 'do' parameter must be a function.")

  while (!identical(do(), TRUE) && times > 0) {
    times <- times - 1
    Sys.sleep(sleep)
  }

  times > 0
}

wait_for_server <- function(url) {
  start <- Sys.time()
  if (!retry(function() server_success(url), 10))
    stop(
      "Failed to connect to server: ",
      url,
      " after ",
      round(as.numeric(Sys.time() - start), 2),
      " secs."
    )
}

predict_savedmodel.serve_test_prediction <- function(
  instances,
  model,
  signature_name = "serving_default",
  ...) {

  full_path <- normalizePath(model)

  output_log <- tempfile()

  rscript <- system2("which", "Rscript", stdout = TRUE)
  if (length(rscript) == 0)
    stop("Failed to find Rscript")

  process <- processx::process$new(
    command = rscript,
    args = c(
      "-e",
      paste0(
        "library(tfdeploy); ",
        "serve_savedmodel('",
        full_path,
        "', port = 9090)"
      ),
      "--vanilla"
    ),
    stdout = output_log
  )

  on.exit(expr = process$kill(), add = TRUE)

  url <- paste0(
    "http://127.0.0.1:9090/",
    signature_name,
    "/predict/"
  )

  wait_for_server(url)

  predict_savedmodel(
    instances,
    model = url,
    type = "webapi")

}
