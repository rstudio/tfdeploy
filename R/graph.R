#' @export
tfserve_view_graph <- function(
  path_pb = file.path(getwd(), "trained/tensorflow-mnist/1/saved_model.pb"),
  log_dir = file.path(getwd(), "logs")) {

  gfile <- tf$python$platform$gfile
  compat <- tf$python$util$compat
  saved_model_pb2 <- tf$core$protobuf$saved_model_pb2

  with(tf$Session() %as% sess, {
    with(gfile$FastGFile(path_pb, "rb") %as% f, {
      graph_def <- tf$GraphDef()

      data <- compat$as_bytes(f$read())
      sm <- saved_model_pb2$SavedModel()
      sm$ParseFromString(data)

      if (sm$meta_graphs$`__len__`() > 1) stop("More than one graph")

      g_in <- tf$import_graph_def(sm$meta_graphs[[0]]$graph_def)
    })

    train_writer <- tf$summary$FileWriter(log_dir)
    train_writer$add_graph(sess$graph)
    train_writer$close()
  })

  tensorboard(log_dir = log_dir)
}
