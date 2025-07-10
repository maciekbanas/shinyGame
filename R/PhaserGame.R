#' @importFrom rlang %||%
#'
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

    #' @param session Shiny session object (default: shiny::getDefaultReactiveDomain()).
    set_shiny_session = function(session = shiny::getDefaultReactiveDomain()) {
      private$session <- session
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
          script = c("phaser-game.js", "phaser-groups.js",
                     "phaser-sprite.js")
        ),
        htmltools::tags$script(
          sprintf("initPhaserGame('%s', %s);", self$id,
                  jsonlite::toJSON(private$config, auto_unbox = TRUE))
        )
      )
    },

    add_text = function(text, id, x, y, style = list(fontSize = '22px')) {
      return(TextObject$new(text, id, x, y, style))
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
    #' @return Invisible; sends a custom message to the client.
    add_player_sprite = function(name, url, x, y, frameWidth, frameHeight, frameCount, frameRate) {
      js <- sprintf("addPlayerSprite('%s', '%s', %d, %d, %d, %d, %d, %d);",
                    name, url, x, y, frameWidth, frameHeight, frameCount, frameRate)
      send_js(private, js)
    },

    #' @description Load a custom animation for any sprite previously added.
    #' @param name Character. Base key used in add_player_sprite or add_enemy_sprite.
    #' @param suffix Character. Identifier for this animation (e.g. "move_left").
    #' @param url Character. URL or path to the spritesheet.
    #' @param frameWidth Numeric. Width of each frame.
    #' @param frameHeight Numeric. Height of each frame.
    #' @param frameCount Numeric. Number of frames in the spritesheet.
    #' @param frameRate Numeric. Frames per second for playback.
    #' @return Invisible; sends a custom message to the client.
    add_sprite_animation = function(name, suffix, url,
                                    frameWidth, frameHeight,
                                    frameCount, frameRate) {
      js <- sprintf(
        "addSpriteAnimation('%s','%s','%s',%d,%d,%d,%d);",
        name, suffix, url, frameWidth, frameHeight, frameCount, frameRate
      )
      send_js(private, js)
    },

    #' @description Adds a static image to the Phaser scene.
    #' @param imageName Character. Unique key to reference this image.
    #' @param imageUrl Character. URL or path to the image file.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @return Invisible; sends a custom message to the client.
    add_image = function(imageName, imageUrl, x, y) {
      js <- sprintf("addImage('%s', '%s', %d, %d);", imageName, imageUrl, x, y)
      send_js(private, js)
    },

    #' @description Add a background (tilemap) layer from Tiled JSON + tileset image(s).
    #' @param mapKey Character. Key for the tilemap JSON.
    #' @param mapUrl Character. URL of the Tiled JSON file (relative to www/assets/).
    #' @param tilesetUrls Character vector. URLs of tileset image files.
    #' @param tilesetNames Character vector. Names of tilesets as defined in Tiled.
    #' @param layerName Character. Name of the layer to render from Tiled.
    #' @return Invisible; sends a custom message to the client.
    add_map = function(mapKey,
                       mapUrl,
                       tilesetUrls,
                       tilesetNames,
                       layerName) {
      js <- sprintf(
        "addMap(%s, %s, %s, %s, %s);",
        jsonlite::toJSON(mapKey, auto_unbox = TRUE),
        jsonlite::toJSON(mapUrl, auto_unbox = TRUE),
        jsonlite::toJSON(tilesetUrls, auto_unbox = TRUE),
        jsonlite::toJSON(tilesetNames, auto_unbox = TRUE),
        jsonlite::toJSON(layerName, auto_unbox = TRUE)
      )
      send_js(private, js)
    },

    #' @description Enable movement controls (arrow keys) for a player sprite.
    #' @param name Character. Name of the player sprite (as added via add_player_sprite).
    #' @param directions Character vector. Directions to enable (defaults to c("left","right","down","up")).
    #' @param speed Numeric. Movement speed in pixels/second (default: 200).
    add_player_controls = function(name,
                                   directions = c("left", "right", "down", "up"),
                                   speed = 200) {
      js_dirs <- jsonlite::toJSON(directions, auto_unbox = TRUE)
      js <- sprintf("addPlayerControls('%s', %s, %d);", name, js_dirs, speed)
      send_js(private, js)
    },

    #' @description Enable terrain collision for a player sprite.
    #' @param name Character. Name of the player sprite (as added via add_player_sprite).
    enable_terrain_collision = function(name) {
      js <- sprintf("addPlayerTerrainCollider('%s');", name)
      send_js(private, js)
    },

    #' @description Adds a static sprite to the scene (non-animated).
    #' @param name Character. Unique name of the sprite.
    #' @param url Character. URL or path to the image file.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    add_static_sprite = function(name, url, x, y) {
      return(StaticSprite$new(name, url, x, y))
    },

    #' @description Adds a static group to the scene (non-animated).
    #' @param name Character. Unique name of the group.
    #' @param url Character. URL or path to the image file.
    add_static_group = function(name, url) {
      return(StaticGroup$new(
        name = name,
        url = url,
        session = private$session)
      )
    },

    #' @description Adds a collider between two game objects.
    #' @param object_one_name Character. Name of the first object.
    #' @param object_two_name Character. Name of the second object.
    add_collider = function(object_one_name,
                            object_two_name = NULL,
                            group_name      = NULL,
                            callback_fun    = NULL,
                            input) {
      input_id <- paste(
        c("collide", object_one_name,
          object_two_name %||% group_name),
        collapse = "_"
      )

      js <- if (!is.null(object_two_name)) {
        sprintf("addCollider('%s','%s','%s')",
                object_one_name, object_two_name, input_id)
      } else {
        sprintf("addGroupCollider('%s','%s','%s')",
                object_one_name, group_name, input_id)
      }
      send_js(private, js)
      if (!is.null(callback_fun)) {
        shiny::observeEvent(input[[input_id]], {
          evt <- input[[input_id]]
          callback_fun(evt)
        }, ignoreNULL = TRUE)
      }
    },

    #' @description Adds a collider between two game objects.
    #' @param object_one_name Character. Name of the first object.
    #' @param object_two_name Character. Name of the second object.
    #' @param group_name Character. Name of the group.
    #' @param callback_fun A function to be run when overlap occurs.
    add_overlap = function(object_one_name,
                           object_two_name = NULL,
                           group_name      = NULL,
                           callback_fun,
                           input) {

      input_id <- paste(
        c("overlap", object_one_name,
          object_two_name %||% group_name),
        collapse = "_"
      )

      js <- if (!is.null(object_two_name)) {
        sprintf("addOverlap('%s','%s','%s')",
                object_one_name, object_two_name, input_id)
      } else {
        sprintf("addGroupOverlap('%s','%s','%s')",
                object_one_name, group_name, input_id)
      }
      send_js(private, js)

      shiny::observeEvent(input[[input_id]], {
        evt <- input[[input_id]]
        callback_fun(evt)
      }, ignoreNULL = TRUE)
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
    add_sprite = function(name, url,
                          x, y,
                          frameWidth, frameHeight,
                          frameCount = 1, frameRate = 1) {
      return(Sprite$new(name, url, x, y, frameWidth, frameHeight, frameCount, frameRate))
    },

    #' @description Move all sprites of a given type along a vector for a set distance.
    #' @param type Character. Key used in add_sprite().
    #' @param dirX Numeric. Horizontal direction (-1 = left, +1 = right, 0 = none).
    #' @param dirY Numeric. Vertical direction (-1 = up, +1 = down, 0 = none).
    #' @param speed Numeric. Speed in pixels/second.
    #' @param distance Numeric. Distance in pixels to travel before stopping.
    #' @param lag Numeric. Optional delay before sending the command (defaults to distance/speed).
    set_sprite_in_motion = function(type,
                                    dirX,
                                    dirY,
                                    speed,
                                    distance,
                                    lag = distance/speed) {
      Sys.sleep(lag)
      js <- sprintf(
        "setSpriteInMotion('%s', %d, %d, %d, %d);",
        type, dirX, dirY, speed, distance
      )
      send_js(private, js)
    }
  ),

  private = list(
    config = list(),
    input = NULL,
    session = NULL
  )
)

TextObject <- R6::R6Class(
  classname = "TextObject",
  public = list(
    initialize = function(text, id, x, y, style, session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addText('%s', '%s', %d, %d, %s);",
                    text, id, x, y, jsonlite::toJSON(style, auto_unbox = TRUE))
      private$id <- id
      private$session <- session
      send_js(private, js)
    },
    set = function(text) {
      js <- sprintf("setText('%s', '%s');",
                    text, private$id)
      send_js(private, js)
    }
  ),
  private = list(
    id = NULL,
    session = NULL
  )
)

StaticGroup <- R6::R6Class(
  classname = "StaticGroup",
  public = list(
    initialize = function(name, url, session) {
      private$name <- name
      private$session <- session

      js <- sprintf("addStaticGroup('%s','%s');", name, url)
      send_js(private, js)

      Sys.sleep(0.1)
    },
    create = function(x, y) {
      js <- sprintf(
        "addToStaticGroup('%s', %d, %d);",
        private$name, x, y
      )
      send_js(private, js)
    },
    disable = function(evt) {
      x <- evt$x2
      y <- evt$y2
      js <- sprintf(
        "disableBody('%s', %d, %d);",
        private$name, x, y
      )
      send_js(private, js)
    }
  ),
  private = list(
    name = NULL,
    session = NULL
  )
)

Sprite <- R6::R6Class(
  classname = "Sprite",
  public = list(
    initialize = function(name, url, x, y,
                          frameWidth, frameHeight, frameCount, frameRate,
                          session = getDefaultReactiveDomain()) {
      private$session <- session
      private$name <- name
      js <- sprintf(
        "addSprite('%s', '%s', %d, %d, %d, %d, %d, %d);",
        name, url, x, y, frameWidth, frameHeight, frameCount, frameRate
      )
      send_js(private, js)
    },
    move = function(dx = NULL, dy = NULL, duration) {
      js <- sprintf("move('%s', %d, %d, %d);",
                    private$name, dx, dy, duration)
      send_js(private, js)
    }
  ),
  private = list(
    name = NULL,
    session = NULL
  )
)

StaticSprite <- R6::R6Class(
  classname = "StaticSprite",
  public = list(
    initialize = function(name, url, x, y, session = getDefaultReactiveDomain()) {
      private$session <- session
      private$name <- name
      js <- sprintf("addStaticSprite('%s','%s', %s, %s);",
                    name, url, x, y)
      send_js(private, js)
    }
  ),
  private = list(
    name = NULL,
    session = NULL
  )
)

send_js <- function(private, js) {
  private$session$sendCustomMessage("phaser", list(js = js))
}
