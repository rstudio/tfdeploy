
## Deploying TensorFlow Models from R

[![Build
Status](https://travis-ci.org/rstudio/tfdeploy.svg?branch=master)](https://travis-ci.org/rstudio/tfdeploy)
[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/tfdeploy)](https://cran.r-project.org/package=tfdeploy)
[![codecov](https://codecov.io/gh/rstudio/tfdeploy/branch/master/graph/badge.svg)](https://codecov.io/gh/rstudio/tfdeploy)

While TensorFlow models are typically defined and trained using R or Python code, it is possible to deploy TensorFlow models in a wide variety of environments without any runtime dependency on R or Python:

- [TensorFlow Serving](https://www.tensorflow.org/serving/) is an open-source software library for serving TensorFlow models using a [gRPC](https://grpc.io/) interface.

- [CloudML](https://tensorflow.rstudio.com/tools/cloudml/) is a managed cloud service that serves TensorFlow models using a [REST](https://cloud.google.com/ml-engine/reference/rest/v1/projects/predict) interface.

- [RStudio Connect](https://www.rstudio.com/products/connect/) provides support for serving models using the same REST API as CloudML, but on a server within your own organization.

TensorFlow models can also be deployed to [mobile](https://www.tensorflow.org/mobile/tflite/) and [embedded](https://aws.amazon.com/blogs/machine-learning/how-to-deploy-deep-learning-models-with-aws-lambda-and-tensorflow/) devices including iOS and Android mobile phones and Raspberry Pi computers.
The tfdeploy package includes a variety of tools designed to make exporting and serving TensorFlow models straightforward. For documentation on using tfdeploy, see the package website at <https://tensorflow.rstudio.com/tools/tfdeploy/>.


