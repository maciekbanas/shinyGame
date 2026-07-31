make_mock_session <- function() {
  msgs <- list()
  env <- new.env(parent = emptyenv())
  env$sendCustomMessage <- function(type, message) {
    msgs[[length(msgs) + 1]] <<- list(type = type, message = message)
  }
  env$get_messages <- function() msgs
  env
}

test_that("Image and Rectangle methods send expected JS", {
  session <- make_mock_session()
  img <- Image$new("ground", "ground.png", 10, 20, TRUE, FALSE, session = session)
  img$show()
  img$hide()
  img$follow_camera(lerp_x = 0.2, lerp_y = 0.3, round_pixels = FALSE)
  img$stop_camera_follow()
  img$set_scroll_factor(0)

  rect <- Rectangle$new("hitbox", 1, 2, 3, 4, "0xff00ff", TRUE, TRUE, session = session)
  rect$show()
  rect$hide()
  rect$follow_camera(lerp_x = 0.4, lerp_y = 0.5, round_pixels = TRUE)
  rect$stop_camera_follow()
  rect$set_scroll_factor(0.25, 0.75)

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("addImage\\('ground', 'ground.png', 10, 20, true, false\\);", msgs)))
  expect_true(any(grepl("showImage\\('ground'\\);", msgs)))
  expect_true(any(grepl("hideImage\\('ground'\\);", msgs)))
  expect_true(any(grepl("followSpriteWithCamera\\('ground', 0.200000, 0.300000, false\\);", msgs)))
  expect_true(any(grepl("stopCameraFollow\\('ground'\\);", msgs)))
  expect_true(any(grepl("setScrollFactor\\('ground', 0.000000, 0.000000\\);", msgs)))
  expect_true(any(grepl("addRectangle\\('hitbox', 1, 2, 3, 4, 0xff00ff, true, true\\);", msgs)))
  expect_true(any(grepl("showImage\\('hitbox'\\);", msgs)))
  expect_true(any(grepl("hideImage\\('hitbox'\\);", msgs)))
  expect_true(any(grepl("followSpriteWithCamera\\('hitbox', 0.400000, 0.500000, true\\);", msgs)))
  expect_true(any(grepl("stopCameraFollow\\('hitbox'\\);", msgs)))
  expect_true(any(grepl("setScrollFactor\\('hitbox', 0.250000, 0.750000\\);", msgs)))
})

test_that("Group and StaticGroup methods send expected JS", {
  session <- make_mock_session()
  g <- Group$new("enemies", session = session)
  g$add_animation("walk", "enemy.png", 16, 16, 4, 10)
  g$create(50, 60)

  sg <- StaticGroup$new("obstacles", "box.png", session = session)
  sg$create(5, 6)
  sg$disable(list(x2 = 5, y2 = 6))

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("addGroup\\('enemies'\\);", msgs)))
  expect_true(any(grepl("addGroupAnimation\\('enemies','walk','enemy.png',16,16,4,10\\);", msgs)))
  expect_true(any(grepl("addToGroup\\('enemies', 50, 60\\);", msgs)))
  expect_true(any(grepl("addStaticGroup\\('obstacles','box.png'\\);", msgs)))
  expect_true(any(grepl("disableBody\\('obstacles', 5, 6\\);", msgs)))
})

test_that("StaticSprite destroy sends expected JS", {
  session <- make_mock_session()
  static_sprite <- StaticSprite$new("rock", "rock.png", 10, 20, session = session)
  static_sprite$follow_camera(lerp_x = 0.6, lerp_y = 0.7, round_pixels = FALSE)
  static_sprite$stop_camera_follow()
  static_sprite$set_scroll_factor(0)
  static_sprite$destroy()

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("addStaticSprite\\('rock','rock.png', 10, 20\\);", msgs)))
  expect_true(any(grepl("followSpriteWithCamera\\('rock', 0.600000, 0.700000, false\\);", msgs)))
  expect_true(any(grepl("stopCameraFollow\\('rock'\\);", msgs)))
  expect_true(any(grepl("setScrollFactor\\('rock', 0.000000, 0.000000\\);", msgs)))
  expect_true(any(grepl("destroySprite\\('rock'\\);", msgs)))
})

test_that("Sprite utility methods send expected JS", {
  session <- make_mock_session()
  s <- Sprite$new("hero", "hero.png", 0, 0, 32, 32, frame_count = 4, frame_rate = 12, session = session)
  s$play_animation("idle")
  s$play_animation("run", duration = 300)
  s$add_player_controls(c("left", "right"), speed = 180)
  s$follow_camera(lerp_x = 0.5, lerp_y = 0.75, round_pixels = FALSE)
  s$stop_camera_follow()
  s$set_scroll_factor(1, 0.5)
  s$set_velocity_x(120)
  s$set_velocity_y(140)
  s$set_gravity(1, 2)
  s$set_bounce(0.5)
  s$set_in_motion(1, 0, 90, 45, lag = 0)
  s$set_in_motion_random_or_toward("mushroom_man", 300, 0, 1, 90, 45, 1.35, 2, lag = 0)
  s$start_approach_on_sight("mushroom_man", 500, 120, 80, 250, 1200)
  s$destroy()

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("playAnimation\\('hero','idle'\\);", msgs)))
  expect_true(any(grepl("playAnimationForDuration\\('hero','run', 300\\);", msgs)))
  expect_true(any(grepl("addPlayerControls\\('hero',", msgs)))
  expect_true(any(grepl("followSpriteWithCamera\\('hero', 0.500000, 0.750000, false\\);", msgs)))
  expect_true(any(grepl("stopCameraFollow\\('hero'\\);", msgs)))
  expect_true(any(grepl("setScrollFactor\\('hero', 1.000000, 0.500000\\);", msgs)))
  expect_true(any(grepl("setVelocityX\\('hero', 120\\);", msgs)))
  expect_true(any(grepl("setVelocityY\\('hero', 140\\);", msgs)))
  expect_true(any(grepl("setGravity\\('hero', 1, 2\\);", msgs)))
  expect_true(any(grepl("setBounce\\('hero', 0.500000\\);", msgs)))
  expect_true(any(grepl("setSpriteInMotion\\('hero', 1, 0, 90, 45\\);", msgs)))
  expect_true(any(grepl('setSpriteInMotionRandomOrToward("hero", "mushroom_man", 300.000000', msgs, fixed = TRUE)))
  expect_true(any(grepl('startSpriteApproachOnSight("hero", "mushroom_man", 500.000000, 120.000000, 80.000000, 250.000000, 1200.000000, 1500.000000);', msgs, fixed = TRUE)))
  expect_true(any(grepl("destroySprite\\('hero'\\);", msgs)))
})

test_that("Text methods send expected JS", {
  session <- make_mock_session()
  txt <- Text$new("Score", "score_text", 15, 25, list(font_size = "22px"),
                  visible = FALSE, session = session)
  txt$set("Score: 1")
  txt$show()
  txt$hide()
  txt$follow_camera(lerp_x = 0.8, lerp_y = 0.9, round_pixels = TRUE)
  txt$stop_camera_follow()
  txt$set_scroll_factor(0)

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("addText\\('Score', 'score_text', 15, 25, .*false\\);", msgs)))
  expect_true(any(grepl("setText\\('Score: 1', 'score_text'\\);", msgs)))
  expect_true(any(grepl("showText\\('score_text'\\);", msgs)))
  expect_true(any(grepl("hideText\\('score_text'\\);", msgs)))
  expect_true(any(grepl("followSpriteWithCamera\\('score_text', 0.800000, 0.900000, true\\);", msgs)))
  expect_true(any(grepl("stopCameraFollow\\('score_text'\\);", msgs)))
  expect_true(any(grepl("setScrollFactor\\('score_text', 0.000000, 0.000000\\);", msgs)))
})

test_that("sample app and hedgehog assets are available", {
  sample_app <- system.file("sample_app", "app.R", package = "shinyphaser")
  expect_true(file.exists(sample_app))
  expect_true(file.exists(system.file("assets", "hedgehog", "terrain", "grass.png", package = "shinyphaser")))
})

test_that("PhaserGame set_world_bounds sends expected JS", {
  session <- make_mock_session()
  game <- PhaserGame$new()
  game$set_shiny_session(session)
  game$set_world_bounds(width = 1600, height = 800)

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("setWorldBounds\\(1600, 800\\);", msgs)))
})

test_that("PhaserGame exposes use_phaser UI initializer", {
  game <- PhaserGame$new()

  expect_true(is.function(game$use_phaser))
  expect_null(game$ui)
})

test_that("PhaserGame passes world gravity to its browser configuration", {
  game <- PhaserGame$new(gravity_x = 10, gravity_y = 1200)
  ui <- as.character(game$use_phaser())

  expect_true(any(grepl('"gravity_x":10', ui, fixed = TRUE)))
  expect_true(any(grepl('"gravity_y":1200', ui, fixed = TRUE)))
})

test_that("Sound methods send expected JS", {
  session <- make_mock_session()
  sound <- Sound$new("coin", "coin.mp3", volume = 0.5, loop = FALSE, session = session)
  sound$play()
  sound$play(volume = 0.8, loop = TRUE)
  sound$pause()
  sound$resume()
  sound$set_volume(0.25)
  sound$set_loop(TRUE)
  sound$stop()

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("addSound\\(\\\"coin\\\", \\\"coin.mp3\\\", 0.500000, false\\);", msgs)))
  expect_true(any(grepl("playSound\\(\\\"coin\\\", null, null\\);", msgs)))
  expect_true(any(grepl("playSound\\(\\\"coin\\\", 0.800000, true\\);", msgs)))
  expect_true(any(grepl("pauseSound\\(\\\"coin\\\"\\);", msgs)))
  expect_true(any(grepl("resumeSound\\(\\\"coin\\\"\\);", msgs)))
  expect_true(any(grepl("setSoundVolume\\(\\\"coin\\\", 0.250000\\);", msgs)))
  expect_true(any(grepl("setSoundLoop\\(\\\"coin\\\", true\\);", msgs)))
  expect_true(any(grepl("stopSound\\(\\\"coin\\\"\\);", msgs)))
})

test_that("PhaserGame can create Sound objects", {
  session <- make_mock_session()
  game <- PhaserGame$new()
  game$set_shiny_session(session)
  sound <- game$add_sound("jump", "jump.wav", volume = 0.4, loop = TRUE)

  expect_s3_class(sound, "Sound")
  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("addSound\\(\\\"jump\\\", \\\"jump.wav\\\", 0.400000, true\\);", msgs)))
})

test_that("browser_actions compile R6 calls for immediate execution", {
  session <- make_mock_session()
  game <- PhaserGame$new()
  game$set_shiny_session(session)
  input <- list()

  prompt <- game$add_text("Talk", "prompt", 0, 0, visible = FALSE)
  sound <- game$add_sound("hello", "hello.wav")
  hero <- game$add_sprite("hero", "hero.png", 0, 0, 32, 32, 1, 1)
  apples <- game$add_static_group("apples", "apple.png")
  game$add_overlap(
    object_one = "hero",
    object_two = "wizard",
    input = input,
    browser_action = browser_actions({
      prompt$show()
      sound$play(volume = 0.5)
      hero$play_animation("wave", duration = 250)
    })
  )
  game$add_overlap_end(
    object_one = "hero",
    object_two = "wizard",
    input = input,
    session = session,
    browser_action = browser_actions(prompt$hide())
  )
  game$add_collider("hero", "rock", input = input, browser_action = browser_actions(sound$stop()))
  game$add_overlap(
    "hero", group = "apples", input = input,
    browser_action = browser_actions({
      hero$set_in_motion(1, 0, 100, 50, lag = 0)
      apples$disable()
    })
  )

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl('addOverlap("hero", "wizard"', msgs, fixed = TRUE)))
  expect_true(any(grepl('"show_text":"prompt"', msgs, fixed = TRUE)))
  expect_true(any(grepl('"play_sound":"hello","volume":0.5', msgs, fixed = TRUE)))
  expect_true(any(grepl('"play_animation":"wave","sprite":"hero","duration":250', msgs, fixed = TRUE)))
  expect_true(any(grepl('addOverlapEnd("hero", "wizard"', msgs, fixed = TRUE)))
  expect_true(any(grepl('"hide_text":"prompt"', msgs, fixed = TRUE)))
  expect_true(any(grepl('addCollider(\'hero\',\'rock\'', msgs, fixed = TRUE)))
  expect_true(any(grepl('"stop_sound":"hello"', msgs, fixed = TRUE)))
  expect_true(any(grepl('"set_in_motion":{"name":"hero","dir_x":1,"dir_y":0,"speed":100,"distance":50}', msgs, fixed = TRUE)))
  expect_true(any(grepl('"disable_overlap_member":"apples"', msgs, fixed = TRUE)))
})

test_that("non-notifying physics handlers serialize a JavaScript null target", {
  session <- make_mock_session()
  game <- PhaserGame$new()
  game$set_shiny_session(session)

  game$add_collider("hero", "ground")
  game$add_overlap("hero", "coin")

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("addCollider('hero','ground',null,", msgs, fixed = TRUE)))
  expect_true(any(grepl('addOverlap("hero", "coin", null,', msgs, fixed = TRUE)))
  expect_false(any(grepl("[object Object]", msgs, fixed = TRUE)))
})

test_that("public handlers expose separate browser and server actions", {
  game <- PhaserGame$new()

  expect_false("client_action" %in% names(formals(game$add_overlap)))
  expect_false("client_action" %in% names(formals(game$add_overlap_end)))
  expect_false("client_action" %in% names(formals(game$add_control)))
  expect_true("browser_action" %in% names(formals(game$add_control)))
  expect_true("server_action" %in% names(formals(game$add_control)))
  expect_false("action" %in% names(formals(game$add_control)))
  expect_false("notify_server" %in% names(formals(game$add_control)))
  expect_false("callback_fun" %in% names(formals(game$add_collider)))
  expect_false("callback_fun" %in% names(formals(game$add_overlap)))
  expect_false("callback_fun" %in% names(formals(game$add_overlap_end)))

  for (handler in list(
    game$add_collider,
    game$add_overlap,
    game$add_overlap_end,
    game$add_control
  )) {
    arguments <- names(formals(handler))
    expect_true(all(c("browser_action", "server_action") %in% arguments))
    expect_false(any(c("action", "notify_server") %in% arguments))
  }
})

test_that("browser and server action declarations are validated", {
  session <- make_mock_session()
  game <- PhaserGame$new()
  game$set_shiny_session(session)

  expect_error(
    game$add_control("Space", browser_action = list()),
    "must be created with browser_actions"
  )
  expect_error(
    game$add_control("Space", server_action = function(event) NULL),
    "input is required"
  )
  expect_error(
    game$add_control("Space", server_action = "not a function"),
    "must be a function"
  )
})

test_that("browser state, cooldowns, conditions, and semantic events compile", {
  session <- make_mock_session()
  game <- PhaserGame$new()
  game$set_shiny_session(session)
  hero <- game$add_sprite("hero", "hero.png", 0, 0, 32, 32, 1, 1)
  sword <- game$add_static_sprite("sword", "sword.png", 10, 10)
  has_sword <- game$add_state("has_sword", FALSE)
  attack <- game$add_cooldown("attack", 750)

  game$add_control("Space", browser_action = browser_actions({
    if (hero$overlaps(sword) && sword$exists()) {
      sword$destroy()
      has_sword$set(TRUE)
    } else if (attack$ready()) {
      attack$trigger()
      game$alert(title = "Attack")
      game$emit("attack")
    }
  }))

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl('setBrowserState("has_sword", false)', msgs, fixed = TRUE)))
  control <- msgs[grepl('addKeyControl("Space"', msgs, fixed = TRUE)]
  expect_length(control, 1)
  expect_true(grepl('"op":"overlaps"', control, fixed = TRUE))
  expect_true(grepl('"op":"cooldown_ready"', control, fixed = TRUE))
  expect_true(grepl('"state_action":{"key":"has_sword","op":"set","value":true}', control, fixed = TRUE))
  expect_true(grepl('"show_alert":{"title":"Attack"}', control, fixed = TRUE))
  expect_true(grepl('"emit":{"name":"attack","data":[]}', control, fixed = TRUE))
})

test_that("browser actions reject unsupported R code instead of running it", {
  session <- make_mock_session()
  game <- PhaserGame$new()
  game$set_shiny_session(session)

  input <- list()
  ran <- FALSE
  expect_error(
    game$add_overlap(
      object_one = "hero",
      object_two = "wizard",
      browser_action = browser_actions({ ran <- TRUE }),
      input = input
    ),
    "browser_action must contain calls"
  )
  expect_false(ran)
})

test_that("hedgehog action events retain game progress alerts", {
  example <- readLines(
    system.file("examples", "hedgehog.R", package = "shinyphaser"),
    warn = FALSE
  )

  expect_true(any(grepl('title = "Game over"', example, fixed = TRUE)))
  expect_true(any(grepl("passed_level_alert(level_id)", example, fixed = TRUE)))
  expect_true(any(grepl('title = "You won!"', example, fixed = TRUE)))
  expect_false(any(grepl("callback_fun", example, fixed = TRUE)))
})

test_that("dungeonheroes Space action retains interactions and combat", {
  example <- readLines(
    system.file("examples", "dungeonheroes.R", package = "shinyphaser"),
    warn = FALSE
  )

  expect_true(any(grepl("if (sword_in_range && !has_sword)", example, fixed = TRUE)))
  expect_true(any(grepl('inventory_text$set("weapon: sword")', example, fixed = TRUE)))
  expect_true(any(grepl("if (wizard_in_range)", example, fixed = TRUE)))
  expect_true(any(grepl("server_action = handle_space", example, fixed = TRUE)))
  expect_true(any(grepl("server_action", example, fixed = TRUE)))
  expect_true(any(grepl("enemy_hit_points[[enemy_in_range]]", example, fixed = TRUE)))
  expect_true(any(grepl('title = "Game over"', example, fixed = TRUE)))
  expect_false(any(grepl("client_action", example, fixed = TRUE)))
  expect_false(any(grepl("dungeonheroes_version", example, fixed = TRUE)))
  expect_false(any(grepl("dungeonheroes v", example, fixed = TRUE)))
  expect_true(any(grepl('text = sprintf("shinyphaser v%s"', example, fixed = TRUE)))
})

test_that("bear Space control names its input argument", {
  example <- readLines(
    system.file("examples", "bear.R", package = "shinyphaser"),
    warn = FALSE
  )

  space_control <- grep('game\\$add_control\\(', example)[1]
  expect_true(any(grepl(
    "input = input",
    example[space_control:min(space_control + 15, length(example))],
    fixed = TRUE
  )))
  expect_true(any(grepl('name = "wooden_box"', example, fixed = TRUE)))
  expect_true(any(grepl('name = "apples"', example, fixed = TRUE)))

  game <- PhaserGame$new()
  control_arguments <- names(formals(game$add_control))
  expect_lt(match("input", control_arguments), match("server_action", control_arguments))
})

test_that("browser feedback is configured for immediate visibility and audio", {
  game_js <- readLines(system.file("www", "phaser-game.js", package = "shinyphaser"), warn = FALSE)
  sprite_js <- readLines(system.file("www", "phaser-sprite.js", package = "shinyphaser"), warn = FALSE)

  expect_true(any(grepl('context.state === "suspended"', game_js, fixed = TRUE)))
  expect_true(any(grepl("context.resume().then", game_js, fixed = TRUE)))
  expect_true(any(grepl("setDepth(10000)", sprite_js, fixed = TRUE)))
  expect_true(any(grepl("alertText.setPosition(sprite.x", sprite_js, fixed = TRUE)))
  expect_true(any(grepl("filecomplete-audio-${name}", game_js, fixed = TRUE)))
  expect_true(any(grepl("if (!scene.load.isLoading()) scene.load.start()", game_js, fixed = TRUE)))
  expect_true(any(grepl("() => addCollider(objectOneName", game_js, fixed = TRUE)))
  expect_true(any(grepl('typeof target !== "string"', game_js, fixed = TRUE)))
})

test_that("runtime visual assets initialize when the loader batch completes", {
  sprite_js <- readLines(system.file("www", "phaser-sprite.js", package = "shinyphaser"), warn = FALSE)
  group_js <- readLines(system.file("www", "phaser-groups.js", package = "shinyphaser"), warn = FALSE)
  image_js <- readLines(system.file("www", "phaser-image.js", package = "shinyphaser"), warn = FALSE)

  expect_true(any(grepl("scene.load.once('complete'", sprite_js, fixed = TRUE)))
  expect_true(any(grepl("scene.load.once('complete'", group_js, fixed = TRUE)))
  expect_true(any(grepl("scene.load.once('complete'", image_js, fixed = TRUE)))
  expect_false(any(grepl("if (!scene.load.isLoading())", sprite_js, fixed = TRUE)))
})

test_that("bear uses Arcade world gravity", {
  game_js <- readLines(system.file("www", "phaser-game.js", package = "shinyphaser"), warn = FALSE)
  bear <- readLines(system.file("examples", "bear.R", package = "shinyphaser"), warn = FALSE)

  expect_true(any(grepl("gravity: {", game_js, fixed = TRUE)))
  expect_true(any(grepl("gravity_y = 1200", bear, fixed = TRUE)))
  expect_false(any(grepl("$set_gravity", bear, fixed = TRUE)))
})
