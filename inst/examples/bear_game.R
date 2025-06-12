devtools::load_all()

game <- PhaserGame$new(width = 1600, height = 800)

ui <- game$ui()

server <- function(input, output, session) {
  # game$add_image(
  #   imageName = "sky",
  #   imageUrl = "assets/bear_game/terrain/sky.png",
  # )
  game$add_player_sprite(
    name = "bear",
    url = "assets/bear_game/player_sprites/bear_idle.png",
    x = 100,
    y = 100,
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 10,
    frameRate = 4
  )
  game$add_player_controls(
    name = "bear",
    directions = c("left", "right"),
    speed = 200
  )
}

shinyApp(ui, server)
