#' Run the packaged shinyphaser sample app
#'
#' @description Launches the sample Shiny application bundled with the package.
#' This is a quick way to see a working `shinyphaser` game setup.
#'
#' @export
run_sample_app <- function() {
  app_dir <- system.file("sample_app", package = "shinyphaser")

  if (app_dir == "") {
    stop("Sample app not found in installed shinyphaser package.", call. = FALSE)
  }

  shiny::runApp(appDir = app_dir, display.mode = "normal")
}

#' Run the spin and win marketing example
#'
#' @description Launches a promotional prize-wheel Shiny application bundled
#' with the package. The example demonstrates a Phaser-rendered wheel,
#' server-selected weighted prizes, and a coupon result flow.
#'
#' @export
run_spin_and_win <- function() {
  app_dir <- system.file("examples", "spin-and-win", package = "shinyphaser")

  if (app_dir == "") {
    stop("Spin and win example not found in installed shinyphaser package.",
         call. = FALSE)
  }

  shiny::runApp(appDir = app_dir, display.mode = "normal")
}
