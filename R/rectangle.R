#' @title Rectangle
#' @description Create and manage rectangles in the Phaser scene. Created with
#'   PhaserGame$add_rectangle() method.
#' @export
Rectangle <- R6::R6Class(
  classname = "Rectangle",
  public = list(
    #' @description Add a rectangle object to the Phaser scene.
    #' @param name Character. Unique name of the rectangle.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param width Numeric. Rectangle width in pixels.
    #' @param height Numeric. Rectangle height in pixels.
    #' @param color Character. Fill color in Phaser-compatible format.
    #' @param visible Logical. Whether rectangle is initially visible.
    #' @param clickable Logical. Whether rectangle emits click events.
    #' @param session Shiny session object.
    initialize = function(name, x, y, width, height, color, visible, clickable,
                          session = getDefaultReactiveDomain()) {
      private$session <- session
      private$name <- name
      js <- sprintf("addRectangle('%s', %d, %d, %d, %d, %s, %s, %s);",
                    name, x, y, width, height, color, tolower(visible), tolower(clickable))
      send_js(private, js)
    },
    #' @description Show a previously added rectangle.
    show = function() {
      js <- sprintf("showImage('%s');", private$name)
      send_js(private, js)
    },
    #' @description Hide a previously added rectangle.
    hide = function() {
      js <- sprintf("hideImage('%s');", private$name)
      send_js(private, js)
    },
    #' @description Make the camera follow this rectangle as it moves through the world.
    #' @param lerp_x Numeric. Horizontal interpolation factor from 0 to 1 (default: 1).
    #' @param lerp_y Numeric. Vertical interpolation factor from 0 to 1 (default: 1).
    #' @param round_pixels Logical. Whether to round camera pixels to avoid sub-pixel rendering (default: TRUE).
    follow_camera = function(lerp_x = 1,
                             lerp_y = 1,
                             round_pixels = TRUE) {
      js <- sprintf(
        "followSpriteWithCamera('%s', %f, %f, %s);",
        private$name, lerp_x, lerp_y, tolower(round_pixels)
      )
      send_js(private, js)
    },
    #' @description Stop the camera from following this rectangle.
    stop_camera_follow = function() {
      js <- sprintf("stopCameraFollow('%s');", private$name)
      send_js(private, js)
    },
    #' @description Add a click event listener to the rectangle that triggers an R
    #'  function when clicked.
    #' @param event_fun A function.
    #' @param input Shiny input object.
    click = function(event_fun, input) {
      js <- sprintf("clickImage('%s');", private$name)
      send_js(private, js)
      observe_id <- paste0(private$name, "_click")
      shiny::observeEvent(input[[observe_id]], {
        evt <- input[[observe_id]]
        event_fun(evt)
      }, ignoreNULL = TRUE)
    }
  ),
  private = list(
    name = NULL,
    session = NULL
  )
)
