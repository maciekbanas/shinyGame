devtools::load_all()

game <- PhaserGame$new(width = 1000, height = 800)

ui <- game$ui()

server <- function(input, output, session) {
  game$add_player_sprite("hero",
                         "assets/hero_idle.png",
                         x = 100,
                         y = 100,
                         frameCount = 15,
                         frameRate = 8)
  game$enable_movement("hero", speed = 200)
  game$add_player_move_left_animation(
    name = "hero",
    "assets/hero_move_left.png",
    4,
    8
  )
  game$add_player_move_right_animation(
    name = "hero",
    "assets/hero_move_right.png",
    4,
    8
  )
}

shinyApp(ui, server)
