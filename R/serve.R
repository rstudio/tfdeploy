#' Serve a TensorFlow Model
#'
#' Serve a TensorFlow Model into a local REST/JSON API.
#'
#' @param model_dir The path to the exported model, as a string.
#' @param host Address to use to serve model, as a string.
#' @param port Port to use to serve model, as numeric.
#' @param daemonized Makes 'httpuv' server daemonized so R interactive sessions
#'   are not blocked to handle requests. To terminate a daemonized server, call
#'   'httpuv::stopDaemonizedServer()' with the handle returned from this call.
#'
#' @examples
#' \dontrun{
#'
#' library(tensorflow)
#' sess <- tf$Session()
#'
#' # (1) Train MNIST model.
#'
#' # (2) Save model with signature.
#'
#' model_dir <- "trained"
#' builder <- tf$saved_model$builder$SavedModelBuilder(model_dir)
#' builder$add_meta_graph_and_variables(
#'   sess,
#'   list(
#'     tf$python$saved_model$tag_constants$SERVING
#'   ),
#'   signature_def_map = list(
#'     serving_default = tf$saved_model$signature_def_utils$build_signature_def(
#'       inputs = list(images = tf$saved_model$utils$build_tensor_info(x)),
#'       outputs = list(scores = tf$saved_model$utils$build_tensor_info(y))
#'     )
#'   )
#' )
#' builder$save()
#'
#' # (3) Serve saved model.
#'
#' serve_savedmodel(model_dir)
#' }
#' @importFrom httpuv runServer
#' @export
serve_savedmodel <- function(
  model_dir,
  host = "127.0.0.1",
  port = 8089,
  daemonized = FALSE
  ) {
  httpuv_start <- if (daemonized) httpuv::startDaemonizedServer else httpuv::runServer
  serve_run(model_dir, host, port, httpuv_start, !daemonized && interactive())
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

serve_handlers <- function(host, port) {
  list(
    "^/swagger.json" = function(req, sess, signature_def) {
      list(
        status = 200L,
        headers = list(
          "Content-Type" = paste0(serve_content_type("json"), "; charset=UTF-8")
        ),
        body = charToRaw(enc2utf8(
          swagger_from_signature_def(signature_def)
        ))
      )
    },
    "^/$" = function(req, sess, signature_def) {
      serve_static_file_response(
        "swagger",
        "dist/index.html",
        list(
          "http://petstore\\.swagger\\.io/v2" = "",
          "layout: \"StandaloneLayout\"" = "layout: \"StandaloneLayout\",\nvalidatorUrl : false"
        )
      )
    },
    "^/[^/]*$" = function(req, sess, signature_def) {
      serve_static_file_response("swagger", file.path("dist", req$PATH_INFO))
    },
    "^/api/[^/]*/predict" = function(req, sess, signature_def) {
      signature_name <- strsplit(req$PATH_INFO, "/")[[1]][[3]]

      json_raw <- req$rook.input$read()
      json_req <- jsonlite::fromJSON(
        rawToChar(json_raw),
        simplifyDataFrame = FALSE,
        simplifyMatrix = FALSE
      )

      result <- predict_savedmodel_file(
        input = json_req$instances,
        sess = sess,
        signature_def = signature_def,
        signature_name = signature_name
      )

      list(
        status = 200L,
        headers = list(
          "Content-Type" = paste0(serve_content_type("json"), "; charset=UTF-8")
        ),
        body = charToRaw(enc2utf8(
          jsonlite::toJSON(result)
        ))
      )
    },
    ".*" = function(req, signature_def) {
      stop("Invalid path.")
    }
  )
}

serve_run <- function(model_dir, host, port, start, browse) {
  sess <- tf$Session()
  on.exit(sess$close(), add = TRUE)

  graph <- load_savedmodel(sess, model_dir)
  signature_def <- graph$signature_def

  if (browse) utils::browseURL(paste0("http://", host, ":", port))

  handlers <- serve_handlers(host, port)

  start(host, port, list(
    onHeaders = function(req) {
      NULL
    },
    call = function(req) {
      tryCatch({
        matches <- sapply(names(handlers), function(e) grepl(e, req$PATH_INFO))
        handlers[matches][[1]](req, sess, signature_def)
      }, error = function(e) {
        serve_invalid_request(e$message)
      })
    },
    onWSOpen = function(ws) {
      NULL
    }
  ))
}
