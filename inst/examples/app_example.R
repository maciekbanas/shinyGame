devtools::load_all()

game <- PhaserGame$new(width = 1600, height = 800)

ui <- game$ui()

server <- function(input, output, session) {

  game$add_background(
    mapKey = "myMap",
    mapUrl = "assets/tilemaps/map.json",
    tilesetUrls = paste0("assets/tilemaps/", c("grass", "water"), ".png"),
    tilesetNames = c("grass", "water"),
    layerName = "Ground"
  )
  game$add_player_sprite(
    name = "hero",
    url = "assets/sprites/wolf_hero_idle.png",
    x = 100,
    y = 100,
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 17,
    frameRate = 8
  )
  game$enable_movement(name = "hero", speed = 200)
  Sys.sleep(0.1)
  game$enable_terrain_collision("hero")
  game$add_obstacle(
    name = "rock-1",
    url  = "assets/obstacles/rock.png",
    x    = 400,
    y    = 400
  )
  game$add_obstacle(
    name = "rock-2",
    url  = "assets/obstacles/rock.png",
    x    = 600,
    y    = 500
  )
  Sys.sleep(0.1)
  game$enable_obstacle_collision("hero", "rock-1")
  game$enable_obstacle_collision("hero", "rock-2")
  game$add_player_move_left_animation(
    name = "hero",
    url = "assets/sprites/wolf_hero_move_left.png",
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 3,
    frameRate = 8
  )
  game$add_player_move_right_animation(
    name = "hero",
    url = "assets/sprites/wolf_hero_move_right.png",
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 3,
    frameRate = 8
  )
}

shinyApp(ui, server)
