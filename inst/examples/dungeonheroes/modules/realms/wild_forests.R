  choose_wild_forests <- function(event) {
    current_realm <<- "wild_forests"
    move_realm_marker(current_realm)
    hide_map_navigation()
    game$activate_map(
      current_realm, player_name = "hero", x = 100, y = 100,
      visible_objects = wild_forests_objects,
      hidden_objects = c(mushroom_swamps_objects, "talk_bubble_text", "blacksmith")
    )
    enemy_status_text$set("enemies: none in wild forests")
    set_combat_status("Explore the wild forests.")
  }
