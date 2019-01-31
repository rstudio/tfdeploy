#' Serve a SavedModel
#'
#' Serve a TensorFlow SavedModel as a local web api.
#'
#' @param model_dir The path to the exported model, as a string.
#' @param host Address to use to serve model, as a string.
#' @param port Port to use to serve model, as numeric.
#' @param daemonized Makes 'httpuv' server daemonized so R interactive sessions
#'   are not blocked to handle requests. To terminate a daemonized server, call
#'   'httpuv::stopDaemonizedServer()' with the handle returned from this call.
#' @param browse Launch browser with serving landing page?
#'
#' @seealso [export_savedmodel()]
#'
#' @examples
#' \dontrun{
#' # serve an existing model over a web interface
#' tfdeploy::serve_savedmodel(
#'   system.file("models/tensorflow-mnist", package = "tfdeploy")
#' )
#' }
#' @importFrom httpuv runServer
#' @import swagger
#' @export
serve_savedmodel <- function(
  model_dir,
  host = "127.0.0.1",
  port = 8089,
  daemonized = FALSE,
  browse = !daemonized
  ) {
  httpuv_start <- if (daemonized) httpuv::startDaemonizedServer else httpuv::runServer
  serve_run(model_dir, host, port, httpuv_start, browse && interactive())
}

serve_content_type <- function(file_path) {
  file_split <- strsplit(file_path, split = "\\.")[[1]]
  switch(file_split[[length(file_split)]],
    "css" = "text/css",
    "html" = "text/html",
    "js" = "application/javascript",
    "json" = "application/json",
    "map" = "text/plain",
    "png" = "image/png"
  )
}

serve_static_file_response <- function(package, file_path, replace = NULL) {
  file_path <- system.file(file_path, package = package)
  file_contents <- if (file.exists(file_path)) readBin(file_path, "raw", n = file.info(file_path)$size) else NULL

  if (!is.null(remove)) {
    contents <- rawToChar(file_contents)
    for (r in names(replace)) {
      contents <- sub(r, replace[[r]], contents)
    }
    file_contents <- charToRaw(enc2utf8(contents))
  }

  list(
    status = 200L,
    headers = list(
      "Content-Type" = paste0(serve_content_type(file_path))
    ),
    body = file_contents
  )
}

serve_invalid_request <- function(message = NULL) {
  list(
    status = 404L,
    headers = list(
      "Content-Type" = "text/plain; charset=UTF-8"
    ),
    body = charToRaw(enc2utf8(
      paste(
        "Invalid Request. ",
        message
      )
    ))
  )
}

serve_empty_page <- function(req, sess, graph) {
  list(
    status = 200L,
    headers = list(
      "Content-Type" = "text/html"
    ),
    body = "<html></html>"
  )
}

serve_handlers <- function(host, port) {
  handlers <- list(
    "^/swagger.json" = function(req, sess, graph) {
      list(
        status = 200L,
        headers = list(
          "Content-Type" = paste0(serve_content_type("json"), "; charset=UTF-8")
        ),
        body = charToRaw(enc2utf8(
          swagger_from_signature_def(graph$signature_def)
        ))
      )
    },
    "^/$" = function(req, sess, graph) {
      serve_static_file_response(
        "swagger",
        "dist/index.html",
        list(
          "http://petstore\\.swagger\\.io/v2" = "",
          "layout: \"StandaloneLayout\"" = "layout: \"StandaloneLayout\",\nvalidatorUrl : false"
        )
      )
    },
    "^/[^/]*$" = function(req, sess, graph) {
      serve_static_file_response("swagger", file.path("dist", req$PATH_INFO))
    },
    "^/[^/]+/predict" = function(req, sess, graph) {
      signature_name <- strsplit(req$PATH_INFO, "/")[[1]][[2]]

      json_raw <- req$rook.input$read()

      instances <- list()
      if (length(json_raw) > 0) {
        body <- jsonlite::fromJSON(
          rawToChar(json_raw),
          simplifyDataFrame = FALSE,
          simplifyMatrix = FALSE
        )

        instances <- body$instances

        if (!is.null(body$signature_name)) {
          signature_name <- body$signature_name
        }
      }

      result <- predict_savedmodel(
        instances,
        graph,
        type = "graph",
        sess = sess,
        signature_name = signature_name
      )

      list(
        status = 200L,
        headers = list(
          "Content-Type" = paste0(serve_content_type("json"), "; charset=UTF-8")
        ),
        body = charToRaw(enc2utf8(
          jsonlite::toJSON(result, auto_unbox = TRUE)
        ))
      )
    },
    ".*" = function(req, sess, graph) {
      stop("Invalid path.")
    }
  )

  if (!getOption("tfdeploy.swagger", default = TRUE)) {
    handlers[["^/swagger.json"]] <- serve_empty_page
    handlers[["^/$"]] <- serve_empty_page
  }

  handlers
}

message_serve_start <- function(host, port, graph) {
  hostname <- paste("http://", host, ":", port, sep = "")

  message()
  message("Starting server under ", hostname, " with the following API entry points:")

  for (signature_name in py_dict_get_keys(graph$signature_def)) {
    message("  ", hostname, "/", signature_name, "/predict/")
  }
}

serve_run <- function(model_dir, host, port, start, browse) {
  with_new_session(function(sess) {

    graph <- load_savedmodel(sess, model_dir)

    message_serve_start(host, port, graph)

    if (browse) utils::browseURL(paste0("http://", host, ":", port))

    handlers <- serve_handlers(host, port)

    start(host, port, list(
      onHeaders = function(req) {
        NULL
      },
      call = function(req) {
        tryCatch({
          matches <- sapply(names(handlers), function(e) grepl(e, req$PATH_INFO))
          handlers[matches][[1]](req, sess, graph)
        }, error = function(e) {
          serve_invalid_request(e$message)
        })
      },
      onWSOpen = function(ws) {
        NULL
      }
    ))

  })
}
