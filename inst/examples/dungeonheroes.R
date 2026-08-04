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

    #character_select {
      position: fixed;
      inset: 0;
      z-index: 9500;
      display: none;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 28px;
      overflow: hidden;
      background:
        radial-gradient(circle at 50% 35%, rgba(61, 81, 70, 0.9), transparent 38%),
        linear-gradient(180deg, #17221e 0%, #080d0b 100%);
      color: #f6e7bd;
      font-family: Georgia, serif;
    }

    #character_select h1 {
      margin: 0;
      color: #f5d98b;
      font-size: clamp(42px, 6vw, 76px);
      letter-spacing: 0.08em;
      text-shadow: 0 4px 0 #51351e, 0 8px 18px #000;
    }

    #character_select .select_prompt {
      margin: -16px 0 4px;
      color: #d8c9a3;
      font: 600 22px sans-serif;
      letter-spacing: 0.12em;
      text-transform: uppercase;
    }

    #character_select .character_choices {
      display: flex;
      gap: clamp(24px, 6vw, 80px);
    }

    #character_select .character_choice {
      width: 260px;
      padding: 24px 20px 20px;
      border: 3px solid #8f7140;
      border-radius: 12px;
      background: rgba(20, 27, 23, 0.94);
      box-shadow: 0 10px 28px #000;
      color: #f6e7bd;
      cursor: pointer;
      transition: transform 120ms ease, border-color 120ms ease, background 120ms ease;
    }

    #character_select .character_choice:hover,
    #character_select .character_choice:focus-visible {
      transform: translateY(-7px) scale(1.02);
      border-color: #f5d98b;
      background: #28352e;
      outline: none;
    }

    #character_select .character_portrait {
      display: block;
      width: 100px;
      height: 100px;
      margin: 0 auto 16px;
      background-repeat: no-repeat;
      image-rendering: pixelated;
      transform: scale(1.35);
    }

    #choose_hero .character_portrait {
      background-image: url('assets/dungeonheroes/sprites/hero_sword_idle.png');
    }

    #choose_orc .character_portrait {
      background-image: url('assets/dungeonheroes/sprites/hero_orc_idle.png');
    }

    #choose_elf .character_portrait {
      background-image: url('assets/dungeonheroes/sprites/hero_elf_idle.png');
    }

    #character_select .character_name {
      display: block;
      font: 700 28px Georgia, serif;
      letter-spacing: 0.05em;
    }

    #character_select .character_description {
      display: block;
      margin-top: 7px;
      color: #bcb59e;
      font: 15px sans-serif;
    }

    #realm_character_marker {
      position: absolute;
      z-index: 8500;
      display: none;
      width: 100px;
      height: 100px;
      background-repeat: no-repeat;
      image-rendering: pixelated;
      pointer-events: none;
      transform: translate(-50%, -50%);
    }

    #realm_character_marker.human {
      background-image: url('assets/dungeonheroes/sprites/hero_sword_idle.png');
    }

    #realm_character_marker.orc {
      background-image: url('assets/dungeonheroes/sprites/hero_orc_idle.png');
    }

    #realm_character_marker.elf {
      background-image: url('assets/dungeonheroes/sprites/hero_elf_idle.png');
    }

    #realm_character_marker.mushroom_swamps {
      left: 800px;
      top: 400px;
    }

    #realm_character_marker.magma_hills {
      left: 1300px;
      top: 700px;
    }

    #realm_character_marker.wild_forests {
      left: 700px;
      top: 400px;
    }

    #realm_character_marker.grey_mountains {
      left: 300px;
      top: 700px;
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

    #game_start, #save_game_dialog {
      position: fixed;
      inset: 0;
      z-index: 9600;
      display: flex;
      align-items: center;
      justify-content: center;
      background: radial-gradient(circle at 50% 35%, #3d5146, #080d0b 62%);
      color: #f6e7bd;
      font-family: Georgia, serif;
    }

    .game_menu_panel {
      width: min(520px, calc(100vw - 48px));
      padding: 38px;
      border: 3px solid #8f7140;
      border-radius: 12px;
      background: rgba(15, 22, 18, .96);
      box-shadow: 0 14px 38px #000;
      text-align: center;
    }

    .game_menu_panel h1, .game_menu_panel h2 { color: #f5d98b; }
    .game_menu_button, #save_game_name {
      box-sizing: border-box;
      width: 100%;
      margin-top: 14px;
      padding: 13px 18px;
      border: 2px solid #8f7140;
      border-radius: 6px;
      background: #202d26;
      color: #f6e7bd;
      font: 700 18px sans-serif;
    }
    button.game_menu_button { cursor: pointer; }
    button.game_menu_button:hover { border-color: #f5d98b; background: #304238; }
    #saved_games { max-height: 260px; overflow-y: auto; }
    #saved_games .empty_save { color: #bcb59e; font-family: sans-serif; }
    #save_game_dialog { z-index: 9700; display: none; background: rgba(0, 0, 0, .72); }
    #save_game_actions { display: flex; gap: 12px; }
    #game_session_actions {
      position: fixed; left: 18px; top: 18px; z-index: 9000; display: none;
    }
    #game_session_actions .game_menu_button {
      width: auto; margin: 0; padding: 11px 20px;
    }
    #game_session_menu {
      display: none; width: 190px; margin-top: 8px; padding: 8px;
      border: 2px solid #8f7140; border-radius: 6px;
      background: rgba(15, 22, 18, .96); box-shadow: 0 8px 24px #000;
    }
    #game_session_menu .game_menu_button { width: 100%; margin-top: 6px; }

  ")),
  htmltools::tags$div(
    id = "dungeonheroes_loader",
    htmltools::tags$div(class = "skeleton_loader_sprite"),
    htmltools::tags$div("Loading dungeon heroes...")
  ),
  htmltools::tags$div(
    id = "game_start",
    htmltools::tags$div(
      class = "game_menu_panel",
      htmltools::tags$h1("DUNGEON HEROES"),
      htmltools::tags$button(id = "new_game", class = "game_menu_button action-button", type = "button", "New game"),
      htmltools::tags$button(id = "show_load_game", class = "game_menu_button", type = "button", "Load game"),
      htmltools::tags$div(id = "saved_games", style = "display:none;")
    )
  ),
  htmltools::tags$div(
    id = "character_select",
    htmltools::tags$h1("DUNGEON HEROES"),
    htmltools::tags$p(class = "select_prompt", "Choose your champion"),
    htmltools::tags$div(
      class = "character_choices",
      htmltools::tags$button(
        id = "choose_hero", class = "character_choice action-button",
        type = "button",
        htmltools::tags$span(class = "character_portrait"),
        htmltools::tags$span(class = "character_name", "Human Knight"),
        htmltools::tags$span(class = "character_description", "Courage against the darkness")
      ),
      htmltools::tags$button(
        id = "choose_orc", class = "character_choice action-button",
        type = "button",
        htmltools::tags$span(class = "character_portrait"),
        htmltools::tags$span(class = "character_name", "Orc Hunter"),
        htmltools::tags$span(class = "character_description", "Strength born of the wilds")
      ),
      htmltools::tags$button(
        id = "choose_elf", class = "character_choice action-button",
        type = "button",
        htmltools::tags$span(class = "character_portrait"),
        htmltools::tags$span(class = "character_name", "Elf Ranger"),
        htmltools::tags$span(class = "character_description", "Fleet guardian of the forest")
      )
    )
  ),
  htmltools::tags$div(
    id = "realm_character_marker",
    class = "mushroom_swamps",
    `aria-hidden` = "true"
  ),
  shiny::actionButton(
    "leave_map", "Leave map",
    onclick = "this.style.display = 'none';"
  ),
  htmltools::tags$div(
    id = "game_session_actions",
    htmltools::tags$button(id = "toggle_game_menu", class = "game_menu_button", type = "button",
                          `aria-expanded` = "false", "Menu"),
    htmltools::tags$div(
      id = "game_session_menu",
      htmltools::tags$button(id = "save_game", class = "game_menu_button", type = "button", "Save game"),
      htmltools::tags$button(id = "exit_game", class = "game_menu_button", type = "button", "Exit")
    )
  ),
  htmltools::tags$div(
    id = "save_game_dialog",
    htmltools::tags$div(
      class = "game_menu_panel",
      htmltools::tags$h2("Save game"),
      htmltools::tags$label(`for` = "save_game_name", "Name this save"),
      htmltools::tags$input(id = "save_game_name", type = "text", maxlength = "60", placeholder = "My adventure"),
      htmltools::tags$div(
        id = "save_game_actions",
        htmltools::tags$button(id = "confirm_save_game", class = "game_menu_button", type = "button", "Save"),
        htmltools::tags$button(id = "cancel_save_game", class = "game_menu_button", type = "button", "Cancel")
      )
    )
  ),
  game$use_phaser(),
  htmltools::tags$script(htmltools::HTML("
    (function() {
      function renderSaves(items) {
        var host = document.getElementById('saved_games');
        host.innerHTML = '';
        if (!items.length) { host.innerHTML = '<p class=\"empty_save\">No saved games yet.</p>'; return; }
        items.forEach(function(save) {
          var button = document.createElement('button');
          button.type = 'button'; button.className = 'game_menu_button';
          button.textContent = save.name + ' — ' + new Date(save.savedAt).toLocaleString();
          button.onclick = function() { Shiny.setInputValue('load_game', {name: save.name, nonce: Date.now()}, {priority: 'event'}); };
          host.appendChild(button);
        });
      }
      window.renderDungeonHeroesSaves = renderSaves;
      window.addEventListener('shinyphaser:saved', function() {
        document.getElementById('save_game_dialog').style.display = 'none';
        Shiny.setInputValue('list_saved_games', Date.now(), {priority: 'event'});
      });
      document.addEventListener('DOMContentLoaded', function() {
        document.getElementById('show_load_game').onclick = function() {
          document.getElementById('saved_games').style.display = 'block';
          Shiny.setInputValue('list_saved_games', Date.now(), {priority: 'event'});
        };
        document.getElementById('toggle_game_menu').onclick = function() {
          var menu = document.getElementById('game_session_menu');
          var open = menu.style.display === 'block';
          menu.style.display = open ? 'none' : 'block';
          this.setAttribute('aria-expanded', open ? 'false' : 'true');
        };
        document.getElementById('save_game').onclick = function() { document.getElementById('game_session_menu').style.display = 'none'; var d = document.getElementById('save_game_dialog'); d.style.display = 'flex'; document.getElementById('save_game_name').focus(); };
        document.getElementById('exit_game').onclick = function() { window.location.reload(); };
        document.getElementById('cancel_save_game').onclick = function() { document.getElementById('save_game_dialog').style.display = 'none'; };
        document.getElementById('confirm_save_game').onclick = function() {
          var name = document.getElementById('save_game_name').value.trim();
          if (!name) { document.getElementById('save_game_name').focus(); return; }
          capturePhaserGameState('save_game_requested', String(Date.now()), name, {
            objects: ['hero'],
            state: {navigation: !!GameBridge.navigationOverlayVisible}
          });
        };
      });
    })();
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
  wizard_in_range <- FALSE
  berry_in_range <- NULL
  hero_last_attack_time <- as.numeric(Sys.time()) - 1
  hero_attack_cooldown <- 0.75
  hero_weapon_damage <- 2
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

  game$set_shiny_session()

  game$set_world_bounds(world_width, world_height)

  map_navigation_background <- game$add_rectangle(
    name = "map_navigation_background",
    x = 800, y = 400, width = 1600, height = 800,
    color = "0x000000", visible = FALSE
  )
  mushroom_swamps_map_image <- game$add_image(
    name = "choose_mushroom_swamps",
    url = "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_map.png",
    x = 800, y = 400, visible = FALSE, clickable = TRUE
  )
  wild_forests_map_image <- game$add_image(
    name = "choose_wild_forests",
    url = "assets/dungeonheroes/terrain/wild_forests/wild_forests_map.png",
    x = 700, y = 400, visible = FALSE, clickable = TRUE
  )
  grey_mountains_map_image <- game$add_image(
    name = "choose_grey_mountains",
    url = "assets/dungeonheroes/terrain/grey_mountains/grey_mountains_map.png",
    x = 300, y = 700, visible = FALSE, clickable = TRUE
  )
  magma_hills_map_image <- game$add_image(
    name = "choose_magma_hills",
    url = "assets/dungeonheroes/terrain/magma_hills/magma_hills_map.png",
    x = 1300, y = 700, visible = FALSE, clickable = TRUE
  )
  navigation_images <- list(
    wild_forests_map_image, mushroom_swamps_map_image,
    grey_mountains_map_image, magma_hills_map_image
  )
  map_navigation_background$set_scroll_factor(0)
  map_navigation_background$set_depth(99)
  lapply(navigation_images, function(image) image$set_scroll_factor(0))
  lapply(navigation_images, function(image) image$set_depth(100))

  game$add_map(
    map_key = "mushroom_swamps",
    map_url = "assets/dungeonheroes/maps/mushroom_swamps.json",
    tileset_urls = c(
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_grass_1.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_1.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_bottom.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_bottom_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_left.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_left_bottom.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_left_bottom_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_bottom_left_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_left.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_left_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_bottom.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_bottom_left.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_bottom_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_left_right.png",
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
  game$add_map(
    map_key = "wild_forests",
    map_url = "assets/dungeonheroes/maps/wild_forests.json",
    tileset_urls = sprintf(
      "assets/dungeonheroes/terrain/wild_forests/grass_%d.png", 1:5
    ),
    tileset_names = sprintf("grass_%d", 1:5),
    layer_name = "terrain"
  )
  game$add_map(
    map_key = "grey_mountains",
    map_url = "assets/dungeonheroes/maps/grey_mountains.json",
    tileset_urls = "assets/dungeonheroes/terrain/grey_mountains/hill_1.png",
    tileset_names = "hill_1",
    layer_name = "terrain"
  )
  hero <- game$add_sprite(
    name = "hero",
    url = "assets/dungeonheroes/sprites/hero_sword_idle.png",
    x = 100,
    y = 100,
    frame_width = 100,
    frame_height = 100,
    frame_count = 7,
    frame_rate = 4
  )
  hero$follow_camera()
  hero$set_depth(10)
  game$set_map_exit("mushroom_swamps", "hero", x = 100, y = 100)
  game$set_map_exit("magma_hills", "hero", x = 1550, y = 650)
  game$set_map_exit("wild_forests", "hero", x = 100, y = 100)
  game$set_map_exit("grey_mountains", "hero", x = 100, y = 100)
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
    suffix = "orc_idle",
    url = "assets/dungeonheroes/sprites/hero_orc_idle.png",
    frame_width = 100, frame_height = 100,
    frame_count = 29, frame_rate = 4
  )
  lapply(c("down", "up", "left", "right"), function(direction) {
    hero$add_animation(
      suffix = paste0("orc_move_", direction),
      url = sprintf("assets/dungeonheroes/sprites/hero_orc_move_%s.png", direction),
      frame_width = 100, frame_height = 100,
      frame_count = 6, frame_rate = 8
    )
  })
  hero$add_animation(
    suffix = "orc_attack",
    url = "assets/dungeonheroes/sprites/hero_orc_attack.png",
    frame_width = 100, frame_height = 100,
    frame_count = 3, frame_rate = 4
  )

  hero$add_animation(
    suffix = "elf_idle",
    url = "assets/dungeonheroes/sprites/hero_elf_idle.png",
    frame_width = 100, frame_height = 100,
    frame_count = 26, frame_rate = 4
  )
  lapply(c("down", "left", "right", "up"), function(direction) {
    source_direction <- if (direction %in% c("up", "down")) direction else "down"
    hero$add_animation(
      suffix = paste0("elf_move_", direction),
      url = sprintf("assets/dungeonheroes/sprites/hero_elf_move_%s.png", source_direction),
      frame_width = 100, frame_height = 100,
      frame_count = 4, frame_rate = 8
    )
  })

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
        damage <- hero_weapon_damage
        enemy_hit_points[[enemy_in_range]] <<- max(0, enemy_hit_points[[enemy_in_range]] - damage)
        play_hero_attack_animation()
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
    "dead_tree_1_bottom", "dead_tree_1_top", names(berries),
    "wizard", "mushroom_spirit"
  )

  hide_map_navigation <- function() {
    map_navigation_background$hide()
    lapply(navigation_images, function(image) image$hide())
    hero$set_depth(10)
    session$sendCustomMessage(
      "phaser",
      list(js = paste(
        "setNavigationOverlayVisible(false);",
        "document.getElementById('leave_map').style.display = 'block';"
      ))
    )
  }

  choose_character <- function(character) {
    if (!is.null(selected_character)) return(invisible(NULL))

    selected_character <<- character
    hero$add_player_controls()
    animation_prefix <- switch(character,
      hero_orc = "hero_orc", hero_elf = "hero_elf", "hero_sword"
    )
    marker_character <- switch(character,
      hero_orc = "orc", hero_elf = "elf", "human"
    )
    weapon <- switch(character, hero_orc = "axe", hero_elf = "bow", "sword")
    hero$set_player_animation_prefix(animation_prefix)
    inventory_text$set(sprintf("weapon: %s", weapon))
    map_navigation_background$show()
    hero$set_depth(98)
    lapply(navigation_images, function(image) image$show())
    session$sendCustomMessage(
      "phaser",
      list(js = paste(
        sprintf(
          "document.getElementById('realm_character_marker').className = '%s %s';",
          marker_character, current_realm
        ),
        "setNavigationOverlayVisible(true);",
        "document.getElementById('character_select').style.display = 'none';",
        "document.getElementById('game_start').style.display = 'none';",
        "document.getElementById('game_session_actions').style.display = 'flex';"
      ))
    )
  }

  shiny::observeEvent(input$new_game, {
    session$sendCustomMessage(
      "phaser",
      list(js = paste(
        "document.getElementById('game_start').style.display = 'none';",
        "document.getElementById('character_select').style.display = 'flex';"
      ))
    )
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$choose_hero, {
    choose_character("hero")
  }, ignoreInit = TRUE)
  shiny::observeEvent(input$choose_orc, {
    choose_character("hero_orc")
  }, ignoreInit = TRUE)
  shiny::observeEvent(input$choose_elf, {
    choose_character("hero_elf")
  }, ignoreInit = TRUE)

  send_saved_games <- function() {
    summaries <- lapply(game$list_saved_games(), function(save) {
      list(name = save$name, savedAt = save$savedAt)
    })
    session$sendCustomMessage("phaser", list(js = sprintf(
      "renderDungeonHeroesSaves(%s);",
      jsonlite::toJSON(summaries, auto_unbox = TRUE, null = "null")
    )))
  }

  shiny::observeEvent(input$list_saved_games, send_saved_games(), ignoreInit = TRUE)

  shiny::observeEvent(input$save_game_requested, {
    request <- input$save_game_requested
    game$save_game(
      name = as.character(request$name),
      snapshot = request$objects,
      state = list(
        character = selected_character,
        realm = current_realm,
        navigation = isTRUE(request$state$navigation),
        lifePoints = life_points,
        enemyHitPoints = as.list(enemy_hit_points),
        enemyIsAlive = as.list(enemy_is_alive),
        berriesAvailable = as.list(berry_is_available)
      )
    )
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$load_game, {
    save <- game$load_game(input$load_game$name, restore = FALSE)
    if (is.null(save$character) || !save$character %in% c("hero", "hero_orc", "hero_elf")) return()

    choose_character(save$character)
    available_realms <- c("mushroom_swamps", "wild_forests", "grey_mountains", "magma_hills")
    current_realm <<- if (save$realm %in% available_realms) save$realm else "mushroom_swamps"
    life_points <<- max(0, min(max_life_points, as.numeric(save$lifePoints %||% max_life_points)))
    update_life_points()

    saved_enemy_hp <- unlist(save$enemyHitPoints)
    saved_enemy_alive <- unlist(save$enemyIsAlive)
    common_enemies <- intersect(enemy_names, names(saved_enemy_hp))
    enemy_hit_points[common_enemies] <<- as.numeric(saved_enemy_hp[common_enemies])
    common_alive <- intersect(enemy_names, names(saved_enemy_alive))
    enemy_is_alive[common_alive] <<- as.logical(saved_enemy_alive[common_alive])
    saved_berries <- unlist(save$berriesAvailable)
    common_berries <- intersect(names(berries), names(saved_berries))
    berry_is_available[common_berries] <<- as.logical(saved_berries[common_berries])
    update_enemy_status()

    marker_character <- switch(save$character,
      hero_orc = "orc", hero_elf = "elf", "human"
    )
    saved_hero <- save$phaser$objects$hero %||% list()
    x <- as.numeric(saved_hero$x %||% 100)
    y <- as.numeric(saved_hero$y %||% 100)
    on_navigation <- isTRUE(save$navigation)
    session$sendCustomMessage(
      "phaser",
      list(js = sprintf(
        paste(
          "document.getElementById('realm_character_marker').className = %s + ' ' + %s;",
          "document.getElementById('game_start').style.display = 'none';",
          "document.getElementById('game_session_actions').style.display = 'flex';"
        ),
        jsonlite::toJSON(marker_character, auto_unbox = TRUE),
        jsonlite::toJSON(current_realm, auto_unbox = TRUE)
      ))
    )
    if (on_navigation) {
      map_navigation_background$show()
      hero$set_depth(98)
      lapply(navigation_images, function(image) image$show())
      session$sendCustomMessage("phaser", list(js = "setNavigationOverlayVisible(true);"))
    } else {
      hide_map_navigation()
      persistent_objects <- c("dead_tree_1_bottom", "dead_tree_1_top", "wizard", "mushroom_spirit")
      available_objects <- c(enemy_names[enemy_is_alive], names(berries)[berry_is_available], persistent_objects)
      unavailable_objects <- c(enemy_names[!enemy_is_alive], names(berries)[!berry_is_available])
      visible <- if (identical(current_realm, "mushroom_swamps")) available_objects else character()
      hidden <- if (!identical(current_realm, "mushroom_swamps")) {
        c(mushroom_swamps_objects, "talk_bubble_text")
      } else {
        unavailable_objects
      }
      game$activate_map(current_realm, player_name = "hero", x = x, y = y,
                        visible_objects = visible, hidden_objects = hidden)
    }
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$leave_map, {
    session$sendCustomMessage(
      "phaser", list(js = "setNavigationOverlayVisible(true);")
    )
    map_navigation_background$show()
    # Keep the player out of the realm navigation display by rendering it
    # behind the opaque navigation background.
    hero$set_depth(98)
    lapply(navigation_images, function(image) image$show())
  }, ignoreInit = TRUE)

  show_controls_alert <- function() {
    shinyalert::shinyalert(
      title = "Use Space to attack and interact",
      type = "info"
    )
  }

  move_realm_marker <- function(realm) {
    session$sendCustomMessage(
      "phaser",
      list(js = sprintf(
        paste0(
          "document.getElementById('realm_character_marker').classList.remove(",
          "'mushroom_swamps','wild_forests','grey_mountains','magma_hills');",
          "document.getElementById('realm_character_marker').classList.add(%s);"
        ),
        jsonlite::toJSON(realm, auto_unbox = TRUE)
      ))
    )
  }

  choose_mushroom_swamps <- function(event) {
    current_realm <<- "mushroom_swamps"
    move_realm_marker(current_realm)
    hide_map_navigation()
    show_controls_alert()
    game$activate_map(
      "mushroom_swamps", player_name = "hero", x = 100, y = 100,
      visible_objects = mushroom_swamps_objects
    )
    update_enemy_status()
    set_combat_status("Back in the mushroom swamps.")
  }

  choose_magma_hills <- function(event) {
    current_realm <<- "magma_hills"
    move_realm_marker(current_realm)
    hide_map_navigation()
    show_controls_alert()
    game$activate_map(
      # Magma hills has its own hill-top arrival point, separate from the
      # mushroom swamps entrance at (100, 100).
      "magma_hills", player_name = "hero", x = 1550, y = 650,
      hidden_objects = c(mushroom_swamps_objects, "talk_bubble_text")
    )
    enemy_status_text$set("enemies: none in magma hills")
    set_combat_status("Explore the hills. Lava is impassable.")
  }

  choose_wild_forests <- function(event) {
    current_realm <<- "wild_forests"
    move_realm_marker(current_realm)
    hide_map_navigation()
    show_controls_alert()
    game$activate_map(
      current_realm, player_name = "hero", x = 100, y = 100,
      hidden_objects = c(mushroom_swamps_objects, "talk_bubble_text")
    )
    enemy_status_text$set("enemies: none in wild forests")
    set_combat_status("Explore the wild forests.")
  }

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

  wild_forests_map_image$click(choose_wild_forests, input)
  mushroom_swamps_map_image$click(choose_mushroom_swamps, input)
  grey_mountains_map_image$click(choose_grey_mountains, input)
  magma_hills_map_image$click(choose_magma_hills, input)
}


shiny::shinyApp(ui, server)
