library(keras)

# load data
c(c(x_train, y_train), c(x_test, y_test)) %<-% dataset_mnist()

# reshape and rescale
x_train <- array_reshape(x_train, dim = c(nrow(x_train), 784)) / 255
x_test <- array_reshape(x_test, dim = c(nrow(x_test), 784)) / 255

# one-hot encode response
y_train <- to_categorical(y_train, 10)
y_test <- to_categorical(y_test, 10)

# define and compile model
model <- keras_model_sequential()
model %>%
  layer_dense(units = 32, activation = 'relu', input_shape = c(784),
              name = "image") %>%
  layer_dense(units = 16, activation = 'relu') %>%
  layer_dense(units = 10, activation = 'softmax',
              name = "prediction") %>%
  compile(
    loss = 'categorical_crossentropy',
    optimizer = optimizer_rmsprop(),
    metrics = c('accuracy')
  )

# train model
history <- model %>% fit(
  x_train, y_train,
  epochs = 30, batch_size = 128,
  validation_split = 0.2
)

# save model
export_savedmodel(model, "keras-mnist", as_text = TRUE)
