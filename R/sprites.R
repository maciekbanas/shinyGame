Sprite <- R6::R6Class(
  classname = "Sprite",
  public = list(
    #' @param name Character. Unique key for the sprite and its idle animation.
    #' @param url Character. URL or path to the spritesheet image.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param frameWidth Numeric. Width of each frame.
    #' @param frameHeight Numeric. Height of each frame.
    #' @param frameCount Numeric. Number of frames in the spritesheet.
    #' @param frameRate Numeric. Frames per second for the idle animation.
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
    #' @description Load a custom animation for any sprite previously added.
    #' @param suffix Character. Identifier for this animation (e.g. "move_left").
    #' @param url Character. URL or path to the spritesheet.
    #' @param frameWidth Numeric. Width of each frame.
    #' @param frameHeight Numeric. Height of each frame.
    #' @param frameCount Numeric. Number of frames in the spritesheet.
    #' @param frameRate Numeric. Frames per second for playback.
    #' @return Invisible; sends a custom message to the client.
    add_animation = function(suffix, url,
                             frameWidth, frameHeight,
                             frameCount, frameRate) {
      js <- sprintf(
        "addSpriteAnimation('%s','%s','%s',%d,%d,%d,%d);",
        private$name, suffix, url, frameWidth, frameHeight, frameCount, frameRate
      )
      send_js(private, js)
    },

    play_animation = function(anim_name) {
      Sys.sleep(0.1)
      js <- sprintf(
        "playAnimation('%s','%s');",
        private$name, anim_name
      )
      send_js(private, js)
    },

    #' @description Enable movement controls (arrow keys) for a player sprite.
    #' @param directions Character vector. Directions to enable (defaults to c("left","right","down","up")).
    #' @param speed Numeric. Movement speed in pixels/second (default: 200).
    add_player_controls = function(directions = c("left", "right", "down", "up"),
                                   speed = 200) {
      js_dirs <- jsonlite::toJSON(directions, auto_unbox = TRUE)
      js <- sprintf("addPlayerControls('%s', %s, %d);", private$name, js_dirs, speed)
      send_js(private, js)
    },

    #' @key A character, accepts Javascript key events (they need to align with
    #'   event.code).
    #' @action A function to be run after key is pressed.
    add_control = function(key, action, input) {
      event <- paste0(key, "_action")
      js <- sprintf("addKeyControl('%s');", key)
      send_js(private, js)
      shiny::observeEvent(input[[event]], {
        action()
      })
    },

    set_velocity_x = function(x = 100) {
      js <- sprintf("setVelocityX('%s', %d);",
                    private$name, x)
      send_js(private, js)
    },

    set_velocity_y = function(x = 100) {
      js <- sprintf("setVelocityY('%s', %d);",
                    private$name, x)
      send_js(private, js)
    },

    set_gravity = function(x = 100, y = 100) {
      Sys.sleep(0.1)
      js <- sprintf("setGravity('%s', %d, %d);",
                    private$name, x, y)
      send_js(private, js)
    },

    set_bounce = function(x) {
      Sys.sleep(0.1)
      js <- sprintf("setBounce('%s', %f);",
                    private$name, x)
      send_js(private, js)
    },

    #' @param dirX Numeric. Horizontal direction (-1 = left, +1 = right, 0 = none).
    #' @param dirY Numeric. Vertical direction (-1 = up, +1 = down, 0 = none).
    #' @param speed Numeric. Speed in pixels/second.
    #' @param distance Numeric. Distance in pixels to travel before stopping.
    move = function(dirX = 0, dirY = 0, speed, distance) {
      js <- sprintf("moveSprite('%s', %d, %d, %d, %d);",
                    private$name, dirX, dirY, speed, distance)
      send_js(private, js)
    },

    #' @description Move sprite along a vector for a set distance.
    #' @param dirX Numeric. Horizontal direction (-1 = left, +1 = right, 0 = none).
    #' @param dirY Numeric. Vertical direction (-1 = up, +1 = down, 0 = none).
    #' @param speed Numeric. Speed in pixels/second.
    #' @param distance Numeric. Distance in pixels to travel before stopping.
    #' @param lag Numeric. Optional delay before sending the command (defaults to distance/speed).
    set_in_motion = function(dirX,
                             dirY,
                             speed,
                             distance,
                             lag = distance/speed) {
      Sys.sleep(lag)
      js <- sprintf(
        "setSpriteInMotion('%s', %d, %d, %d, %d);",
        private$name, dirX, dirY, speed, distance
      )
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
