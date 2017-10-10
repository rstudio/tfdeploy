#' @export
tfserve_view_graph <- function(path = file.path(getwd(), "trained/tensorflow-mnist/1/saved_model.pb")) {
  gfile <- tf$python$platform$gfile
  compat <- tf$python$util$compat
  saved_model_pb2 <- tf$core$protobuf$saved_model_pb2

  with(tf$Session() %as% sess, {
    with(gfile$FastGFile(path, "rb") %as% f, {
      graph_def <- tf$GraphDef()

      data <- compat$as_bytes(f$read())
      sm <- saved_model_pb2$SavedModel()
      sm$ParseFromString(data)

      # if (length(sm$meta_graphs) > 1) stop("More than one graph")

      g_in <- tf$import_graph_def(graph_def[[1]]$graph_def)
    })
  })

  LOGDIR <- "logs"
  train_writer <- tf$summary$FileWriter(LOGDIR)
  train_writer$add_graph(sess$graph)
}
