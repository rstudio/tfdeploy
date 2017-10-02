#' @export
tfserve_save <- function(model_path = "models/mnist", overwrite = FALSE) {
  if (overwrite && dir.exists(model_path)) unlink(model_path, recursive = TRUE)
  builder <- tf$saved_model$builder$SavedModelBuilder(model_path)
  builder$save()
}
