# shinyphaser (development version)

* Added camera follow helpers for sprites, images, rectangles, static sprites, and text scene objects so the Phaser camera can move with scene objects.

* Added new arcade example game (bear).
* Added `PhaserGame$set_world_bounds()` for configuring Phaser physics world and camera bounds from R.

* Added `StaticSprite$destroy()` for removing static sprites from the Phaser scene.

* Added initial visibility control for text objects via `PhaserGame$add_text(..., visible = FALSE)` and `Text$new(..., visible = FALSE)`.
* Added `Text$show()` and `Text$hide()` helpers for toggling text objects after creation.

* Added CRAN downloads badge to README.
* Added animated gif example to README.

# shinyphaser 0.1.0

Initial CRAN release.

* Added an R6-based `PhaserGame` API to define `Phaser.js` scenes, sprites, image assets, groups, and rectangle helpers from R.
* Added Shiny/htmltools bindings that render Phaser games in Shiny apps and synchronize game actions from R to JavaScript.
* Added a sample Shiny app, an end-to-end hedgehog example, package documentation, and test coverage for core methods and sprite behavior.
