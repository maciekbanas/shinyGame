Image <- R6::R6Class(
  classname = "Image",
  public = list(
    initialize = function(name, url, x, y, visible,
                          session = getDefaultReactiveDomain()) {
      private$session <- session
      private$name <- name
      js <- sprintf("addImage('%s', '%s', %d, %d, %s);", name, url, x, y, tolower(visible))
      send_js(private, js)
    },
    show = function() {
      js <- sprintf("showImage('%s');", private$name)
      send_js(private, js)
    },
    hide = function() {
      js <- sprintf("hideImage('%s');", private$name)
      send_js(private, js)
    }
  ),
  private = list(
    name = NULL,
    session = NULL
  )
)
