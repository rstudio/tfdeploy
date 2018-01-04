predict_single_savedmodel_export <- function(instance, sess, signature_def, signature_name) {
  if (!is.list(instance)) instance <- list(instance)

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

    if (is.null(names(instance)) && length(tensor_input_names) == 1) {
      input_instance <- instance[[1]]
    }
    else if (!tensor_input_name %in% names(instance)) {
      stop("Input '", tensor_input_name, "' found in model but missing in prediciton instance.")
    } else {
      input_instance <- instance[[tensor_input_name]]
    }

    if (is.list(input_instance) && "b64" %in% names(input_instance)) {
      feed_dict[[placeholder_name]] <- tf$decode_base64(instance$b64)
    }
    else {
      feed_dict[[placeholder_name]] <- input_instance
    }

    is_multi_instance_tensor <- tensor_is_multi_instance(input_tensor)

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

  names(result) <- tensor_output_names

  if (is_multi_instance_tensor) {
    for (tensor_output_name in tensor_output_names) {
      dim(result[[tensor_output_name]]) <- dim(result[[tensor_output_name]])[-1]
    }
  }

  result
}

predict_savedmodel_export <- function(instances, sess, signature_def, signature_name) {
  # to provide the matching cloudml JSON structure, we use a dataframe
  predictions <- data.frame(instance_id = rep(0, length(instances)))

  entries <- list()
  for (instance in instances) {
    result <- predict_single_savedmodel_export(
      instance = instance,
      sess = sess,
      signature_def = signature_def,
      signature_name = signature_name
    )

    for (r in names(result)) {
      if (is.null(entries[[r]])) entries[[r]] <- list()
      entries[[r]][[length(entries[[r]]) + 1]] <- result[[r]]
    }
  }

  for (e in names(entries)) {
    predictions[[e]] <- entries[[e]]
  }

  predictions$instance_id <- NULL

  predictions
}

#' @export
predict_savedmodel.graph_predictionservice <- function(
  instances,
  model = NULL,
  service,
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

  results <- list(predictions = predictions)

  jsonlite::fromJSON(
    jsonlite::toJSON(results)
  )
}
