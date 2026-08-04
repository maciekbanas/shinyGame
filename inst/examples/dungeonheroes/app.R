library(shinyphaser)

game <- PhaserGame$new(width = 1600, height = 800)
map_tile_size <- 100
map_tile_width <- 32
map_tile_height <- 64
world_width <- map_tile_width * map_tile_size
world_height <- map_tile_height * map_tile_size
shinyphaser_version <- as.character(utils::packageVersion("shinyphaser"))

# Each module is evaluated in the app or server environment so the example stays
# easy to read while retaining the shared state expected by its Shiny callbacks.
source("ui.R", local = TRUE)

server <- function(input, output, session) {
  server_env <- environment()
  modules <- c(
    "game_state.R",
    "navigation_setup.R",
    "hero.R",
    file.path("realms", "mushroom_swamps_world.R"),
    "navigation.R",
    "saving.R",
    "navigation_events.R",
    file.path("realms", "mushroom_swamps.R"),
    file.path("realms", "magma_hills.R"),
    file.path("realms", "wild_forests.R"),
    file.path("realms", "grey_mountains.R"),
    "realm_routes.R"
  )
  # These files intentionally live outside an R/ directory. Shiny automatically
  # sources R/ before it evaluates app.R, when `game` does not exist yet.
  for (module in file.path("modules", modules)) {
    sys.source(module, envir = server_env)
  }
}

shiny::shinyApp(ui, server)
