  enemies <- stats::setNames(lapply(enemy_specs, function(spec) {
    enemy <- game$add_sprite(
      name = spec$name,
      url = "assets/dungeonheroes/sprites/enemies/mushroom_man/mushroom_man_idle.png",
      x = spec$x,
      y = spec$y,
      frame_width = 100,
      frame_height = 100,
      frame_count = 8,
      frame_rate = 8
    )

    lapply(c("down", "left", "right", "up"), function(direction) {
      enemy$add_animation(
        suffix = paste0("move_", direction),
        url = sprintf("assets/dungeonheroes/sprites/enemies/mushroom_man/mushroom_man_walk_%s.png", direction),
        frame_width = 100, frame_height = 100,
        frame_count = 2, frame_rate = 8
      )
    })

    lapply(c("down", "left", "right", "up"), function(direction) {
      enemy$add_animation(
        suffix = paste0("damage_", direction),
        url = sprintf("assets/dungeonheroes/sprites/enemies/mushroom_man/mushroom_man_damage_%s.png", direction),
        frame_width = 100, frame_height = 100,
        frame_count = 3, frame_rate = 8
      )
    })

    enemy$add_animation(
      suffix = "attack",
      url = "assets/dungeonheroes/sprites/enemies/mushroom_man/mushroom_man_attack.png",
      frame_width = 100, frame_height = 100,
      frame_count = 4, frame_rate = 6
    )
    lapply(c("left", "right"), function(direction) {
      enemy$add_animation(
        suffix = paste0("attack_", direction),
        url = sprintf("assets/dungeonheroes/sprites/enemies/mushroom_man/mushroom_man_attack_%s.png", direction),
        frame_width = 100, frame_height = 100,
        frame_count = 4, frame_rate = 6
      )
    })
    enemy$add_animation(
      suffix = "destroy",
      url = "assets/dungeonheroes/sprites/enemies/mushroom_man/mushroom_man_destroy.png",
      frame_width = 100, frame_height = 100,
      frame_count = 4, frame_rate = 8
    )

    enemy
  }), enemy_names)

  lapply(enemy_names, function(enemy_name) {
    game$enable_terrain_collision(enemy_name)
  })

  lapply(mushroom_enemy_names, function(enemy_name) {
    motion_spec <- mushroom_motion_specs[[enemy_name]]
    enemies[[enemy_name]]$start_approach_on_sight(
      target_name = "hero",
      sight_range = mushroom_sight_range,
      speed = motion_spec$speed * mushroom_approach_speed_multiplier,
      distance = motion_spec$distance * mushroom_approach_distance_multiplier,
      check_interval = mushroom_reaction_check_interval,
      alert_duration = mushroom_alert_duration,
      wander_interval = motion_spec$interval
    )
  })

  handle_space <- function(event) {
      if (life_points <= 0) return(invisible(NULL))

      if (!is.null(berry_in_range) && isTRUE(berry_is_available[[berry_in_range]])) {
        consumed_berry <- berry_in_range
        restored_life <- min(10, max_life_points - life_points)
        life_points <<- min(max_life_points, life_points + 10)
        berry_is_available[[consumed_berry]] <<- FALSE
        berry_in_range <<- NULL
        berries[[consumed_berry]]$destroy()
        update_life_points()
        set_combat_status(sprintf(
          "You ate berries and restored %d life. Life: %d/%d",
          restored_life, life_points, max_life_points
        ))
        return(invisible(NULL))
      }

      if (wizard_in_range) {
        shinyalert::shinyalert(
          title = "Dear, oh dear. What are you doing here in these dark forests, lad?",
          type = "info",
          callbackR = function(value) shinyalert::shinyalert(
            title = "There is a good spirit waiting to be saved!",
            type = "info"
          )
        )
        return(invisible(NULL))
      }

      now <- as.numeric(Sys.time())
      if (now - hero_last_attack_time < hero_attack_cooldown) return(invisible(NULL))
      hero_last_attack_time <<- now
      hero_attack_sound$play()

      if (!is.null(enemy_in_range) && isTRUE(enemy_is_alive[[enemy_in_range]])) {
        hit_enemy <- enemy_in_range
        damage <- hero_weapon$damage
        enemy_hit_points[[hit_enemy]] <<- max(0, enemy_hit_points[[hit_enemy]] - damage)
        play_hero_attack_animation()
        knockback_direction <- enemy_damage_direction[[hit_enemy]]
        knockback_vector <- switch(knockback_direction,
          left = c(-1, 0), right = c(1, 0), up = c(0, -1), c(0, 1)
        )
        enemies[[hit_enemy]]$stop_motion()
        enemies[[hit_enemy]]$set_in_motion(
          dir_x = knockback_vector[[1]],
          dir_y = knockback_vector[[2]],
          # play_animation() queues after 100 ms; keep the generic movement
          # active for the same total window as all three damage frames.
          speed = ceiling(hero_weapon$knockback / 0.475),
          distance = hero_weapon$knockback,
          lag = 0
        )
        enemies[[hit_enemy]]$play_animation(
          enemy_animation_key(hit_enemy, paste0("damage_", knockback_direction)),
          duration = 375
        )
        set_combat_status(sprintf(
          "You hit %s for %d. Enemy life: %d/%d",
          format_enemy_label(hit_enemy), damage,
          enemy_hit_points[[hit_enemy]], enemy_max_hit_points[[hit_enemy]]
        ))

        if (enemy_hit_points[[hit_enemy]] <= 0) {
          defeated <- hit_enemy
          enemy_is_alive[[defeated]] <<- FALSE
          defeated_enemy_count <<- defeated_enemy_count + 1
          later::later(function() {
            enemies[[defeated]]$play_animation(
              enemy_animation_key(defeated, "destroy"), duration = 500
            )
          }, delay = 0.275)
          later::later(function() enemies[[defeated]]$destroy(), delay = 0.875)
          enemy_in_range <<- NULL
        }
        update_enemy_status()
      } else {
        play_hero_attack_animation()
      }

  }

  game$add_control(
    "Space",
    server_action = handle_space,
    input = input
  )

  inventory_text <- game$add_text(
    text = "weapon: waiting for character",
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
    text = "combat: face the enemies and protect the realms",
    id = "combat_status",
    x = 800,
    y = 660
  )
  combat_status_text$set_scroll_factor(0)
  update_enemy_status()
  version_text <- game$add_text(
    text = sprintf("shinyphaser v%s", shinyphaser_version),
    id = "game_version",
    x = 50,
    y = 660
  )
  version_text$set_scroll_factor(0)

  dead_tree_bottom <- game$add_static_sprite(
    name = "dead_tree_1_bottom",
    url = "assets/dungeonheroes/terrain/mushroom_swamps/dead_tree_1_bottom.png",
    x = 550,
    y = 650
  )
  dead_tree_bottom$set_depth(10)

  dead_tree_top <- game$add_image(
    name = "dead_tree_1_top",
    url = "assets/dungeonheroes/terrain/mushroom_swamps/dead_tree_1_top.png",
    x = 550,
    y = 650 - map_tile_size
  )
  dead_tree_top$set_depth(20)

  game$add_collider("hero", "dead_tree_1_bottom")

  berry_specs <- list(
    berries_1 = c(x = 650, y = 650),
    berries_2 = c(x = 1450, y = 1650),
    berries_3 = c(x = 2550, y = 2250),
    berries_4 = c(x = 1150, y = 3150),
    berries_5 = c(x = 2050, y = 3850),
    berries_6 = c(x = 2850, y = 4750),
    berries_7 = c(x = 450, y = 5450),
    berries_8 = c(x = 1550, y = 5550),
    berries_9 = c(x = 2450, y = 5850),
    berries_10 = c(x = 2950, y = 6350)
  )
  berry_is_available <- stats::setNames(
    rep(TRUE, length(berry_specs)),
    names(berry_specs)
  )
  berries <- lapply(names(berry_specs), function(berry_name) {
    position <- berry_specs[[berry_name]]
    game$add_static_sprite(
      name = berry_name,
      url = "assets/dungeonheroes/perks/berries.png",
      x = position[["x"]],
      y = position[["y"]]
    )
  })
  names(berries) <- names(berry_specs)

  add_berry_handlers <- function(berry_names) lapply(berry_names, function(berry_name) {
    force(berry_name)
    game$add_overlap(
      "hero", berry_name, input = input,
      server_action = function(event) {
        if (isTRUE(berry_is_available[[berry_name]])) berry_in_range <<- berry_name
      }
    )
    game$add_overlap_end(
      "hero", berry_name, input = input, session = session,
      server_action = function(event) {
        if (identical(berry_in_range, berry_name)) berry_in_range <<- NULL
      }
    )
  })
  add_berry_handlers(names(berries))

  mushroom_swamps_berry_names <- names(berries)


  wizard <- game$add_sprite(
    name = "wizard",
    url = "assets/dungeonheroes/sprites/npc/wizard/wizard_idle.png",
    x = 1600,
    y = 800,
    frame_width = 100,
    frame_height = 100,
    frame_count = 17,
    frame_rate = 4
  )
  wizard$add_animation(
    suffix = "talk",
    url = "assets/dungeonheroes/sprites/npc/wizard/wizard_talk.png",
    frame_width = 100, frame_height = 100,
    frame_count = 2, frame_rate = 4
  )

  mushroom_spirit <- game$add_sprite(
    name = "mushroom_spirit",
    url = "assets/dungeonheroes/sprites/npc/mushroom_spirit/mushroom_spirit.png",
    x = 2850,
    y = 5850,
    frame_width = 32,
    frame_height = 32,
    frame_count = 14,
    frame_rate = 8
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
    input = input,
    browser_action = browser_actions({
      talk_bubble_text$show()
      wizard$play_animation("talk", duration = 2000)
      wizard_laugh_sound$play()
    }),
    server_action = function(event) wizard_in_range <<- TRUE
  )
  game$add_overlap_end(
    object_one = "hero",
    object_two = "wizard",
    input = input,
    browser_action = browser_actions({
      talk_bubble_text$hide()
      wizard$play_animation("idle")
    }),
    server_action = function(event) wizard_in_range <<- FALSE
  )

  game$add_overlap(
    object_one = "hero",
    object_two = "mushroom_spirit",
    input = input,
    browser_action = browser_actions(mushroom_spirit$destroy()),
    server_action = function(event) {
      shinyalert::shinyalert(
        title = "Mushroom spirit saved!",
        text = "The good spirit is safe. You win!",
        type = "success",
        closeOnClickOutside = FALSE,
        showCancelButton = FALSE
      )
    }
  )

  add_enemy_handlers <- function(enemy_name) {
    force(enemy_name)

    game$add_overlap(
      object_one = "hero",
      object_two = enemy_name,
      input = input,
      browser_action = browser_actions({
        enemies[[enemy_name]]$stop_motion()
        enemies[[enemy_name]]$play_animation(
          enemy_animation_key(enemy_name, "attack"),
          duration = enemy_attack_cooldown * 1000
        )
      }),
      mode = "stay",
      interval = enemy_attack_cooldown * 1000,
      server_action = function(event) {
        enemy_in_range <<- enemy_name
        delta_x <- event$x2 - event$x1
        delta_y <- event$y2 - event$y1
        enemy_damage_direction[[enemy_name]] <<- if (abs(delta_x) > abs(delta_y)) {
          if (delta_x < 0) "left" else "right"
        } else {
          if (delta_y < 0) "up" else "down"
        }
        now <- as.numeric(Sys.time())
        if (life_points <= 0 || !isTRUE(enemy_is_alive[[enemy_name]]) ||
            now - enemy_last_attack_time[[enemy_name]] < enemy_attack_cooldown) {
          return(invisible(NULL))
        }

        enemy_last_attack_time[[enemy_name]] <<- now
        life_points <<- max(0, life_points - enemy_damage[[enemy_name]])
        set_combat_status(sprintf(
          "%s hits you for %d. Life: %d/%d",
          format_enemy_label(enemy_name), enemy_damage[[enemy_name]],
          life_points, max_life_points
        ))
        update_life_points()

        if (life_points <= 0 && !game_over_shown) {
          game_over_shown <<- TRUE
          shinyalert::shinyalert(
            title = "Game over",
            text = "Your life points reached 0.",
            type = "error",
            closeOnClickOutside = FALSE,
            showCancelButton = FALSE
          )
        }
      }
    )

    game$add_overlap_end(
      object_one = "hero",
      object_two = enemy_name,
      # Release the forced attack without leaving a permanent forced-idle state.
      browser_action = browser_actions(enemies[[enemy_name]]$play_animation(
        enemy_animation_key(enemy_name, "idle"),
        duration = 1
      )),
      input = input,
      session = session,
      server_action = function(event) {
        if (identical(enemy_in_range, enemy_name)) enemy_in_range <<- NULL
      }
    )
  }

  lapply(enemy_names, add_enemy_handlers)

  mushroom_swamps_objects <- c(
    enemy_names,
    "dead_tree_1_bottom", "dead_tree_1_top", names(berries),
    "wizard", "mushroom_spirit"
  )
