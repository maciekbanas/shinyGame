devtools::load_all()

game <- PhaserGame$new(width = 1600, height = 800)

ui <- game$ui()

server <- function(input, output, session) {
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
}

shinyApp(ui, server)
