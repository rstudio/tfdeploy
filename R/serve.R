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

server_handlers <- function() {
  list(
    "^/[^/]*$" = function() {
      list(
        status = 500L,
        headers = list(
          "Content-Type" = "text/plain; charset=UTF-8"
        ),
        body = charToRaw(enc2utf8(
          "Hello from tfserve."
        ))
      )
    },
    ".*" = function() {
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
      handlers[matches][[1]]()
    },
    onWSOpen = function(ws) {
      NULL
    }
  ))
}

swagger_from_graph <- function() {
  # http://petstore.swagger.io/v2/swagger.json
}
