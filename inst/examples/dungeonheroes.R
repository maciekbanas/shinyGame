devtools::load_all()

game <- PhaserGame$new(width = 1600, height = 800)
map_tile_size <- 100
map_tile_width <- 32
map_tile_height <- 64
world_width <- map_tile_width * map_tile_size
world_height <- map_tile_height * map_tile_size
shinyphaser_version <- as.character(utils::packageVersion("shinyphaser"))
dungeonheroes_version <- read.dcf("DESCRIPTION", fields = "Version")[[1]]

ui <- shiny::tagList(
  game$use_phaser()
)

server <- function(input, output, session) {

  enemy_specs <- list(
    list(name = "mushroom_man_1", type = "mushroom_man", x = 150, y = 1850, hit_points = 2, damage = 4, motion = "walk"),
    list(name = "mushroom_man_2", type = "mushroom_man", x = 850, y = 2150, hit_points = 2, damage = 4, motion = "attack"),
    list(name = "mushroom_man_3", type = "mushroom_man", x = 1750, y = 2450, hit_points = 2, damage = 5, motion = "walk"),
    list(name = "mushroom_man_4", type = "mushroom_man", x = 2650, y = 2350, hit_points = 3, damage = 5, motion = "attack"),
    list(name = "mushroom_man_5", type = "mushroom_man", x = 450, y = 3250, hit_points = 2, damage = 4, motion = "walk"),
    list(name = "mushroom_man_6", type = "mushroom_man", x = 1450, y = 3850, hit_points = 3, damage = 5, motion = "attack"),
    list(name = "mushroom_man_7", type = "mushroom_man", x = 2450, y = 3950, hit_points = 2, damage = 4, motion = "walk"),
    list(name = "mushroom_man_8", type = "mushroom_man", x = 2850, y = 4550, hit_points = 3, damage = 5, motion = "attack"),
    list(name = "mushroom_man_9", type = "mushroom_man", x = 950, y = 5250, hit_points = 2, damage = 4, motion = "walk"),
    list(name = "mushroom_man_10", type = "mushroom_man", x = 2150, y = 5550, hit_points = 3, damage = 5, motion = "attack"),
    list(name = "skeleton", type = "skeleton", x = 2850, y = 2150, hit_points = 6, damage = 16, motion = "idle"),
    list(name = "skeleton_2", type = "skeleton", x = 3050, y = 2250, hit_points = 7, damage = 18, motion = "idle"),
    list(name = "skeleton_3", type = "skeleton", x = 2700, y = 2350, hit_points = 7, damage = 20, motion = "idle"),
    list(name = "skeleton_4", type = "skeleton", x = 3000, y = 2650, hit_points = 8, damage = 22, motion = "idle")
  )
  enemy_names <- vapply(enemy_specs, `[[`, character(1), "name")

  wizard_laugh_sound <- game$add_sound(
    name = "wizard_laugh",
    url = "assets/dungeonheroes/sounds/wizard_laugh.wav"
  )

  hero_attack_sound <- game$add_sound(
    name = "hero_attack",
    url = "assets/dungeonheroes/sounds/attack.wav"
  )

  max_life_points <- 100
  life_points <- max_life_points
  enemy_max_hit_points <- stats::setNames(
    vapply(enemy_specs, `[[`, numeric(1), "hit_points"),
    enemy_names
  )
  enemy_hit_points <- enemy_max_hit_points
  enemy_is_alive <- stats::setNames(rep(TRUE, length(enemy_names)), enemy_names)
  enemy_last_attack_time <- stats::setNames(
    rep(as.numeric(Sys.time()) - 2, length(enemy_names)),
    enemy_names
  )
  enemy_damage <- stats::setNames(
    vapply(enemy_specs, `[[`, numeric(1), "damage"),
    enemy_names
  )
  enemy_attack_cooldown <- 2
  enemy_in_range <- NULL
  wizard_in_range <- FALSE
  sword_in_range <- FALSE
  has_sword <- FALSE
  hero_last_attack_time <- as.numeric(Sys.time()) - 1
  hero_attack_cooldown <- 0.75
  hero_fist_damage <- 1
  hero_sword_damage <- 2
  health_bar_segment_count <- 10
  health_bar_segment_width <- 18
  health_bar_segment_height <- 14
  health_bar_segment_gap <- 3
  game_over_shown <- FALSE
  wizard_is_talking <- FALSE
  defeated_enemy_count <- 0

  show_intro_alerts <- function() {
    shinyalert::shinyalert(
      title = "Welcome to the game, dungeon hero!",
      type = "success",
      callbackR = function(value) {
        shinyalert::shinyalert(
          title = "Use arrows to move and space to attack or interact",
          type = "info"
        )
      }
    )
  }

  session$onFlushed(show_intro_alerts, once = TRUE)

  enemy_animation_key <- function(enemy_name, suffix) {
    paste(enemy_name, suffix, sep = "_")
  }

  format_enemy_label <- function(enemy_name) {
    gsub("_", " ", enemy_name)
  }

  enemy_type <- stats::setNames(
    vapply(enemy_specs, `[[`, character(1), "type"),
    enemy_names
  )
  enemy_motion <- stats::setNames(
    vapply(enemy_specs, `[[`, character(1), "motion"),
    enemy_names
  )
  mushroom_enemy_names <- enemy_names[enemy_type == "mushroom_man"]
  mushroom_motion_specs <- list(
    mushroom_man_1 = list(speed = 42, distance = 70, lag = 0.0, interval = 1300),
    mushroom_man_2 = list(speed = 48, distance = 95, lag = 0.2, interval = 1700),
    mushroom_man_3 = list(speed = 54, distance = 80, lag = 0.4, interval = 1500),
    mushroom_man_4 = list(speed = 60, distance = 110, lag = 0.1, interval = 2100),
    mushroom_man_5 = list(speed = 46, distance = 125, lag = 0.3, interval = 1900),
    mushroom_man_6 = list(speed = 52, distance = 85, lag = 0.5, interval = 1600),
    mushroom_man_7 = list(speed = 58, distance = 100, lag = 0.6, interval = 2300),
    mushroom_man_8 = list(speed = 44, distance = 115, lag = 0.2, interval = 1800),
    mushroom_man_9 = list(speed = 56, distance = 75, lag = 0.4, interval = 1400),
    mushroom_man_10 = list(speed = 50, distance = 105, lag = 0.7, interval = 2200)
  )

  set_combat_status <- function(message) {
    combat_status_text$set(message)
  }

  update_life_points <- function() {
    visible_segments <- ceiling(life_points / max_life_points * health_bar_segment_count)

    lapply(seq_len(health_bar_segment_count), function(segment_index) {
      if (segment_index <= visible_segments) {
        health_bar_segments[[segment_index]]$show()
      } else {
        health_bar_segments[[segment_index]]$hide()
      }
    })
  }

  update_enemy_status <- function() {
    living_enemy_names <- enemy_names[enemy_is_alive]
    if (length(living_enemy_names) == 0) {
      enemy_status_text$set("enemies: defeated")
      return()
    }

    enemy_summaries <- vapply(living_enemy_names, function(skeleton_name) {
      sprintf(
        "%s %d/%d",
        format_enemy_label(skeleton_name),
        enemy_hit_points[[skeleton_name]],
        enemy_max_hit_points[[skeleton_name]]
      )
    }, character(1))

    enemy_status_text$set(paste("enemies:", paste(enemy_summaries, collapse = " | ")))
  }

  nearest_living_enemy <- function() {
    if (!is.null(enemy_in_range) && isTRUE(enemy_is_alive[[enemy_in_range]])) {
      return(enemy_in_range)
    }

    NULL
  }

  hero_idle_animation <- function() {
    if (has_sword) {
      return("hero_sword")
    }

    "hero"
  }

  play_hero_idle_animation <- function() {
    hero$play_animation(hero_idle_animation())
  }

  play_hero_timed_animation <- function(animation_name, duration = 500) {
    hero$play_animation(animation_name, duration = duration)
    later::later(
      function() {
        if (life_points > 0) {
          play_hero_idle_animation()
        }
      },
      delay = duration / 1000
    )
  }

  game$set_shiny_session()

  game$set_world_bounds(world_width, world_height)

  game$add_map(
    map_key = "mushroom_swamps",
    map_url = "assets/dungeonheroes/maps/mushroom_swamps.json",
    tileset_urls = c(
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_grass_1.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_1.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_bottom.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_bottom_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_left.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_left_bottom.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_left_bottom_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_top_bottom_left_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_top_left.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_top_left_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_top_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_top.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_top_bottom.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_top_bottom_left.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_top_bottom_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_bank_left_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_grass_2.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_grass_3.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_grass_4.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_grass_5.png"
    ),
    tileset_names = c(
      "mushroom_swamps_grass_1",
      "mushroom_swamps_swamp_1",
      "mushroom_swamps_swamp_bank_bottom",
      "mushroom_swamps_swamp_bank_bottom_right",
      "mushroom_swamps_swamp_bank_left",
      "mushroom_swamps_swamp_bank_left_bottom",
      "mushroom_swamps_swamp_bank_left_bottom_right",
      "mushroom_swamps_swamp_bank_right",
      "mushroom_swamps_swamp_bank_top_bottom_left_right",
      "mushroom_swamps_swamp_bank_top_left",
      "mushroom_swamps_swamp_bank_top_left_right",
      "mushroom_swamps_swamp_bank_top_right",
      "mushroom_swamps_swamp_bank_top",
      "mushroom_swamps_swamp_bank_top_bottom",
      "mushroom_swamps_swamp_bank_top_bottom_left",
      "mushroom_swamps_swamp_bank_top_bottom_right",
      "mushroom_swamps_swamp_bank_left_right",
      "mushroom_swamps_grass_2",
      "mushroom_swamps_grass_3",
      "mushroom_swamps_grass_4",
      "mushroom_swamps_grass_5"
    ),
    layer_name = "terrain"
  )
  hero <- game$add_sprite(
    name = "hero",
    url = "assets/dungeonheroes/sprites/hero_idle.png",
    x = 100,
    y = 100,
    frame_width = 100,
    frame_height = 100,
    frame_count = 7,
    frame_rate = 4
  )
  hero$add_player_controls()
  hero$follow_camera()
  Sys.sleep(0.1)
  game$enable_terrain_collision("hero")
  hero$add_animation(
    suffix = "move_down",
    url = "assets/dungeonheroes/sprites/hero_move_down.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "move_up",
    url = "assets/dungeonheroes/sprites/hero_move_up.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "move_left",
    url = "assets/dungeonheroes/sprites/hero_move_left.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "move_right",
    url = "assets/dungeonheroes/sprites/hero_move_right.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "attack",
    url = "assets/dungeonheroes/sprites/hero_attack.png",
    frame_width = 100, frame_height = 100,
    frame_count = 2, frame_rate = 4
  )

  hero$add_animation(
    suffix = "sword_idle",
    url = "assets/dungeonheroes/sprites/hero_sword_idle.png",
    frame_width = 100, frame_height = 100,
    frame_count = 7, frame_rate = 4
  )
  hero$add_animation(
    suffix = "sword_move_down",
    url = "assets/dungeonheroes/sprites/hero_sword_move_down.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "sword_move_up",
    url = "assets/dungeonheroes/sprites/hero_sword_move_up.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "sword_move_left",
    url = "assets/dungeonheroes/sprites/hero_sword_move_left.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "sword_move_right",
    url = "assets/dungeonheroes/sprites/hero_sword_move_right.png",
    frame_width = 100, frame_height = 100,
    frame_count = 4, frame_rate = 8
  )
  hero$add_animation(
    suffix = "sword_attack",
    url = "assets/dungeonheroes/sprites/hero_sword_attack.png",
    frame_width = 100, frame_height = 100,
    frame_count = 2, frame_rate = 4
  )

  enemies <- stats::setNames(lapply(enemy_specs, function(spec) {
    if (identical(spec$type, "mushroom_man")) {
      enemy <- game$add_sprite(
        name = spec$name,
        url = "assets/dungeonheroes/sprites/mushroom_man_walk.png",
        x = spec$x,
        y = spec$y,
        frame_width = 100,
        frame_height = 100,
        frame_count = 12,
        frame_rate = 8
      )

      enemy$add_animation(
        suffix = "attack",
        url = "assets/dungeonheroes/sprites/mushroom_man_attack.png",
        frame_width = 100, frame_height = 100,
        frame_count = 6, frame_rate = 6
      )

      if (identical(spec$motion, "attack")) {
        enemy$play_animation(enemy_animation_key(spec$name, "attack"))
      }
    } else {
      enemy <- game$add_sprite(
        name = spec$name,
        url = "assets/dungeonheroes/sprites/skeleton_idle.png",
        x = spec$x,
        y = spec$y,
        frame_width = 100,
        frame_height = 100,
        frame_count = 8,
        frame_rate = 4
      )

      enemy$add_animation(
        suffix = "attack",
        url = "assets/dungeonheroes/sprites/skeleton_attack.png",
        frame_width = 100, frame_height = 100,
        frame_count = 2, frame_rate = 4
      )
    }

    enemy
  }), enemy_names)

  lapply(mushroom_enemy_names, function(enemy_name) {
    game$enable_terrain_collision(enemy_name)
  })

  lapply(mushroom_enemy_names, function(enemy_name) {
    motion_spec <- mushroom_motion_specs[[enemy_name]]
    force(enemy_name)
    force(motion_spec)

    shiny::observe({
      shiny::invalidateLater(motion_spec$interval, session)

      if (!isTRUE(enemy_is_alive[[enemy_name]])) {
        return(NULL)
      }

      direction <- sample(
        list(c(-1, 0), c(1, 0), c(0, -1), c(0, 1)),
        1
      )[[1]]
      enemies[[enemy_name]]$set_in_motion(
        dir_x = direction[1],
        dir_y = direction[2],
        speed = motion_spec$speed,
        distance = motion_spec$distance,
        lag = motion_spec$lag
      )
    })
  })

  game$add_control(
    "Space",
    action = function() {
      if (life_points <= 0) {
        set_combat_status("You are defeated and cannot fight.")
        return()
      }

      if (sword_in_range && !has_sword) {
        has_sword <<- TRUE
        sword_in_range <<- FALSE
        sword$destroy()
        inventory_text$set("weapon: sword")
        set_combat_status("You equipped the sword. Your attacks are stronger.")
        play_hero_idle_animation()
      } else {
        current_time <- as.numeric(Sys.time())
        if ((current_time - hero_last_attack_time) < hero_attack_cooldown) {
          set_combat_status("You need a moment before attacking again.")
          return()
        }

        hero_last_attack_time <<- current_time

        target_name <- nearest_living_enemy()
        if (!is.null(target_name)) {
          attack_damage <- if (has_sword) hero_sword_damage else hero_fist_damage
          enemy_hit_points[target_name] <<- max(
            enemy_hit_points[[target_name]] - attack_damage,
            0
          )

          if (enemy_hit_points[[target_name]] <= 0) {
            enemy_is_alive[target_name] <<- FALSE
            enemies[[target_name]]$destroy()
            enemy_in_range <<- NULL
            defeated_enemy_count <<- defeated_enemy_count + 1
            set_combat_status(sprintf(
              "You defeated %s (%d/%d defeated).",
              format_enemy_label(target_name),
              defeated_enemy_count,
              length(enemy_names)
            ))
          } else {
            set_combat_status(sprintf(
              "You hit %s for %d damage.",
              format_enemy_label(target_name),
              attack_damage
            ))
          }
          update_enemy_status()
        } else {
          set_combat_status("Your attack hits only air.")
        }
      }
      if (wizard_in_range) {
        # Wizard feedback is handled immediately in the browser; server state remains available here.
      }
    },
    input,
    client_action = dungeonheroes_space_client_actions(hero_attack_cooldown, enemy_names)
  )

  inventory_text <- game$add_text(
    text = "weapon: none",
    id = "inventory_weapon",
    x = 1200,
    y = 85
  )
  inventory_text$set_scroll_factor(0)
  lapply(seq_len(health_bar_segment_count), function(segment_index) {
    segment_x <- 1200 + ((segment_index - 1) * (health_bar_segment_width + health_bar_segment_gap))
    game$add_rectangle(
      name = sprintf("life_bar_red_%02d", segment_index),
      x = segment_x,
      y = 60,
      width = health_bar_segment_width,
      height = health_bar_segment_height,
      color = "0xc0392b"
    )$set_scroll_factor(0)
  })
  health_bar_segments <- lapply(seq_len(health_bar_segment_count), function(segment_index) {
    segment_x <- 1200 + ((segment_index - 1) * (health_bar_segment_width + health_bar_segment_gap))
    life_bar <- game$add_rectangle(
      name = sprintf("life_bar_green_%02d", segment_index),
      x = segment_x,
      y = 60,
      width = health_bar_segment_width,
      height = health_bar_segment_height,
      color = "0x2ecc71"
    )
    life_bar$set_scroll_factor(0)
    life_bar
  })
  update_life_points()
  enemy_status_text <- game$add_text(
    text = "enemies: loading",
    id = "enemy_status",
    x = 1200,
    y = 120
  )
  enemy_status_text$set_scroll_factor(0)
  combat_status_text <- game$add_text(
    text = "combat: find a weapon, then face the enemies",
    id = "combat_status",
    x = 800,
    y = 660
  )
  combat_status_text$set_scroll_factor(0)
  update_enemy_status()
  version_text <- game$add_text(
    text = sprintf("dungeonheroes v%s | shinyphaser v%s", dungeonheroes_version, shinyphaser_version),
    id = "game_version",
    x = 50,
    y = 660
  )
  version_text$set_scroll_factor(0)

  sword <- game$add_static_sprite(
    name = "sword",
    url = "assets/dungeonheroes/weapons/sword.png",
    x = 300,
    y = 300
  )
  game$add_overlap(
    object_one = "hero",
    object_two = "sword",
    callback_fun = function(evt) {
      if (!has_sword) {
        sword_in_range <<- TRUE
      }
    },
    input = input
  )
  game$add_overlap_end(
    object_one = "hero",
    object_two = "sword",
    callback_fun = function(evt) {
      sword_in_range <<- FALSE
    },
    input = input
  )

  wizard <- game$add_sprite(
    name = "wizard",
    url = "assets/dungeonheroes/sprites/wizard_idle.png",
    x = 1600,
    y = 800,
    frame_width = 100,
    frame_height = 100,
    frame_count = 17,
    frame_rate = 4
  )
  wizard$add_animation(
    suffix = "talk",
    url = "assets/dungeonheroes/sprites/wizard_talk.png",
    frame_width = 100, frame_height = 100,
    frame_count = 2, frame_rate = 4
  )

  talk_bubble_text <- game$add_text(
    text = "...",
    id = "talk_bubble_text",
    x = 1600,
    y = 693,
    visible = FALSE
  )
  game$add_overlap(
    object_one = "hero",
    object_two = "wizard",
    callback_fun = function(evt) {
      talk_bubble_text$show()
      wizard_in_range <<- TRUE
      if (!wizard_is_talking) {
        wizard_is_talking <<- TRUE
        wizard$play_animation("wizard_talk", 2e3)
      }
    },
    input = input
  )
  game$add_overlap_end(
    object_one = "hero",
    object_two = "wizard",
    callback_fun = function(evt) {
      talk_bubble_text$hide()
      wizard_in_range <<- FALSE
      wizard_is_talking <<- FALSE
      wizard$play_animation("wizard_idle")
    },
    input = input
  )

  add_enemy_handlers <- function(skeleton_name) {
    force(skeleton_name)

    game$add_overlap(
      object_one = "hero",
      object_two = skeleton_name,
      callback_fun = function(evt) {
        enemy_in_range <<- skeleton_name
        if (!isTRUE(enemy_is_alive[[skeleton_name]])) {
          return()
        }

        current_time <- as.numeric(Sys.time())
        if ((current_time - enemy_last_attack_time[[skeleton_name]]) >= enemy_attack_cooldown) {
          enemy_last_attack_time[skeleton_name] <<- current_time
          enemies[[skeleton_name]]$play_animation(
            enemy_animation_key(skeleton_name, "attack"),
            duration = 350
          )
          damage <- enemy_damage[[skeleton_name]]
          life_points <<- max(life_points - damage, 0)
          update_life_points()
          set_combat_status(sprintf(
            "%s strikes you for %d damage.",
            format_enemy_label(skeleton_name),
            damage
          ))
          if (life_points <= 0 && !game_over_shown) {
            game_over_shown <<- TRUE
            shinyalert::shinyalert(
              title = "Game Over",
              text = "You have been defeated.",
              type = "error"
            )
          }
        }
      },
      input = input
    )

    game$add_overlap_end(
      object_one = "hero",
      object_two = skeleton_name,
      callback_fun = function(evt) {
        if (identical(enemy_in_range, skeleton_name)) {
          enemy_in_range <<- NULL
        }
        if (isTRUE(enemy_is_alive[[skeleton_name]])) {
          enemies[[skeleton_name]]$play_animation(enemy_animation_key(skeleton_name, enemy_motion[[skeleton_name]]))
        }
      },
      input = input
    )
  }

  lapply(enemy_names, add_enemy_handlers)
}


dungeonheroes_space_client_actions <- function(hero_attack_cooldown, enemy_names) {
  enemy_hit_feedback <- lapply(enemy_names, function(enemy_name) {
    list(
      set_text = list(
        id = "combat_status",
        text = sprintf("You strike %s.", gsub("_", " ", enemy_name))
      ),
      when_overlap = c("hero", enemy_name),
      when_exists = enemy_name
    )
  })

  c(
    list(
      list(
        destroy_sprite = "sword",
        set_text = list(id = "inventory_weapon", text = "weapon: sword"),
        sprite = "hero",
        play_animation = "hero_sword_idle",
        when_overlap = c("hero", "sword"),
        when_exists = "sword",
        stop_after_match = TRUE
      ),
      list(
        play_sound = "wizard_laugh",
        show_alert = list(
          title = "Dear, oh dear. What are you doing here in these dark forests, lad?",
          text = "",
          type = "info"
        ),
        when_overlap = c("hero", "wizard"),
        cooldown = 1000,
        stop_after_match = TRUE
      )
    ),
    enemy_hit_feedback,
    list(
      list(
        play_sound = "hero_attack",
        sprite = "hero",
        play_animation = "hero_attack",
        duration = 500,
        cooldown = hero_attack_cooldown * 1000,
        when_exists = list(name = "sword", exists = TRUE)
      ),
      list(
        play_sound = "hero_attack",
        sprite = "hero",
        play_animation = "hero_sword_attack",
        duration = 500,
        cooldown = hero_attack_cooldown * 1000,
        when_exists = list(name = "sword", exists = FALSE)
      )
    )
  )
}



shiny::shinyApp(ui, server)
