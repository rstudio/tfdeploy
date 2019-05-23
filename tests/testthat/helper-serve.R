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

wait_for_server <- function(url, output_log) {
  start <- Sys.time()
  if (!retry(function() server_success(url), 10))
    stop(
      "Failed to connect to server: ",
      url,
      " after ",
      round(as.numeric(Sys.time() - start), 2),
      " secs. Logs:\n",
      if (!is.null(output_log)) paste(readLines(output_log), collapse = "\n") else ""
    )
}

serve_savedmodel_async <- function(
  model,
  operation,
  signature_name = "serving_default") {

  full_path <- normalizePath(model)

  output_log <- tempfile()

  port_numer <- 9000

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
        "', port = ",
        port_numer,
        ")"
      ),
      "--vanilla"
    ),
    stdout = output_log,
    stderr = output_log
  )

  Sys.sleep(5)
  if (!process$is_alive()) {
    stop(paste(readLines(output_log), collapse = "\n"))
  }

  on.exit(expr = {
    process$signal(signal = 2)
    Sys.sleep(2)
  }, add = TRUE)

  url <- paste0(
    paste("http://127.0.0.1:", port_numer, "/", sep = ""),
    signature_name,
    "/predict/"
  )

  wait_for_server(url, output_log)

  operation()
}
