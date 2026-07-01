send_js <- function(private, js) {
  recorder <- getOption("shinyphaser.control_recorder")
  if (is.function(recorder)) {
    recorder(js)
  }
  private$session$sendCustomMessage("phaser", list(js = js))
}
