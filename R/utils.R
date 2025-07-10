send_js <- function(private, js) {
  private$session$sendCustomMessage("phaser", list(js = js))
}
