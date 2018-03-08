library(tfestimators)

r <- rnorm(100)
q <- data.frame(x1 = r,
                x2 = sample(LETTERS, 100, replace = TRUE),
                y = 2*r + rep(c(0,1,1,0), 25))
indices <- sample(1:nrow(q), size = 0.80 * nrow(q))
train <- q[indices, ]
test  <- q[-indices, ]

# input function
my_input_fn <- function(dat, num_epochs = 1){
  tfestimators::input_fn(
    dat,
    features = c("x1", "x2"),
    response = "y",
    batch_size = 10,
    num_epochs = num_epochs
  )
}

# feature columns
cols <- tfestimators::feature_columns(
  tfestimators::column_numeric("x1"),
  tfestimators::column_indicator(tfestimators::column_categorical_with_identity("x2", num_buckets = 26))
)

# DNN regressor
model <- tfestimators::dnn_regressor(c(10,10), feature_columns = cols, './tmp')

# train the model
model %>% tfestimators::train(my_input_fn(train, 100))

# export with custom function
tfestimators::export_savedmodel(
  model,
  "tests/testthat/models/tfestimators-example",
  serving_input_receiver_fn = tf$estimator$export$build_parsing_serving_input_receiver_fn(
    regressor_parse_example_spec(
      feature_columns = cols,
      weight_column = NULL,
      label_key = "label"
    )),
  as_text = TRUE
)
