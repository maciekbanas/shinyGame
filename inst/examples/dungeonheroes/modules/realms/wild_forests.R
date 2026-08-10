  choose_wild_forests <- function(event) {
    current_realm <<- "wild_forests"
    move_realm_marker(current_realm)
    hide_map_navigation()
    game$activate_map(
      current_realm, player_name = "hero", x = 100, y = 100,
      objects = wild_forests_objects
    )
    enemy_status_text$set("enemies: none in wild forests")
    set_combat_status("Explore the wild forests.")
  }
