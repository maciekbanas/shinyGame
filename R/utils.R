send_js <- function(private, js) {
  recorder <- getOption("shinyphaser.client_action_recorder", NULL)
  if (is.function(recorder)) {
    recorder(js)
    return(invisible(NULL))
  }

  private$session$sendCustomMessage("phaser", list(js = js))
}

record_client_callback <- function(callback_fun) {
  if (is.null(callback_fun)) {
    return(NULL)
  }

  body_text <- paste(deparse(body(callback_fun)), collapse = "\n")
  if (grepl("<<-|\\bif\\b|\\breturn\\b", body_text)) {
    return(NULL)
  }

  js_calls <- character()
  recorder <- function(js) {
    js_calls <<- c(js_calls, js)
  }

  old_recorder <- getOption("shinyphaser.client_action_recorder", NULL)
  options(shinyphaser.client_action_recorder = recorder)
  on.exit(options(shinyphaser.client_action_recorder = old_recorder), add = TRUE)

  ok <- tryCatch({
    callback_fun(NULL)
    TRUE
  }, error = function(e) {
    FALSE
  })

  if (!ok || length(js_calls) == 0) {
    return(NULL)
  }

  list(raw_js = js_calls)
}


resolve_client_action <- function(client_action = NULL) {
  if (is.null(client_action) || !is.function(client_action)) {
    return(client_action)
  }

  recorded_client_action <- record_client_callback(client_action)
  if (is.null(recorded_client_action)) {
    stop(
      "client_action functions must contain recordable browser-side shinyphaser calls.",
      call. = FALSE
    )
  }

  recorded_client_action
}
