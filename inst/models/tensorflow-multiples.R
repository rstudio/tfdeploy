library(tensorflow)

# define output folder
model_dir <- tempfile()

# define simple string-based tensor operations
sess <- tf$Session()
input1 <- tf$placeholder(tf$string)
input2 <- tf$placeholder(tf$string)
output1 <- tf$string_join(inputs = c("Input1: ", input1, "!"))
output2 <- tf$string_join(inputs = c("Input2: ", input2, "!"))

export_savedmodel(
  sess,
  "tensorflow-multiple",
  inputs = list(i1 = input1, i2 = input2),
  outputs = list(o1 = output1, o2 = output2),
  as_text = TRUE)
