test_that("save/load example is installed and uses public state restoration", {
  example <- readLines(
    testthat::test_path("..", "..", "inst", "examples", "save-load.R"),
    warn = FALSE
  )

  expect_true(any(grepl("saveRDS(list(score = score())", example, fixed = TRUE)))
  expect_true(any(grepl("saved <- readRDS(save_file)", example, fixed = TRUE)))
  expect_true(any(grepl("score_text$set(paste", example, fixed = TRUE)))
})
