#' @title Sound
#' @description Create and manage audio in the Phaser scene. Created with
#'   PhaserGame$add_sound() method.
#' @export
Sound <- R6::R6Class(
  classname = "Sound",
  public = list(
    #' @description Load a sound file and register it with the Phaser scene.
    #' @param name Character. Unique key for the sound.
    #' @param url Character. URL or path to the audio file.
    #' @param volume Numeric. Initial playback volume from 0 to 1 (default: 1).
    #' @param loop Logical. Whether the sound should loop by default (default: FALSE).
    #' @param session Shiny session object.
    initialize = function(name, url, volume = 1, loop = FALSE,
                          session = shiny::getDefaultReactiveDomain()) {
      private$session <- session
      private$name <- name
      js <- sprintf(
        "addSound(%s, %s, %f, %s);",
        jsonlite::toJSON(name, auto_unbox = TRUE),
        jsonlite::toJSON(url, auto_unbox = TRUE),
        volume,
        tolower(loop)
      )
      send_js(private, js)
    },

    #' @description Play the sound.
    #' @param volume Numeric. Optional playback volume from 0 to 1. Defaults to
    #'   the sound's current/default volume.
    #' @param loop Logical. Optional loop setting for this playback. Defaults to
    #'   the sound's current/default loop setting.
    play = function(volume = NULL, loop = NULL) {
      js <- sprintf(
        "playSound(%s, %s, %s);",
        jsonlite::toJSON(private$name, auto_unbox = TRUE),
        if (is.null(volume)) "null" else sprintf("%f", volume),
        if (is.null(loop)) "null" else tolower(loop)
      )
      send_js(private, js)
    },

    #' @description Pause the sound.
    pause = function() {
      js <- sprintf("pauseSound(%s);", jsonlite::toJSON(private$name, auto_unbox = TRUE))
      send_js(private, js)
    },

    #' @description Resume a paused sound.
    resume = function() {
      js <- sprintf("resumeSound(%s);", jsonlite::toJSON(private$name, auto_unbox = TRUE))
      send_js(private, js)
    },

    #' @description Stop the sound.
    stop = function() {
      js <- sprintf("stopSound(%s);", jsonlite::toJSON(private$name, auto_unbox = TRUE))
      send_js(private, js)
    },

    #' @description Set the sound's volume.
    #' @param volume Numeric. Volume from 0 to 1.
    set_volume = function(volume) {
      js <- sprintf(
        "setSoundVolume(%s, %f);",
        jsonlite::toJSON(private$name, auto_unbox = TRUE),
        volume
      )
      send_js(private, js)
    },

    #' @description Set whether the sound loops by default.
    #' @param loop Logical. Whether playback should loop.
    set_loop = function(loop) {
      js <- sprintf(
        "setSoundLoop(%s, %s);",
        jsonlite::toJSON(private$name, auto_unbox = TRUE),
        tolower(loop)
      )
      send_js(private, js)
    }
  ),
  private = list(
    name = NULL,
    session = NULL
  )
)
