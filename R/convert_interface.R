#' Converts a SavedModel
#'
#' Converts a TensorFlow SavedModel into a other model formats.
#'
#' @param model_dir The path to the exported model, as a string.
#'
#' @param format The target format for the converted model. Valid values
#'   are \code{tflite}.
#'
#' @param target The conversion target, currently only \code{'.tflite'}
#'   extensions supported to perform TensorFlow lite conversion.
#'
#' @param signature_name The named entry point to use in the model for prediction.
#'
#' @param ... Additional arguments. See \code{?convert_savedmodel.tflite_conversion}
#'   for additional options.
#'
#' @export
convert_savedmodel <- function(
  model_dir = NULL,
  format = c("tflite"),
  target = paste("savedmodel", format, sep = "."),
  signature_name = "serving_default",
  ...
) {
  class(instances) <- paste0(format, "_conversion")
  UseMethod("convert_savedmodel", model_dir)
}


