PhaserGame <- R6::R6Class(
  "PhaserGame",
  public = list(
    id = NULL,
    initialize = function(id = "phaser_game") {
      self$id <- id
    },
    ui = function() {
      htmltools::tagList(
        phaser_dependency(),
        htmltools::tags$div(id = self$id, style = "width:100vw; height:100vh;"),
        htmltools::htmlDependency(
          name = "phaserR-assets",
          version = "0.1",
          package = "phaserR",
          src = "www",
          script = "phaser-bridge.js"
        ),
        htmltools::tags$script(
          sprintf("initPhaserGame('%s');", self$id)
        )
      )
    },
    add_player_sprite = function(name, url, x = 100, y = 100,
                                 session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addPlayerSprite('%s', '%s', %d, %d);", name, url, x, y)
      session$sendCustomMessage("phaser", list(js = js))
    }
  )
)
