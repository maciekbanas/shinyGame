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
        lifePoints = life_points,
        enemyHitPoints = as.list(enemy_hit_points),
        enemyIsAlive = as.list(enemy_is_alive),
        berriesAvailable = as.list(berry_is_available)
      )
    )
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$load_game, {
    save <- game$load_game(input$load_game$name, restore = FALSE)
    life_points <<- max(0, min(max_life_points, as.numeric(save$lifePoints %||% max_life_points)))
    update_life_points()

    saved_enemy_hp <- unlist(save$enemyHitPoints)
    common_enemies <- intersect(enemy_names, names(saved_enemy_hp))
    enemy_hit_points[common_enemies] <<- as.numeric(saved_enemy_hp[common_enemies])
    saved_enemy_alive <- unlist(save$enemyIsAlive)
    common_alive <- intersect(enemy_names, names(saved_enemy_alive))
    enemy_is_alive[common_alive] <<- as.logical(saved_enemy_alive[common_alive])
    saved_berries <- unlist(save$berriesAvailable)
    common_berries <- intersect(names(berries), names(saved_berries))
    berry_is_available[common_berries] <<- as.logical(saved_berries[common_berries])
    update_enemy_status()

    saved_hero <- save$phaser$objects$hero %||% list()
    x <- as.numeric(saved_hero$x %||% 100)
    y <- as.numeric(saved_hero$y %||% 100)
    unavailable <- c(enemy_names[!enemy_is_alive], names(berries)[!berry_is_available])
    start_game(x, y)
    lapply(unavailable, function(object_name) {
      session$sendCustomMessage("phaser", list(js = sprintf(
        "setRealmObjectVisibility(%s, false);",
        jsonlite::toJSON(object_name, auto_unbox = TRUE)
      )))
    })
  }, ignoreInit = TRUE)
