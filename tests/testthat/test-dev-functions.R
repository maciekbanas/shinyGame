test_that("run_sample_app is available", {
  expect_true(is.function(run_sample_app))
})

test_that("run_dungeonheroes is available and its app is packaged", {
  expect_true(is.function(run_dungeonheroes))
  expect_true(file.exists(system.file(
    "examples", "dungeonheroes", "app.R", package = "shinyphaser"
  )))
})
