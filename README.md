tfserve: Serve Tensorflow Models
================

`tfserve` provides a [GoogleML](https://cloud.google.com/ml-engine/docs/prediction-overview) compatiable REST API for predictions to serve TensorFlow Models from R with ease.

<img src="tools/readme/swagger.png" width=400 />

Quick Start
-----------

For example, we can train MNIST as described by [MNIST For ML Beginners](https://tensorflow.rstudio.com/tensorflow/articles/tutorial_mnist_beginners.html) and then save using `SavedModelBuilder` and the right signature or, for conviniece, use a `tfserve` helper function as follows:

``` r
library(tfserve)

model_path <- "trained/tensorflow-mnist/1"
mnist_train_save(model_path)
```

    ## [1] "trained/tensorflow-mnist/1/saved_model.pb"

Then, we can serve this model with ease by running:

``` r
serve(model_path)
```
