#' Run the packaged shinyphaser sample app
#'
#' @description Launches the sample Shiny application bundled with the package.
#' This is a quick way to see a working `shinyphaser` game setup.
#'
#' @return The value returned by [shiny::runApp()]. This function is normally
#'   called for its side effect of starting the application.
#' @export
run_sample_app <- function() {
  app_dir <- system.file("sample_app", package = "shinyphaser")

  if (app_dir == "") {
    stop("Sample app not found in installed shinyphaser package.", call. = FALSE)
  }

  shiny::runApp(appDir = app_dir, display.mode = "normal")
}

#' Run the Swamps RPG example
#'
#' @description Launches the modular Swamps RPG Shiny application bundled
#'   with shinyphaser.
#'
#' @return The value returned by [shiny::runApp()]. This function is normally
#'   called for its side effect of starting the application.
#' @export
run_swamps_rpg <- function() {
  app_dir <- system.file("examples", "swamps_rpg", package = "shinyphaser")

  if (app_dir == "") {
    stop("Swamps RPG example not found in installed shinyphaser package.",
         call. = FALSE)
  }

  shiny::runApp(appDir = app_dir, display.mode = "normal")
}
