library(keras)

input1 <- layer_input(name = "input1", dtype = "string", shape = c(1))
input2 <- layer_input(name = "input2", dtype = "string", shape = c(1))

output1 <- layer_concatenate(name = "output1", inputs = c(input1, input2))
output2 <- layer_concatenate(name = "output2", inputs = c(input2, input1))

model <- keras_model(
  inputs = c(input1, input2),
  outputs = c(output1, output2)
)

unlink("keras-multiple", recursive = TRUE)
export_savedmodel(model, "keras-multiple")
