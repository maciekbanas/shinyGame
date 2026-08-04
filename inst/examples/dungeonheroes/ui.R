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
      background-image: url('assets/dungeonheroes/sprites/enemies/skeleton/skeleton_idle.png');
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
      background-image: url('assets/dungeonheroes/sprites/hero/human/hero_sword_idle.png');
    }

    #choose_orc .character_portrait {
      background-image: url('assets/dungeonheroes/sprites/hero/orc/hero_orc_idle.png');
    }

    #choose_elf .character_portrait {
      background-image: url('assets/dungeonheroes/sprites/hero/elf/hero_elf_idle.png');
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
      background-image: url('assets/dungeonheroes/sprites/hero/human/hero_sword_idle.png');
    }

    #realm_character_marker.orc {
      background-image: url('assets/dungeonheroes/sprites/hero/orc/hero_orc_idle.png');
    }

    #realm_character_marker.elf {
      background-image: url('assets/dungeonheroes/sprites/hero/elf/hero_elf_idle.png');
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
