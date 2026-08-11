library(shiny)
library(shinyphaser)

game <- PhaserGame$new(id = "save_load_game", width = 640, height = 360)

ui <- tagList(
  game$use_phaser(),
  absolutePanel(
    top = 12, left = 12, style = "z-index: 10; background: white; padding: 10px;",
    strong(textOutput("score", inline = TRUE)),
    actionButton("add_point", "+1 point"),
    actionButton("save", "Save"),
    actionButton("load", "Load")
  )
)

server <- function(input, output, session) {
  game$set_shiny_session(session)
  score <- reactiveVal(0)

  game$add_sprite(
    name = "player",
    url = "assets/bear/player_sprites/bear_idle.png",
    x = 100, y = 220,
    frame_width = 100, frame_height = 100,
    frame_rate = 4
  )$add_player_controls(directions = c("left", "right"), speed = 180)

  output$score <- renderText(sprintf("Score: %d", score()))
  observeEvent(input$add_point, score(score() + 1))

  observeEvent(input$save, {
    game$save_game(
      name = "quick-save",
      state = list(score = score()),
      objects = "player"
    )
    showNotification("Save requested")
  })

  observeEvent(input$load, {
    if (!length(game$list_saved_games())) {
      showNotification("Save the game first", type = "warning")
      return()
    }
    restored <- game$load_game("quick-save")
    score(restored$score)
    showNotification("Score and player position restored")
  })
}

shinyApp(ui, server)
