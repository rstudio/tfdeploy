#' @export
convert_savedmodel <- function(
  model_dir = NULL,
  optimized_file = "savedmodel.tflite",
  signature_name = "serving_default") {

  if (!identical(tools::file_ext(optimized_file), "tflite"))
    stop("Use 'tflite' extensions to convert to TensorFlow light.")

  if (tf$VERSION < "1.5.0")
    stop("TensorFlow Lite requires TensorFlow 1.5 or later.")

  with_new_session(function(sess) {
    graph <- load_savedmodel(sess, model_dir)

    tensor_boundaries <- tensor_get_boundaries(sess$graph, graph$signature_def, signature_name)

    tflite_model <- tf$contrib$lite$toco_convert(
      graph$graph_def,
      unlist(tensor_boundaries$tensors$inputs, use.names = FALSE),
      unlist(tensor_boundaries$tensors$outputs, use.names = FALSE)
    )

    builtins <- reticulate::import_builtins()
    builtins$open(optimized_file, "wb")$write(tflite_model)
  })
}
