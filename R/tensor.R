# Models created using the data libraries will create an input
# tensor that supports multiple entries. MINST would be (-1, 784)
# instead of just (784). This is to optimize prediction performance, but
# since we feed one at a time, this function is used to ignore instances.
tensor_is_multi_instance <- function(tensor) {
  tensor$tensor_shape$dim$`__len__`() > 0 &&
    tensor$tensor_shape$dim[[0]]$size == -1
}
