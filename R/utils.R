send_js <- function(private, js) {
  private$session$sendCustomMessage("phaser", list(js = js))
}

phaser_event_target_json <- function(target) {
  if (is.null(target)) return("null")
  jsonlite::toJSON(target, auto_unbox = TRUE)
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

#' Define actions that run immediately in the browser
#'
#' Captures supported shinyphaser method calls without evaluating them in R.
#' Browser actions are compiled when passed to an event registration method.
#' Arbitrary R code belongs in the corresponding `server_action` function.
#'
#' @param ... Supported shinyphaser browser action calls.
#' @return A browser action specification.
#' @export
browser_actions <- function(...) {
  structure(
    list(
      expressions = as.list(substitute(list(...)))[-1],
      env = parent.frame()
    ),
    class = "shinyphaser_browser_actions"
  )
}

compile_browser_actions <- function(expr, env) {
  specification <- eval(expr, envir = env)
  if (!inherits(specification, "shinyphaser_browser_actions")) {
    stop(
      "browser_action must be created with browser_actions().",
      call. = FALSE
    )
  }

  unlist(lapply(
    specification$expressions,
    compile_phaser_action,
    env = specification$env
  ), recursive = FALSE)
}

register_server_action <- function(input, event, server_action) {
  if (is.null(server_action)) return(NULL)
  if (!is.function(server_action)) {
    stop("server_action must be a function.", call. = FALSE)
  }
  if (is.null(input)) {
    stop("input is required when server_action is supplied.", call. = FALSE)
  }

  shiny::observeEvent(input[[event]], {
    server_action(input[[event]])
  }, ignoreInit = TRUE)
}

compile_phaser_value <- function(expr, env) {
  if (is.call(expr) && is.call(expr[[1]]) && identical(expr[[1]][[1]], as.name("$"))) {
    target <- eval(expr[[1]][[2]], env)
    method <- as.character(expr[[1]][[3]])
    if (inherits(target, "BrowserState") && method == "value") {
      return(list(state = target$.__enclos_env__$private$key))
    }
  }
  eval(expr, env)
}

compile_phaser_condition <- function(expr, env) {
  operator <- if (is.call(expr) && is.symbol(expr[[1]])) {
    as.character(expr[[1]])
  } else {
    NULL
  }
  if (!is.null(operator) && operator %in% c("&&", "||")) {
    return(list(op = operator,
                left = compile_phaser_condition(expr[[2]], env),
                right = compile_phaser_condition(expr[[3]], env)))
  }
  if (is.call(expr) && identical(expr[[1]], as.name("!"))) {
    return(list(op = "!", value = compile_phaser_condition(expr[[2]], env)))
  }
  if (!is.null(operator) && operator %in% c("==", "!=", "<", "<=", ">", ">=")) {
    return(list(op = operator,
                left = compile_phaser_value(expr[[2]], env),
                right = compile_phaser_value(expr[[3]], env)))
  }
  if (is.call(expr) && is.call(expr[[1]]) && identical(expr[[1]][[1]], as.name("$"))) {
    target <- eval(expr[[1]][[2]], env)
    method <- as.character(expr[[1]][[3]])
    args <- as.list(expr)[-1]
    private <- target$.__enclos_env__$private
    name <- private$id %||% private$name
    if (method == "overlaps") {
      other <- eval(args[[1]], env)
      other_name <- other$.__enclos_env__$private$id %||% other$.__enclos_env__$private$name
      return(list(op = "overlaps", objects = c(name, other_name)))
    }
    if (method == "exists") return(list(op = "exists", object = name))
    if (inherits(target, "BrowserState") && method %in% c("is_true", "is_false")) {
      return(list(op = method, state = private$key))
    }
    if (inherits(target, "BrowserCooldown") && method == "ready") {
      return(list(op = "cooldown_ready", key = private$key, duration = private$duration))
    }
  }
  stop("Unsupported condition in action block.", call. = FALSE)
}

compile_phaser_action_call <- function(expr, env) {
  if (is.call(expr) && identical(expr[[1]], as.name("if"))) {
    return(list(`if` = list(
      condition = compile_phaser_condition(expr[[2]], env),
      then = compile_phaser_action(expr[[3]], env),
      `else` = if (length(expr) >= 4) compile_phaser_action(expr[[4]], env) else list()
    )))
  }
  if (!is.call(expr) || !is.call(expr[[1]]) ||
      !identical(expr[[1]][[1]], as.name("$"))) {
    stop(
      "browser_action must contain calls to supported shinyphaser R6 object methods.",
      call. = FALSE
    )
  }

  target_expr <- expr[[1]][[2]]
  method <- as.character(expr[[1]][[3]])
  target <- eval(target_expr, envir = env)
  arg_exprs <- as.list(expr)[-1]
  if (inherits(target, "PhaserGame") && method == "after") {
    return(list(after = list(
      delay = compile_phaser_value(arg_exprs[[1]], env),
      actions = compile_phaser_action(arg_exprs[[2]], env)
    )))
  }
  args <- lapply(arg_exprs, compile_phaser_value, env = env)
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
  if (inherits(target, c("Sprite", "StaticSprite", "Group", "StaticGroup")) &&
      method == "show") {
    return(list(show_object = object_name))
  }
  if (inherits(target, c("Sprite", "StaticSprite", "Group", "StaticGroup")) &&
      method == "hide") {
    return(list(hide_object = object_name))
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
  if (inherits(target, "Sprite") && method == "set_in_motion") {
    return(list(set_in_motion = list(
      name = object_name,
      dir_x = value("dir_x", 1),
      dir_y = value("dir_y", 2),
      speed = value("speed", 3),
      distance = value("distance", 4)
    )))
  }
  if (inherits(target, "Sprite") && method %in% c("set_velocity_x", "set_velocity_y")) {
    return(setNames(list(list(name = object_name, value = value("x", 1, 100))), method))
  }
  if (inherits(target, "Sprite") && method == "stop_motion") {
    return(list(stop_motion = object_name))
  }
  if (inherits(target, "Sprite") && method == "add_player_controls") {
    return(list(player_controls = list(
      name = object_name,
      directions = value("directions", 1, c("left", "right", "down", "up")),
      speed = value("speed", 2, 200)
    )))
  }
  if (inherits(target, "StaticGroup") && method == "disable") {
    return(list(disable_overlap_member = object_name))
  }
  if (inherits(target, "BrowserState") && method %in% c("set", "increment", "decrement", "add", "subtract")) {
    return(list(state_action = list(key = private$key, op = method,
                                    value = value("value", 1, 1))))
  }
  if (inherits(target, "BrowserCooldown") && method == "trigger") {
    return(list(cooldown_trigger = private$key))
  }
  if (inherits(target, "PhaserGame") && method == "alert") {
    return(list(show_alert = args))
  }
  if (inherits(target, "PhaserGame") && method == "emit") {
    return(list(emit = list(name = value("name", 1), data = value("data", 2, list()))))
  }
  if (inherits(target, c("Sprite", "StaticSprite")) && method == "destroy") {
    return(list(destroy_sprite = object_name))
  }

  stop(
    sprintf("%s$%s() is not supported in a browser action.",
            class(target)[[1]], method),
    call. = FALSE
  )
}
