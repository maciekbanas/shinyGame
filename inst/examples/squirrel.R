devtools::load_all()

# Configuration -----------------------------------------------------------

GAME_WIDTH <- 1000
GAME_HEIGHT <- 700
RUN_DURATION_SECONDS <- 10 * 60 # Use 60 while iterating on the example.

CARRYING_CAPACITY <- 5
NORMAL_SPEED <- 250
SPEED_LOSS_PER_NUT <- 9
DASH_SPEED <- 600
DASH_DURATION_MS <- 700
DASH_COOLDOWN_SECONDS <- 2.5

HOME_X <- GAME_WIDTH / 2
HOME_Y <- GAME_HEIGHT / 2
FOX_RESET_X <- 90
FOX_RESET_Y <- 90
FOX_SIGHT_RANGE <- 300
FOX_SPEED <- 185

# Placeholder graphics ----------------------------------------------------
#
# These embedded SVG data URLs keep the example asset-free. Each placeholder
# has a strong colour and a letter/label so it can be replaced with a sprite
# later by changing only this section.

placeholder_svg <- function(width, height, background, label, foreground = "white",
                            shape = "rounded") {
  shape_tag <- if (identical(shape, "circle")) {
    sprintf("<circle cx='%s' cy='%s' r='%s' fill='%s'/>",
            width / 2, height / 2, min(width, height) * 0.46, background)
  } else {
    sprintf("<rect x='2' y='2' width='%s' height='%s' rx='10' fill='%s'/>",
            width - 4, height - 4, background)
  }
  svg <- sprintf(
    paste0("<svg xmlns='http://www.w3.org/2000/svg' width='%s' height='%s'>",
           "%s<text x='50%%' y='54%%' text-anchor='middle' dominant-baseline='middle' ",
           "font-family='sans-serif' font-size='%s' font-weight='bold' fill='%s'>%s</text></svg>"),
    width, height, shape_tag, floor(min(width, height) * 0.34), foreground, label
  )
  paste0("data:image/svg+xml,", utils::URLencode(svg, reserved = TRUE))
}

graphics <- list(
  squirrel = placeholder_svg(54, 54, "#b86b2b", "S"),
  tree = placeholder_svg(132, 132, "#287a3d", "TREE"),
  nut = placeholder_svg(28, 28, "#8b5a2b", "N", shape = "circle"),
  fox = placeholder_svg(58, 58, "#d94827", "FOX")
)

nut_spawn_points <- data.frame(
  x = c(390, 610, 500, 350, 650, 230, 770, 160, 840, 120, 880, 280, 720, 500, 500),
  y = c(350, 350, 235, 250, 450, 350, 350, 150, 550, 600, 100, 610, 90, 90, 620)
)

game <- PhaserGame$new(width = GAME_WIDTH, height = GAME_HEIGHT)

ui <- shiny::tagList(game$use_phaser())

server <- function(input, output, session) {
  game$set_shiny_session()
  game$set_world_bounds(GAME_WIDTH, GAME_HEIGHT)

  state <- new.env(parent = emptyenv())
  state$carrying <- 0
  state$stash <- 0
  state$running <- TRUE
  state$finish_at <- Sys.time() + RUN_DURATION_SECONDS
  state$last_dash <- as.POSIXct("1970-01-01", tz = "UTC")
  state$control_version <- 0
  state$last_catch <- as.POSIXct("1970-01-01", tz = "UTC")
  state$nuts_collected <- 0
  state$spawn_batch <- 0
  state$message_until <- Sys.time()
  state$dash_until <- Sys.time()
  state$dash_active <- FALSE

  current_speed <- function() {
    NORMAL_SPEED - state$carrying * SPEED_LOSS_PER_NUT
  }

  # Environment and map boundary -----------------------------------------

  game$add_rectangle(
    name = "meadow", x = GAME_WIDTH / 2, y = GAME_HEIGHT / 2,
    width = GAME_WIDTH - 12, height = GAME_HEIGHT - 12,
    color = "0x9acb73"
  )$set_depth(-10)
  game$add_rectangle(
    name = "map_boundary", x = GAME_WIDTH / 2, y = GAME_HEIGHT / 2,
    width = GAME_WIDTH - 30, height = GAME_HEIGHT - 30,
    color = "0x719b52"
  )$set_depth(-9)

  # Home and player -------------------------------------------------------

  home <- game$add_static_sprite("squirrel_home", graphics$tree, HOME_X, HOME_Y)
  home$set_depth(1)
  game$add_text("TREE / HOME", "home_label", HOME_X - 62, HOME_Y - 88,
                style = list(font_size = "18px", color = "#143d20"))$set_depth(2)

  squirrel <- game$add_sprite(
    "squirrel", graphics$squirrel, HOME_X, HOME_Y + 90,
    frame_width = 54, frame_height = 54
  )
  squirrel$set_depth(5)
  squirrel$add_player_controls(c("left", "right", "up", "down"), NORMAL_SPEED)

  # Collectibles ----------------------------------------------------------

  nuts <- game$add_static_group("nuts", graphics$nut)

  spawn_nut_batch <- function() {
    state$spawn_batch <- state$spawn_batch + 1
    # Small deterministic offsets avoid recreating a disabled body at exactly
    # the same coordinate while keeping the hand-authored near/far layout.
    offset <- ((state$spawn_batch - 1) %% 5) * 3
    for (i in seq_len(nrow(nut_spawn_points))) {
      nuts$create(nut_spawn_points$x[i] + offset, nut_spawn_points$y[i] - offset)
    }
  }
  spawn_nut_batch()

  # Fox -------------------------------------------------------------------

  fox <- game$add_sprite(
    "fox", graphics$fox, FOX_RESET_X, FOX_RESET_Y,
    frame_width = 58, frame_height = 58
  )
  fox$set_depth(4)
  fox$start_approach_on_sight(
    target_name = "squirrel", sight_range = FOX_SIGHT_RANGE,
    speed = FOX_SPEED, distance = 75, check_interval = 180,
    wander_interval = 1200
  )

  # HUD -------------------------------------------------------------------

  stash_text <- game$add_text("Winter stash: 0", "stash_text", 24, 20)
  carrying_text <- game$add_text(
    paste0("Carrying: 0 / ", CARRYING_CAPACITY), "carrying_text", 24, 52
  )
  timer_text <- game$add_text("Time: 10:00", "timer_text", 790, 20)
  message_text <- game$add_text(
    "Arrow keys move | Space dashes", "message_text", 24, 660,
    style = list(font_size = "18px", color = "#17320f")
  )
  result_text <- game$add_text(
    "", "result_text", 250, 285,
    style = list(font_size = "34px", color = "#ffffff"), visible = FALSE
  )
  for (hud in list(stash_text, carrying_text, timer_text, message_text, result_text)) {
    hud$set_depth(20)
  }

  update_movement_speed <- function() {
    squirrel$add_player_controls(
      c("left", "right", "up", "down"), current_speed()
    )
  }

  show_temporary_message <- function(text, duration_ms = 1400) {
    message_text$set(text)
    state$message_until <- Sys.time() + duration_ms / 1000
  }

  # Collision and overlap handling ---------------------------------------

  game$add_overlap(
    object_one = "squirrel", group = "nuts", input = input,
    server_action = function(event) {
      if (!state$running) return(invisible(NULL))
      if (state$carrying >= CARRYING_CAPACITY) {
        show_temporary_message("Pockets full! Return home.")
        return(invisible(NULL))
      }

      nuts$disable(event)
      state$carrying <- state$carrying + 1
      state$nuts_collected <- state$nuts_collected + 1
      carrying_text$set(paste0("Carrying: ", state$carrying, " / ", CARRYING_CAPACITY))
      update_movement_speed()
      if (state$carrying == CARRYING_CAPACITY) {
        show_temporary_message("Pockets full! Return home.")
      }

      # Add another hand-authored batch before resources can run out.
      if (state$nuts_collected %% 10 == 0) spawn_nut_batch()
    }
  )

  game$add_overlap(
    object_one = "squirrel", object_two = "squirrel_home", input = input,
    server_action = function(event) {
      if (!state$running || state$carrying == 0) return(invisible(NULL))
      banked <- state$carrying
      state$stash <- state$stash + banked
      state$carrying <- 0
      stash_text$set(paste0("Winter stash: ", state$stash))
      carrying_text$set(paste0("Carrying: 0 / ", CARRYING_CAPACITY))
      update_movement_speed()
      show_temporary_message(paste("Banked", banked, "nuts safely!"))
    }
  )

  game$add_overlap(
    object_one = "squirrel", object_two = "fox", input = input,
    server_action = function(event) {
      now <- Sys.time()
      if (!state$running || as.numeric(difftime(now, state$last_catch, units = "secs")) < 1) {
        return(invisible(NULL))
      }
      state$last_catch <- now
      state$control_version <- state$control_version + 1
      state$carrying <- 0
      carrying_text$set(paste0("Carrying: 0 / ", CARRYING_CAPACITY))
      squirrel$set_position(HOME_X, HOME_Y + 90)
      fox$set_position(FOX_RESET_X, FOX_RESET_Y)
      update_movement_speed()
      show_temporary_message("The fox caught you: carried food lost!", 2200)
    }
  )

  # Dash and game timer ---------------------------------------------------

  game$add_control(
    "Space", input = input,
    server_action = function(event) {
      now <- Sys.time()
      cooldown_elapsed <- as.numeric(difftime(now, state$last_dash, units = "secs"))
      if (!state$running || cooldown_elapsed < DASH_COOLDOWN_SECONDS) return(invisible(NULL))

      state$last_dash <- now
      state$control_version <- state$control_version + 1
      state$dash_active <- TRUE
      state$dash_until <- now + DASH_DURATION_MS / 1000
      squirrel$add_player_controls(c("left", "right", "up", "down"), DASH_SPEED)
      show_temporary_message("DASH!", DASH_DURATION_MS)
    }
  )

  shiny::observe({
    shiny::invalidateLater(250, session)
    if (!state$running) return(invisible(NULL))

    now <- Sys.time()
    if (state$dash_active && now >= state$dash_until) {
      state$dash_active <- FALSE
      update_movement_speed()
    }
    if (now >= state$message_until) {
      message_text$set("Arrow keys move | Space dashes")
      state$message_until <- now + RUN_DURATION_SECONDS
    }

    seconds_left <- max(0, ceiling(as.numeric(difftime(
      state$finish_at, now, units = "secs"
    ))))
    timer_text$set(sprintf("Time: %02d:%02d", seconds_left %/% 60, seconds_left %% 60))

    if (seconds_left == 0) {
      state$running <- FALSE
      state$control_version <- state$control_version + 1
      squirrel$set_velocity_x(0)
      squirrel$set_velocity_y(0)
      squirrel$add_player_controls(character(), 0)
      fox$destroy()
      result_text$set(paste0(
        "Time! Winter stash: ", state$stash,
        "\nPress Enter to play again"
      ))
      result_text$show()
      message_text$set("Run complete")
    }
  })

  game$add_control(
    "Enter", input = input,
    server_action = function(event) {
      if (!state$running) session$reload()
    }
  )
}

shiny::shinyApp(ui, server)
