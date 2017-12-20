library(testthat)
library(tfdeploy)

if (identical(Sys.getenv("NOT_CRAN"), "true")) {
  test_check("tfdeploy")
}
