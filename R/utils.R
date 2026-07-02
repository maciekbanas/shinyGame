send_js <- function(private, js) {
  private$session$sendCustomMessage("phaser", list(js = js))
}


validate_client_action <- function(client_action = NULL) {
  if (!is.null(client_action) && !is.list(client_action)) {
    stop("client_action must be a list or list of lists.", call. = FALSE)
  }

  client_action
}
