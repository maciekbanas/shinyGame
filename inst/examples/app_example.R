devtools::load_all()

game <- PhaserGame$new()

ui <- fluidPage(game$ui())

server <- function(input, output, session) {
  game$add_player_sprite("hero", "https://labs.phaser.io/assets/sprites/phaser-dude.png", 100, 100)
}

shinyApp(ui, server)
