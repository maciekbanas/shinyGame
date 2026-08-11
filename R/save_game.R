read_phaser_saves <- function(path) {
  if (!file.exists(path)) return(list())
  result <- tryCatch(
    jsonlite::fromJSON(path, simplifyVector = FALSE),
    error = function(e) list()
  )
  if (is.list(result)) result else list()
}

write_phaser_saves <- function(saves, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  temporary <- tempfile("save-games-", tmpdir = dirname(path), fileext = ".json")
  jsonlite::write_json(saves, temporary, auto_unbox = TRUE, null = "null", pretty = TRUE)
  if (!file.rename(temporary, path)) {
    unlink(temporary)
    stop("Could not replace the saved-game file.", call. = FALSE)
  }
  invisible(path)
}
