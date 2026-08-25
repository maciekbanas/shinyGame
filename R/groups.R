#' @title Group
#' @description Create and manage groups of sprites in the Phaser scene. Created
#'  with PhaserGame$add_group() method.
#' @export
Group <- R6::R6Class(
  classname = "Group",
  public = list(
    #' @description Create a dynamic group in the Phaser scene.
    #' @param name Character. Unique name of the group.
    #' @param session Shiny session object.
    initialize = function(name,
                          session = shiny::getDefaultReactiveDomain()) {
      private$name <- name
      private$session <- session

      js <- sprintf("addGroup('%s');",name)
      send_js(private, js)

      Sys.sleep(0.1)
    },
    #' @description Add an animation that can be used by members of this group.
    #' @param suffix Character. Animation suffix/key.
    #' @param url Character. URL or path to spritesheet.
    #' @param frame_width Numeric. Width of each frame.
    #' @param frame_height Numeric. Height of each frame.
    #' @param frame_count Numeric. Number of frames.
    #' @param frame_rate Numeric. Frames per second.
    add_animation = function(suffix, url,
                             frame_width, frame_height,
                             frame_count, frame_rate) {
      js <- sprintf(
        "addGroupAnimation('%s','%s','%s',%d,%d,%d,%d);",
        private$name, suffix, url,
        frame_width, frame_height, frame_count, frame_rate
      )
      send_js(private, js)
      Sys.sleep(0.1)
    },
    #' @description Create one group member at a coordinate.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    create = function(x, y) {
      js <- sprintf(
        "addToGroup('%s', %d, %d);",
        private$name, x, y
      )
      send_js(private, js)
    },
    #' @description Show all current members of this group.
    #' @return Invisible; sends a custom message to the client.
    show = function() {
      send_js(private, sprintf("showObject('%s');", private$name))
    },
    #' @description Hide all current members of this group.
    #' @return Invisible; sends a custom message to the client.
    hide = function() {
      send_js(private, sprintf("hideObject('%s');", private$name))
    }
  ),
  private = list(
    name = NULL,
    session = NULL
  )
)

#' @title Static Group
#' @description Create and manage groups of static sprites in the Phaser scene.
#'   Created with PhaserGame$add_static_group() method.
#' @export
StaticGroup <- R6::R6Class(
  classname = "StaticGroup",
  public = list(
    #' @description Create a static group from a base image.
    #' @param name Character. Unique name of the group.
    #' @param url Character. URL or path to image file.
    #' @param session Shiny session object.
    initialize = function(name, url, session = shiny::getDefaultReactiveDomain()) {
      private$name <- name
      private$session <- session

      js <- sprintf("addStaticGroup('%s','%s');", name, url)
      send_js(private, js)

      Sys.sleep(0.1)
    },
    #' @description Create one static group member at a coordinate.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    create = function(x, y) {
      js <- sprintf(
        "addToGroup('%s', %d, %d);",
        private$name, x, y
      )
      send_js(private, js)
    },
    #' @description Show all current members of this static group.
    #' @return Invisible; sends a custom message to the client.
    show = function() {
      send_js(private, sprintf("showObject('%s');", private$name))
    },
    #' @description Hide all current members of this static group.
    #' @return Invisible; sends a custom message to the client.
    hide = function() {
      send_js(private, sprintf("hideObject('%s');", private$name))
    },
    #' @description Disable a static group member body based on overlap event payload.
    #' @param evt List-like event payload containing x2 and y2 values.
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
