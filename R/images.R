Image <- R6::R6Class(
  classname = "Image",
  public = list(
    initialize = function(name, url, x, y, visible, clickable,
                          session = getDefaultReactiveDomain()) {
      private$session <- session
      private$name <- name
      js <- sprintf("addImage('%s', '%s', %d, %d, %s, %s);",
                    name, url, x, y, tolower(visible), tolower(clickable))
      send_js(private, js)
    },
    show = function() {
      js <- sprintf("showImage('%s');", private$name)
      send_js(private, js)
    },
    hide = function() {
      js <- sprintf("hideImage('%s');", private$name)
      send_js(private, js)
    },
    #' @param event_fun A function.
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
