# PhaserGame

R6 class to create and manage a Phaser game within a Shiny application.
Provides methods for adding sprites, animations, images, sounds,
backgrounds, controls, and collision handling.

## Public fields

- `id`:

  Character. ID of the Game container. Used as the HTML element ID where
  the game canvas will be rendered.

## Methods

### Public methods

- [`PhaserGame$new()`](#method-PhaserGame-new)

- [`PhaserGame$set_shiny_session()`](#method-PhaserGame-set_shiny_session)

- [`PhaserGame$save_game()`](#method-PhaserGame-save_game)

- [`PhaserGame$list_saved_games()`](#method-PhaserGame-list_saved_games)

- [`PhaserGame$load_game()`](#method-PhaserGame-load_game)

- [`PhaserGame$use_phaser()`](#method-PhaserGame-use_phaser)

- [`PhaserGame$add_text()`](#method-PhaserGame-add_text)

- [`PhaserGame$add_rectangle()`](#method-PhaserGame-add_rectangle)

- [`PhaserGame$add_image()`](#method-PhaserGame-add_image)

- [`PhaserGame$add_sound()`](#method-PhaserGame-add_sound)

- [`PhaserGame$add_state()`](#method-PhaserGame-add_state)

- [`PhaserGame$add_cooldown()`](#method-PhaserGame-add_cooldown)

- [`PhaserGame$add_map()`](#method-PhaserGame-add_map)

- [`PhaserGame$activate_map()`](#method-PhaserGame-activate_map)

- [`PhaserGame$add_proximity_trigger()`](#method-PhaserGame-add_proximity_trigger)

- [`PhaserGame$set_world_bounds()`](#method-PhaserGame-set_world_bounds)

- [`PhaserGame$enable_terrain_collision()`](#method-PhaserGame-enable_terrain_collision)

- [`PhaserGame$add_sprite()`](#method-PhaserGame-add_sprite)

- [`PhaserGame$add_collision_rectangle()`](#method-PhaserGame-add_collision_rectangle)

- [`PhaserGame$add_group()`](#method-PhaserGame-add_group)

- [`PhaserGame$add_static_sprite()`](#method-PhaserGame-add_static_sprite)

- [`PhaserGame$add_static_group()`](#method-PhaserGame-add_static_group)

- [`PhaserGame$add_collider()`](#method-PhaserGame-add_collider)

- [`PhaserGame$add_overlap()`](#method-PhaserGame-add_overlap)

- [`PhaserGame$are_overlap()`](#method-PhaserGame-are_overlap)

- [`PhaserGame$add_overlap_end()`](#method-PhaserGame-add_overlap_end)

- [`PhaserGame$add_control()`](#method-PhaserGame-add_control)

- [`PhaserGame$clone()`](#method-PhaserGame-clone)

------------------------------------------------------------------------

### Method `new()`

Create a PhaserGame object with the given configuration.

#### Usage

    PhaserGame$new(
      id = "phaser_game",
      width = 800,
      height = 600,
      gravity_x = 0,
      gravity_y = 0
    )

#### Arguments

- `id`:

  Character. ID of the Game container (defaults to "phaser_game").

- `width`:

  Numeric. Width of the Phaser canvas in pixels (defaults to 800).

- `height`:

  Numeric. Height of the Phaser canvas in pixels (defaults to 600).

- `gravity_x`:

  Numeric. Horizontal Arcade Physics world gravity (defaults to 0).

- `gravity_y`:

  Numeric. Vertical Arcade Physics world gravity (defaults to 0).

#### Returns

A new PhaserGame object.

#### Examples

    game <- PhaserGame$new(id = "my_game", width = 1024, height = 768)

------------------------------------------------------------------------

### Method `set_shiny_session()`

Set the Shiny session used to send Phaser custom messages.

#### Usage

    PhaserGame$set_shiny_session(session = shiny::getDefaultReactiveDomain())

#### Arguments

- `session`:

  Shiny session object (default: shiny::getDefaultReactiveDomain()).

------------------------------------------------------------------------

### Method `save_game()`

Save game data and Phaser object state to a JSON file on the server.
Positions are read directly from Phaser immediately before the save
request, avoiding stale Shiny coordinates.

#### Usage

    PhaserGame$save_game(
      name,
      state = list(),
      objects = NULL,
      snapshot = NULL,
      directory = NULL
    )

#### Arguments

- `name`:

  Character. Human-readable name of the save.

- `state`:

  Named list. Additional JSON-serializable application state.

- `objects`:

  Character vector. Named Phaser scene objects to capture. By default
  all named scene objects are captured.

- `snapshot`:

  Named list. Optional Phaser object snapshot already captured in the
  browser. Supplying it writes the save synchronously.

- `directory`:

  Character. Server-side directory. Defaults to a game-specific folder
  below [`tempdir()`](https://rdrr.io/r/base/tempfile.html).

#### Returns

Invisible request identifier. The disk write completes asynchronously
after Phaser returns its snapshot.

------------------------------------------------------------------------

### Method `list_saved_games()`

List saves stored on the server for this game.

#### Usage

    PhaserGame$list_saved_games(directory = NULL)

#### Arguments

- `directory`:

  Character. Server-side save directory.

#### Returns

A list of saved game records, newest first.

------------------------------------------------------------------------

### Method `load_game()`

Load a saved game from server disk.

#### Usage

    PhaserGame$load_game(name, restore = TRUE, directory = NULL)

#### Arguments

- `name`:

  Character. Save name.

- `restore`:

  Logical. Restore captured Phaser object properties.

- `directory`:

  Character. Server-side save directory.

#### Returns

The additional application state stored with the save, invisibly.

------------------------------------------------------------------------

### Method `use_phaser()`

Load dependencies and initialize the Phaser game in the UI.

#### Usage

    PhaserGame$use_phaser()

#### Returns

HTML tag list containing dependencies and initialization script.

#### Examples

     game$use_phaser()

------------------------------------------------------------------------

### Method `add_text()`

Add a text object to the Phaser scene.

#### Usage

    PhaserGame$add_text(
      text,
      id,
      x,
      y,
      style = list(font_size = "22px"),
      visible = TRUE
    )

#### Arguments

- `text`:

  Character. Text value to display.

- `id`:

  Character. Unique ID for the text object.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

- `style`:

  Named list. Styling options passed to Phaser text rendering.

- `visible`:

  Logical. Whether text is initially visible.

------------------------------------------------------------------------

### Method `add_rectangle()`

Add a rectangle object to the Phaser scene.

#### Usage

    PhaserGame$add_rectangle(
      name,
      x,
      y,
      width,
      height,
      color,
      visible = TRUE,
      clickable = FALSE
    )

#### Arguments

- `name`:

  Character. Unique name for the rectangle.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

- `width`:

  Numeric. Rectangle width in pixels.

- `height`:

  Numeric. Rectangle height in pixels.

- `color`:

  Character. Fill color in Phaser-compatible format.

- `visible`:

  Logical. Whether rectangle is initially visible.

- `clickable`:

  Logical. Whether rectangle emits click events.

------------------------------------------------------------------------

### Method `add_image()`

Adds a static image to the Phaser scene.

#### Usage

    PhaserGame$add_image(name, url, x, y, visible = TRUE, clickable = FALSE)

#### Arguments

- `name`:

  Character. Unique key to reference this image.

- `url`:

  Character. URL or path to the image file.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

- `visible`:

  Logical. Whether the image is initially visible (default: TRUE).

- `clickable`:

  Logical. Whether the image should emit click events (default: FALSE).

------------------------------------------------------------------------

### Method `add_sound()`

Adds a sound to the Phaser scene.

#### Usage

    PhaserGame$add_sound(name, url, volume = 1, loop = FALSE)

#### Arguments

- `name`:

  Character. Unique key to reference this sound.

- `url`:

  Character. URL or path to the audio file.

- `volume`:

  Numeric. Initial playback volume from 0 to 1 (default: 1).

- `loop`:

  Logical. Whether the sound should loop by default (default: FALSE).

------------------------------------------------------------------------

### Method `add_state()`

Create browser-resident state for use in browser actions.

#### Usage

    PhaserGame$add_state(key, initial = NULL)

#### Arguments

- `key`:

  Character. Unique state key.

- `initial`:

  Initial JSON-serializable value.

------------------------------------------------------------------------

### Method `add_cooldown()`

Create a browser-resident cooldown for browser-action conditions.

#### Usage

    PhaserGame$add_cooldown(key, duration)

#### Arguments

- `key`:

  Character. Unique cooldown key.

- `duration`:

  Numeric. Cooldown duration in milliseconds.

------------------------------------------------------------------------

### Method `add_map()`

Add a background (tilemap) layer from Tiled JSON + tileset image(s).

#### Usage

    PhaserGame$add_map(map_key, map_url, tileset_urls, tileset_names, layer_name)

#### Arguments

- `map_key`:

  Character. Key for the tilemap JSON.

- `map_url`:

  Character. URL of the Tiled JSON file (relative to www/assets/).

- `tileset_urls`:

  Character vector. URLs of tileset image files.

- `tileset_names`:

  Character vector. Names of tilesets as defined in Tiled.

- `layer_name`:

  Character. Name of the layer to render from Tiled.

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `activate_map()`

Activate a tilemap previously loaded with `add_map()`.

#### Usage

    PhaserGame$activate_map(
      map_key,
      player_name = NULL,
      x = NULL,
      y = NULL,
      visible_objects = character(),
      hidden_objects = character()
    )

#### Arguments

- `map_key`:

  Character. Key of the tilemap to activate.

- `player_name`:

  Character. Optional player sprite to reposition.

- `x`:

  Numeric. Optional player x-coordinate.

- `y`:

  Numeric. Optional player y-coordinate.

- `visible_objects`:

  Character vector. Scene objects to show and enable.

- `hidden_objects`:

  Character vector. Scene objects to hide and disable.

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `add_proximity_trigger()`

Add a trigger that monitors when a scene object is near a point.

#### Usage

    PhaserGame$add_proximity_trigger(
      id,
      object_name,
      x,
      y,
      radius = 180,
      element_id = NULL,
      context = NULL,
      input_id = NULL
    )

#### Arguments

- `id`:

  Character. Unique trigger identifier.

- `object_name`:

  Character. Scene object whose position is monitored.

- `x`:

  Numeric. Target x-coordinate.

- `y`:

  Numeric. Target y-coordinate.

- `radius`:

  Numeric. Maximum distance at which the trigger is active.

- `element_id`:

  Character or `NULL`. ID of an HTML element to show while the trigger
  is active.

- `context`:

  Character or `NULL`. Optional map key that must be active for the
  trigger to be evaluated.

- `input_id`:

  Character or `NULL`. Optional Shiny input that receives a payload
  whenever the trigger is entered or exited.

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `set_world_bounds()`

Set the Phaser physics world and camera bounds.

#### Usage

    PhaserGame$set_world_bounds(width, height)

#### Arguments

- `width`:

  Numeric. World width in pixels.

- `height`:

  Numeric. World height in pixels.

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `enable_terrain_collision()`

Enable terrain collision for a player sprite.

#### Usage

    PhaserGame$enable_terrain_collision(name)

#### Arguments

- `name`:

  Character. Name of the player sprite (as added via add_player_sprite).

------------------------------------------------------------------------

### Method `add_sprite()`

Load a base spritesheet and create an "idle" animation.

#### Usage

    PhaserGame$add_sprite(
      name,
      url,
      x,
      y,
      frame_width,
      frame_height,
      frame_count = 1,
      frame_rate = 1
    )

#### Arguments

- `name`:

  Character. Unique key for the sprite and its idle animation.

- `url`:

  Character. URL or path to the spritesheet image.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

- `frame_width`:

  Numeric. Width of each frame.

- `frame_height`:

  Numeric. Height of each frame.

- `frame_count`:

  Numeric. Number of frames in the spritesheet.

- `frame_rate`:

  Numeric. Frames per second for the idle animation.

------------------------------------------------------------------------

### Method `add_collision_rectangle()`

Add an invisible static collision rectangle to the world.

#### Usage

    PhaserGame$add_collision_rectangle(name, x, y, width, height)

#### Arguments

- `name`:

  Character. Unique name of the collision rectangle.

- `x`:

  Numeric. X-coordinate of its center.

- `y`:

  Numeric. Y-coordinate of its center.

- `width`:

  Numeric. Collision width in pixels.

- `height`:

  Numeric. Collision height in pixels.

------------------------------------------------------------------------

### Method `add_group()`

Adds a dynamic group from a spritesheet.

#### Usage

    PhaserGame$add_group(name)

#### Arguments

- `name`:

  Character. Unique name of the group.

------------------------------------------------------------------------

### Method `add_static_sprite()`

Adds a static sprite to the scene (non-animated).

#### Usage

    PhaserGame$add_static_sprite(name, url, x, y)

#### Arguments

- `name`:

  Character. Unique name of the sprite.

- `url`:

  Character. URL or path to the image file.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

------------------------------------------------------------------------

### Method `add_static_group()`

Adds a static group to the scene (non-animated).

#### Usage

    PhaserGame$add_static_group(name, url)

#### Arguments

- `name`:

  Character. Unique name of the group.

- `url`:

  Character. URL or path to the image file.

------------------------------------------------------------------------

### Method `add_collider()`

Adds a collider between two game objects.

#### Usage

    PhaserGame$add_collider(
      object_one,
      object_two = NULL,
      group = NULL,
      browser_action = browser_actions(),
      input = NULL,
      server_action = NULL
    )

#### Arguments

- `object_one`:

  Character. Name of the first object.

- `object_two`:

  Character. Name of the second object.

- `group`:

  Character. Name of the group to compare against.

- `browser_action`:

  Actions created with [`browser_actions()`](browser_actions.md) that
  run immediately in the browser.

- `input`:

  Shiny input list.

- `server_action`:

  Function called in R with the collision event.

------------------------------------------------------------------------

### Method `add_overlap()`

Adds a collider between two game objects.

#### Usage

    PhaserGame$add_overlap(
      object_one,
      object_two = NULL,
      group = NULL,
      browser_action = browser_actions(),
      input = NULL,
      server_action = NULL,
      mode = c("enter", "stay"),
      interval = 0
    )

#### Arguments

- `object_one`:

  Character. Name of the first object.

- `object_two`:

  Character. Name of the second object.

- `group`:

  Character. Name of the group.

- `browser_action`:

  Actions created with [`browser_actions()`](browser_actions.md) that
  run immediately in the browser.

- `input`:

  Shiny input list.

- `server_action`:

  Function called in R with the overlap event.

- `mode`:

  Character. `"enter"` (default) runs once per contact; `"stay"` repeats
  while overlapping.

- `interval`:

  Numeric. Minimum milliseconds between `"stay"` actions.

------------------------------------------------------------------------

### Method `are_overlap()`

Create a reactive expression for overlap state between two objects.

#### Usage

    PhaserGame$are_overlap(object_one, object_two, input)

#### Arguments

- `object_one`:

  Character. Name of the first object.

- `object_two`:

  Character. Name of the second object.

- `input`:

  Shiny input list.

------------------------------------------------------------------------

### Method `add_overlap_end()`

Register a callback fired when overlap between objects ends.

#### Usage

    PhaserGame$add_overlap_end(
      object_one,
      object_two = NULL,
      group = NULL,
      browser_action = browser_actions(),
      input = NULL,
      server_action = NULL,
      session = shiny::getDefaultReactiveDomain()
    )

#### Arguments

- `object_one`:

  Character. Name of the first object.

- `object_two`:

  Character. Name of the second object.

- `group`:

  Character. Name of the group to compare against.

- `browser_action`:

  Actions created with [`browser_actions()`](browser_actions.md) that
  run immediately in the browser.

- `input`:

  Shiny input list.

- `server_action`:

  Function called in R with the overlap-end event.

- `session`:

  Shiny session object.

------------------------------------------------------------------------

### Method `add_control()`

Register a callback fired when a specific key is pressed.

#### Usage

    PhaserGame$add_control(
      key,
      browser_action = browser_actions(),
      input = NULL,
      server_action = NULL
    )

#### Arguments

- `key`:

  A character, accepts Javascript key events (they need to align with
  event.code).

- `browser_action`:

  Actions created with [`browser_actions()`](browser_actions.md) that
  run immediately in the browser.

- `input`:

  Shiny input list.

- `server_action`:

  Function called in R with the keyboard event.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    PhaserGame$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r

## ------------------------------------------------
## Method `PhaserGame$new`
## ------------------------------------------------

game <- PhaserGame$new(id = "my_game", width = 1024, height = 768)

## ------------------------------------------------
## Method `PhaserGame$use_phaser`
## ------------------------------------------------

 game$use_phaser()
#> <div id="my_game" style="width:100vw; height:100vh;"></div>
#> <script>initPhaserGame('my_game', {"width":1024,"height":768,"gravity_x":0,"gravity_y":0});</script>
```
