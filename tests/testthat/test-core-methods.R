read_dungeonheroes_example <- function() {
  example_dir <- system.file("examples", "dungeonheroes", package = "shinyphaser")
  files <- list.files(example_dir, pattern = "[.]R$", recursive = TRUE, full.names = TRUE)
  unlist(lapply(files, readLines, warn = FALSE), use.names = FALSE)
}

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
  img$set_depth(20)

  rect <- Rectangle$new("hitbox", 1, 2, 3, 4, "0xff00ff", TRUE, TRUE, session = session)
  rect$show()
  rect$hide()
  rect$follow_camera(lerp_x = 0.4, lerp_y = 0.5, round_pixels = TRUE)
  rect$stop_camera_follow()
  rect$set_scroll_factor(0.25, 0.75)
  rect$set_depth(30)

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("addImage\\('ground', 'ground.png', 10, 20, true, false\\);", msgs)))
  expect_true(any(grepl("showImage\\('ground'\\);", msgs)))
  expect_true(any(grepl("hideImage\\('ground'\\);", msgs)))
  expect_true(any(grepl("followSpriteWithCamera\\('ground', 0.200000, 0.300000, false\\);", msgs)))
  expect_true(any(grepl("stopCameraFollow\\('ground'\\);", msgs)))
  expect_true(any(grepl("setScrollFactor\\('ground', 0.000000, 0.000000\\);", msgs)))
  expect_true(any(grepl("setSpriteDepth\\('ground', 20.000000\\);", msgs)))
  expect_true(any(grepl("addRectangle\\('hitbox', 1, 2, 3, 4, 0xff00ff, true, true\\);", msgs)))
  expect_true(any(grepl("showImage\\('hitbox'\\);", msgs)))
  expect_true(any(grepl("hideImage\\('hitbox'\\);", msgs)))
  expect_true(any(grepl("followSpriteWithCamera\\('hitbox', 0.400000, 0.500000, true\\);", msgs)))
  expect_true(any(grepl("stopCameraFollow\\('hitbox'\\);", msgs)))
  expect_true(any(grepl("setScrollFactor\\('hitbox', 0.250000, 0.750000\\);", msgs)))
  expect_true(any(grepl("setSpriteDepth\\('hitbox', 30.000000\\);", msgs)))
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
  static_sprite$set_depth(10)
  static_sprite$destroy()

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("addStaticSprite\\('rock','rock.png', 10, 20\\);", msgs)))
  expect_true(any(grepl("followSpriteWithCamera\\('rock', 0.600000, 0.700000, false\\);", msgs)))
  expect_true(any(grepl("stopCameraFollow\\('rock'\\);", msgs)))
  expect_true(any(grepl("setScrollFactor\\('rock', 0.000000, 0.000000\\);", msgs)))
  expect_true(any(grepl("setSpriteDepth\\('rock', 10.000000\\);", msgs)))
  expect_true(any(grepl("destroySprite\\('rock'\\);", msgs)))
})

test_that("Sprite utility methods send expected JS", {
  session <- make_mock_session()
  s <- Sprite$new("hero", "hero.png", 0, 0, 32, 32, frame_count = 4, frame_rate = 12, session = session)
  s$play_animation("idle")
  s$play_animation("run", duration = 300)
  s$stop_motion()
  s$add_player_controls(c("left", "right"), speed = 180)
  s$follow_camera(lerp_x = 0.5, lerp_y = 0.75, round_pixels = FALSE)
  s$stop_camera_follow()
  s$set_scroll_factor(1, 0.5)
  s$set_depth(15)
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
  expect_true(any(grepl("stopSpriteMotion\\('hero'\\);", msgs)))
  expect_true(any(grepl("addPlayerControls\\('hero',", msgs)))
  expect_true(any(grepl("followSpriteWithCamera\\('hero', 0.500000, 0.750000, false\\);", msgs)))
  expect_true(any(grepl("stopCameraFollow\\('hero'\\);", msgs)))
  expect_true(any(grepl("setScrollFactor\\('hero', 1.000000, 0.500000\\);", msgs)))
  expect_true(any(grepl("setSpriteDepth\\('hero', 15.000000\\);", msgs)))
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

test_that("activate_map serializes map objects as an array", {
  session <- make_mock_session()
  game <- PhaserGame$new()
  game$set_shiny_session(session)

  game$activate_map(
    "castle", player_name = "hero", x = 700, y = 500,
    objects = "blacksmith"
  )
  game$activate_map("mushroom_swamps", objects = character())

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl(
    'activateMap("castle", "hero", 700, 500, ["blacksmith"]);',
    msgs, fixed = TRUE
  )))
  expect_true(any(grepl(
    'activateMap("mushroom_swamps", null, null, null, []);',
    msgs, fixed = TRUE
  )))
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
      hero$stop_motion()
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
  expect_true(any(grepl('"stop_motion":"hero"', msgs, fixed = TRUE)))
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
  example <- read_dungeonheroes_example()

  expect_false(any(grepl("sword_in_range", example, fixed = TRUE)))
  expect_true(any(grepl(
    'weapon <- switch(character, hero_orc = "axe", hero_elf = "staff", "sword")',
    example,
    fixed = TRUE
  )))
  expect_true(any(grepl('inventory_text$set(sprintf("weapon: %s", weapon))', example, fixed = TRUE)))
  expect_true(any(grepl("if (wizard_in_range)", example, fixed = TRUE)))
  expect_true(any(grepl("server_action = handle_space", example, fixed = TRUE)))
  expect_true(any(grepl("server_action", example, fixed = TRUE)))
  expect_true(any(grepl("damage <- hero_weapon$damage", example, fixed = TRUE)))
  expect_true(any(grepl("enemy_hit_points[[hit_enemy]]", example, fixed = TRUE)))
  expect_true(any(grepl("distance = hero_weapon$knockback", example, fixed = TRUE)))
  expect_true(any(grepl('paste0("damage_", knockback_direction)', example, fixed = TRUE)))
  expect_true(any(grepl("mushroom_reaction_check_interval <- 16", example, fixed = TRUE)))
  expect_true(any(grepl("enemies[[enemy_name]]$stop_motion()", example, fixed = TRUE)))
  expect_true(any(grepl("browser_action = browser_actions", example, fixed = TRUE)))
  expect_true(any(grepl('duration = enemy_attack_cooldown * 1000', example, fixed = TRUE)))
  expect_true(any(grepl('mode = "stay"', example, fixed = TRUE)))
  expect_true(any(grepl('interval = enemy_attack_cooldown * 1000', example, fixed = TRUE)))
  expect_true(any(grepl('duration = 1', example, fixed = TRUE)))
  expect_true(any(grepl('title = "Game over"', example, fixed = TRUE)))
  expect_false(any(grepl("client_action", example, fixed = TRUE)))
  expect_false(any(grepl("dungeonheroes_version", example, fixed = TRUE)))
  expect_false(any(grepl("dungeonheroes v", example, fixed = TRUE)))
  expect_true(any(grepl('text = sprintf("shinyphaser v%s"', example, fixed = TRUE)))
})

test_that("dungeonheroes tree has a collidable base and foreground top", {
  example <- read_dungeonheroes_example()

  expect_true(any(grepl('name = "dead_tree_1_bottom"', example, fixed = TRUE)))
  expect_true(any(grepl('name = "dead_tree_1_top"', example, fixed = TRUE)))
  expect_true(any(grepl('url = "assets/dungeonheroes/terrain/mushroom_swamps/dead_tree_1_bottom.png"', example, fixed = TRUE)))
  expect_true(any(grepl('url = "assets/dungeonheroes/terrain/mushroom_swamps/dead_tree_1_top.png"', example, fixed = TRUE)))
  expect_true(any(grepl("y = 650", example, fixed = TRUE)))
  expect_true(any(grepl('game$add_collider("hero", "dead_tree_1_bottom")', example, fixed = TRUE)))
  expect_false(any(grepl('game$add_collider("hero", "dead_tree_1_top")', example, fixed = TRUE)))
  expect_true(any(grepl("dead_tree_top$set_depth(20)", example, fixed = TRUE)))
})

test_that("dungeonheroes can travel between mushroom swamps and magma hills", {
  example <- read_dungeonheroes_example()
  magma_map <- jsonlite::read_json(
    system.file("assets", "dungeonheroes", "maps", "magma_hills.json",
                package = "shinyphaser"),
    simplifyVector = FALSE
  )

  expect_true(any(grepl('"leave_map", "Leave map"', example, fixed = TRUE)))
  expect_true(any(grepl("onclick = \"this.style.display = 'none';\"", example, fixed = TRUE)))
  expect_true(any(grepl('name = "map_navigation_background"', example, fixed = TRUE)))
  expect_true(any(grepl('name = "choose_mushroom_swamps"', example, fixed = TRUE)))
  expect_true(any(grepl('name = "choose_magma_hills"', example, fixed = TRUE)))
  expect_true(any(grepl('x = 400, y = 300', example, fixed = TRUE)))
  expect_true(any(grepl('mushroom_swamps_map_image$click(', example, fixed = TRUE)))
  expect_true(any(grepl('magma_hills_map_image$click(', example, fixed = TRUE)))
  expect_true(any(grepl('hero$set_depth(98)', example, fixed = TRUE)))
  expect_true(any(grepl('map_key = "magma_hills"', example, fixed = TRUE)))
  expect_true(any(grepl('game$activate_map(', example, fixed = TRUE)))
  expect_true(any(grepl('game$set_map_exit("mushroom_swamps", "hero", x = 100, y = 100)',
                        example, fixed = TRUE)))
  expect_true(any(grepl('game$set_map_exit("magma_hills", "hero", x = 1550, y = 650)',
                        example, fixed = TRUE)))
  expect_true(any(grepl('"magma_hills", player_name = "hero", x = 1550, y = 650',
                        example, fixed = TRUE)))
  expect_identical(magma_map$layers[[1]]$name, "terrain")
  expect_identical(vapply(magma_map$tilesets, `[[`, character(1), "name"),
                   c("hill_1", "lava_1"))
  expect_true(magma_map$tilesets[[2]]$tiles[[1]]$properties[[1]]$value)
  expect_true(all(unlist(magma_map$layers[[1]]$data) %in% c(1L, 2L)))
})

test_that("dungeonheroes includes the elf and new western realms", {
  example <- read_dungeonheroes_example()
  wild_map <- jsonlite::read_json(
    system.file("assets", "dungeonheroes", "maps", "wild_forests.json",
                package = "shinyphaser"),
    simplifyVector = FALSE
  )
  grey_map <- jsonlite::read_json(
    system.file("assets", "dungeonheroes", "maps", "grey_mountains.json",
                package = "shinyphaser"),
    simplifyVector = FALSE
  )

  expect_true(any(grepl('class = "character_name", "Elf Ranger"', example, fixed = TRUE)))
  expect_true(any(grepl('class = "character_name", "Human Knight"', example, fixed = TRUE)))
  expect_true(any(grepl('class = "character_name", "Orc Hunter"', example, fixed = TRUE)))
  expect_true(any(grepl('suffix = "elf_idle"', example, fixed = TRUE)))
  expect_true(any(grepl('frame_count = 21, frame_rate = 4', example, fixed = TRUE)))
  expect_true(any(grepl(
    'hero_orc = "grey_mountains", hero_elf = "wild_forests", "castle"',
    example, fixed = TRUE
  )))
  expect_true(any(grepl('frame_count = 2, frame_rate = 8', example, fixed = TRUE)))
  expect_true(any(grepl('frame_count = 4, frame_rate = 6', example, fixed = TRUE)))
  expect_true(any(grepl('choose_character("hero_elf")', example, fixed = TRUE)))
  expect_true(any(grepl('name = "choose_wild_forests"', example, fixed = TRUE)))
  expect_true(any(grepl('name = "choose_grey_mountains"', example, fixed = TRUE)))
  expect_true(any(grepl('map_key = "grey_mountains"', example, fixed = TRUE)))
  expect_true(any(grepl(
    '"assets/dungeonheroes/terrain/grey_mountains/hill_1.png"',
    example, fixed = TRUE
  )))
  expect_true(any(grepl(
    '"assets/dungeonheroes/terrain/grey_mountains/rock_1.png"',
    example, fixed = TRUE
  )))
  expect_true(any(grepl('tileset_names = c("hill_1", "rock_1")',
                        example, fixed = TRUE)))
  expect_true(any(grepl('x = 400, y = 200', example, fixed = TRUE)))
  expect_true(any(grepl('x = 300, y = 300', example, fixed = TRUE)))
  expect_true(any(grepl('left: 400px;', example, fixed = TRUE)))
  expect_false(any(grepl('border-radius: 50%;', example, fixed = TRUE)))
  expect_identical(vapply(wild_map$tilesets, `[[`, character(1), "name"),
                   c(sprintf("grass_%d", 1:5), "forest_path_1"))
  expect_true(any(grepl(
    '"assets/dungeonheroes/terrain/wild_forests/forest_path_1.png"',
    example, fixed = TRUE
  )))
  expect_identical(wild_map$tilesets[[6]]$firstgid, 6L)
  expect_true(sum(unlist(wild_map$layers[[1]]$data) == 6L) >= 128)
  expect_identical(vapply(grey_map$tilesets, `[[`, character(1), "name"),
                   c("hill_1", "rock_1"))
  expect_true(grey_map$tilesets[[2]]$tiles[[1]]$properties[[1]]$value)
  expect_length(wild_map$layers[[1]]$data, 32 * 64)
  expect_length(grey_map$layers[[1]]$data,
                grey_map$width * grey_map$height)
})

test_that("wild forests has passable foreground vegetation and berries", {
  example <- read_dungeonheroes_example()
  asset_dir <- system.file(
    "assets", "dungeonheroes", "terrain", "wild_forests",
    package = "shinyphaser"
  )

  expect_true(all(file.exists(file.path(
    asset_dir, c(sprintf("bush_%d.png", 1:4), "big_tree_1.png")
  ))))
  expect_true(any(grepl(
    'file.path("realms", "wild_forests_world.R")', example, fixed = TRUE
  )))
  expect_true(any(grepl(
    '"assets/dungeonheroes/terrain/wild_forests/%s.png", spec[["asset"]]',
    example, fixed = TRUE
  )))
  expect_true(any(grepl(
    "frame_width = 200, frame_height = 400", example, fixed = TRUE
  )))
  expect_true(any(grepl(
    'is_animated_tree <- spec[["asset"]] %in% c("big_tree_1", "big_tree_4")',
    example, fixed = TRUE
  )))
  expect_true(any(grepl("decoration$set_depth(20)", example, fixed = TRUE)))
  expect_true(sum(grepl("bush_[1-4]_[0-9]+ = c\\(asset", example)) >= 48)
  expect_true(sum(grepl('asset = "big_tree_1"', example, fixed = TRUE)) >= 16)
  expect_true(sum(grepl('asset = "big_tree_2"', example, fixed = TRUE)) >= 8)
  expect_true(sum(grepl('asset = "big_tree_3"', example, fixed = TRUE)) >= 8)
  expect_true(sum(grepl('asset = "big_tree_4"', example, fixed = TRUE)) >= 20)
  expect_true(sum(grepl('asset = "bush_5"', example, fixed = TRUE)) >= 12)
  expect_true(sum(grepl('asset = "bush_6"', example, fixed = TRUE)) >= 12)
  expect_true(sum(grepl('asset = "big_tree_5"', example, fixed = TRUE)) >= 16)
  expect_true(sum(grepl('asset = "small_tree_1"', example, fixed = TRUE)) >= 12)
  expect_true(any(grepl(
    'identical(spec[["asset"]], "small_tree_1")', example, fixed = TRUE
  )))
  expect_true(any(grepl("game$add_collision_rectangle(", example, fixed = TRUE)))
  expect_true(any(grepl(
    "game$add_collider(\"hero\", collision_name)", example, fixed = TRUE
  )))
  expect_true(any(grepl(
    "width = if (is_big_tree) 120 else 60", example, fixed = TRUE
  )))
  expect_true(any(grepl(
    "height = if (is_tree) 50 else 20", example, fixed = TRUE
  )))
  expect_true(any(grepl(
    'url = "assets/dungeonheroes/perks/berries.png"', example, fixed = TRUE
  )))
  expect_true(any(grepl(
    "add_berry_handlers(names(forest_berries))", example, fixed = TRUE
  )))
  expect_true(any(grepl(
    "objects = wild_forests_objects", example, fixed = TRUE
  )))
})

test_that("collision rectangles create invisible static physics bodies", {
  session <- make_mock_session()
  game <- PhaserGame$new()
  game$set_shiny_session(session)
  game$add_collision_rectangle("tree_base", 100, 175, 200, 50)
  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl(
    'addCollisionRectangle("tree_base", 100.000000, 175.000000, 200.000000, 50.000000);',
    msgs, fixed = TRUE
  )))

  game_js <- readLines(
    system.file("www", "phaser-game.js", package = "shinyphaser"), warn = FALSE
  )
  expect_true(any(grepl(
    "scene.add.rectangle(x, y, width, height, 0x000000, 0)",
    game_js, fixed = TRUE
  )))
  expect_true(any(grepl(
    "scene.physics.add.existing(rectangle, true);", game_js, fixed = TRUE
  )))
})

test_that("image visibility waits for asynchronously loaded images", {
  image_js <- readLines(
    system.file("www", "phaser-image.js", package = "shinyphaser"), warn = FALSE
  )
  image_source <- paste(image_js, collapse = "\n")

  expect_true(grepl(
    'withSprite(imageName, (image) => image.setVisible(true), "showImage()")',
    image_source, fixed = TRUE
  ))
  expect_true(grepl(
    'withSprite(imageName, (image) => image.setVisible(false), "hideImage()")',
    image_source, fixed = TRUE
  ))
  expect_lt(
    regexpr("scene[imageName].setVisible(visible)", image_source, fixed = TRUE)[[1]],
    regexpr("applyPendingSpriteActions(imageName)", image_source, fixed = TRUE)[[1]]
  )
})

test_that("realm marker shares the navigation canvas coordinate space", {
  game_js <- readLines(
    system.file("www", "phaser-game.js", package = "shinyphaser"),
    warn = FALSE
  )

  expect_true(any(grepl('const container = game?.canvas?.parentElement;',
                        game_js, fixed = TRUE)))
  expect_true(any(grepl('container.appendChild(marker);', game_js, fixed = TRUE)))
})

test_that("sight approach does not restart active movement or hide alerts", {
  sprite_js <- readLines(
    system.file("www", "phaser-sprite.js", package = "shinyphaser"),
    warn = FALSE
  )
  sight_start <- grep("function startSpriteApproachOnSight", sprite_js, fixed = TRUE)
  sight_end <- grep("function constrainedTerrainMotionEnd", sprite_js, fixed = TRUE)
  sight_code <- sprite_js[sight_start:(sight_end - 1)]

  forced_guard <- grep("if (GameBridge.forcedAnimations[name]) return;", sight_code, fixed = TRUE)
  alert_creation <- grep('scene.add.text(sprite.x, sprite.y - sprite.displayHeight * 0.6, "!"', sight_code, fixed = TRUE)
  movement_guard <- grep("if (scene.tweens.isTweening(sprite)) return;", sight_code, fixed = TRUE)
  approach_move <- grep("setSpriteInMotion(", sight_code, fixed = TRUE)
  delayed_approach <- grep('setData("sightAlertUntil", now + alertDuration)', sight_code, fixed = TRUE)

  expect_length(forced_guard, 1)
  expect_length(alert_creation, 1)
  expect_length(movement_guard, 1)
  expect_length(delayed_approach, 0)
  expect_lt(alert_creation, forced_guard)
  expect_lt(forced_guard, movement_guard)
  expect_lt(movement_guard, approach_move[[length(approach_move)]])
})

test_that("recent movement selects four-way directional attack animations", {
  game_js <- readLines(system.file("www", "phaser-game.js", package = "shinyphaser"), warn = FALSE)
  sprite_js <- readLines(system.file("www", "phaser-sprite.js", package = "shinyphaser"), warn = FALSE)
  example <- read_dungeonheroes_example()

  expect_true(any(grepl("GameBridge.directionalAttackMemory = 1500", game_js, fixed = TRUE)))
  expect_true(any(grepl('rememberMovementDirection(sprite, "left", time)', game_js, fixed = TRUE)))
  expect_true(any(grepl('rememberMovementDirection(sprite, "right", time)', game_js, fixed = TRUE)))
  expect_true(any(grepl('rememberMovementDirection(sprite, "up", time)', game_js, fixed = TRUE)))
  expect_true(any(grepl('rememberMovementDirection(sprite, "down", time)', game_js, fixed = TRUE)))
  expect_true(any(grepl('animationKey + "_" + direction', game_js, fixed = TRUE)))
  expect_true(any(grepl('forcedKey + "_" + movementSuffix', game_js, fixed = TRUE)))
  expect_true(any(grepl("targetAnim !== animationPrefix + '_idle'", game_js, fixed = TRUE)))
  expect_true(any(grepl('rememberMovementDirection(sprite, movementDirection, now)', sprite_js, fixed = TRUE)))
  expect_true(any(grepl('suffix = paste0("sword_attack_", direction)', example, fixed = TRUE)))
  expect_true(any(grepl('suffix = paste0("orc_attack_", direction)', example, fixed = TRUE)))
  expect_true(any(grepl('hero_orc_attack_%s.png', example, fixed = TRUE)))
  expect_true(any(grepl('suffix = paste0("attack_", direction)', example, fixed = TRUE)))
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
  expect_true(any(grepl("groundLayer.setDepth(-1)", game_js, fixed = TRUE)))
})

test_that("runtime visual assets initialize when the loader batch completes", {
  sprite_js <- readLines(system.file("www", "phaser-sprite.js", package = "shinyphaser"), warn = FALSE)
  group_js <- readLines(system.file("www", "phaser-groups.js", package = "shinyphaser"), warn = FALSE)
  image_js <- readLines(system.file("www", "phaser-image.js", package = "shinyphaser"), warn = FALSE)

  expect_true(any(grepl("scene.load.once('complete'", sprite_js, fixed = TRUE)))
  expect_true(any(grepl("scene.load.once('complete'", group_js, fixed = TRUE)))
  expect_true(any(grepl("applyPendingSpriteActions(imageName)", image_js, fixed = TRUE)))
  expect_true(any(grepl("scene.load.once('complete'", image_js, fixed = TRUE)))
  expect_false(any(grepl("if (!scene.load.isLoading())", sprite_js, fixed = TRUE)))

  interactive <- grep("scene[imageName].setInteractive();", image_js, fixed = TRUE)
  pending <- grep("applyPendingSpriteActions(imageName);", image_js, fixed = TRUE)
  expect_length(interactive, 1)
  expect_length(pending, 1)
  expect_lt(interactive, pending)
  expect_true(any(grepl(
    'withSprite(imageName, (image) => {', image_js, fixed = TRUE
  )))
  expect_true(any(grepl('}, "clickImage()");', image_js, fixed = TRUE)))
  expect_false(any(grepl("scene[imageName].on('pointerdown'", image_js, fixed = TRUE)))
})

test_that("bear uses Arcade world gravity", {
  game_js <- readLines(system.file("www", "phaser-game.js", package = "shinyphaser"), warn = FALSE)
  bear <- readLines(system.file("examples", "bear.R", package = "shinyphaser"), warn = FALSE)

  expect_true(any(grepl("gravity: {", game_js, fixed = TRUE)))
  expect_true(any(grepl("gravity_y = 1200", bear, fixed = TRUE)))
  expect_false(any(grepl("$set_gravity", bear, fixed = TRUE)))
})

test_that("saved games use Phaser snapshots and server disk persistence", {
  game_js <- readLines(system.file("www", "phaser-game.js", package = "shinyphaser"), warn = FALSE)
  example <- read_dungeonheroes_example()

  expect_true(any(grepl("function capturePhaserGameState", game_js, fixed = TRUE)))
  expect_true(any(grepl("object.body.reset(saved.x, saved.y)", game_js, fixed = TRUE)))
  expect_false(any(grepl("localStorage", example, fixed = TRUE)))
  expect_true(any(grepl('game$save_game(', example, fixed = TRUE)))
  expect_true(any(grepl('game$load_game(input$load_game$name', example, fixed = TRUE)))
})

test_that("save file helpers replace named JSON records", {
  directory <- tempfile("shinyphaser-saves-")
  path <- file.path(directory, "save-games.json")
  saves <- list(list(name = "first", savedAt = "2026-01-01", state = list(score = 1)))

  write_phaser_saves(saves, path)
  expect_true(file.exists(path))
  expect_equal(read_phaser_saves(path), saves)
})

test_that("dungeonheroes captures its hero before the synchronous disk save", {
  example <- read_dungeonheroes_example()

  expect_true(any(grepl("capturePhaserGameState('save_game_requested'", example, fixed = TRUE)))
  expect_true(any(grepl("snapshot = request$objects", example, fixed = TRUE)))
  expect_true(any(grepl('id = "toggle_game_menu"', example, fixed = TRUE)))
  expect_true(any(grepl('position: fixed; left: 18px; top: 18px', example, fixed = TRUE)))
})

test_that("save_game writes a supplied Phaser snapshot immediately", {
  directory <- tempfile("shinyphaser-game-")
  game <- PhaserGame$new(id = "save-test")

  game$save_game(
    "checkpoint",
    state = list(score = 12),
    snapshot = list(hero = list(x = 321, y = 654)),
    directory = directory
  )

  saves <- game$list_saved_games(directory)
  expect_length(saves, 1)
  expect_equal(saves[[1]]$phaser$objects$hero$x, 321)
  loaded <- game$load_game("checkpoint", restore = FALSE, directory = directory)
  expect_equal(loaded$score, 12)
})

test_that("dungeonheroes is organized into focused modules and sprite directories", {
  example_dir <- system.file("examples", "dungeonheroes", package = "shinyphaser")
  asset_dir <- system.file("assets", "dungeonheroes", "sprites", package = "shinyphaser")

  expect_true(file.exists(file.path(example_dir, "app.R")))
  expect_true(file.exists(file.path(example_dir, "modules", "saving.R")))
  expect_true(file.exists(file.path(example_dir, "modules", "navigation.R")))
  expect_true(file.exists(file.path(example_dir, "modules", "realms", "magma_hills.R")))
  expect_true(file.exists(file.path(example_dir, "modules", "realms", "mushroom_swamps.R")))
  expect_true(file.exists(file.path(example_dir, "modules", "realms", "wild_forests.R")))
  expect_true(file.exists(file.path(example_dir, "modules", "realms", "grey_mountains.R")))
  expect_true(file.exists(file.path(asset_dir, "hero", "human", "hero_sword_idle.png")))
  expect_true(file.exists(file.path(asset_dir, "hero", "elf", "hero_elf_idle.png")))
  expect_true(file.exists(file.path(asset_dir, "hero", "orc", "hero_orc_idle.png")))
  expect_true(file.exists(file.path(asset_dir, "enemies", "mushroom_man", "mushroom_man_idle.png")))
  expect_true(file.exists(file.path(asset_dir, "enemies", "skeleton", "skeleton_idle.png")))
  expect_true(file.exists(file.path(asset_dir, "npc", "wizard", "wizard_idle.png")))
})
