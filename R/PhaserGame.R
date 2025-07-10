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

    #' @description Enable terrain collision for a player sprite.
    #' @param name Character. Name of the player sprite (as added via add_player_sprite).
    enable_terrain_collision = function(name) {
      js <- sprintf("addPlayerTerrainCollider('%s');", name)
      send_js(private, js)
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

    #' @description Adds a dynamic group from a spritesheet.
    #' @param name Character. Unique name of the group.
    add_group = function(name) {
      return(Group$new(name))
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
        url = url
      ))
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
