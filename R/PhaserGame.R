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
    #' @description Load a custom animation for any sprite.
    #'   `suffix` should match the suffix you want (e.g. "move_left", "move_right", "move").
    #' @param name character: base key you used in add_player_sprite() or add_enemy_sprite().
    #' @param suffix character: one of "move_left", "move_right", "move", etc.
    #' @param url character: path to the spritesheet image.
    #' @param frameWidth numeric: width of each frame.
    #' @param frameHeight numeric: height of each frame.
    #' @param frameCount numeric: number of frames in the spritesheet.
    #' @param frameRate numeric: frames per second to play this animation.
    add_sprite_animation = function(name, suffix, url,
                                    frameWidth, frameHeight,
                                    frameCount, frameRate,
                                    session = shiny::getDefaultReactiveDomain()) {
      # Build a JS call to addSpriteAnimation(name, suffix, url, frameWidth, frameHeight, frameCount, frameRate)
      js <- sprintf(
        "addSpriteAnimation('%s','%s','%s',%d,%d,%d,%d);",
        name, suffix, url, frameWidth, frameHeight, frameCount, frameRate
      )
      session$sendCustomMessage("phaser", list(js = js))
    },
    add_image = function(imageName, imageUrl, x, y, session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addImage('%s', '%s', %d, %d);", imageName, imageUrl, x, y)
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
    add_player_controls = function(name, directions = c("left", "right", "down", "up"),
                                   speed = 200,
                                   session = shiny::getDefaultReactiveDomain()) {
      js_dirs <- jsonlite::toJSON(directions, auto_unbox = TRUE)
      js <- sprintf("addPlayerControls('%s', '%s', %d);", name, js_dirs, speed)
      session$sendCustomMessage("phaser", list(js = js))
    },
    #' Enable terrain collision for a player
    #' @param name Name of the player sprite (as given in add_player_sprite)
    enable_terrain_collision = function(name, session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addPlayerTerrainCollider('%s');", name)
      session$sendCustomMessage("phaser", list(js = js))
    },
    #' @description Adds static sprite to scene.
    #' @param name A character, unique name of the sprite.
    #' @param url A character, URL or path to the image file.
    #' @param x A numeric - horizontal position (in pixels).
    #' @param y A numeric - vertical position (in pixels.)
    add_static_sprite = function(name, url, x, y, session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addStaticSprite('%s','%s',%s,%s);",
                         name, url, x, y)
      session$sendCustomMessage("phaser", list(js = js))
    },

    #' @description Adds a collider between two objects
    #' @param sprite_one_name A character, name of the first object.
    #' @param sprite_two_name A character, name of the second object.
    add_collider = function(object_one_name, object_two_name, session = shiny::getDefaultReactiveDomain()) {
      js <- sprintf("addCollider('%s','%s');",
                    object_one_name, object_two_name)
      session$sendCustomMessage("phaser", list(js = js))
    },

    #' @description Load a base spritesheet and create an "idle" animation.
    #' @param url A character, URL or path to the image file.
    #' @param x A numeric - horizontal position (in pixels).
    #' @param y A numeric - vertical position (in pixels.)
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

    #' @description Put all existing sprites of this type into motion along (dirX, dirY)
    #'   at the given speed, and stop them once they’ve traveled `distance` pixels.
    #' @param type A character: the key used in add_sprite()
    #' @param dirX A numeric: horizontal direction (–1 = left, +1 = right, 0 = no horizontal)
    #' @param dirY A numeric: vertical direction (–1 = up,   +1 = down,  0 = no vertical)
    #' @param speed A numeric: number of px/sec to move in that (dirX,dirY) direction
    #' @param distance  A numeric: how many pixels (Euclidean) to travel before stopping
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
