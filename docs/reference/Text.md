# Text

R6 class to represent a text object in the Phaser scene, allowing
dynamic updates to its content. Created with PhaserGame\$add_text()
method.

## Methods

### Public methods

- [`Text$new()`](#method-Text-new)

- [`Text$set()`](#method-Text-set)

- [`Text$show()`](#method-Text-show)

- [`Text$hide()`](#method-Text-hide)

- [`Text$follow_camera()`](#method-Text-follow_camera)

- [`Text$stop_camera_follow()`](#method-Text-stop_camera_follow)

- [`Text$set_scroll_factor()`](#method-Text-set_scroll_factor)

- [`Text$clone()`](#method-Text-clone)

------------------------------------------------------------------------

### Method `new()`

Create a text object in the Phaser scene.

#### Usage

    Text$new(
      text,
      id,
      x,
      y,
      style,
      visible = TRUE,
      session = shiny::getDefaultReactiveDomain()
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

- `session`:

  Shiny session object.

------------------------------------------------------------------------

### Method `set()`

Update the text content of this object.

#### Usage

    Text$set(text)

#### Arguments

- `text`:

  Character. New text value to display.

------------------------------------------------------------------------

### Method `show()`

Show a previously added text object.

#### Usage

    Text$show()

------------------------------------------------------------------------

### Method `hide()`

Hide a previously added text object.

#### Usage

    Text$hide()

------------------------------------------------------------------------

### Method `follow_camera()`

Make the camera follow this text object as it moves through the world.

#### Usage

    Text$follow_camera(lerp_x = 1, lerp_y = 1, round_pixels = TRUE)

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

Stop the camera from following this text object.

#### Usage

    Text$stop_camera_follow()

------------------------------------------------------------------------

### Method `set_scroll_factor()`

Set how much this text object scrolls with the camera.

#### Usage

    Text$set_scroll_factor(x, y = x)

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

    Text$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
