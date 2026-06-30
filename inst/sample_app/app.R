library(shiny)
library(shinyphaser)

game <- PhaserGame$new(width = 1500, height = 800)

ui <- tagList(
  game$use_phaser()
)

server <- function(input, output, session) {
  game$set_shiny_session()

  floor <- game$add_image(
    name = "floor",
    url = "assets/hedgehog/terrain/grass.png",
    x = 800,
    y = 300
  )

  hedgehog <- game$add_sprite(
    name = "hedgehog",
    url = "assets/hedgehog/sprites/hedgehog_32.png",
    x = 140,
    y = 260,
    frame_width = 32,
    frame_height = 32,
    frame_count = 5,
    frame_rate = 6
  )

  hedgehog$add_player_controls(
    directions = c("left", "right", "up", "down"),
    speed = 220
  )

  game$enable_terrain_collision("hedgehog")

  moves <- c("move_left", "move_right", "move_up", "move_down")

  for (move in moves) {
    hedgehog$add_animation(
      suffix = move,
      url = paste0("assets/hedgehog/sprites/hedgehog_", move, "_32.png"),
      frame_width = 32,
      frame_height = 32,
      frame_rate = 5
    )
  }

  score <- reactiveVal(0)
  apples <- game$add_static_group("apples", "assets/hedgehog/perks/apple_20.png")

  apples$create(260, 140)
  apples$create(640, 180)
  apples$create(730, 390)

  rocks <- game$add_static_group(
    name = "rocks",
    url = "assets/hedgehog/obstacles/rock.png"
  )

  rocks$create(400, 200)
  rocks$create(200, 300)

  score_text <- game$add_text(text = "Score: 0", id = "score", x = 20, y = 20)

  game$add_overlap(
    object_one = "hedgehog",
    group = "apples",
    callback_fun = function(evt) {
      apples$disable(evt)
      score(score() + 1)
      score_text$set(paste("Score:", score()))
    },
    input = input
  )

  game$add_collider(
    object_one = "hedgehog",
    group = "rocks"
  )

  enemy <- game$add_sprite(
    name = "badger",
    url = "assets/hedgehog/sprites/badger_move_left_50.png",
    x = 700,
    y = 300,
    frame_width = 50,
    frame_height = 50,
    frame_count = 1,
    frame_rate = 1
  )

  game$add_overlap(
    object_one = "hedgehog",
    object_two = "badger",
    callback_fun = function(evt) {
      shinyalert::shinyalert(
        title = "Game over", type = "error",
        closeOnClickOutside = FALSE, showCancelButton = FALSE,
        callbackR = function(value) shiny::stopApp()
      )
    },
    input = input
  )

  if (!isTRUE(getOption("shiny.testmode"))) {
    shiny::observe({
      shiny::invalidateLater(700, session)
      dir <- sample(list(c(-1, 0), c(1, 0), c(0, -1), c(0, 1)), 1)[[1]]
      enemy$set_in_motion(
        dir_x = dir[1],
        dir_y = dir[2],
        speed = 70,
        distance = 150,
        lag = 0
      )
    })
  }
}
shinyApp(ui, server)
