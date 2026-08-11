  send_saved_games <- function() {
    summaries <- lapply(game$list_saved_games(), function(save) {
      list(name = save$name, savedAt = save$savedAt)
    })
    session$sendCustomMessage("phaser", list(js = sprintf(
      "renderDungeonHeroesSaves(%s);",
      jsonlite::toJSON(summaries, auto_unbox = TRUE, null = "null")
    )))
  }

  shiny::observeEvent(input$list_saved_games, send_saved_games(), ignoreInit = TRUE)

  shiny::observeEvent(input$save_game_requested, {
    request <- input$save_game_requested
    game$save_game(
      name = as.character(request$name),
      snapshot = request$objects,
      state = list(
        character = selected_character,
        realm = current_realm,
        navigation = isTRUE(request$state$navigation),
        lifePoints = life_points,
        enemyHitPoints = as.list(enemy_hit_points),
        enemyIsAlive = as.list(enemy_is_alive),
        berriesAvailable = as.list(berry_is_available)
      )
    )
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$load_game, {
    save <- game$load_game(input$load_game$name, restore = FALSE)
    if (is.null(save$character) || !save$character %in% c("hero", "hero_orc", "hero_elf")) return()

    choose_character(save$character)
    available_realms <- c("castle", "mushroom_swamps", "wild_forests", "grey_mountains", "magma_hills")
    current_realm <<- if (save$realm %in% available_realms) save$realm else "mushroom_swamps"
    life_points <<- max(0, min(max_life_points, as.numeric(save$lifePoints %||% max_life_points)))
    update_life_points()

    saved_enemy_hp <- unlist(save$enemyHitPoints)
    saved_enemy_alive <- unlist(save$enemyIsAlive)
    common_enemies <- intersect(enemy_names, names(saved_enemy_hp))
    enemy_hit_points[common_enemies] <<- as.numeric(saved_enemy_hp[common_enemies])
    common_alive <- intersect(enemy_names, names(saved_enemy_alive))
    enemy_is_alive[common_alive] <<- as.logical(saved_enemy_alive[common_alive])
    saved_berries <- unlist(save$berriesAvailable)
    common_berries <- intersect(names(berries), names(saved_berries))
    berry_is_available[common_berries] <<- as.logical(saved_berries[common_berries])
    update_enemy_status()

    marker_character <- switch(save$character,
      hero_orc = "orc", hero_elf = "elf", "human"
    )
    saved_hero <- save$phaser$objects$hero %||% list()
    x <- as.numeric(saved_hero$x %||% 100)
    y <- as.numeric(saved_hero$y %||% 100)
    on_navigation <- isTRUE(save$navigation)
    session$sendCustomMessage(
      "phaser",
      list(js = sprintf(
        paste(
          "document.getElementById('realm_character_marker').className = %s + ' ' + %s;",
          "setNavigationRealm(%s);",
          "document.getElementById('game_start').style.display = 'none';",
          "document.getElementById('game_session_actions').style.display = 'flex';"
        ),
        jsonlite::toJSON(marker_character, auto_unbox = TRUE),
        jsonlite::toJSON(current_realm, auto_unbox = TRUE),
        jsonlite::toJSON(current_realm, auto_unbox = TRUE)
      ))
    )
    if (on_navigation) {
      map_navigation_background$show()
      hero$set_depth(98)
      lapply(navigation_images, function(image) image$show())
      session$sendCustomMessage("phaser", list(js = "setNavigationOverlayVisible(true);"))
    } else {
      hide_map_navigation()
      persistent_objects <- c("dead_tree_1_bottom", "dead_tree_1_top", "wizard", "mushroom_spirit")
      available_objects <- c(enemy_names[enemy_is_alive], names(berries)[berry_is_available], persistent_objects)
      unavailable_objects <- c(enemy_names[!enemy_is_alive], names(berries)[!berry_is_available])
      visible <- if (identical(current_realm, "mushroom_swamps")) {
        intersect(available_objects, mushroom_swamps_objects)
      } else if (identical(current_realm, "wild_forests")) {
        c(names(forest_decorations), intersect(available_objects, names(forest_berries)))
      } else if (identical(current_realm, "castle")) {
        "blacksmith"
      } else character()
      hidden <- if (identical(current_realm, "mushroom_swamps")) {
        c(unavailable_objects, wild_forests_objects, "blacksmith")
      } else if (identical(current_realm, "wild_forests")) {
        c(mushroom_swamps_objects, unavailable_objects, "talk_bubble_text", "blacksmith")
      } else {
        c(mushroom_swamps_objects, wild_forests_objects, "talk_bubble_text", "blacksmith")
      }
      if (identical(current_realm, "castle")) hidden <- setdiff(hidden, "blacksmith")
      game$activate_map(current_realm, player_name = "hero", x = x, y = y,
                        visible_objects = visible, hidden_objects = hidden)
    }
  }, ignoreInit = TRUE)
