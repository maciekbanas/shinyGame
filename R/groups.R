Group <- R6::R6Class(
  classname = "Group",
  public = list(
    initialize = function(name,
                          session = shiny::getDefaultReactiveDomain()) {
      private$name <- name
      private$session <- session

      js <- sprintf("addGroup('%s');",name)
      send_js(private, js)

      Sys.sleep(0.1)
    },
    add_animation = function(suffix, url,
                             frameWidth, frameHeight,
                             frameCount, frameRate) {
      js <- sprintf(
        "addGroupAnimation('%s','%s','%s',%d,%d,%d,%d);",
        private$name, suffix, url,
        frameWidth, frameHeight, frameCount, frameRate
      )
      send_js(private, js)
      Sys.sleep(0.1)
    },
    create = function(x, y) {
      js <- sprintf(
        "addToGroup('%s', %d, %d);",
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

StaticGroup <- R6::R6Class(
  classname = "StaticGroup",
  public = list(
    initialize = function(name, url, session = shiny::getDefaultReactiveDomain()) {
      private$name <- name
      private$session <- session

      js <- sprintf("addStaticGroup('%s','%s');", name, url)
      send_js(private, js)

      Sys.sleep(0.1)
    },
    create = function(x, y) {
      js <- sprintf(
        "addToGroup('%s', %d, %d);",
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
