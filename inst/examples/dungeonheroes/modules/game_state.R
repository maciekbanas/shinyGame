  enemy_specs <- list(
    list(name = "mushroom_man_1", type = "mushroom_man", x = 1250, y = 1550, hit_points = 5, damage = 4, motion = "walk"),
    list(name = "mushroom_man_2", type = "mushroom_man", x = 850, y = 2150, hit_points = 5, damage = 4, motion = "walk"),
    list(name = "mushroom_man_3", type = "mushroom_man", x = 1750, y = 2450, hit_points = 5, damage = 5, motion = "walk"),
    list(name = "mushroom_man_4", type = "mushroom_man", x = 2650, y = 2350, hit_points = 6, damage = 5, motion = "walk"),
    list(name = "mushroom_man_5", type = "mushroom_man", x = 450, y = 3250, hit_points = 5, damage = 4, motion = "walk"),
    list(name = "mushroom_man_6", type = "mushroom_man", x = 1450, y = 3850, hit_points = 6, damage = 5, motion = "walk"),
    list(name = "mushroom_man_7", type = "mushroom_man", x = 2450, y = 3950, hit_points = 5, damage = 4, motion = "walk"),
    list(name = "mushroom_man_8", type = "mushroom_man", x = 2850, y = 4550, hit_points = 6, damage = 5, motion = "walk"),
    list(name = "mushroom_man_9", type = "mushroom_man", x = 950, y = 5250, hit_points = 5, damage = 4, motion = "walk"),
    list(name = "mushroom_man_10", type = "mushroom_man", x = 2150, y = 5550, hit_points = 6, damage = 5, motion = "walk"),
    list(name = "mushroom_man_11", type = "mushroom_man", x = 550, y = 1350, hit_points = 5, damage = 4, motion = "walk"),
    list(name = "mushroom_man_12", type = "mushroom_man", x = 1850, y = 1550, hit_points = 6, damage = 5, motion = "walk"),
    list(name = "mushroom_man_13", type = "mushroom_man", x = 1050, y = 2550, hit_points = 5, damage = 4, motion = "walk"),
    list(name = "mushroom_man_14", type = "mushroom_man", x = 1650, y = 2850, hit_points = 6, damage = 5, motion = "walk"),
    list(name = "mushroom_man_15", type = "mushroom_man", x = 2350, y = 3150, hit_points = 5, damage = 4, motion = "walk"),
    list(name = "mushroom_man_16", type = "mushroom_man", x = 3050, y = 3450, hit_points = 6, damage = 5, motion = "walk"),
    list(name = "mushroom_man_17", type = "mushroom_man", x = 850, y = 4050, hit_points = 5, damage = 4, motion = "walk"),
    list(name = "mushroom_man_18", type = "mushroom_man", x = 1550, y = 4650, hit_points = 6, damage = 5, motion = "walk"),
    list(name = "mushroom_man_19", type = "mushroom_man", x = 950, y = 5550, hit_points = 5, damage = 4, motion = "walk"),
    list(name = "mushroom_man_20", type = "mushroom_man", x = 3050, y = 5550, hit_points = 6, damage = 5, motion = "walk")
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
  enemy_damage_direction <- stats::setNames(
    rep("down", length(enemy_names)), enemy_names
  )
  wizard_in_range <- FALSE
  berry_in_range <- NULL
  hero_last_attack_time <- as.numeric(Sys.time()) - 1
  hero_attack_cooldown <- 0.75
  hero_weapons <- list(
    sword = list(damage = 2, knockback = 28),
    axe = list(damage = 2, knockback = 52),
    bow = list(damage = 2, knockback = 40)
  )
  hero_weapon <- NULL
  health_bar_segment_count <- 10
  health_bar_segment_width <- 18
  health_bar_segment_height <- 14
  health_bar_segment_gap <- 3
  game_over_shown <- FALSE
  defeated_enemy_count <- 0
  selected_character <- NULL
  current_realm <- "mushroom_swamps"

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
  mushroom_sight_range <- 500
  mushroom_approach_speed_multiplier <- 1.35
  mushroom_approach_distance_multiplier <- 2
  # Check every frame so noticing the hero never waits on the movement timer.
  mushroom_reaction_check_interval <- 16
  mushroom_alert_duration <- 1200
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
    mushroom_man_10 = list(speed = 50, distance = 105, lag = 0.7, interval = 2200),
    mushroom_man_11 = list(speed = 43, distance = 70, lag = 0.1, interval = 1350),
    mushroom_man_12 = list(speed = 49, distance = 95, lag = 0.3, interval = 1750),
    mushroom_man_13 = list(speed = 55, distance = 80, lag = 0.5, interval = 1550),
    mushroom_man_14 = list(speed = 61, distance = 110, lag = 0.2, interval = 2150),
    mushroom_man_15 = list(speed = 47, distance = 125, lag = 0.4, interval = 1950),
    mushroom_man_16 = list(speed = 53, distance = 85, lag = 0.6, interval = 1650),
    mushroom_man_17 = list(speed = 59, distance = 100, lag = 0.7, interval = 2350),
    mushroom_man_18 = list(speed = 45, distance = 115, lag = 0.3, interval = 1850),
    mushroom_man_19 = list(speed = 57, distance = 75, lag = 0.5, interval = 1450),
    mushroom_man_20 = list(speed = 51, distance = 105, lag = 0.8, interval = 2250)
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

    enemy_summaries <- vapply(living_enemy_names, function(enemy_name) {
      sprintf(
        "%s %d/%d",
        format_enemy_label(enemy_name),
        enemy_hit_points[[enemy_name]],
        enemy_max_hit_points[[enemy_name]]
      )
    }, character(1))

    enemy_status_text$set(paste("enemies:", paste(enemy_summaries, collapse = " | ")))
  }

  hero_attack_animation <- function() {
    if (identical(selected_character, "hero_orc")) {
      return("hero_orc_attack")
    }
    if (identical(selected_character, "hero_elf")) {
      return("hero_elf_idle")
    }
    "hero_sword_attack"
  }

  hero_attack_duration <- function() {
    # At four frames per second, the Orc needs 750 ms to display all three
    # attack frames before player controls resume the movement animation.
    if (identical(selected_character, "hero_orc")) 750 else 500
  }

  play_hero_attack_animation <- function() {
    hero$play_animation(
      hero_attack_animation(),
      duration = hero_attack_duration()
    )
  }
