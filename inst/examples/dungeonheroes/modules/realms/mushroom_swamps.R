  choose_mushroom_swamps <- function(event) {
    current_realm <<- "mushroom_swamps"
    move_realm_marker(current_realm)
    hide_map_navigation()
    game$activate_map(
      "mushroom_swamps", player_name = "hero", x = 100, y = 100,
      visible_objects = mushroom_swamps_objects,
      hidden_objects = c(wild_forests_objects, "blacksmith")
    )
    update_enemy_status()
    set_combat_status("Back in the mushroom swamps.")
  }
