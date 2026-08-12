  start_game <- function(x = 100, y = 100) {
    if (is.null(selected_character)) {
      selected_character <<- "hero_orc"
      hero_weapon <<- hero_weapons$axe
      hero$set_player_animation_prefix("hero")
      hero$add_player_controls()
      inventory_text$set("weapon: axe")
    }
    game$activate_map(
      "mushroom_swamps", player_name = "hero", x = x, y = y,
      visible_objects = mushroom_swamps_objects
    )
    session$sendCustomMessage("phaser", list(js = paste(
      "document.getElementById('game_start').style.display = 'none';",
      "document.getElementById('game_session_actions').style.display = 'flex';"
    )))
  }

  shiny::observeEvent(input$new_game, start_game(), ignoreInit = TRUE)
