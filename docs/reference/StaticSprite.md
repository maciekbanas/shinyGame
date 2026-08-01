# Static Sprite

Create and manage non-animated sprites in the Phaser scene. Created with
PhaserGame\$add_static_sprite() method.

## Methods

### Public methods

- [`StaticSprite$new()`](#method-StaticSprite-new)

- [`StaticSprite$destroy()`](#method-StaticSprite-destroy)

- [`StaticSprite$follow_camera()`](#method-StaticSprite-follow_camera)

- [`StaticSprite$stop_camera_follow()`](#method-StaticSprite-stop_camera_follow)

- [`StaticSprite$set_scroll_factor()`](#method-StaticSprite-set_scroll_factor)

- [`StaticSprite$clone()`](#method-StaticSprite-clone)

------------------------------------------------------------------------

### Method `new()`

Add a non-animated static sprite to the scene.

#### Usage

    StaticSprite$new(name, url, x, y, session = getDefaultReactiveDomain())

#### Arguments

- `name`:

  Character. Unique name of the sprite.

- `url`:

  Character. URL or path to image file.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

- `session`:

  Shiny session object.

------------------------------------------------------------------------

### Method `destroy()`

Remove static sprite from the scene.

#### Usage

    StaticSprite$destroy()

------------------------------------------------------------------------

### Method `follow_camera()`

Make the camera follow this static sprite as it moves through the world.

#### Usage

    StaticSprite$follow_camera(lerp_x = 1, lerp_y = 1, round_pixels = TRUE)

#### Arguments

- `lerp_x`:

  Numeric. Horizontal interpolation factor from 0 to 1 (default: 1).

- `lerp_y`:

  Numeric. Vertical interpolation factor from 0 to 1 (default: 1).

- `round_pixels`:

  Logical. Whether to round camera pixels to avoid sub-pixel rendering
  (default: TRUE).

------------------------------------------------------------------------

### Method `stop_camera_follow()`

Stop the camera from following this static sprite.

#### Usage

    StaticSprite$stop_camera_follow()

------------------------------------------------------------------------

### Method `set_scroll_factor()`

Set how much this static sprite scrolls with the camera.

#### Usage

    StaticSprite$set_scroll_factor(x, y = x)

#### Arguments

- `x`:

  Numeric. Horizontal scroll factor (0 = fixed to viewport, 1 = scrolls
  with world).

- `y`:

  Numeric. Vertical scroll factor. Defaults to `x`.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    StaticSprite$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
