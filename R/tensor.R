# Models created using the data libraries will create an input
# tensor that supports multiple entries. MINST would be (-1, 784)
# instead of just (784). This is to optimize prediction performance, but
# since we feed one at a time, this function is used to ignore instances.
tensor_is_multi_instance <- function(tensor) {
  tensor$tensor_shape$dim$`__len__`() > 0 &&
    tensor$tensor_shape$dim[[0]]$size == -1
}

# Retrieves the input and output tensors from a graph as a named list.
tensor_get_boundaries <- function(graph, signature_def, signature_name) {
  signature_names <- py_dict_get_keys(signature_def)
  if (!signature_name %in% signature_names) {
    stop(
      "Signature '", signature_name, "' not available in model signatures. ",
      "Available signatures: ", paste(signature_names, collapse = ","), ".")
  }

  signature_obj <- signature_def$get(signature_name)

  signature_input_names <- py_dict_get_keys(signature_obj$inputs)
  signature_output_names <- py_dict_get_keys(signature_obj$outputs)

  if (length(signature_input_names) == 0) {
    stop("Signature '", signature_name, "' contains no inputs.")
  }

  if (length(signature_output_names) == 0) {
    stop("Signature '", signature_name, "' contains no outputs.")
  }

  signature_inputs <- lapply(seq_along(signature_input_names), function(fetch_idx) {
    signature_obj$inputs$get(signature_input_names[[fetch_idx]])
  })
  names(signature_inputs) <- signature_input_names

  tensor_inputs <- lapply(signature_inputs, function(signature_input) {
    graph$get_tensor_by_name(signature_input$name)
  })
  tensor_input_names <- lapply(tensor_inputs, function(tensor_input) {
    tensor_inputs$name
  })
  names(tensor_inputs) <- tensor_input_names

  signature_outputs <- lapply(seq_along(signature_output_names), function(fetch_idx) {
    signature_obj$outputs$get(signature_output_names[[fetch_idx]])
  })
  names(signature_outputs) <- signature_output_names

  tensor_outputs <- lapply(signature_outputs, function(signature_output) {
    graph$get_tensor_by_name(signature_output$name)
  })
  tensor_output_names <- lapply(tensor_outputs, function(tensor_output) {
    tensor_outputs$name
  })
  names(tensor_outputs) <- tensor_output_names

  list(
    signatures = list(
      inputs = signature_inputs,
      outputs = signature_outputs
    ),
    tensors = list(
      inputs = tensor_inputs,
      outputs = tensor_outputs
    )
  )
}
