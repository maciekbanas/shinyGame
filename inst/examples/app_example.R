devtools::load_all()

game <- PhaserGame$new(width = 1000, height = 800)

ui <- game$ui()

server <- function(input, output, session) {
  game$add_player_sprite("hero",
                         "assets/hero_idle.png",
                         100, 100,
                         frameCount = 15,
                         frameRate = 8)
  game$add_player_move_animation(
    name = "hero",
    "assets/hero_move.png",
    2,
    4
  )
  game$enable_movement("hero", speed = 200)
}

shinyApp(ui, server)
