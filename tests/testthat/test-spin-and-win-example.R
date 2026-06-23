test_that("spin and win example is included", {
  app_dir <- system.file("examples", "spin-and-win", package = "shinyphaser")

  expect_true(nzchar(app_dir))
  expect_true(file.exists(file.path(app_dir, "app.R")))
  expect_true(file.exists(file.path(app_dir, "www", "spin-and-win.css")))
  expect_true(file.exists(file.path(app_dir, "www", "spin-and-win.js")))
  expect_error(parse(file.path(app_dir, "app.R")), NA)
})

test_that("spin and win runner fails clearly without the bundled app", {
  local_mocked_bindings(
    system.file = function(...) "",
    .package = "shinyphaser"
  )

  expect_error(
    run_spin_and_win(),
    "Spin and win example not found"
  )
})
