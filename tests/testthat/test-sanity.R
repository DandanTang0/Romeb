test_that("Romeb basic functionality and structure", {
  if (!requireNamespace("rjags", quietly = TRUE)) {
    skip("rjags not installed; skipping MCMC-related tests.")
  }
  
  expect_true("Romeb" %in% getNamespaceExports("Romeb"),
              info = "Romeb() should be exported from the package namespace.")
  
  set.seed(123)
  Y <- matrix(rnorm(30), nrow = 10, ncol = 3)
  time <- c(0, 1, 2)
  
  # Expect no error when running the model
  expect_error({
    fit <- Romeb::Romeb(
      Missing_Type = "no missing",
      data  = Y,
      time  = time,
      seed  = 123,
      K     = 0,
      chain = 1,
      Niter = 200,
      burnIn = 100
    )
  }, NA)
  
  expect_s3_class(fit, "RomebResult")
  expect_true(is.list(fit$quantiles))
  expect_true(is.matrix(fit$credible_intervals))
  expect_true(inherits(fit$samps_full, "mcmc.list"))
  
  # print method should not fail
  expect_error(print(fit), NA)
})
