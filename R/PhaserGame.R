#' @title PhaserGame
#' @description R6 class to create and manage a Phaser game within a Shiny application.
#' Provides methods for adding sprites, animations, images, backgrounds, controls, and collision handling.
#'
#' @export
PhaserGame <- R6::R6Class(
  "PhaserGame",
  public = list(
    #' @field id Character. ID of the Game container. Used as the HTML element ID where the game canvas will be rendered.
    id = NULL,

    #' @description Create a PhaserGame object with the given configuration.
    #' @param id Character. ID of the Game container (defaults to "phaser_game").
    #' @param width Numeric. Width of the Phaser canvas in pixels (defaults to 800).
    #' @param height Numeric. Height of the Phaser canvas in pixels (defaults to 600).
    #' @return A new PhaserGame object.
    #' @examples
    #' game <- PhaserGame$new(id = "my_game", width = 1024, height = 768)
    initialize = function(id = "phaser_game",
                          width = 800,
                          height = 600) {
      self$id <- id
      private$config <- list(
        width = width,
        height = height
      )
    },

    #' @description Load dependencies and initialize the Phaser game in the UI.
    #' @return HTML tag list containing dependencies and initialization script.
    #' @examples
    #'  game$ui()
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

    #' @description Add a player sprite to the scene as an animated spritesheet.
    #' @param name Character. Unique key for the sprite.
    #' @param url Character. URL or relative path to the spritesheet image.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param frameWidth Numeric. Width of each frame in the spritesheet.
    #' @param frameHeight Numeric. Height of each frame in the spritesheet.
    #' @param frameCount Numeric. Total number of frames.
    #' @param frameRate Numeric. Frames per second for the animation.
    #' @param session Shiny session object (default: shiny::getDefaultReactiveDomain()).
    #' @return Invisible; sends a custom message to the client.
    add_player_sprite = function(name, url, x, y, frameWidth, frameHeight, frameCount, frameRate,
                                 session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addPlayerSprite('%s', '%s', %d, %d, %d, %d, %d, %d);",
                    name, url, x, y, frameWidth, frameHeight, frameCount, frameRate)
      session$sendCustomMessage("phaser", list(js = js))
    },

    #' @description Load a custom animation for any sprite previously added.
    #' @param name Character. Base key used in add_player_sprite or add_enemy_sprite.
    #' @param suffix Character. Identifier for this animation (e.g. "move_left").
    #' @param url Character. URL or path to the spritesheet.
    #' @param frameWidth Numeric. Width of each frame.
    #' @param frameHeight Numeric. Height of each frame.
    #' @param frameCount Numeric. Number of frames in the spritesheet.
    #' @param frameRate Numeric. Frames per second for playback.
    #' @param session Shiny session object (default: shiny::getDefaultReactiveDomain()).
    #' @return Invisible; sends a custom message to the client.
    add_sprite_animation = function(name, suffix, url,
                                    frameWidth, frameHeight,
                                    frameCount, frameRate,
                                    session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf(
        "addSpriteAnimation('%s','%s','%s',%d,%d,%d,%d);",
        name, suffix, url, frameWidth, frameHeight, frameCount, frameRate
      )
      session$sendCustomMessage("phaser", list(js = js))
    },

    #' @description Adds a static image to the Phaser scene.
    #' @param imageName Character. Unique key to reference this image.
    #' @param imageUrl Character. URL or path to the image file.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param session Shiny session object (default: shiny::getDefaultReactiveDomain()).
    #' @return Invisible; sends a custom message to the client.
    add_image = function(imageName, imageUrl, x, y, session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addImage('%s', '%s', %d, %d);", imageName, imageUrl, x, y)
      session$sendCustomMessage("phaser", list(js = js))
    },

    #' @description Add a background (tilemap) layer from Tiled JSON + tileset image(s).
    #' @param mapKey Character. Key for the tilemap JSON.
    #' @param mapUrl Character. URL of the Tiled JSON file (relative to www/assets/).
    #' @param tilesetUrls Character vector. URLs of tileset image files.
    #' @param tilesetNames Character vector. Names of tilesets as defined in Tiled.
    #' @param layerName Character. Name of the layer to render from Tiled.
    #' @param session Shiny session object (default: shiny::getDefaultReactiveDomain()).
    #' @return Invisible; sends a custom message to the client.
    add_map = function(mapKey,
                       mapUrl,
                       tilesetUrls,
                       tilesetNames,
                       layerName,
                       session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf(
        "addMap(%s, %s, %s, %s, %s);",
        jsonlite::toJSON(mapKey, auto_unbox = TRUE),
        jsonlite::toJSON(mapUrl, auto_unbox = TRUE),
        jsonlite::toJSON(tilesetUrls, auto_unbox = TRUE),
        jsonlite::toJSON(tilesetNames, auto_unbox = TRUE),
        jsonlite::toJSON(layerName, auto_unbox = TRUE)
      )
      session$sendCustomMessage("phaser", list(js = js))
    },

    #' @description Enable movement controls (arrow keys) for a player sprite.
    #' @param name Character. Name of the player sprite (as added via add_player_sprite).
    #' @param directions Character vector. Directions to enable (defaults to c("left","right","down","up")).
    #' @param speed Numeric. Movement speed in pixels/second (default: 200).
    #' @param session Shiny session object (default: shiny::getDefaultReactiveDomain()).
    add_player_controls = function(name, directions = c("left", "right", "down", "up"),
                                   speed = 200,
                                   session = shiny::getDefaultReactiveDomain()) {
      js_dirs <- jsonlite::toJSON(directions, auto_unbox = TRUE)
      js <- sprintf("addPlayerControls('%s', %s, %d);", name, js_dirs, speed)
      session$sendCustomMessage("phaser", list(js = js))
    },

    #' @description Enable terrain collision for a player sprite.
    #' @param name Character. Name of the player sprite (as added via add_player_sprite).
    #' @param session Shiny session object (default: shiny::getDefaultReactiveDomain()).
    enable_terrain_collision = function(name, session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addPlayerTerrainCollider('%s');", name)
      session$sendCustomMessage("phaser", list(js = js))
    },

    #' @description Adds a static sprite to the scene (non-animated).
    #' @param name Character. Unique name of the sprite.
    #' @param url Character. URL or path to the image file.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param session Shiny session object (default: shiny::getDefaultReactiveDomain()).
    add_static_sprite = function(name, url, x, y, session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addStaticSprite('%s','%s',%s,%s);",
                    name, url, x, y)
      session$sendCustomMessage("phaser", list(js = js))
    },

    #' @description Adds a collider between two game objects.
    #' @param object_one_name Character. Name of the first object.
    #' @param object_two_name Character. Name of the second object.
    #' @param session Shiny session object (default: shiny::getDefaultReactiveDomain()).
    add_collider = function(object_one_name, object_two_name, session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addCollider('%s','%s');",
                    object_one_name, object_two_name)
      session$sendCustomMessage("phaser", list(js = js))
    },

    #' @description Load a base spritesheet and create an "idle" animation.
    #' @param name Character. Unique key for the sprite and its idle animation.
    #' @param url Character. URL or path to the spritesheet image.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param frameWidth Numeric. Width of each frame.
    #' @param frameHeight Numeric. Height of each frame.
    #' @param frameCount Numeric. Number of frames in the spritesheet.
    #' @param frameRate Numeric. Frames per second for the idle animation.
    #' @param session Shiny session object (default: shiny::getDefaultReactiveDomain()).
    add_sprite = function(name, url,
                          x, y,
                          frameWidth, frameHeight,
                          frameCount, frameRate,
                          session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf(
        "addSprite('%s', '%s', %d, %d, %d, %d, %d, %d);",
        name, url, x, y, frameWidth, frameHeight, frameCount, frameRate
      )
      session$sendCustomMessage("phaser", list(js = js))
    },

    #' @description Move all sprites of a given type along a vector for a set distance.
    #' @param type Character. Key used in add_sprite().
    #' @param dirX Numeric. Horizontal direction (-1 = left, +1 = right, 0 = none).
    #' @param dirY Numeric. Vertical direction (-1 = up, +1 = down, 0 = none).
    #' @param speed Numeric. Speed in pixels/second.
    #' @param distance Numeric. Distance in pixels to travel before stopping.
    #' @param lag Numeric. Optional delay before sending the command (defaults to distance/speed).
    #' @param session Shiny session object (default: shiny::getDefaultReactiveDomain()).
    set_sprite_in_motion = function(type,
                                    dirX,
                                    dirY,
                                    speed,
                                    distance,
                                    lag = distance/speed,
                                    session = shiny::getDefaultReactiveDomain()) {
      Sys.sleep(lag)
      js <- sprintf(
        "setSpriteInMotion('%s', %d, %d, %d, %d);",
        type, dirX, dirY, speed, distance
      )
      session$sendCustomMessage("phaser", list(js = js))
    }
  ),

  private = list(
    config = list()
  )
)
