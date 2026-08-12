  hero <- game$add_sprite(
    name = "hero",
    url = "assets/dungeonheroes/sprites/hero/human/hero_sword_idle.png",
    x = 100,
    y = 100,
    frame_width = 100,
    frame_height = 100,
    frame_count = 7,
    frame_rate = 4
  )
  hero$follow_camera()
  hero$set_depth(10)
  game$add_proximity_trigger("mushroom_swamps_exit", "hero", x = 100, y = 100,
                             element_id = "leave_map", context = "mushroom_swamps")
  game$add_proximity_trigger("magma_hills_exit", "hero", x = 1550, y = 650,
                             element_id = "leave_map", context = "magma_hills")
  game$add_proximity_trigger("wild_forests_exit", "hero", x = 100, y = 100,
                             element_id = "leave_map", context = "wild_forests")
  game$add_proximity_trigger("grey_mountains_exit", "hero", x = 100, y = 100,
                             element_id = "leave_map", context = "grey_mountains")
  Sys.sleep(0.1)
  game$enable_terrain_collision("hero")
  hero$add_animation(
    suffix = "move_down",
    url = "assets/dungeonheroes/sprites/hero/human/hero_move_down.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "move_up",
    url = "assets/dungeonheroes/sprites/hero/human/hero_move_up.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "move_left",
    url = "assets/dungeonheroes/sprites/hero/human/hero_move_left.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "move_right",
    url = "assets/dungeonheroes/sprites/hero/human/hero_move_right.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "attack",
    url = "assets/dungeonheroes/sprites/hero/human/hero_attack.png",
    frame_width = 100, frame_height = 100,
    frame_count = 2, frame_rate = 4
  )

  hero$add_animation(
    suffix = "orc_idle",
    url = "assets/dungeonheroes/sprites/hero/orc/hero_orc_idle.png",
    frame_width = 100, frame_height = 100,
    frame_count = 29, frame_rate = 4
  )
  lapply(c("down", "up", "left", "right"), function(direction) {
    hero$add_animation(
      suffix = paste0("orc_move_", direction),
      url = sprintf("assets/dungeonheroes/sprites/hero/orc/hero_orc_move_%s.png", direction),
      frame_width = 100, frame_height = 100,
      frame_count = 6, frame_rate = 8
    )
  })
  hero$add_animation(
    suffix = "orc_attack",
    url = "assets/dungeonheroes/sprites/hero/orc/hero_orc_attack.png",
    frame_width = 100, frame_height = 100,
    frame_count = 3, frame_rate = 4
  )
  lapply(c("down", "up", "left", "right"), function(direction) {
    hero$add_animation(
      suffix = paste0("orc_attack_", direction),
      url = sprintf("assets/dungeonheroes/sprites/hero/orc/hero_orc_attack_%s.png", direction),
      frame_width = 100, frame_height = 100,
      frame_count = 3, frame_rate = 4
    )
  })

  hero$add_animation(
    suffix = "elf_idle",
    url = "assets/dungeonheroes/sprites/hero/elf/hero_elf_idle.png",
    frame_width = 100, frame_height = 100,
    frame_count = 21, frame_rate = 4
  )
  lapply(c("down", "left", "right", "up"), function(direction) {
    source_direction <- if (direction %in% c("up", "down")) direction else "down"
    hero$add_animation(
      suffix = paste0("elf_move_", direction),
      url = sprintf("assets/dungeonheroes/sprites/hero/elf/hero_elf_move_%s.png", source_direction),
      frame_width = 100, frame_height = 100,
      frame_count = 4, frame_rate = 8
    )
  })

  hero$add_animation(
    suffix = "sword_idle",
    url = "assets/dungeonheroes/sprites/hero/human/hero_sword_idle.png",
    frame_width = 100, frame_height = 100,
    frame_count = 7, frame_rate = 4
  )
  hero$add_animation(
    suffix = "sword_move_down",
    url = "assets/dungeonheroes/sprites/hero/human/hero_sword_move_down.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "sword_move_up",
    url = "assets/dungeonheroes/sprites/hero/human/hero_sword_move_up.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "sword_move_left",
    url = "assets/dungeonheroes/sprites/hero/human/hero_sword_move_left.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "sword_move_right",
    url = "assets/dungeonheroes/sprites/hero/human/hero_sword_move_right.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "sword_attack",
    url = "assets/dungeonheroes/sprites/hero/human/hero_sword_attack.png",
    frame_width = 100, frame_height = 100,
    frame_count = 2, frame_rate = 4
  )
  lapply(c("left", "right"), function(direction) {
    hero$add_animation(
      suffix = paste0("sword_attack_", direction),
      url = sprintf("assets/dungeonheroes/sprites/hero/human/hero_sword_attack_%s.png", direction),
      frame_width = 100, frame_height = 100,
      frame_count = 2, frame_rate = 4
    )
  })
