#' @import tensorflow
predict_savedmodel_export <- function(input, sess, signature_def, signature_name) {
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

  input_instances <- input

  feed_dict <- list()
  if (is.list(input_instances)) {
    lapply(tensor_input_names, function(tensor_input_name) {
      placeholder_name <- signature_obj$inputs$get(tensor_input_name)$name

      if (length(tensor_input_names) == 1) {
        input_instance <- input_instances[[1]]
      }
      else if (!tensor_input_name %in% names(input_instances)) {
        stop("Input '", tensor_input_name, "' found in model but not in API request.")
      } else {
        input_instance <- input_instances[[tensor_input_name]]
      }

      if (is.list(input_instance) && "b64" %in% names(input_instance)) {
        feed_dict[[placeholder_name]] <<- tf$decode_base64(instance$b64)
      }
      else if (length(tensor_input_names) == 1 && length(names(input_instance)) == 0) {
        feed_dict[[placeholder_name]] <<- input_instance
      }
      else if (!tensor_input_name %in% names(input_instance)) {
        stop("Input named '", tensor_input_name, "' not defined in all input instances.")
      }
      else {
        feed_dict[[placeholder_name]] <<- lapply(input_instance[[tensor_input_name]], function(e) {
          if (is.list(e) && "b64" %in% names(e))
            tf$decode_base64(instance$b64)
          else
            e
        })
      }
    })
  }
  else {
    feed_dict[[signature_obj$inputs$get(tensor_input_names[[1]])$name]] <- input_instances
  }

  result <- sess$run(
    fetches = fetches_list,
    feed_dict = feed_dict
  )

  result
}

#' @export
predict_savedmodel.export_predictionservice <- function(
  input,
  location,
  service,
  signature_name = tf$saved_model$signature_constants$DEFAULT_SERVING_SIGNATURE_DEF_KEY,
  ...) {
  with_new_session(function(sess) {

    graph <- load_savedmodel(sess, location)
    signature_def <- graph$signature_def

    predict_savedmodel_export(
      input = input,
      sess = sess,
      signature_def = signature_def,
      signature_name = signature_name
    )

  })
}
