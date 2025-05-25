#' Create assets folder in your project
#'
#' @description Creates the default `inst/examples/assets/` directory in your package project
#'   if it doesn't exist. Useful for storing your game's graphic assets.
#' @export
phaser_create_assets <- function() {
  assets_dir <- file.path("inst", "examples", "assets")

  if (!dir.exists(assets_dir)) {
    dir.create(assets_dir, recursive = TRUE)
    message("Created directory: ", assets_dir)
  } else {
    message("Directory already exists: ", assets_dir)
  }
}
