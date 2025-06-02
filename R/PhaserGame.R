#' @title PhaserGame class object
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
      shiny::addResourcePath("assets", system.file("assets", package = "phaserR"))
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
    #' @param x X position of player sprite.
    #' @param y Y position of player sprite.
    #' @param frameWidth Should be adjusted to sprite resolution.
    #' @param frameHeight Should be adjusted to sprite resolution.
    #' @param frameCount Number of frames in sprite.
    #' @param frameRate Speed of rendering frames (number of frames per second).
    add_player_sprite = function(name, url, x, y, frameWidth, frameHeight, frameCount, frameRate,
                                 session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addPlayerSprite('%s', '%s', %d, %d, %d, %d, %d, %d);",
                    name, url, x, y, frameWidth, frameHeight, frameCount, frameRate)
      session$sendCustomMessage("phaser", list(js = js))
    },
    add_player_move_right_animation = function(name, url, frameWidth, frameHeight, frameCount, frameRate,
                                 session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addPlayerMoveRightAnimation('%s', '%s', %d, %d, %d, %d);",
                    name, url, frameWidth, frameHeight, frameCount, frameRate)
      session$sendCustomMessage("phaser", list(js = js))
    },
    add_player_move_left_animation = function(name, url, frameWidth, frameHeight, frameCount, frameRate,
                                               session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addPlayerMoveLeftAnimation('%s', '%s', %d, %d, %d, %d);",
                    name, url, frameWidth, frameHeight, frameCount, frameRate)
      session$sendCustomMessage("phaser", list(js = js))
    },
    #' Add a background/tilemap layer from Tiled JSON + tileset image.
    #'
    #' @param mapKey A short string key (used internally in Phaser) for your tilemap JSON.
    #' @param mapUrl URL (relative to www/assets/) of the `.json` exported from Tiled.
    #' @param tilesetNames The exact names of the tileset as it appears inside Tiled (must match the Tiled "Tileset" name).
    #' @param tilesetUrls URLs (relative to www/assets/) of the `PNG` or `JPG` used by your Tiled map.
    #' @param layerName The name of the layer inside the Tiled map (e.g. "Ground") that you want to render.
    #' @param session Shiny session.
    # Inside your PhaserGame R6:
    add_background = function(mapKey,
                              mapUrl,
                              tilesetUrls,
                              tilesetNames,
                              layerName,
                              session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf(
        "addBackground(%s, %s, %s, %s, %s);",
        jsonlite::toJSON(mapKey, auto_unbox = TRUE),
        jsonlite::toJSON(mapUrl, auto_unbox = TRUE),
        jsonlite::toJSON(tilesetUrls, auto_unbox = TRUE),
        jsonlite::toJSON(tilesetNames, auto_unbox = TRUE),
        jsonlite::toJSON(layerName, auto_unbox = TRUE)
      )
      session$sendCustomMessage("phaser", list(js = js))
    },
    #' Enable movement controls (arrow keys) for a player
    #' @param name Name of the player sprite (as given in add_player_sprite)
    #' @param speed Movement speed in pixels/sec (default: 200)
    enable_movement = function(name, speed = 200,
                               session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addPlayerControls('%s', %d);", name, speed)
      session$sendCustomMessage("phaser", list(js = js))
    },
    #' Enable terrain collision for a player
    #' @param name Name of the player sprite (as given in add_player_sprite)
    enable_terrain_collision = function(name, session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addPlayerTerrainCollider('%s');", name)
      session$sendCustomMessage("phaser", list(js = js))
    }
  ),
  private = list(
    config = list()
  )
)
