#' PhaserGame class object
#' @export
PhaserGame <- R6::R6Class(
  "PhaserGame",
  public = list(
    #' @field id ID of the Game container.
    id = NULL,
    #' Create PhaserGame object with configuration
    #' @param id ID of the Game container.
    #' @param width Width of canvas element in pixels.
    #' @param height Height of canvas element in pixels.
    initialize = function(id = "phaser_game",
                          width = 800,
                          height = 600) {
      self$id <- id
      private$config <- list(
        width = width,
        height = height
      )
    },
    #' @description Load dependencies and initialize Phaser.Game
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
          sprintf("initPhaserGame('%s', %s);", self$id,
                  jsonlite::toJSON(private$config, auto_unbox = TRUE))
        )
      )
    },
    add_player_sprite = function(name, url, x = 100, y = 100,
                                 session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addPlayerSprite('%s', '%s', %d, %d);", name, url, x, y)
      session$sendCustomMessage("phaser", list(js = js))
    }
  ),
  private = list(
    config = list()
  )
)
