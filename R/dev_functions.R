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

#' Run the Dungeon Heroes example
#'
#' @description Launches the modular Dungeon Heroes Shiny application bundled
#'   with shinyphaser.
#'
#' @return The value returned by [shiny::runApp()]. This function is normally
#'   called for its side effect of starting the application.
#' @export
run_dungeonheroes <- function() {
  app_dir <- system.file("examples", "dungeonheroes", package = "shinyphaser")

  if (app_dir == "") {
    stop("Dungeon Heroes example not found in installed shinyphaser package.",
         call. = FALSE)
  }

  shiny::runApp(appDir = app_dir, display.mode = "normal")
}
