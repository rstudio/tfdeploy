#' Serve a TensorFlow Model
#'
#' Serve a TensorFlow Model into a local REST API.
#'
#' @importFrom httpuv runServer
#' @export
serve <- function(model_path, host = "127.0.0.1", port = 8089) {
  httpuv::runServer(host, port, list(
      onHeaders = function(req) {
        NULL
      },
      call = function(req){
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
      onWSOpen = function(ws) {
        NULL
      }
    )
  )
}
