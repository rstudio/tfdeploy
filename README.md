tfserve: Tensorflow Serve Examples
================

This repo provides tools and examples to serve Tensorflow models from R.

Tensorflow Serving
------------------

### Saving a Model

One can train MNIST as described by [MNIST For ML Beginners](https://tensorflow.rstudio.com/tensorflow/articles/tutorial_mnist_beginners.html) and track the model's inputs and outputs named `x` and `y` under that particular article. For convinience, we can run instead:

``` r
library(tensorflow)
library(tfserve)

sess <- tf$Session()
mnist_model <- tfserve_mnist_train(sess)
```

Once trained, the model can be saved with [SavedModelBuilder](https://www.tensorflow.org/api_docs/python/tf/saved_model/builder/SavedModelBuilder).

``` r
temp_path <- file.path(tempdir(), "tf")
if (dir.exists(temp_path)) unlink(temp_path, recursive = TRUE)

builder <- tf$saved_model$builder$SavedModelBuilder(temp_path)
builder$save()
```

    ## [1] "/var/folders/fz/v6wfsg2x1fb1rw4f6r0x4jwm0000gn/T//RtmprARMYx/tf/saved_model.pb"

``` r
dir(temp_path, recursive = TRUE)
```

    ## [1] "saved_model.pb"

However, saving the model is not sufficient when using Tensorflow Serving, see [Serving a Tensorflow Model](https://www.tensorflow.org/serving/serving_basic).

Instead, we need to create a signature for the model, which will require references to the input and output Tensors for the model which we retrieved from the model:

``` r
mnist_model
```

    ## $input
    ## Tensor("Placeholder:0", shape=(?, 784), dtype=float32)
    ## 
    ## $output
    ## Tensor("Softmax:0", shape=(?, 10), dtype=float32)

with them, we can use the following convenience function to retrieve the signature for the model:

``` r
signature <- tfserve_mnist_signature(mnist_model$input, mnist_model$output)
```

This signature can be used in combination with `SavedModelBuilder.add_meta_graph_and_variables` to provide a model usable with Tensorflow Serving:

``` r
tfserve_save(sess, temp_path, signature, overwrite = TRUE)
```

    ## [1] "/var/folders/fz/v6wfsg2x1fb1rw4f6r0x4jwm0000gn/T//RtmprARMYx/tf/saved_model.pb"

``` r
dir(temp_path, recursive = TRUE)
```

    ## [1] "saved_model.pb"                         
    ## [2] "variables/variables.data-00000-of-00001"
    ## [3] "variables/variables.index"

### Serving a Model

**TODO**
