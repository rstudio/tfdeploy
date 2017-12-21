load_savedmodel <- function(sess, model_dir) {
  tf$reset_default_graph()

  graph <- tf$saved_model$loader$load(
    sess,
    list(tf$python$saved_model$tag_constants$SERVING),
    model_dir)

  graph
}
