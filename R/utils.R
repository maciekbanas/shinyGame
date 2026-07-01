send_js <- function(private, js) {
  private$session$sendCustomMessage("phaser", list(js = js))
}

register_phaser_event_endpoint <- function(session, event_id, callback_fun) {
  if (is.null(session)) {
    session <- shiny::getDefaultReactiveDomain()
  }
  if (is.null(session)) {
    stop("A Shiny session is required to register Phaser event endpoints.", call. = FALSE)
  }

  session$registerDataObj(
    name = event_id,
    data = callback_fun,
    filterFunc = function(callback, req) {
      body <- rawToChar(req$rook.input$read())
      evt <- if (nzchar(body)) {
        jsonlite::fromJSON(body, simplifyVector = FALSE)
      } else {
        list()
      }

      promise <- promises::then(promises::promise_resolve(evt), callback)
      promises::catch(promise, function(error) {
        warning(
          sprintf("Phaser event callback '%s' failed: %s", event_id, error$message),
          call. = FALSE
        )
      })

      shiny::httpResponse(
        status = 202,
        content_type = "application/json",
        content = '{"status":"accepted"}'
      )
    }
  )
}
