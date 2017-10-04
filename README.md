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
model_path <- file.path("trained/tensorflow-mnst/1")
if (dir.exists(model_path)) unlink(model_path, recursive = TRUE)

builder <- tf$saved_model$builder$SavedModelBuilder(model_path)
builder$save()
```

    ## [1] "trained/tensorflow-mnst/1/saved_model.pb"

``` r
dir(model_path, recursive = TRUE)
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
tfserve_save(sess, model_path, signature, overwrite = TRUE)
```

    ## [1] "trained/tensorflow-mnst/1/saved_model.pb"

``` r
dir(model_path, recursive = TRUE)
```

    ## [1] "saved_model.pb"                         
    ## [2] "variables/variables.data-00000-of-00001"
    ## [3] "variables/variables.index"

### Serving a Model

See [Tensorflow Serving Setup](https://www.tensorflow.org/serving/setup#installing_using_apt-get), but in general, from Linux, first install prereqs:

``` bash
sudo apt-get update && sudo apt-get install -y build-essential curl libcurl3-dev git libfreetype6-dev libpng12-dev libzmq3-dev pkg-config python-dev python-numpy python-pip software-properties-common swig zip zlib1g-dev
```

Then install Tensorflow Serving:

``` bash
echo "deb [arch=amd64] http://storage.googleapis.com/tensorflow-serving-apt stable tensorflow-model-server tensorflow-model-server-universal" | sudo tee /etc/apt/sources.list.d/tensorflow-serving.list

curl https://storage.googleapis.com/tensorflow-serving-apt/tensorflow-serving.release.pub.gpg | sudo apt-key add -

sudo apt-get update && sudo apt-get install tensorflow-model-server
```

Optionally, install the api client:

``` bash
sudo pip install tensorflow-serving-api --no-cache-dir
```

Then serve the model using:

``` bash
tensorflow_model_server --port=9000 --model_name=mnist --model_base_path=/mnt/hgfs/tfserve/trained/tensorflow-mnst/1
```

    2017-10-04 14:32:43.250698: I external/org_tensorflow/tensorflow/cc/saved_model/loader.cc:284] Loading SavedModel: success. Took 106015 microseconds.
    2017-10-04 14:32:43.254197: I tensorflow_serving/core/loader_harness.cc:86] Successfully loaded servable version {name: mnist version: 1}
    2017-10-04 14:32:43.258085: I tensorflow_serving/model_servers/main.cc:288] Running ModelServer at 0.0.0.0:9000 ...

One can use `saved_model_cli` to inspect model contents, as in:

``` bash
saved_model_cli show --dir /mnt/hgfs/tfserve/trained/tensorflow-mnst/1
```
