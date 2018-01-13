predict_single_savedmodel_export <- function(instance, sess, signature_def, signature_name) {
  if (!is.list(instance)) instance <- list(instance)

  tensor_boundaries <- tensor_get_boundaries(sess$graph, signature_def, signature_name)

  signature_output_names <- names(tensor_boundaries$signatures$outputs)
  signature_inputs_names <- names(tensor_boundaries$signatures$inputs)
  signature_inputs <- tensor_boundaries$signatures$inputs
  tensor_outputs <- tensor_boundaries$tensors$outputs

  fetches_list <- tensor_outputs
  names(fetches_list) <- signature_output_names

  feed_dict <- list()
  for (signature_input_name in signature_inputs_names) {
    signature_input <- signature_inputs[[signature_input_name]]
    placeholder_name <- signature_input$name

    if (is.null(names(instance)) && length(signature_inputs_names) == 1) {
      input_instance <- instance[[1]]
    }
    else if (!signature_input_name %in% names(instance)) {
      stop("Input '", signature_input_name, "' found in model but missing in prediciton instance.")
    } else {
      input_instance <- instance[[signature_input_name]]
    }

    if (is.list(input_instance) && "b64" %in% names(input_instance)) {
      feed_dict[[placeholder_name]] <- tf$decode_base64(instance$b64)
    }
    else {
      feed_dict[[placeholder_name]] <- input_instance
    }

    is_multi_instance_tensor <- tensor_is_multi_instance(signature_input)

    if (is_multi_instance_tensor) {
      if (is.null(dim(feed_dict[[placeholder_name]])))
        input_dim <- length(feed_dict[[placeholder_name]])
      else
        input_dim <- dim(feed_dict[[placeholder_name]])

      feed_dict[[placeholder_name]] <- array(
        feed_dict[[placeholder_name]],
        c(1, input_dim)
      )
    }
  }

  result <- sess$run(
    fetches = fetches_list,
    feed_dict = feed_dict
  )

  if (is_multi_instance_tensor) {
    for (result_name in names(result)) {
      dim(result[[result_name]]) <- dim(result[[result_name]])[-1]
    }
  }

  result
}

predict_savedmodel_export <- function(instances, sess, signature_def, signature_name) {

  lapply(instances, function(instance) {
    predict_single_savedmodel_export(
      instance = instance,
      sess = sess,
      signature_def = signature_def,
      signature_name = signature_name
    )
  })

}

#' Predict using a Loaded SavedModel
#'
#' Performs a prediction using a SavedModel model already loaded using
#' \code{load_savedmodel()}.
#'
#' @param sess The active TensorFlow session.
#'
#' @export
predict_savedmodel.graph_prediction <- function(
  instances,
  signature_name = "serving_default",
  sess,
  ...) {

  if (grep("MetaGraphDef", class(model)) == 0)
    stop("MetaGraphDef type expected but found '", class(model)[[1]], "' instead.")

  signature_def <- model$signature_def

  if (!is.list(instances)) instances <- list(instances)

  predictions <- predict_savedmodel_export(
    instances = instances,
    sess = sess,
    signature_def = signature_def,
    signature_name = signature_name
  )

  list(predictions = predictions) %>%
    append_predictions_class()
}
