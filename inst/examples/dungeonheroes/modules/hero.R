  hero <- game$add_sprite(
    name = "hero",
    url = "assets/dungeonheroes/sprites/hero/orc/hero_orc_idle.png",
    x = 100, y = 100,
    frame_width = 100, frame_height = 100,
    frame_count = 29, frame_rate = 4
  )
  hero$follow_camera()
  hero$set_depth(10)
  Sys.sleep(0.1)
  game$enable_terrain_collision("hero")

  lapply(c("down", "up", "left", "right"), function(direction) {
    hero$add_animation(
      suffix = paste0("move_", direction),
      url = sprintf("assets/dungeonheroes/sprites/hero/orc/hero_orc_move_%s.png", direction),
      frame_width = 100, frame_height = 100,
      frame_count = 6, frame_rate = 8
    )
  })
  hero$add_animation(
    suffix = "attack",
    url = "assets/dungeonheroes/sprites/hero/orc/hero_orc_attack.png",
    frame_width = 100, frame_height = 100,
    frame_count = 3, frame_rate = 4
  )
  lapply(c("down", "up", "left", "right"), function(direction) {
    hero$add_animation(
      suffix = paste0("attack_", direction),
      url = sprintf("assets/dungeonheroes/sprites/hero/orc/hero_orc_attack_%s.png", direction),
      frame_width = 100, frame_height = 100,
      frame_count = 3, frame_rate = 4
    )
  })
