context("Load Model")

test_that("loading invalid savedmodel should fail", {
  expect_error(
    load_savedmodel(NULL)
  )
})
