# A minimal save/load example using R as the authoritative state store.
# Run after installing shinyphaser with:
# shiny::runApp(system.file("examples/save-load.R", package = "shinyphaser"))

library(shiny)
library(shinyphaser)

game <- PhaserGame$new(width = 640, height = 360)

ui <- fluidPage(
  game$use_phaser(),
  actionButton("save", "Save score"),
  actionButton("load", "Load score"),
  textOutput("status")
)

server <- function(input, output, session) {
  game$set_shiny_session(session)
  score <- reactiveVal(0L)
  save_file <- file.path(tempdir(), paste0("shinyphaser-", session$token, ".rds"))

  score_text <- game$add_text("Score: 0", "score", 30, 30)

  # Space changes state in R, so the same state can be persisted by R.
  game$add_control(
    key = "Space",
    input = input,
    server_action = function(event) {
      score(score() + 1L)
      score_text$set(paste("Score:", score()))
    }
  )

  observeEvent(input$save, {
    saveRDS(list(score = score()), save_file)
    output$status <- renderText("Game saved")
  })

  observeEvent(input$load, {
    req(file.exists(save_file))
    saved <- readRDS(save_file)
    score(saved$score)
    score_text$set(paste("Score:", score()))
    output$status <- renderText("Game loaded")
  })

  session$onSessionEnded(function() unlink(save_file))
}

shinyApp(ui, server)
