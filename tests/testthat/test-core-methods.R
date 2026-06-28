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

  rect <- Rectangle$new("hitbox", 1, 2, 3, 4, "0xff00ff", TRUE, TRUE, session = session)
  rect$show()
  rect$hide()

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("addImage\\('ground', 'ground.png', 10, 20, true, false\\);", msgs)))
  expect_true(any(grepl("showImage\\('ground'\\);", msgs)))
  expect_true(any(grepl("hideImage\\('ground'\\);", msgs)))
  expect_true(any(grepl("addRectangle\\('hitbox', 1, 2, 3, 4, 0xff00ff, true, true\\);", msgs)))
  expect_true(any(grepl("showImage\\('hitbox'\\);", msgs)))
  expect_true(any(grepl("hideImage\\('hitbox'\\);", msgs)))
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
  static_sprite$destroy()

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("addStaticSprite\\('rock','rock.png', 10, 20\\);", msgs)))
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
  s$set_velocity_x(120)
  s$set_velocity_y(140)
  s$set_gravity(1, 2)
  s$set_bounce(0.5)
  s$set_in_motion(1, 0, 90, 45, lag = 0)
  s$destroy()

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("playAnimation\\('hero','idle'\\);", msgs)))
  expect_true(any(grepl("playAnimationForDuration\\('hero','run', 300\\);", msgs)))
  expect_true(any(grepl("addPlayerControls\\('hero',", msgs)))
  expect_true(any(grepl("followSpriteWithCamera\\('hero', 0.500000, 0.750000, false\\);", msgs)))
  expect_true(any(grepl("stopCameraFollow\\('hero'\\);", msgs)))
  expect_true(any(grepl("setVelocityX\\('hero', 120\\);", msgs)))
  expect_true(any(grepl("setVelocityY\\('hero', 140\\);", msgs)))
  expect_true(any(grepl("setGravity\\('hero', 1, 2\\);", msgs)))
  expect_true(any(grepl("setBounce\\('hero', 0.500000\\);", msgs)))
  expect_true(any(grepl("setSpriteInMotion\\('hero', 1, 0, 90, 45\\);", msgs)))
  expect_true(any(grepl("destroySprite\\('hero'\\);", msgs)))
})


test_that("Text methods send expected JS", {
  session <- make_mock_session()
  txt <- Text$new("Score", "score_text", 15, 25, list(font_size = "22px"),
                  visible = FALSE, session = session)
  txt$set("Score: 1")
  txt$show()
  txt$hide()

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("addText\\('Score', 'score_text', 15, 25, .*false\\);", msgs)))
  expect_true(any(grepl("setText\\('Score: 1', 'score_text'\\);", msgs)))
  expect_true(any(grepl("showText\\('score_text'\\);", msgs)))
  expect_true(any(grepl("hideText\\('score_text'\\);", msgs)))
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

test_that("PhaserGame use_phaser refreshes without cache by default", {
  game <- PhaserGame$new()
  ui <- game$use_phaser()
  ui_html <- paste(as.character(ui), collapse = "\n")

  expect_match(ui_html, "refreshBrowserWithoutCache\\(true\\)")
  expect_match(ui_html, "shinyphaser-assets")
  expect_match(ui_html, "0\\.1-[0-9]+")
})

test_that("PhaserGame use_phaser can disable cache-busting refresh", {
  game <- PhaserGame$new()
  ui <- game$use_phaser(refresh_browser = FALSE)
  ui_html <- paste(as.character(ui), collapse = "\n")

  expect_match(ui_html, "refreshBrowserWithoutCache\\(false\\)")
  expect_match(ui_html, "0\\.1")
  expect_false(grepl("0\\.1-[0-9]+", ui_html))
})
