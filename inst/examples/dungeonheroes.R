devtools::load_all()

game <- PhaserGame$new(width = 1600, height = 800)
map_tile_size <- 100
map_tile_width <- 32
map_tile_height <- 64
world_width <- map_tile_width * map_tile_size
world_height <- map_tile_height * map_tile_size
shinyphaser_version <- as.character(utils::packageVersion("shinyphaser"))

ui <- shiny::tagList(
  htmltools::tags$style(htmltools::HTML("
    @keyframes dungeonheroes-skeleton-loader {
      from { background-position: 0 0; }
      to { background-position: -800px 0; }
    }

    #dungeonheroes_loader {
      position: fixed;
      inset: 0;
      z-index: 9999;
      display: flex;
      flex-direction: column;
      gap: 18px;
      align-items: center;
      justify-content: center;
      background: #111827;
      color: #f9fafb;
      font: 24px sans-serif;
    }

    #dungeonheroes_loader .skeleton_loader_sprite {
      width: 100px;
      height: 100px;
      background-image: url('assets/dungeonheroes/sprites/skeleton_idle.png');
      background-repeat: no-repeat;
      animation: dungeonheroes-skeleton-loader 1s steps(8) infinite;
      image-rendering: pixelated;
    }

    #leave_map {
      position: fixed;
      display: none;
      top: 18px;
      left: 50%;
      z-index: 9000;
      transform: translateX(-50%);
      padding: 12px 24px;
      border: 2px solid #f9fafb;
      border-radius: 6px;
      background: #111827;
      color: #f9fafb;
      font: 700 18px sans-serif;
      cursor: pointer;
    }

  ")),
  htmltools::tags$div(
    id = "dungeonheroes_loader",
    htmltools::tags$div(class = "skeleton_loader_sprite"),
    htmltools::tags$div("Loading dungeon heroes...")
  ),
  shiny::actionButton(
    "leave_map", "Leave map"
  ),
  game$use_phaser(),
  htmltools::tags$script(htmltools::HTML("
    window.addEventListener('load', function() {
      setTimeout(function() {
        var loader = document.getElementById('dungeonheroes_loader');
        if (loader) loader.style.display = 'none';
      }, 1200);
    });
  "))
)

server <- function(input, output, session) {

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
  sword_in_range <- FALSE
  wizard_in_range <- FALSE
  berry_in_range <- NULL
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
  defeated_enemy_count <- 0

  session$onFlushed(function() {
    shinyalert::shinyalert(
      title = "Use Space to attack and interact",
      type = "info"
    )
  }, once = TRUE)

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

  map_navigation_background <- game$add_rectangle(
    name = "map_navigation_background",
    x = 800, y = 400, width = 1600, height = 800,
    color = "0x000000", visible = FALSE
  )
  mushroom_swamps_map_image <- game$add_image(
    name = "choose_mushroom_swamps",
    url = "assets/dungeonheroes/terrain/ms/mushroom_swamps_map.png",
    x = 800, y = 400, visible = FALSE, clickable = TRUE
  )
  magma_hills_map_image <- game$add_image(
    name = "choose_magma_hills",
    url = "assets/dungeonheroes/terrain/magma_hills/magma_hills_map.png",
    x = 950, y = 400, visible = FALSE, clickable = TRUE
  )
  mushroom_swamps_map_image_from_magma <- game$add_image(
    name = "choose_mushroom_swamps_from_magma",
    url = "assets/dungeonheroes/terrain/ms/mushroom_swamps_map.png",
    x = 650, y = 400, visible = FALSE, clickable = TRUE
  )
  magma_hills_map_image_current <- game$add_image(
    name = "choose_current_magma_hills",
    url = "assets/dungeonheroes/terrain/magma_hills/magma_hills_map.png",
    x = 800, y = 400, visible = FALSE, clickable = TRUE
  )
  navigation_images <- list(
    mushroom_swamps_map_image, magma_hills_map_image,
    mushroom_swamps_map_image_from_magma, magma_hills_map_image_current
  )
  map_navigation_background$set_scroll_factor(0)
  map_navigation_background$set_depth(99)
  lapply(navigation_images, function(image) image$set_scroll_factor(0))
  lapply(navigation_images, function(image) image$set_depth(100))

  game$add_map(
    map_key = "mushroom_swamps",
    map_url = "assets/dungeonheroes/maps/mushroom_swamps.json",
    tileset_urls = c(
      "assets/dungeonheroes/terrain/ms/mushroom_swamps_grass_1.png",
      "assets/dungeonheroes/terrain/ms/mushroom_swamps_swamp_1.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_bottom.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_bottom_right.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_left.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_left_bottom.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_left_bottom_right.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_right.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_top_bottom_left_right.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_top_left.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_top_left_right.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_top_right.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_top.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_top_bottom.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_top_bottom_left.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_top_bottom_right.png",
      "assets/dungeonheroes/terrain/ms/ms_bank_left_right.png",
      "assets/dungeonheroes/terrain/ms/mushroom_swamps_grass_2.png",
      "assets/dungeonheroes/terrain/ms/mushroom_swamps_grass_3.png",
      "assets/dungeonheroes/terrain/ms/mushroom_swamps_grass_4.png",
      "assets/dungeonheroes/terrain/ms/mushroom_swamps_grass_5.png"
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
  game$add_map(
    map_key = "magma_hills",
    map_url = "assets/dungeonheroes/maps/magma_hills.json",
    tileset_urls = c(
      "assets/dungeonheroes/terrain/magma_hills/hill_1.png",
      "assets/dungeonheroes/terrain/magma_hills/lava_1.png"
    ),
    tileset_names = c("hill_1", "lava_1"),
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
  hero$set_depth(10)
  game$set_map_exit("mushroom_swamps", "hero", x = 100, y = 100)
  game$set_map_exit("magma_hills", "hero", x = 1550, y = 650)
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
  lapply(c("left", "right"), function(direction) {
    hero$add_animation(
      suffix = paste0("sword_attack_", direction),
      url = sprintf("assets/dungeonheroes/sprites/hero_sword_attack_%s.png", direction),
      frame_width = 100, frame_height = 100,
      frame_count = 2, frame_rate = 4
    )
  })

  enemies <- stats::setNames(lapply(enemy_specs, function(spec) {
    enemy <- game$add_sprite(
      name = spec$name,
      url = "assets/dungeonheroes/sprites/mushroom_man_idle.png",
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
        url = sprintf("assets/dungeonheroes/sprites/mushroom_man_walk_%s.png", direction),
        frame_width = 100, frame_height = 100,
        frame_count = 12, frame_rate = 8
      )
    })

    enemy$add_animation(
      suffix = "attack",
      url = "assets/dungeonheroes/sprites/mushroom_man_attack.png",
      frame_width = 100, frame_height = 100,
      frame_count = 6, frame_rate = 6
    )
    lapply(c("left", "right"), function(direction) {
      enemy$add_animation(
        suffix = paste0("attack_", direction),
        url = sprintf("assets/dungeonheroes/sprites/mushroom_man_attack_%s.png", direction),
        frame_width = 100, frame_height = 100,
        frame_count = 6, frame_rate = 6
      )
    })
    enemy$add_animation(
      suffix = "destroy",
      url = "assets/dungeonheroes/sprites/mushroom_man_destroy.png",
      frame_width = 100, frame_height = 100,
      frame_count = 6, frame_rate = 8
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

      if (sword_in_range && !has_sword) {
        has_sword <<- TRUE
        sword_in_range <<- FALSE
        sword$destroy()
        inventory_text$set("weapon: sword")
        hero$play_animation("hero_sword")
        set_combat_status("You picked up the sword.")
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
        damage <- if (has_sword) hero_sword_damage else hero_fist_damage
        hero_animation <- if (has_sword) "hero_sword_attack" else "hero_attack"
        enemy_hit_points[[enemy_in_range]] <<- max(0, enemy_hit_points[[enemy_in_range]] - damage)
        play_hero_timed_animation(hero_animation)
        set_combat_status(sprintf(
          "You hit %s for %d. Enemy life: %d/%d",
          format_enemy_label(enemy_in_range), damage,
          enemy_hit_points[[enemy_in_range]], enemy_max_hit_points[[enemy_in_range]]
        ))

        if (enemy_hit_points[[enemy_in_range]] <= 0) {
          defeated <- enemy_in_range
          enemy_is_alive[[defeated]] <<- FALSE
          defeated_enemy_count <<- defeated_enemy_count + 1
          enemies[[defeated]]$play_animation(enemy_animation_key(defeated, "destroy"), duration = 750)
          later::later(function() enemies[[defeated]]$destroy(), delay = 0.75)
          enemy_in_range <<- NULL
        }
        update_enemy_status()
      } else {
        play_hero_timed_animation(if (has_sword) "hero_sword_attack" else "hero_attack")
      }

  }

  game$add_control(
    "Space",
    server_action = handle_space,
    input = input
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
    text = sprintf("shinyphaser v%s", shinyphaser_version),
    id = "game_version",
    x = 50,
    y = 660
  )
  version_text$set_scroll_factor(0)

  dead_tree_bottom <- game$add_static_sprite(
    name = "dead_tree_1_bottom",
    url = "assets/dungeonheroes/terrain/ms/dead_tree_1_bottom.png",
    x = 550,
    y = 650
  )
  dead_tree_bottom$set_depth(10)

  dead_tree_top <- game$add_image(
    name = "dead_tree_1_top",
    url = "assets/dungeonheroes/terrain/ms/dead_tree_1_top.png",
    x = 550,
    y = 650 - map_tile_size
  )
  dead_tree_top$set_depth(20)

  game$add_collider("hero", "dead_tree_1_bottom")

  sword <- game$add_static_sprite(
    name = "sword",
    url = "assets/dungeonheroes/weapons/sword.png",
    x = 300,
    y = 300
  )
  game$add_overlap(
    "hero", "sword", input = input,
    server_action = function(event) sword_in_range <<- TRUE
  )
  game$add_overlap_end(
    "hero", "sword", input = input, session = session,
    server_action = function(event) sword_in_range <<- FALSE
  )

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

  lapply(names(berries), function(berry_name) {
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

  mushroom_spirit <- game$add_sprite(
    name = "mushroom_spirit",
    url = "assets/dungeonheroes/sprites/mushroom_spirit.png",
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
    "dead_tree_1_bottom", "dead_tree_1_top", "sword", names(berries),
    "wizard", "mushroom_spirit"
  )

  current_map <- "mushroom_swamps"

  hide_map_navigation <- function() {
    map_navigation_background$hide()
    lapply(navigation_images, function(image) image$hide())
    hero$set_depth(10)
  }

  shiny::observeEvent(input$leave_map, {
    map_navigation_background$show()
    # Keep the player out of the realm navigation display by rendering it
    # behind the opaque navigation background.
    hero$set_depth(98)
    if (identical(current_map, "mushroom_swamps")) {
      mushroom_swamps_map_image$show()
      magma_hills_map_image$show()
      mushroom_swamps_map_image_from_magma$hide()
      magma_hills_map_image_current$hide()
    } else {
      mushroom_swamps_map_image$hide()
      magma_hills_map_image$hide()
      mushroom_swamps_map_image_from_magma$show()
      magma_hills_map_image_current$show()
    }
  }, ignoreInit = TRUE)

  choose_mushroom_swamps <- function(event) {
    hide_map_navigation()
    game$activate_map(
      "mushroom_swamps", player_name = "hero", x = 100, y = 100,
      visible_objects = mushroom_swamps_objects
    )
    current_map <<- "mushroom_swamps"
    update_enemy_status()
    set_combat_status("Back in the mushroom swamps.")
  }

  choose_magma_hills <- function(event) {
    hide_map_navigation()
    game$activate_map(
      # Magma hills has its own hill-top arrival point, separate from the
      # mushroom swamps entrance at (100, 100).
      "magma_hills", player_name = "hero", x = 1550, y = 650,
      hidden_objects = c(mushroom_swamps_objects, "talk_bubble_text")
    )
    current_map <<- "magma_hills"
    enemy_status_text$set("enemies: none in magma hills")
    set_combat_status("Explore the hills. Lava is impassable.")
  }

  mushroom_swamps_map_image$click(choose_mushroom_swamps, input)
  mushroom_swamps_map_image_from_magma$click(choose_mushroom_swamps, input)
  magma_hills_map_image$click(choose_magma_hills, input)
  magma_hills_map_image_current$click(choose_magma_hills, input)
}


shiny::shinyApp(ui, server)
