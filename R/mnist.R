#' @import tensorflow

#' @export
tfserve_mnist_train <- function(sess) {
  datasets <- tf$contrib$learn$datasets
  mnist <- datasets$mnist$read_data_sets("MNIST-data", one_hot = TRUE)

  x <- tf$placeholder(tf$float32, shape(NULL, 784L))

  W <- tf$Variable(tf$zeros(shape(784L, 10L)))
  b <- tf$Variable(tf$zeros(shape(10L)))

  y <- tf$nn$softmax(tf$matmul(x, W) + b)

  y_ <- tf$placeholder(tf$float32, shape(NULL, 10L))
  cross_entropy <- tf$reduce_mean(-tf$reduce_sum(y_ * tf$log(y), reduction_indices=1L))

  optimizer <- tf$train$GradientDescentOptimizer(0.5)
  train_step <- optimizer$minimize(cross_entropy)

  init <- tf$global_variables_initializer()

  sess$run(init)

  for (i in 1:1000) {
    batches <- mnist$train$next_batch(100L)
    batch_xs <- batches[[1]]
    batch_ys <- batches[[2]]
    sess$run(train_step,
             feed_dict = dict(x = batch_xs, y_ = batch_ys))
  }

  correct_prediction <- tf$equal(tf$argmax(y, 1L), tf$argmax(y_, 1L))
  accuracy <- tf$reduce_mean(tf$cast(correct_prediction, tf$float32))

  sess$run(accuracy, feed_dict=dict(x = mnist$test$images, y_ = mnist$test$labels))

  list(
    input = x,
    output = y
  )
}

#' @export
tfserve_mnist_signature <- function(x, y) {
  serialized_tf_example <- tf$placeholder(tf$string, name = 'tf_example')

  classification_inputs <- tf$saved_model$utils$build_tensor_info(
    serialized_tf_example)

  values_indices <- tf$nn$top_k(y, 10L)
  values <- values_indices$values
  indices <- values_indices$indices

  table <- tf$contrib$lookup$index_to_string_table_from_tensor(
    tf$constant(as.character(1:10)))

  prediction_classes <- table$lookup(tf$to_int64(indices))

  classification_outputs_classes <- tf$saved_model$utils$build_tensor_info(
    prediction_classes)

  classification_outputs_scores <- tf$saved_model$utils$build_tensor_info(values)

  classification_signature_inputs <- list()
  classification_signature_inputs[[tf$saved_model$signature_constants$CLASSIFY_INPUTS]] <- classification_inputs

  classification_signature_otputs <- list()
  classification_signature_otputs[[tf$saved_model$signature_constants$CLASSIFY_OUTPUT_CLASSES]] <- classification_outputs_classes
  classification_signature_otputs[[tf$saved_model$signature_constants$CLASSIFY_OUTPUT_SCORES]] <- classification_outputs_scores

  classification_signature <- (
    tf$saved_model$signature_def_utils$build_signature_def(
      inputs = classification_signature_inputs,
      outputs = classification_signature_otputs,
      method_name= tf$saved_model$signature_constants$CLASSIFY_METHOD_NAME
    )
  )

  tensor_info_x <- tf$saved_model$utils$build_tensor_info(x)
  tensor_info_y <- tf$saved_model$utils$build_tensor_info(y)

  prediction_signature <- tf$saved_model$signature_def_utils$build_signature_def(
      inputs=list(images = tensor_info_x),
      outputs=list(scores = tensor_info_y),
      method_name=tf$saved_model$signature_constants$PREDICT_METHOD_NAME)

  legacy_init_op <- tf$group(tf$tables_initializer(), name = 'legacy_init_op')

  signature_def_map_class_dig <- tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY
  signature_def_map <- list()
  signature_def_map[["predict_images"]] <- prediction_signature
  signature_def_map[[signature_def_map_class_dig]] <- classification_signature

  signature_def_map
}
