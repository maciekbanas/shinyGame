devtools::load_all()

game <- PhaserGame$new(width = 1000, height = 800)

ui <- game$ui()

server <- function(input, output, session) {
  game$add_player_sprite(
    name = "hero",
    url = "assets/wolf_hero_idle.png",
    x = 300,
    y = 500,
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 17,
    frameRate = 8
  )
  game$enable_movement(name = "hero", speed = 200)
  game$add_player_move_left_animation(
    name = "hero",
    url = "assets/wolf_hero_move_left.png",
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 3,
    frameRate = 8
  )
  game$add_player_move_right_animation(
    name = "hero",
    url = "assets/wolf_hero_move_right.png",
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 3,
    frameRate = 8
  )
}

shinyApp(ui, server)
