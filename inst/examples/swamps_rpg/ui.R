shinyphaser_version <- as.character(utils::packageVersion("shinyphaser"))

ui <- shiny::tagList(
  htmltools::tags$style(htmltools::HTML("
    @keyframes swamps_rpg-skeleton-loader {
      from { background-position: 0 0; }
      to { background-position: -800px 0; }
    }

    #swamps_rpg_loader {
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

    #swamps_rpg_loader .skeleton_loader_sprite {
      width: 100px;
      height: 100px;
      background-image: url('assets/swamps_rpg/sprites/enemies/skeleton/skeleton_idle.png');
      background-repeat: no-repeat;
      animation: swamps_rpg-skeleton-loader 1s steps(8) infinite;
      image-rendering: pixelated;
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
    id = "swamps_rpg_loader",
    htmltools::tags$div(class = "skeleton_loader_sprite"),
    htmltools::tags$div("Loading Swamps RPG...")
  ),
  htmltools::tags$div(
    id = "game_start",
    htmltools::tags$div(
      class = "game_menu_panel",
      htmltools::tags$h1("SWAMPS RPG"),
      htmltools::tags$button(id = "new_game", class = "game_menu_button action-button", type = "button", "New game"),
      htmltools::tags$button(id = "show_load_game", class = "game_menu_button", type = "button", "Load game"),
      htmltools::tags$div(id = "saved_games", style = "display:none;")
    )
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
      window.renderSwampsRpgSaves = renderSaves;
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
            state: {}
          });
        };
      });
    })();
    window.addEventListener('load', function() {
      setTimeout(function() {
        var loader = document.getElementById('swamps_rpg_loader');
        if (loader) loader.style.display = 'none';
      }, 1200);
    });
  "))
)
