predict_single_savedmodel_export <- function(instance, sess, signature_def, signature_name) {
  signature_names <- signature_def$keys()
  if (!signature_name %in% signature_names) {
    stop(
      "Signature '", signature_name, "' not available in model signatures. ",
      "Available signatures: ", paste(signature_names, collapse = ","), ".")
  }

  signature_obj <- signature_def$get(signature_name)

  tensor_input_names <- signature_obj$inputs$keys()
  if (length(tensor_input_names) == 0) {
    stop("Signature '", signature_name, "' contains no inputs.")
  }

  tensor_output_names <- signature_obj$outputs$keys()

  fetches_list <- lapply(seq_along(tensor_output_names), function(fetch_idx) {
    sess$graph$get_tensor_by_name(
      signature_obj$outputs$get(tensor_output_names[[fetch_idx]])$name
    )
  })

  feed_dict <- list()
  for (tensor_input_name in tensor_input_names) {
    input_tensor <- signature_obj$inputs$get(tensor_input_name)
    placeholder_name <- signature_obj$inputs$get(tensor_input_name)$name

    if (length(tensor_input_names) == 1) {
      input_instance <- instance[[1]]
    }
    else if (!tensor_input_name %in% names(instance)) {
      stop("Input '", tensor_input_name, "' found in model but not in API request.")
    } else {
      input_instance <- instance[[tensor_input_name]]
    }

    if (is.list(input_instance) && "b64" %in% names(input_instance)) {
      feed_dict[[placeholder_name]] <- tf$decode_base64(instance$b64)
    }
    else if (length(tensor_input_names) == 1 && length(names(input_instance)) == 0) {
      feed_dict[[placeholder_name]] <- input_instance
    }
    else if (!tensor_input_name %in% names(input_instance)) {
      stop("Input named '", tensor_input_name, "' not defined in all input instances.")
    }
    else {
      feed_dict[[placeholder_name]] <- lapply(input_instance[[tensor_input_name]], function(e) {
        if (is.list(e) && "b64" %in% names(e))
          tf$decode_base64(instance$b64)
        else
          e
      })
    }

    # models created using the data libraries will create an input
    # tensor that supports multiple entries. MINST would be (-1, 784)
    # instead of just (784). This is to optimize prediction performance, but
    # since we feed one at a time, this is currently ignored.
    if (input_tensor$tensor_shape$dim[[0]]$size == -1) {
      if(is.null(dim(feed_dict[[placeholder_name]])))
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

  for (result_idx in length(result)) {
    result[[result_idx]] <- as.vector(result[[result_idx]])
  }

  names(result) <- tensor_output_names

  result
}

#' @export
predict_savedmodel.export_predictionservice <- function(
  instances,
  location,
  service,
  signature_name = tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY,
  ...) {
  with_new_session(function(sess) {

    graph <- load_savedmodel(sess, location)
    signature_def <- graph$signature_def

    if (!is.list(instances)) {
      stop("List of instances expected to perform predictions.")
    }

    predictions <- lapply(instances, function(instance) {
      predict_single_savedmodel_export(
        instance = instance,
        sess = sess,
        signature_def = signature_def,
        signature_name = signature_name
      )
    })

    results <- list(predictions = predictions)

    jsonlite::fromJSON(
      jsonlite::toJSON(results)
    )
  })
}
