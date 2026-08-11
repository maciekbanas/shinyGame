test_that("run_sample_app is available", {
  expect_true(is.function(run_sample_app))
})

test_that("save/load mini-example is exported and packaged", {
  expect_true(is.function(run_save_load_example))
  expect_true("run_save_load_example" %in% getNamespaceExports("shinyphaser"))
  expect_true(file.exists(system.file(
    "examples", "save-load.R", package = "shinyphaser"
  )))
})

test_that("run_simple_rpg is available and its app is packaged", {
  expect_true(is.function(run_simple_rpg))
  expect_true("run_simple_rpg" %in% getNamespaceExports("shinyphaser"))
  app_file <- system.file(
    "examples", "simple_rpg", "app.R", package = "shinyphaser"
  )
  expect_true(file.exists(app_file))
  app <- readLines(app_file, warn = FALSE)
  expect_true(any(grepl('map_key = "wild_forest"', app, fixed = TRUE)))
  expect_false(any(grepl("activate_map", app, fixed = TRUE)))
})
