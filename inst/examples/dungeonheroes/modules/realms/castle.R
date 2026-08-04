  blacksmith <- game$add_sprite(
    name = "blacksmith",
    url = "assets/dungeonheroes/sprites/npc/blacksmith/blacksmith.png",
    x = 800, y = 400,
    frame_width = 100, frame_height = 100,
    frame_count = 72, frame_rate = 8
  )
  session$sendCustomMessage(
    "phaser",
    list(js = "withSprite('blacksmith', function(sprite) { sprite.setVisible(false).setActive(false); if (sprite.body) sprite.body.enable = false; });")
  )

  choose_castle <- function(event) {
    current_realm <<- "castle"
    move_realm_marker(current_realm)
    hide_map_navigation()
    game$activate_map(
      current_realm, player_name = "hero", x = 700, y = 500,
      visible_objects = "blacksmith",
      hidden_objects = c(mushroom_swamps_objects, "talk_bubble_text")
    )
    enemy_status_text$set("enemies: none in the castle")
    set_combat_status("The castle blacksmith is at his forge.")
  }
