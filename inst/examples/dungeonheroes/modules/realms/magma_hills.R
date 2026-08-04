  choose_magma_hills <- function(event) {
    current_realm <<- "magma_hills"
    move_realm_marker(current_realm)
    hide_map_navigation()
    game$activate_map(
      # Magma hills has its own hill-top arrival point, separate from the
      # mushroom swamps entrance at (100, 100).
      "magma_hills", player_name = "hero", x = 1550, y = 650,
      hidden_objects = c(mushroom_swamps_objects, "talk_bubble_text", "blacksmith")
    )
    enemy_status_text$set("enemies: none in magma hills")
    set_combat_status("Explore the hills. Lava is impassable.")
  }
