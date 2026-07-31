# shinyphaser (development version)

* Split event handling into explicit `browser_action` and `server_action`
  parameters. Browser-side calls must now be declared with `browser_actions()`,
  while arbitrary R logic belongs in a server action.
* Removed `action` and `notify_server` from controls, overlaps, overlap-end
  handlers, and colliders.
* Added a vignette explaining when to use browser actions, server actions, or
  both together.

## Performance improvements
* Reduced high-frequency overlap traffic by keeping immediate actions in the browser and registering server events only when a `server_action` is supplied.
* Added explicit `browser_action` declarations for immediate browser-side overlap and collision reactions.
* Extended browser actions with browser state, cooldowns, restricted conditionals,
  overlap/existence predicates, alerts, semantic events, and immediate key controls.
* Overlaps are edge-triggered by default and notify Shiny only when a
  `server_action` is supplied; sustained handlers can use `mode = "stay"` and
  `interval` throttling.
* Moved sprite movement delays from blocking R sleeps to browser timers.
* Queued sprite physics actions until sprites finish loading so setup calls such as `set_gravity()` are not lost during asynchronous asset initialization.

## New interface features
* Added `gravity_x` and `gravity_y` parameters to `PhaserGame$new()` for configuring Arcade Physics world gravity when a game is created.
* Added sound support with `PhaserGame$add_sound()` and a new `Sound` API for loading, playing, pausing, resuming, stopping, and configuring audio.
* Added `set_scroll_factor()` helpers for scene objects so HUD-style elements can stay fixed while the camera follows another target.
* Added camera follow helpers for sprites, images, rectangles, static sprites, and text scene objects so the Phaser camera can move with scene objects.
* Added `PhaserGame$set_world_bounds()` for configuring Phaser physics world and camera bounds from R.
* Added `StaticSprite$destroy()` for removing static sprites from the Phaser scene.
* Added `Sprite$stop_motion()` for immediately cancelling scripted sprite
  movement, including from `browser_actions()`.
* Added initial visibility control for text objects via `PhaserGame$add_text(..., visible = FALSE)` and `Text$new(..., visible = FALSE)`.
* Added `Text$show()` and `Text$hide()` helpers for toggling text objects after creation.

## Updates in examples
* Added new arcade example game (bear).
* Added new RPG game example (dungeonheroes).
* Updated dungeonheroes mushroom enemies to react immediately on sight and keep
  their movement, alert, and attack animations synchronized with combat.
* Updated the hedgehog examples so acknowledging a game-over dialog reloads the Shiny session and starts a fresh game instead of stopping the app.

## README
* Added CRAN downloads badge to README.
* Added animated gif example to README.

# shinyphaser 0.1.0

Initial CRAN release.

* Added an R6-based `PhaserGame` API to define `Phaser.js` scenes, sprites, image assets, groups, and rectangle helpers from R.
* Added Shiny/htmltools bindings that render Phaser games in Shiny apps and synchronize game actions from R to JavaScript.
* Added a sample Shiny app, an end-to-end hedgehog example, package documentation, and test coverage for core methods and sprite behavior.
