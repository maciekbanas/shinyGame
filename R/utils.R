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

  if (!is.function(session$registerDataObj)) {
    return(event_id)
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


# Translate a deliberately small, R-looking action block into the declarative
# commands understood by the browser.  The expression is never evaluated: doing
# so would send the R6 commands to Shiny, which is precisely the round trip this
# interface avoids.
compile_phaser_action <- function(expr, env) {
  if (identical(expr, quote(NULL))) return(list())

  expressions <- if (is.call(expr) && identical(expr[[1]], as.name("{"))) {
    as.list(expr)[-1]
  } else {
    list(expr)
  }

  lapply(expressions, compile_phaser_action_call, env = env)
}

compile_phaser_action_call <- function(expr, env) {
  if (!is.call(expr) || !is.call(expr[[1]]) ||
      !identical(expr[[1]][[1]], as.name("$"))) {
    stop(
      "action must contain calls to supported shinyphaser R6 object methods.",
      call. = FALSE
    )
  }

  target_expr <- expr[[1]][[2]]
  method <- as.character(expr[[1]][[3]])
  target <- eval(target_expr, envir = env)
  args <- lapply(as.list(expr)[-1], eval, envir = env)
  arg_names <- names(as.list(expr)[-1])
  if (is.null(arg_names)) arg_names <- rep("", length(args))
  names(args) <- arg_names

  private <- target$.__enclos_env__$private
  object_name <- private$id %||% private$name
  value <- function(name, position, default = NULL) {
    if (name %in% names(args)) return(args[[name]])
    if (length(args) >= position) return(args[[position]])
    default
  }

  if (inherits(target, "Text") && method == "show") return(list(show_text = object_name))
  if (inherits(target, "Text") && method == "hide") return(list(hide_text = object_name))
  if (inherits(target, "Text") && method == "set") {
    return(list(set_text = list(id = object_name, text = value("text", 1))))
  }
  if (inherits(target, c("Image", "Rectangle")) && method == "show") {
    return(list(show_text = object_name))
  }
  if (inherits(target, c("Image", "Rectangle")) && method == "hide") {
    return(list(hide_text = object_name))
  }
  if (inherits(target, "Sound") && method == "play") {
    action <- list(play_sound = object_name)
    volume <- value("volume", 1)
    loop <- value("loop", 2)
    if (!is.null(volume)) action$volume <- volume
    if (!is.null(loop)) action$loop <- loop
    return(action)
  }
  if (inherits(target, "Sound") && method %in% c("pause", "resume", "stop")) {
    action <- list(object_name)
    names(action) <- paste0(method, "_sound")
    return(action)
  }
  if (inherits(target, "Sprite") && method == "play_animation") {
    action <- list(
      play_animation = value("anim_name", 1),
      sprite = object_name
    )
    duration <- value("duration", 2, Inf)
    if (!is.infinite(duration)) action$duration <- duration
    return(action)
  }
  if (inherits(target, c("Sprite", "StaticSprite")) && method == "destroy") {
    return(list(destroy_sprite = object_name))
  }

  stop(
    sprintf("%s$%s() is not supported in an immediate action.",
            class(target)[[1]], method),
    call. = FALSE
  )
}
