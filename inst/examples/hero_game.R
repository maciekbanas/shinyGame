devtools::load_all()

game <- PhaserGame$new(width = 1600, height = 800)

ui <- shiny::tagList(
  game$ui()
)


server <- function(input, output, session) {

  game$set_shiny_session()

  game$add_image(
    name = "ground",
    url = "assets/hero_game/terrain/ground.png",
    x = 800,
    y = 300
  )
  hero <- game$add_sprite(
    name = "hero",
    url = "assets/hero_game/sprites/hero_idle.png",
    x = 100,
    y = 100,
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 7,
    frameRate = 4
  )
  hero$add_player_controls(
    speed = 200
  )
  hero$add_animation(
    suffix = "move_down",
    url = "assets/hero_game/sprites/hero_move_down.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 4, frameRate = 8
  )
  hero$add_animation(
    suffix = "move_up",
    url = "assets/hero_game/sprites/hero_move_up.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 4, frameRate = 8
  )
  hero$add_animation(
    suffix = "move_left",
    url = "assets/hero_game/sprites/hero_move_left.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 4, frameRate = 8
  )
  hero$add_animation(
    suffix = "move_right",
    url = "assets/hero_game/sprites/hero_move_right.png",
    frameWidth = 100, frameHeight = 100,
    frameCount = 4, frameRate = 8
  )
  wizard <- game$add_sprite(
    name = "wizard",
    url = "assets/hero_game/sprites/wizard_idle.png",
    x = 500,
    y = 300,
    frameWidth = 100,
    frameHeight = 100,
    frameCount = 17,
    frameRate = 4
  )
  talk_btn <- game$add_image(
    name = "talk_btn",
    url = "assets/hero_game/buttons/talk.png",
    y = 600,
    x = 600,
    visible = FALSE
  )
  game$add_overlap(
    object_one = "hero",
    object_two = "wizard",
    callback_fun = function(evt) {
      talk_btn$show()
    },
    input = input
  )
  game$add_overlap_end(
    object_one = "hero",
    object_two = "wizard",
    callback_fun = function(evt) {
      talk_btn$hide()
    },
    input = input
  )
}

shinyApp(ui, server)
