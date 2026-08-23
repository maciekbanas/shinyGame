make_mock_session <- function() {
  msgs <- list()
  env <- new.env(parent = emptyenv())
  env$sendCustomMessage <- function(type, message) {
    msgs[[length(msgs) + 1]] <<- list(type = type, message = message)
  }
  env$get_messages <- function() msgs
  env
}

test_that("Sprite initialize sends null frame_count when omitted", {
  session <- make_mock_session()

  Sprite$new(
    name = "hero",
    url = "hero.png",
    x = 10,
    y = 20,
    frame_width = 16,
    frame_height = 16,
    frame_rate = 12,
    session = session
  )

  msgs <- session$get_messages()
  expect_length(msgs, 1)
  expect_identical(msgs[[1]]$type, "phaser")
  expect_match(msgs[[1]]$message$js, "addSprite\\(\"hero\", \"hero.png\", 10, 20, 16, 16, null, 12\\);")
})

test_that("Sprite add_animation sends explicit frame_count when provided", {
  session <- make_mock_session()
  sprite <- Sprite$new(
    name = "hero",
    url = "hero.png",
    x = 0,
    y = 0,
    frame_width = 16,
    frame_height = 16,
    frame_rate = 8,
    session = session
  )

  sprite$add_animation(
    suffix = "run",
    url = "run.png",
    frame_width = 32,
    frame_height = 32,
    frame_count = 6,
    frame_rate = 24
  )

  msgs <- session$get_messages()
  expect_length(msgs, 2)
  expect_match(msgs[[2]]$message$js, "addSpriteAnimation\\(\"hero\",\"run\",\"run.png\",32,32,6,24\\);")
})

test_that("Sprite show and hide send visibility commands", {
  session <- make_mock_session()
  sprite <- Sprite$new("hero", "hero.png", 0, 0, 16, 16, 1, 8, session)

  sprite$hide()
  sprite$show()

  msgs <- vapply(session$get_messages(), function(m) m$message$js, character(1))
  expect_true(any(grepl("hideObject\\('hero'\\);", msgs)))
  expect_true(any(grepl("showObject\\('hero'\\);", msgs)))
})
  
test_that("Sprite can select a player animation prefix", {
  session <- make_mock_session()
  sprite <- Sprite$new(
    name = "hero",
    url = "hero.png",
    x = 0,
    y = 0,
    frame_width = 16,
    frame_height = 16,
    frame_rate = 8,
    session = session
  )

  sprite$set_player_animation_prefix("hero_orc")

  msgs <- session$get_messages()
  expect_length(msgs, 2)
  expect_match(
    msgs[[2]]$message$js,
    'setPlayerAnimationPrefix\\("hero", "hero_orc"\\);'
  )
})
