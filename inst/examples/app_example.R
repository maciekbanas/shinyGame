devtools::load_all()

game <- PhaserGame$new(width = 1000, height = 800)

ui <- game$ui()

server <- function(input, output, session) {
  game$add_player_sprite("hero", "assets/bear_breath.png", 100, 100)
}

shinyApp(ui, server)
