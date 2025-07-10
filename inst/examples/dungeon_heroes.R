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

  wolf_hero <- game$add_sprite(
    name = "hero",
    url = "assets/rpg_game/sprites/wolf_hero_idle.png",
    x = 100,
    y = 100,
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 17,
    frameRate = 8
  )
  wolf_hero$add_player_controls(
    speed = 200
  )
  wolf_hero$add_animation(
    suffix = "move_left",
    url = "assets/rpg_game/sprites/wolf_hero_move_left.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 3, frameRate = 8
  )
  wolf_hero$add_animation(
    suffix = "move_right",
    url = "assets/rpg_game/sprites/wolf_hero_move_right.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 3, frameRate = 8
  )
  wolf_hero$add_animation(
    suffix = "move_up",
    url = "assets/rpg_game/sprites/wolf_hero_move_left.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 3, frameRate = 8
  )
  wolf_hero$add_animation(
    suffix = "move_down",
    url = "assets/rpg_game/sprites/wolf_hero_move_right.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 3, frameRate = 8
  )

  goblin_1 <- game$add_sprite(
    name = "goblin_1",
    url = "assets/rpg_game/enemies/goblin_idle.png",
    x = 600,
    y = 600,
    frameWidth = 100,
    frameHeight= 100,
    frameCount = 9,
    frameRate  = 8
  )
  goblin_2 <- game$add_sprite(
    name = "goblin_2",
    url = "assets/rpg_game/enemies/goblin_idle.png",
    x = 1200,
    y = 500,
    frameWidth = 100,
    frameHeight= 100,
    frameCount = 9,
    frameRate  = 8
  )

  goblins <- game$add_group(name = "goblin")

  goblins$add_animation(
    suffix = "idle",
    url = "assets/rpg_game/enemies/goblin_idle.png",
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 9,
    frameRate = 8
  )

  goblins$create(x = 800, y = 350)
  goblins$create(x = 600, y = 400)

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
    object_two = "goblin_1",
    callback_fun = function(evt) {
      life_points <<- life_points - 5
      life_points_text$set(paste0("life: ", life_points, "/100"))
    },
    input = input
  )
  game$add_collider(
    object_one = "hero",
    object_two = "goblin_2",
    callback_fun = function(evt) {
      life_points <<- life_points - 5
      life_points_text$set(paste0("life: ", life_points, "/100"))
    },
    input = input
  )

  goblin_1$add_animation(
    suffix = "move_left",
    url = "assets/rpg_game/enemies/goblin_move_left.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 2, frameRate = 6
  )
  goblin_1$add_animation(
    suffix = "move_right",
    url = "assets/rpg_game/enemies/goblin_move_right.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 2, frameRate = 6
  )
  goblin_1$set_in_motion(
    dirX = 1,
    dirY = 0,
    speed = 50,
    distance = 200
  )
  goblin_1$set_in_motion(
    dirX = -1,
    dirY = 0,
    speed = 50,
    distance = 200
  )
}

shinyApp(ui, server)
