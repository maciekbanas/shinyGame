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

#' Run the save and load mini-example
#'
#' @description Launches a small Shiny application demonstrating how to save
#'   application data and live Phaser object state, then restore both.
#' @return The value returned by [shiny::runApp()].
#' @export
run_save_load_example <- function() {
  app_file <- system.file("examples", "save-load.R", package = "shinyphaser")

  if (app_file == "") {
    stop("Save/load example not found in installed shinyphaser package.",
         call. = FALSE)
  }

  shiny::runApp(appDir = app_file, display.mode = "normal")
}

#' Run the simple RPG example
#'
#' @description Launches the single-map Simple RPG application bundled with
#'   shinyphaser.
#'
#' @return The value returned by [shiny::runApp()]. This function is normally
#'   called for its side effect of starting the application.
#' @export
run_simple_rpg <- function() {
  app_dir <- system.file("examples", "simple_rpg", package = "shinyphaser")

  if (app_dir == "") {
    stop("Simple RPG example not found in installed shinyphaser package.",
         call. = FALSE)
  }

  shiny::runApp(appDir = app_dir, display.mode = "normal")
}
