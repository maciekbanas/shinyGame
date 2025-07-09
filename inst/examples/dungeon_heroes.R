devtools::load_all()

game <- PhaserGame$new(width = 1600, height = 800)

ui <- game$ui()

server <- function(input, output, session) {

  life_points = 100

  game$set_shiny_session()

  game$add_map(
    mapKey = "myMap",
    mapUrl = "assets/rpg_game/tilemaps/map.json",
    tilesetUrls = paste0("assets/rpg_game/tilemaps/", c("grass", "water"), ".png"),
    tilesetNames = c("grass", "water"),
    layerName = "Ground"
  )

  game$add_player_sprite(
    name = "hero",
    url = "assets/rpg_game/sprites/wolf_hero_idle.png",
    x = 100,
    y = 100,
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 17,
    frameRate = 8
  )
  game$add_player_controls(name = "hero", speed = 200)
  game$add_sprite(
    name = "goblin",
    url = "assets/rpg_game/enemies/goblin_idle.png",
    x = 600,
    y = 600,
    frameWidth = 100,
    frameHeight= 100,
    frameCount = 9,
    frameRate  = 8
  )
  game$add_sprite(
    name = "goblin",
    url = "assets/rpg_game/enemies/goblin_idle.png",
    x = 1200,
    y = 500,
    frameWidth = 100,
    frameHeight= 100,
    frameCount = 9,
    frameRate  = 8
  )
  Sys.sleep(0.1)
  game$enable_terrain_collision("hero")
  rocks <- game$add_static_group(
    name = "rocks",
    url = "assets/rpg_game/obstacles/rock.png"
  )
  rocks$create(
    x = 400,
    y = 400
  )
  rocks$create(
    x = 600,
    y = 500
  )
  life_points_text <- game$add_text(
    text = "life: 100/100",
    id = "life_points",
    x = 1200,
    y = 50
  )
  Sys.sleep(0.1)
  game$add_collider(
    object_one = "hero",
    group_name = "rocks",
    input = input
  )
  game$add_collider(
    object_one = "hero",
    object_two = "goblin",
    callback_fun = function(evt) {
      life_points <<- life_points - 5
      life_points_text$set(paste0("life: ", life_points, "/100"))
    },
    input = input
  )
  game$add_sprite_animation(
    name = "hero",
    suffix = "move_left",
    url = "assets/rpg_game/sprites/wolf_hero_move_left.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 3, frameRate = 8
  )
  game$add_sprite_animation(
    name = "hero",
    suffix = "move_right",
    url = "assets/rpg_game/sprites/wolf_hero_move_right.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 3, frameRate = 8
  )
  game$add_sprite_animation(
    name = "goblin",
    suffix = "move_left",
    url = "assets/rpg_game/enemies/goblin_move_left.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 2, frameRate = 6
  )
  game$add_sprite_animation(
    name = "goblin",
    suffix = "move_right",
    url = "assets/rpg_game/enemies/goblin_move_right.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 2, frameRate = 6
  )

  game$set_sprite_in_motion(
    type = "goblin",
    dirX = 1,
    dirY = 0,
    speed = 50,
    distance = 200
  )
  game$set_sprite_in_motion(
    type = "goblin",
    dirX = -1,
    dirY = 0,
    speed = 50,
    distance = 200
  )
}

shinyApp(ui, server)
