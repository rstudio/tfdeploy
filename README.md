tfserve: Serve Tensorflow Models
================

`tfserve` provides a [GoogleML](https://cloud.google.com/ml-engine/docs/prediction-overview) compatiable REST API for predictions to serve TensorFlow Models from R with ease.

For example, we can train MNIST as described by [MNIST For ML Beginners](https://tensorflow.rstudio.com/tensorflow/articles/tutorial_mnist_beginners.html) and then save using `SavedModelBuilder` and the right signature or, for conviniece, use a `tfserve` helper function as follows:

``` r
library(tfserve)
```

    ## Warning: replacing previous import 'keras::evaluate' by
    ## 'tfestimators::evaluate' when loading 'tfserve'

``` r
model_path <- "trained/tensorflow-mnist/1"
mnist_train_save(model_path)
```

    ## [1] "trained/tensorflow-mnist/1/saved_model.pb"

``` r
dir(model_path, recursive = T)
```

    ## [1] "saved_model.pb"                         
    ## [2] "variables/variables.data-00000-of-00001"
    ## [3] "variables/variables.index"

Then, we can serve this model with ease by running:

``` r
serve(model_path)
```

    ## NULL
