devtools::load_all()

game <- PhaserGame$new(width = 1600, height = 800)

ui <- game$ui()

server <- function(input, output, session) {
  game$add_image(
    imageName = "sky",
    imageUrl = "assets/bear_game/terrain/sky.png",
    x = 800,
    y = 300
  )
  game$add_player_sprite(
    name = "bear",
    url = "assets/bear_game/player_sprites/bear_idle.png",
    x = 100,
    y = 600,
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 10,
    frameRate = 4
  )
  apples <- game$add_static_group(
    input = input,
    name = "apples",
    url = "assets/bear_game/perks/apple.png"
  )
  apples$create(
    x = 600,
    y = 600
  )
  apples$create(
    x = 1000,
    y = 600
  )
  apples$create(
    x = 1200,
    y = 600
  )
  game$add_player_controls(
    name = "bear",
    directions = c("left", "right"),
    speed = 400
  )
  game$add_static_sprite(
    name = "grass",
    url = "assets/bear_game/terrain/grass.png",
    x = 800,
    y = 700
  )
  Sys.sleep(0.1)
  game$add_overlap(
    object_one_name = "bear",
    group_name = "apples",
    callback_fun = function(evt) {
      apples$disable(evt)
    },
    input = input
  )
  game$add_sprite_animation(
    name = "bear",
    suffix = "move_right",
    url = "assets/bear_game/player_sprites/bear_move_right.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 2, frameRate = 6
  )
  game$add_sprite_animation(
    name = "bear",
    suffix = "move_left",
    url = "assets/bear_game/player_sprites/bear_move_left.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 2, frameRate = 6
  )
}

shinyApp(ui, server)
