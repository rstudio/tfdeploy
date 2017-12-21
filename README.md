tfdeploy: Deploy TensorFlow Models from R
================

[![Build Status](https://travis-ci.org/rstudio/tfdeploy.svg?branch=master)](https://travis-ci.org/rstudio/tfdeploy)

`tfdeploy` provies tools for deploying TensorFlow SavedModels into local and remove services.

SavedModels can be trained using `tensorflow`, `keras` or `tfestimators` and exported using `export_savedmodel()`; or using any other TensorFlow tool that exports them using then [tf.train.Saver](https://www.tensorflow.org/api_docs/python/tf/train/Saver) interface.

To get started, you can also use one of the pretrained models included in this package:

``` r
library(tfdeploy)
model_path <- system.file("models/tensorflow-mnist/", package = "tfdeploy")
```

### Local Deployment

`tfdeploy` provides a [GoogleML](https://cloud.google.com/ml-engine/docs/prediction-overview) compatible local R server that provides a web API to the the SavedModel using `serve_savedmodel()`:

``` r
serve_savedmodel(model_path)
```

<img src="tools/readme/swagger.png" width=500 />

### Deployment Client

`tfdeploy` provides a client capable of performing predictions over a SavedModel for local or remote prediction services A prediction over a local model can be performed using `predict_savedmodel()`:

``` r
predict_savedmodel(rep(0, 784), model_path)
```

    ## $predictions
    ##                                                                           scores
    ## 1 0.0557, 0.1143, 0.0904, 0.0587, 0.0820, 0.2934, 0.0713, 0.1516, 0.0191, 0.0635

We can make use of the `pixels` HTMLWidget to manually collect a vector of pixels and perform a prediction over the model:

``` r
predict_savedmodel(pixels::get_pixels(), model_path)
```

<img src="tools/readme/mnist-digits.gif" width=400 />
