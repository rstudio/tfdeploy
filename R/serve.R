#' Serve a TensorFlow Model
#'
#' Serve a TensorFlow Model into a local REST API.
#'
#' @importFrom httpuv runServer
#' @export
serve <- function(model_path, host = "127.0.0.1", port = 8089) {
  load_model(model_path)
  run_server(host, port)
}

load_model <- function(model_path) {
  tf$reset_default_graph()

  graph <- tf$saved_model$loader$load(
    tf$Session(),
    list(tf$python$saved_model$tag_constants$SERVING),
    model_path)

  graph$signature_def
}

server_content_type <- function(file_path) {
  file_split <- strsplit(file_path, split = "\\.")[[1]]
  switch(file_split[[length(file_split)]],
    "css" = "text/css",
    "html" = "text/html",
    "js" = "application/javascript",
    "map" = "text/plain",
    "png" = "image/png"
  )
}

server_handlers <- function() {
  list(
    "^/swagger.json" = function(req) {
      list(
        status = 200L,
        headers = list(
          "Content-Type" = paste0(server_content_type("js"), "; charset=UTF-8")
        ),
        body = charToRaw(enc2utf8(
          swagger_from_graph()
        ))
      )
    },
    "^/[^/]*$" = function(req) {
      file_path <- system.file(paste0("swagger-ui", req$PATH_INFO), package = "tfserve")
      file_contents <- if (file.exists(file_path)) readBin(file_path, "raw", n = file.info(file_path)$size) else NULL

      list(
        status = 200L,
        headers = list(
          "Content-Type" = paste0(server_content_type(req$PATH_INFO))
        ),
        body = file_contents
      )
    },
    ".*" = function(req) {
      list(
        status = 404L,
        headers = list(
          "Content-Type" = "text/plain; charset=UTF-8"
        ),
        body = charToRaw(enc2utf8(
          "Invalid Request."
        ))
      )
    }
  )
}

run_server <- function(host, port) {
  handlers <- server_handlers()

  httpuv::runServer(host, port, list(
    onHeaders = function(req) {
      NULL
    },
    call = function(req){
      matches <- sapply(names(handlers), function(e) grepl(e, req$PATH_INFO))
      handlers[matches][[1]](req)
    },
    onWSOpen = function(ws) {
      NULL
    }
  ))
}
