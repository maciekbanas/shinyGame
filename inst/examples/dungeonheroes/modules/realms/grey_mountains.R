  choose_grey_mountains <- function(event) {
    current_realm <<- "grey_mountains"
    move_realm_marker(current_realm)
    hide_map_navigation()
    show_controls_alert()
    game$activate_map(
      current_realm, player_name = "hero", x = 100, y = 100,
      hidden_objects = c(mushroom_swamps_objects, "talk_bubble_text")
    )
    enemy_status_text$set("enemies: none in grey mountains")
    set_combat_status("Explore the grey mountains.")
  }
