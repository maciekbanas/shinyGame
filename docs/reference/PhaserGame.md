# PhaserGame

R6 class to create and manage a Phaser game within a Shiny application.
Provides methods for adding sprites, animations, images, backgrounds,
controls, and collision handling.

## Public fields

- `id`:

  Character. ID of the Game container. Used as the HTML element ID where
  the game canvas will be rendered.

## Methods

### Public methods

- [`PhaserGame$new()`](#method-PhaserGame-new)

- [`PhaserGame$set_shiny_session()`](#method-PhaserGame-set_shiny_session)

- [`PhaserGame$use_phaser()`](#method-PhaserGame-use_phaser)

- [`PhaserGame$add_text()`](#method-PhaserGame-add_text)

- [`PhaserGame$add_rectangle()`](#method-PhaserGame-add_rectangle)

- [`PhaserGame$add_image()`](#method-PhaserGame-add_image)

- [`PhaserGame$add_map()`](#method-PhaserGame-add_map)

- [`PhaserGame$enable_terrain_collision()`](#method-PhaserGame-enable_terrain_collision)

- [`PhaserGame$add_sprite()`](#method-PhaserGame-add_sprite)

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

    PhaserGame$new(id = "phaser_game", width = 800, height = 600)

#### Arguments

- `id`:

  Character. ID of the Game container (defaults to "phaser_game").

- `width`:

  Numeric. Width of the Phaser canvas in pixels (defaults to 800).

- `height`:

  Numeric. Height of the Phaser canvas in pixels (defaults to 600).

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

    PhaserGame$add_text(text, id, x, y, style = list(font_size = "22px"))

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
      callback_fun = NULL,
      input
    )

#### Arguments

- `object_one`:

  Character. Name of the first object.

- `object_two`:

  Character. Name of the second object.

- `group`:

  Character. Name of the group to compare against.

- `callback_fun`:

  A function to be run when collision occurs.

- `input`:

  Shiny input list.

------------------------------------------------------------------------

### Method `add_overlap()`

Adds a collider between two game objects.

#### Usage

    PhaserGame$add_overlap(
      object_one,
      object_two = NULL,
      group = NULL,
      callback_fun = NULL,
      input,
      client_action = NULL
    )

#### Arguments

- `object_one`:

  Character. Name of the first object.

- `object_two`:

  Character. Name of the second object.

- `group`:

  Character. Name of the group.

- `callback_fun`:

  Optional function to be run on the Shiny server when overlap occurs.

- `input`:

  Shiny input list.

- `client_action`:

  Optional list or list of lists describing immediate browser-side Phaser feedback to run when overlap occurs.

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
      callback_fun = NULL,
      input,
      session = shiny::getDefaultReactiveDomain(),
      client_action = NULL
    )

#### Arguments

- `object_one`:

  Character. Name of the first object.

- `object_two`:

  Character. Name of the second object.

- `group`:

  Character. Name of the group to compare against.

- `callback_fun`:

  Function. Callback executed when overlap ends.

- `input`:

  Shiny input list.

- `session`:

  Shiny session object.

- `client_action`:

  Optional list or list of lists describing immediate browser-side Phaser feedback to run when overlap ends.

------------------------------------------------------------------------

### Method `add_control()`

Register a callback fired when a specific key is pressed.

#### Usage

    PhaserGame$add_control(
      key,
      action = NULL,
      input,
      client_action = NULL
    )

#### Arguments

- `key`:

  A character, accepts Javascript key events (they need to align with
  event.code).

- `action`:

  A function to be run after key is pressed.

- `input`:

  Shiny input list.

- `client_action`:

  Optional list or list of lists describing immediate browser-side Phaser feedback to run on keydown before Shiny receives the event.

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
#> <script>initPhaserGame('my_game', {"width":1024,"height":768});</script>
```
