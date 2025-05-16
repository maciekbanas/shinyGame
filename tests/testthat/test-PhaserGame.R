test_that("PhaserGame initializes correctly", {
  game <- PhaserGame$new(id = "test_id")
  expect_s3_class(game, "PhaserGame")
  expect_equal(game$id, "test_id")
})

test_that("PhaserGame UI returns expected HTML structure", {
  game <- PhaserGame$new()
  ui_out <- game$ui()

  expect_true(inherits(ui_out, "shiny.tag.list"))
  div_tag <- ui_out[[2]]
  expect_equal(div_tag$name, "div")
  expect_equal(div_tag$attribs$id, game$id)
  expect_match(div_tag$attribs$style, "width:100vw")

  script_tag <- ui_out[[4]]
  expect_equal(script_tag$name, "script")
  expect_match(script_tag$children[[1]], sprintf("initPhaserGame\\('%s'\\);", game$id))
})

test_that("add_player_sprite creates correct JavaScript", {
  fake_session <- structure(list(
    sent_message = NULL,
    sendCustomMessage = function(type, message) {
      fake_session$sent_message <<- list(type = type, message = message)
    }
  ), class = "FakeSession")

  game <- PhaserGame$new()
  game$add_player_sprite("hero", "hero.jpg", 50, 60, session = fake_session)

  expect_equal(fake_session$sent_message$type, "phaser")
  expect_match(fake_session$sent_message$message$js,
               "addPlayerSprite\\('hero', 'hero.jpg', 50, 60\\);")
})
