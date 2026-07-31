#' @importFrom rlang %||%
#'
#' @title PhaserGame
#' @description R6 class to create and manage a Phaser game within a Shiny application.
#' Provides methods for adding sprites, animations, images, sounds, backgrounds, controls, and collision handling.
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
    #' @param gravity_x Numeric. Horizontal Arcade Physics world gravity (defaults to 0).
    #' @param gravity_y Numeric. Vertical Arcade Physics world gravity (defaults to 0).
    #' @return A new PhaserGame object.
    #' @examples
    #' game <- PhaserGame$new(id = "my_game", width = 1024, height = 768)
    initialize = function(id = "phaser_game",
                          width = 800,
                          height = 600,
                          gravity_x = 0,
                          gravity_y = 0) {
      self$id <- id

      private$config <- list(
        width = width,
        height = height,
        gravity_x = gravity_x,
        gravity_y = gravity_y
      )
    },

    #' @description Set the Shiny session used to send Phaser custom messages.
    #' @param session Shiny session object (default: shiny::getDefaultReactiveDomain()).
    set_shiny_session = function(session = shiny::getDefaultReactiveDomain()) {
      private$session <- session
    },

    #' @description Load dependencies and initialize the Phaser game in the UI.
    #' @return HTML tag list containing dependencies and initialization script.
    #' @examples
    #'  game$use_phaser()
    use_phaser = function() {
      shiny::addResourcePath("assets", system.file("assets", package = "shinyphaser"))
      htmltools::tagList(
        phaser_dependency(),
        htmltools::tags$div(id = self$id, style = "width:100vw; height:100vh;"),
        htmltools::htmlDependency(
          name = "shinyphaser-assets",
          version = "0.1",
          package = "shinyphaser",
          src = "www",
          script = c("phaser-game.js", "phaser-groups.js",
                     "phaser-sprite.js", "phaser-image.js")
        ),
        htmltools::tags$script(
          sprintf("initPhaserGame('%s', %s);", self$id,
                  jsonlite::toJSON(private$config, auto_unbox = TRUE))
        )
      )
    },

    #' @description Add a text object to the Phaser scene.
    #' @param text Character. Text value to display.
    #' @param id Character. Unique ID for the text object.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param style Named list. Styling options passed to Phaser text rendering.
    #' @param visible Logical. Whether text is initially visible.
    add_text = function(text, id, x, y, style = list(font_size = '22px'), visible = TRUE) {
      return(Text$new(
        text, id, x, y, style, visible,
        session = private$session %||% shiny::getDefaultReactiveDomain()
      ))
    },

    #' @description Add a rectangle object to the Phaser scene.
    #' @param name Character. Unique name for the rectangle.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param width Numeric. Rectangle width in pixels.
    #' @param height Numeric. Rectangle height in pixels.
    #' @param color Character. Fill color in Phaser-compatible format.
    #' @param visible Logical. Whether rectangle is initially visible.
    #' @param clickable Logical. Whether rectangle emits click events.
    add_rectangle = function(name, x, y, width, height, color, visible = TRUE, clickable = FALSE) {
      return(Rectangle$new(name, x, y, width, height, color, visible, clickable))
    },

    #' @description Adds a static image to the Phaser scene.
    #' @param name Character. Unique key to reference this image.
    #' @param url Character. URL or path to the image file.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param visible Logical. Whether the image is initially visible (default: TRUE).
    #' @param clickable Logical. Whether the image should emit click events (default: FALSE).
    add_image = function(name, url, x, y, visible = TRUE, clickable = FALSE) {
      return(Image$new(name, url, x, y, visible, clickable))
    },

    #' @description Adds a sound to the Phaser scene.
    #' @param name Character. Unique key to reference this sound.
    #' @param url Character. URL or path to the audio file.
    #' @param volume Numeric. Initial playback volume from 0 to 1 (default: 1).
    #' @param loop Logical. Whether the sound should loop by default (default: FALSE).
    add_sound = function(name, url, volume = 1, loop = FALSE) {
      return(Sound$new(
        name, url, volume, loop,
        session = private$session %||% shiny::getDefaultReactiveDomain()
      ))
    },

    #' @description Create browser-resident state for use in browser actions.
    #' @param key Character. Unique state key.
    #' @param initial Initial JSON-serializable value.
    add_state = function(key, initial = NULL) {
      send_js(private, sprintf("setBrowserState(%s, %s);",
        jsonlite::toJSON(key, auto_unbox = TRUE),
        jsonlite::toJSON(initial, auto_unbox = TRUE, null = "null")))
      BrowserState$new(key)
    },

    #' @description Create a browser-resident cooldown for browser-action conditions.
    #' @param key Character. Unique cooldown key.
    #' @param duration Numeric. Cooldown duration in milliseconds.
    add_cooldown = function(key, duration) BrowserCooldown$new(key, duration),

    #' @description Add a background (tilemap) layer from Tiled JSON + tileset image(s).
    #' @param map_key Character. Key for the tilemap JSON.
    #' @param map_url Character. URL of the Tiled JSON file (relative to www/assets/).
    #' @param tileset_urls Character vector. URLs of tileset image files.
    #' @param tileset_names Character vector. Names of tilesets as defined in Tiled.
    #' @param layer_name Character. Name of the layer to render from Tiled.
    #' @return Invisible; sends a custom message to the client.
    add_map = function(map_key,
                       map_url,
                       tileset_urls,
                       tileset_names,
                       layer_name) {
      js <- sprintf(
        "addMap(%s, %s, %s, %s, %s);",
        jsonlite::toJSON(map_key, auto_unbox = TRUE),
        jsonlite::toJSON(map_url, auto_unbox = TRUE),
        jsonlite::toJSON(tileset_urls, auto_unbox = TRUE),
        jsonlite::toJSON(tileset_names, auto_unbox = TRUE),
        jsonlite::toJSON(layer_name, auto_unbox = TRUE)
      )
      send_js(private, js)
    },

    #' @description Set the Phaser physics world and camera bounds.
    #' @param width Numeric. World width in pixels.
    #' @param height Numeric. World height in pixels.
    #' @return Invisible; sends a custom message to the client.
    set_world_bounds = function(width, height) {
      js <- sprintf("setWorldBounds(%d, %d);", width, height)
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
    #' @param frame_width Numeric. Width of each frame.
    #' @param frame_height Numeric. Height of each frame.
    #' @param frame_count Numeric. Number of frames in the spritesheet.
    #' @param frame_rate Numeric. Frames per second for the idle animation.
    add_sprite = function(name, url,
                          x, y,
                          frame_width, frame_height,
                          frame_count = 1, frame_rate = 1) {
      return(Sprite$new(
        name, url, x, y, frame_width, frame_height, frame_count, frame_rate,
        session = private$session %||% shiny::getDefaultReactiveDomain()
      ))
    },

    #' @description Adds a dynamic group from a spritesheet.
    #' @param name Character. Unique name of the group.
    add_group = function(name) {
      return(Group$new(
        name,
        session = private$session %||% shiny::getDefaultReactiveDomain()
      ))
   },

    #' @description Adds a static sprite to the scene (non-animated).
    #' @param name Character. Unique name of the sprite.
    #' @param url Character. URL or path to the image file.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    add_static_sprite = function(name, url, x, y) {
      return(StaticSprite$new(
        name, url, x, y,
        session = private$session %||% shiny::getDefaultReactiveDomain()
      ))
    },

    #' @description Adds a static group to the scene (non-animated).
    #' @param name Character. Unique name of the group.
    #' @param url Character. URL or path to the image file.
    add_static_group = function(name, url) {
      return(StaticGroup$new(
        name = name,
        url = url,
        session = private$session %||% shiny::getDefaultReactiveDomain()
      ))
    },

    #' @description Adds a collider between two game objects.
    #' @param object_one Character. Name of the first object.
    #' @param object_two Character. Name of the second object.
    #' @param group Character. Name of the group to compare against.
    #' @param browser_action Actions created with [browser_actions()] that run
    #'   immediately in the browser.
    #' @param input Shiny input list.
    #' @param server_action Function called in R with the collision event.
    add_collider = function(object_one,
                            object_two = NULL,
                            group = NULL,
                            browser_action = browser_actions(),
                            input = NULL,
                            server_action = NULL) {
      browser_spec <- compile_browser_actions(substitute(browser_action), parent.frame())
      input_id <- paste(
        c("collide", object_one,
          object_two %||% group),
        collapse = "_"
      )

      event_target <- if (!is.null(server_action)) input_id else NULL
      register_server_action(input, input_id, server_action)

      js <- if (!is.null(object_two)) {
        sprintf("addCollider('%s','%s',%s,%s)",
                object_one, object_two,
                phaser_event_target_json(event_target),
                jsonlite::toJSON(browser_spec, auto_unbox = TRUE, null = "null"))
      } else {
        sprintf("addGroupCollider('%s','%s',%s,%s)",
                object_one, group,
                phaser_event_target_json(event_target),
                jsonlite::toJSON(browser_spec, auto_unbox = TRUE, null = "null"))
      }
      send_js(private, js)
    },

    #' @description Adds a collider between two game objects.
    #' @param object_one Character. Name of the first object.
    #' @param object_two Character. Name of the second object.
    #' @param group Character. Name of the group.
    #' @param browser_action Actions created with [browser_actions()] that run
    #'   immediately in the browser.
    #' @param input Shiny input list.
    #' @param server_action Function called in R with the overlap event.
    #' @param mode Character. `"enter"` (default) runs once per contact;
    #'   `"stay"` repeats while overlapping.
    #' @param interval Numeric. Minimum milliseconds between `"stay"` actions.
    add_overlap = function(object_one,
                           object_two = NULL,
                           group = NULL,
                           browser_action = browser_actions(),
                           input = NULL,
                           server_action = NULL,
                           mode = c("enter", "stay"),
                           interval = 0) {
      browser_spec <- compile_browser_actions(substitute(browser_action), parent.frame())
      mode <- match.arg(mode)

      input_id <- paste(
        c("overlap", object_one,
          object_two %||% group),
        collapse = "_"
      )

      event_endpoint <- if (!is.null(server_action)) input_id else NULL
      register_server_action(input, input_id, server_action)

      js <- if (!is.null(object_two)) {
        sprintf("addOverlap(%s, %s, %s, %s, %s, %s)",
                jsonlite::toJSON(object_one, auto_unbox = TRUE),
                jsonlite::toJSON(object_two, auto_unbox = TRUE),
                phaser_event_target_json(event_endpoint),
                jsonlite::toJSON(browser_spec, auto_unbox = TRUE, null = "null"),
                jsonlite::toJSON(mode, auto_unbox = TRUE), interval)
      } else {
        sprintf("addGroupOverlap(%s, %s, %s, %s, %s, %s)",
                jsonlite::toJSON(object_one, auto_unbox = TRUE),
                jsonlite::toJSON(group, auto_unbox = TRUE),
                phaser_event_target_json(event_endpoint),
                jsonlite::toJSON(browser_spec, auto_unbox = TRUE, null = "null"),
                jsonlite::toJSON(mode, auto_unbox = TRUE), interval)
      }
      send_js(private, js)
    },

   #' @description Create a reactive expression for overlap state between two objects.
   #' @param object_one Character. Name of the first object.
   #' @param object_two Character. Name of the second object.
   #' @param input Shiny input list.
   are_overlap = function(object_one,
                          object_two,
                          input) {
     input_id <- paste(
       c("are_overlap", object_one,
         object_two %||% group),
       collapse = "_"
     )
     js <- sprintf("areOverlap('%s','%s','%s')",
            object_one, object_two, input_id)
     send_js(private, js)
     shiny::eventReactive(input[[input_id]], {
       input[[input_id]]
     })
    },

   #' @description Register a callback fired when overlap between objects ends.
   #' @param object_one Character. Name of the first object.
   #' @param object_two Character. Name of the second object.
   #' @param group Character. Name of the group to compare against.
   #' @param browser_action Actions created with [browser_actions()] that run
   #'   immediately in the browser.
   #' @param input Shiny input list.
   #' @param server_action Function called in R with the overlap-end event.
   #' @param session Shiny session object.
   add_overlap_end = function(object_one,
                              object_two = NULL,
                              group = NULL,
                              browser_action = browser_actions(),
                              input = NULL,
                              server_action = NULL,
                              session = shiny::getDefaultReactiveDomain()) {
     browser_spec <- compile_browser_actions(substitute(browser_action), parent.frame())

     input_id <- paste(
       c("overlap_end", object_one,
         object_two %||% group),
       collapse = "_"
     )
     event_endpoint <- if (!is.null(server_action)) input_id else NULL
     register_server_action(input, input_id, server_action)
     js <- sprintf("addOverlapEnd(%s, %s, %s, %s);",
                   jsonlite::toJSON(object_one, auto_unbox = TRUE),
                   jsonlite::toJSON(object_two, auto_unbox = TRUE),
                   phaser_event_target_json(event_endpoint),
                   jsonlite::toJSON(browser_spec, auto_unbox = TRUE, null = "null"))
     session$sendCustomMessage("phaser", list(js = js))
   },

   #' @description Register a callback fired when a specific key is pressed.
   #' @param key A character, accepts Javascript key events (they need to align with
   #'   event.code).
   #' @param browser_action Actions created with [browser_actions()] that run
   #'   immediately in the browser.
   #' @param input Shiny input list.
   #' @param server_action Function called in R with the keyboard event.
   add_control = function(key,
                          browser_action = browser_actions(),
                          input = NULL,
                          server_action = NULL) {
     browser_spec <- compile_browser_actions(substitute(browser_action), parent.frame())
     register_server_action(input, paste0(key, "_action"), server_action)
     js <- sprintf(
       "addKeyControl(%s, %s, %s);",
       jsonlite::toJSON(key, auto_unbox = TRUE),
       jsonlite::toJSON(browser_spec, auto_unbox = TRUE, null = "null"),
       tolower(!is.null(server_action))
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

#' @title Text
#' @description R6 class to represent a text object in the Phaser scene, allowing
#'  dynamic updates to its content. Created with PhaserGame$add_text() method.
#' @export
Text <- R6::R6Class(
  classname = "Text",
  public = list(
    #' @description Create a text object in the Phaser scene.
    #' @param text Character. Text value to display.
    #' @param id Character. Unique ID for the text object.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param style Named list. Styling options passed to Phaser text rendering.
    #' @param visible Logical. Whether text is initially visible.
    #' @param session Shiny session object.
    initialize = function(text, id, x, y, style, visible = TRUE,
                          session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addText('%s', '%s', %d, %d, %s, %s);",
                    text, id, x, y, jsonlite::toJSON(style, auto_unbox = TRUE),
                    tolower(visible))
      private$id <- id
      private$session <- session
      send_js(private, js)
    },
    #' @description Update the text content of this object.
    #' @param text Character. New text value to display.
    set = function(text) {
      js <- sprintf("setText('%s', '%s');",
                    text, private$id)
      send_js(private, js)
    },
    #' @description Show a previously added text object.
    show = function() {
      js <- sprintf("showText('%s');", private$id)
      send_js(private, js)
    },
    #' @description Hide a previously added text object.
    hide = function() {
      js <- sprintf("hideText('%s');", private$id)
      send_js(private, js)
    },
    #' @description Make the camera follow this text object as it moves through the world.
    #' @param lerp_x Numeric. Horizontal interpolation factor from 0 to 1 (default: 1).
    #' @param lerp_y Numeric. Vertical interpolation factor from 0 to 1 (default: 1).
    #' @param round_pixels Logical. Whether to round camera pixels to avoid sub-pixel rendering (default: TRUE).
    follow_camera = function(lerp_x = 1,
                             lerp_y = 1,
                             round_pixels = TRUE) {
      js <- sprintf(
        "followSpriteWithCamera('%s', %f, %f, %s);",
        private$id, lerp_x, lerp_y, tolower(round_pixels)
      )
      send_js(private, js)
    },
    #' @description Stop the camera from following this text object.
    stop_camera_follow = function() {
      js <- sprintf("stopCameraFollow('%s');", private$id)
      send_js(private, js)
    },
    #' @description Set how much this text object scrolls with the camera.
    #' @param x Numeric. Horizontal scroll factor (0 = fixed to viewport, 1 = scrolls with world).
    #' @param y Numeric. Vertical scroll factor. Defaults to `x`.
    set_scroll_factor = function(x, y = x) {
      js <- sprintf("setScrollFactor('%s', %f, %f);", private$id, x, y)
      send_js(private, js)
    }
  ),
  private = list(
    id = NULL,
    session = NULL
  )
)
