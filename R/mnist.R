#' @import tensorflow

#' @export
tfserve_mnist_train <- function() {
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

  sess <- tf$Session()
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
}

#' @export
tfserve_mnist_signature <- function() {
  serialized_tf_example <- tf$placeholder(tf$string, name = 'tf_example')
  feature_configs <- list(x = tf$FixedLenFeature(shape(784), dtype = tf$float32))
  tf$parse_example(serialized_tf_example, feature_configs)

  classification_inputs <- tf$saved_model$utils$build_tensor_info(
    serialized_tf_example)

  x <- tf$placeholder(tf$float32, shape(NULL, 784L))

  W <- tf$Variable(tf$zeros(shape(784L, 10L)))
  b <- tf$Variable(tf$zeros(shape(10L)))

  y <- tf$nn$softmax(tf$matmul(x, W) + b)

  values_indices <- tf$nn$top_k(y, 10L)
  values <- tf$nn$top_k(y, 10L)$values
  indices <- tf$nn$top_k(y, 10L)$indices

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

#' @export
tfserve_mnist_save <- function(path) {
  # import os
  # import sys
  # import tensorflow as tf

  # from tensorflow.examples.tutorials.mnist import input_data
  datasets <- tf$contrib$learn$datasets

  # mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)
  mnist <- datasets$mnist$read_data_sets("MNIST-data", one_hot = TRUE)

  # sess = tf.InteractiveSession()
  sess <- tf$InteractiveSession()

  # serialized_tf_example = tf.placeholder(tf.string, name='tf_example')
  serialized_tf_example <- tf$placeholder(tf$string, name = 'tf_example')

  # feature_configs = {'x': tf.FixedLenFeature(shape=[784], dtype=tf.float32),}
  feature_configs <- list(x = tf$FixedLenFeature(shape = c(784), dtype = tf$float32))

  # tf_example = tf.parse_example(serialized_tf_example, feature_configs)
  tf_example <- tf$parse_example(serialized_tf_example, feature_configs)

  # x = tf.identity(tf_example['x'], name='x')
  x <- tf$identity(tf_example$x, name = 'x')

  # y_ = tf.placeholder('float', shape=[None, 10])
  y_ <- tf$placeholder('float', shape = shape(NULL, 10))

  # w = tf.Variable(tf.zeros([784, 10]))
  w <- tf$Variable(tf$zeros(c(784, 10)))

  # b = tf.Variable(tf.zeros([10]))
  b <- tf$Variable(tf$zeros(c(10)))

  # sess.run(tf.global_variables_initializer())
  sess$run(tf$global_variables_initializer())

  # y = tf.nn.softmax(tf.matmul(x, w) + b, name='y')
  y <- tf$nn$softmax(tf$matmul(x, w) + b, name='y')

  # cross_entropy = -tf.reduce_sum(y_ * tf.log(y))
  cross_entropy <- -tf$reduce_sum(y_ * tf$log(y))

  # train_step = tf.train.GradientDescentOptimizer(0.01).minimize(cross_entropy)
  train_step <- tf$train$GradientDescentOptimizer(0.01)$minimize(cross_entropy)

  # values, indices = tf.nn.top_k(y, 10)
  values_indices <- tf$nn$top_k(y, 10L)
  indices <- values_indices$indices
  values <- values_indices$values

  # table = tf.contrib.lookup.index_to_string_table_from_tensor(tf.constant([str(i) for i in xrange(10)]))
  table <- tf$contrib$lookup$index_to_string_table_from_tensor(
    tf$constant(as.character(1:10)))

  # prediction_classes = table.lookup(tf.to_int64(indices))
  prediction_classes <- table$lookup(tf$to_int64(indices))

  # for _ in range(1000):
  #  batch = mnist.train.next_batch(50)
  #  train_step.run(feed_dict={x: batch[0], y_: batch[1]})
  for (i in 1:1000) {
    batches <- mnist$train$next_batch(50L)

    batch_xs <- batches[[1]]
    batch_ys <- batches[[2]]
    train_step$run(feed_dict = dict(x = batch_xs, y_ = batch_ys))
  }

  # correct_prediction = tf.equal(tf.argmax(y, 1), tf.argmax(y_, 1))
  correct_prediction <- tf$equal(tf$argmax(y, 1L), tf$argmax(y_, 1L))

  # accuracy = tf.reduce_mean(tf.cast(correct_prediction, 'float'))
  accuracy <- tf$reduce_mean(tf$cast(correct_prediction, 'float'))

  # sess.run(accuracy, feed_dict={x: mnist.test.images, y_: mnist.test.labels})
  sess$run(accuracy, feed_dict = dict(x = mnist$test$images, y_ = mnist$test$labels))

  # builder = tf.saved_model.builder.SavedModelBuilder("tf1")
  builder <- tf$saved_model$builder$SavedModelBuilder(path)

  # classification_inputs = tf.saved_model.utils.build_tensor_info(serialized_tf_example)
  # classification_outputs_classes = tf.saved_model.utils.build_tensor_info(prediction_classes)
  # classification_outputs_scores = tf.saved_model.utils.build_tensor_info(values)

  classification_inputs <- tf$saved_model$utils$build_tensor_info(serialized_tf_example)
  classification_outputs_classes <- tf$saved_model$utils$build_tensor_info(prediction_classes)
  classification_outputs_scores <- tf$saved_model$utils$build_tensor_info(values)

  # classification_signature = (
  #  tf.saved_model.signature_def_utils.build_signature_def(
  #    inputs={
  #      tf.saved_model.signature_constants.CLASSIFY_INPUTS:
  #        classification_inputs
  #    },
  #    outputs={
  #      tf.saved_model.signature_constants.CLASSIFY_OUTPUT_CLASSES:
  #        classification_outputs_classes,
  #      tf.saved_model.signature_constants.CLASSIFY_OUTPUT_SCORES:
  #        classification_outputs_scores
  #    },
  #    method_name=tf.saved_model.signature_constants.CLASSIFY_METHOD_NAME))

  classification_signature_inputs <- list()
  classification_signature_inputs[[tf$saved_model$signature_constants$CLASSIFY_INPUTS]] <- classification_inputs

  classification_signature_otputs <- list()
  classification_signature_otputs[[tf$saved_model$signature_constants$CLASSIFY_OUTPUT_CLASSES]] <- classification_outputs_classes
  classification_signature_otputs[[tf$saved_model$signature_constants$CLASSIFY_OUTPUT_SCORES]] <- classification_outputs_scores

  classification_signature <- tf$saved_model$signature_def_utils$build_signature_def(
    inputs = classification_signature_inputs,
    outputs = classification_signature_otputs,
    method_name= tf$saved_model$signature_constants$CLASSIFY_METHOD_NAME
  )

  # tensor_info_x = tf.saved_model.utils.build_tensor_info(x)
  tensor_info_x <- tf$saved_model$utils$build_tensor_info(x)

  # tensor_info_y = tf.saved_model.utils.build_tensor_info(y)
  tensor_info_y <- tf$saved_model$utils$build_tensor_info(y)

  # prediction_signature = (
  #  tf.saved_model.signature_def_utils.build_signature_def(
  #   inputs={'images': tensor_info_x},
  #   outputs={'scores': tensor_info_y},
  #   method_name=tf.saved_model.signature_constants.PREDICT_METHOD_NAME))

  prediction_signature <- tf$saved_model$signature_def_utils$build_signature_def(
    inputs=list(images = tensor_info_x),
    outputs=list(scores = tensor_info_y),
    method_name=tf$saved_model$signature_constants$PREDICT_METHOD_NAME)

  # legacy_init_op = tf.group(tf.tables_initializer(), name='legacy_init_op')
  legacy_init_op <- tf$group(tf$tables_initializer(), name = "legacy_init_op")

  # builder.add_meta_graph_and_variables(
  #  sess, [tf.saved_model.tag_constants.SERVING],
  #  signature_def_map={
  #    'predict_images':
  #      prediction_signature,
  #    tf.saved_model.signature_constants.DEFAULT_SERVING_SIGNATURE_DEF_KEY:
  #      classification_signature,
  #  },
  #  legacy_init_op=legacy_init_op)

  signature_def_map_class_dig <- tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY
  signature_def_map <- list()
  signature_def_map[["predict_images"]] <- prediction_signature
  signature_def_map[[signature_def_map_class_dig]] <- classification_signature

  builder$add_meta_graph_and_variables(
    sess,
    c(
      tf$python$saved_model$tag_constants$SERVING
    ),
    signature_def_map = signature_def_map,
    legacy_init_op = legacy_init_op
  )

  # builder.save()
  builder$save()
}
