  hide_map_navigation <- function() {
    map_navigation_background$hide()
    lapply(navigation_images, function(image) image$hide())
    hero$set_depth(10)
    session$sendCustomMessage(
      "phaser",
      list(js = paste(
        "setNavigationOverlayVisible(false);",
        "document.getElementById('leave_map').style.display = 'block';"
      ))
    )
  }

  choose_character <- function(character) {
    if (!is.null(selected_character)) return(invisible(NULL))

    selected_character <<- character
    current_realm <<- switch(character,
      hero_orc = "grey_mountains", hero_elf = "wild_forests", "castle"
    )
    hero$add_player_controls()
    animation_prefix <- switch(character,
      hero_orc = "hero_orc", hero_elf = "hero_elf", "hero_sword"
    )
    marker_character <- switch(character,
      hero_orc = "orc", hero_elf = "elf", "human"
    )
    weapon <- switch(character, hero_orc = "axe", hero_elf = "staff", "sword")
    hero_weapon <<- hero_weapons[[weapon]]
    hero$set_player_animation_prefix(animation_prefix)
    inventory_text$set(sprintf("weapon: %s", weapon))
    map_navigation_background$show()
    hero$set_depth(98)
    lapply(navigation_images, function(image) image$show())
    session$sendCustomMessage(
      "phaser",
      list(js = paste(
        sprintf(
          "document.getElementById('realm_character_marker').className = '%s %s';",
          marker_character, current_realm
        ),
        sprintf("setNavigationRealm('%s');", current_realm),
        "setNavigationOverlayVisible(true);",
        "document.getElementById('character_select').style.display = 'none';",
        "document.getElementById('game_start').style.display = 'none';",
        "document.getElementById('game_session_actions').style.display = 'flex';"
      ))
    )
  }

  shiny::observeEvent(input$new_game, {
    session$sendCustomMessage(
      "phaser",
      list(js = paste(
        "document.getElementById('game_start').style.display = 'none';",
        "document.getElementById('character_select').style.display = 'flex';"
      ))
    )
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$choose_hero, {
    choose_character("hero")
  }, ignoreInit = TRUE)
  shiny::observeEvent(input$choose_orc, {
    choose_character("hero_orc")
  }, ignoreInit = TRUE)
  shiny::observeEvent(input$choose_elf, {
    choose_character("hero_elf")
  }, ignoreInit = TRUE)
