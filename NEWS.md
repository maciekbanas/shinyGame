# shinyphaser (development version)

## Performance improvements
* Optimized Phaser collision and overlap callbacks by routing high-frequency events through Shiny data endpoints backed by `promises`, with a client-side fallback to `Shiny.setInputValue()`.
* Added a `client_action` parameter to `PhaserGame$add_overlap()`, `PhaserGame$add_overlap_end()`, and `PhaserGame$add_control()` so browser-side Phaser feedback can run immediately before Shiny callbacks are processed.
* Queued sprite physics actions until sprites finish loading so setup calls such as `set_gravity()` are not lost during asynchronous asset initialization.

## New interface features
* Added sound support with `PhaserGame$add_sound()` and a new `Sound` API for loading, playing, pausing, resuming, stopping, and configuring audio.
* Added `set_scroll_factor()` helpers for scene objects so HUD-style elements can stay fixed while the camera follows another target.
* Added camera follow helpers for sprites, images, rectangles, static sprites, and text scene objects so the Phaser camera can move with scene objects.
* Added `PhaserGame$set_world_bounds()` for configuring Phaser physics world and camera bounds from R.
* Added `StaticSprite$destroy()` for removing static sprites from the Phaser scene.
* Added initial visibility control for text objects via `PhaserGame$add_text(..., visible = FALSE)` and `Text$new(..., visible = FALSE)`.
* Added `Text$show()` and `Text$hide()` helpers for toggling text objects after creation.

## Updates in examples
* Added new arcade example game (bear).
* Added new RPG game example (dungeonheroes).
* Updated the hedgehog examples so acknowledging a game-over dialog reloads the Shiny session and starts a fresh game instead of stopping the app.

## README
* Added CRAN downloads badge to README.
* Added animated gif example to README.

# shinyphaser 0.1.0

Initial CRAN release.

* Added an R6-based `PhaserGame` API to define `Phaser.js` scenes, sprites, image assets, groups, and rectangle helpers from R.
* Added Shiny/htmltools bindings that render Phaser games in Shiny apps and synchronize game actions from R to JavaScript.
* Added a sample Shiny app, an end-to-end hedgehog example, package documentation, and test coverage for core methods and sprite behavior.
