BrowserState <- R6::R6Class(
  "BrowserState",
  public = list(
    initialize = function(key) private$key <- key
  ),
  private = list(key = NULL)
)

BrowserCooldown <- R6::R6Class(
  "BrowserCooldown",
  public = list(
    initialize = function(key, duration) {
      private$key <- key
      private$duration <- duration
    }
  ),
  private = list(key = NULL, duration = NULL)
)
