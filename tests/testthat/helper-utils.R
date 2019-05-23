skip_if_no_tensorflow <- function() {
  skip_on_cran()

  if (!reticulate::py_module_available("tensorflow"))
    skip("TensorFlow not available for testing")
}
