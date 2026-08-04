# Dungeon Heroes is a multi-file Shiny application. Run this compatibility
# launcher from the repository root; installed users can use the packaged path.
app_dir <- system.file("examples", "dungeonheroes", package = "shinyphaser")
if (!nzchar(app_dir)) app_dir <- file.path("inst", "examples", "dungeonheroes")
shiny::runApp(app_dir)
