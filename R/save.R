#' @export
tfserve_save <- function(
  path = "models/mnist",
  signature = NULL,
  overwrite = FALSE)
{

  if (overwrite && dir.exists(path)) unlink(path, recursive = TRUE)
  builder <- tf$saved_model$builder$SavedModelBuilder(path)

  if (!is.null(signature)) {
    builder$add_meta_graph_and_variables(
      tf$Session(),
      list(
        tf$python$saved_model$tag_constants$SERVING
      ),
      signature_def_map = signature,
      legacy_init_op = "legacy_init_op"
    )
  }

  builder$save()
}
