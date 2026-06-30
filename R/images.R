#' @title Image
#' @description Create and manage images in the Phaser scene. Created with
#'   PhaserGame$add_image() method.
#' @export
Image <- R6::R6Class(
  classname = "Image",
  public = list(
    #' @description Add an image object to the Phaser scene.
    #' @param name Character. Unique name of the image.
    #' @param url Character. URL or path to image file.
    #' @param x Numeric. X-coordinate in pixels.
    #' @param y Numeric. Y-coordinate in pixels.
    #' @param visible Logical. Whether image is initially visible.
    #' @param clickable Logical. Whether image emits click events.
    #' @param session Shiny session object.
    initialize = function(name, url, x, y, visible, clickable,
                          session = getDefaultReactiveDomain()) {
      private$session <- session
      private$name <- name
      js <- sprintf("addImage('%s', '%s', %d, %d, %s, %s);",
                    name, url, x, y, tolower(visible), tolower(clickable))
      send_js(private, js)
    },
    #' @description Show a previously added image.
    show = function() {
      js <- sprintf("showImage('%s');", private$name)
      send_js(private, js)
    },
    #' @description Hide a previously added image.
    hide = function() {
      js <- sprintf("hideImage('%s');", private$name)
      send_js(private, js)
    },
    #' @description Make the camera follow this image as it moves through the world.
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
    #' @description Stop the camera from following this image.
    stop_camera_follow = function() {
      js <- sprintf("stopCameraFollow('%s');", private$name)
      send_js(private, js)
    },
    #' @description Set how much this image scrolls with the camera.
    #' @param x Numeric. Horizontal scroll factor (0 = fixed to viewport, 1 = scrolls with world).
    #' @param y Numeric. Vertical scroll factor. Defaults to `x`.
    set_scroll_factor = function(x, y = x) {
      js <- sprintf("setScrollFactor('%s', %f, %f);", private$name, x, y)
      send_js(private, js)
    },
    #' @description Add a click event listener to the image that triggers an R
    #'   function when clicked.
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
