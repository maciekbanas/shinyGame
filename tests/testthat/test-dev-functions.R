test_that("run_sample_app is available", {
  expect_true(is.function(run_sample_app))
})

test_that("run_dungeonheroes is available and its app is packaged", {
  expect_true(is.function(run_dungeonheroes))
  app_file <- system.file(
    "examples", "dungeonheroes", "app.R", package = "shinyphaser"
  )
  expect_true(file.exists(app_file))
  expect_false(dir.exists(file.path(dirname(app_file), "R")))

  app <- readLines(app_file, warn = FALSE)
  expect_true(any(grepl("server_env <- environment()", app, fixed = TRUE)))
  expect_true(any(grepl("sys.source(module, envir = server_env)", app, fixed = TRUE)))
  expect_false(any(grepl(
    'lapply(file.path("modules", modules), source', app, fixed = TRUE
  )))
})
