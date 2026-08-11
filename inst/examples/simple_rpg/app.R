library(shiny)
library(shinyphaser)

game <- PhaserGame$new(width = 960, height = 640)

ui <- tagList(
  game$use_phaser(),
  absolutePanel(
    top = 12, left = 12,
    style = paste(
      "z-index: 10; padding: 10px 14px; color: white;",
      "background: rgba(0, 0, 0, .65); border-radius: 6px;"
    ),
    strong("Simple RPG"),
    div("Explore the forest with the arrow keys and gather the berries.")
  )
)

server <- function(input, output, session) {
  game$set_shiny_session(session)

  game$add_map(
    map_key = "wild_forest",
    map_url = "assets/simple_rpg/maps/wild_forests.json",
    tileset_urls = c(
      sprintf("assets/simple_rpg/terrain/wild_forests/grass_%d.png", 1:5),
      "assets/simple_rpg/terrain/wild_forests/forest_path_1.png"
    ),
    tileset_names = c(sprintf("grass_%d", 1:5), "forest_path_1"),
    layer_name = "terrain"
  )

  hero <- game$add_sprite(
    name = "hero",
    url = "assets/simple_rpg/sprites/hero/hero_idle.png",
    x = 350, y = 350,
    frame_width = 100, frame_height = 100,
    frame_rate = 4
  )
  for (direction in c("left", "right", "down", "up")) {
    hero$add_animation(
      suffix = paste0("move_", direction),
      url = sprintf("assets/simple_rpg/sprites/hero/hero_move_%s.png", direction),
      frame_width = 100, frame_height = 100,
      frame_rate = 4
    )
  }
  hero$add_player_controls(speed = 220)
  hero$follow_camera(lerp_x = 0.12, lerp_y = 0.12)
  game$enable_terrain_collision("hero")

  tree_specs <- list(
    list(name = "tree_1", asset = "big_tree_2", x = 900, y = 700),
    list(name = "tree_2", asset = "big_tree_3", x = 1750, y = 1100),
    list(name = "tree_3", asset = "big_tree_2", x = 2450, y = 1850),
    list(name = "tree_4", asset = "small_tree_1", x = 1250, y = 2350)
  )
  lapply(tree_specs, function(spec) {
    game$add_static_sprite(
      name = spec$name,
      url = sprintf(
        "assets/simple_rpg/terrain/wild_forests/%s.png", spec$asset
      ),
      x = spec$x, y = spec$y
    )$set_depth(10)
    base_name <- paste0(spec$name, "_base")
    game$add_collision_rectangle(
      base_name, x = spec$x, y = spec$y + 65, width = 90, height = 35
    )
    game$add_collider("hero", base_name, input = input)
  })

  berries <- game$add_static_group(
    name = "berries",
    url = "assets/simple_rpg/perks/berries.png"
  )
  lapply(
    list(c(750, 450), c(1350, 850), c(2150, 1350), c(2550, 2250)),
    function(position) berries$create(position[[1]], position[[2]])
  )

  message <- game$add_text(
    "Find the four berry bushes", "quest", x = 24, y = 84,
    style = list(font_size = "24px", color = "#ffffff")
  )
  message$set_scroll_factor(0)

  game$add_overlap(
    object_one = "hero",
    group = "berries",
    input = input,
    browser_action = browser_actions({
      berries$disable()
      message$set("Berries gathered!")
    })
  )
}

shinyApp(ui, server)
