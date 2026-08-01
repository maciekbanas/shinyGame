# Rectangle

Create and manage rectangles in the Phaser scene. Created with
PhaserGame\$add_rectangle() method.

## Methods

### Public methods

- [`Rectangle$new()`](#method-Rectangle-new)

- [`Rectangle$show()`](#method-Rectangle-show)

- [`Rectangle$hide()`](#method-Rectangle-hide)

- [`Rectangle$follow_camera()`](#method-Rectangle-follow_camera)

- [`Rectangle$stop_camera_follow()`](#method-Rectangle-stop_camera_follow)

- [`Rectangle$set_scroll_factor()`](#method-Rectangle-set_scroll_factor)

- [`Rectangle$click()`](#method-Rectangle-click)

- [`Rectangle$clone()`](#method-Rectangle-clone)

------------------------------------------------------------------------

### Method `new()`

Add a rectangle object to the Phaser scene.

#### Usage

    Rectangle$new(
      name,
      x,
      y,
      width,
      height,
      color,
      visible,
      clickable,
      session = getDefaultReactiveDomain()
    )

#### Arguments

- `name`:

  Character. Unique name of the rectangle.

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

- `session`:

  Shiny session object.

------------------------------------------------------------------------

### Method `show()`

Show a previously added rectangle.

#### Usage

    Rectangle$show()

------------------------------------------------------------------------

### Method `hide()`

Hide a previously added rectangle.

#### Usage

    Rectangle$hide()

------------------------------------------------------------------------

### Method `follow_camera()`

Make the camera follow this rectangle as it moves through the world.

#### Usage

    Rectangle$follow_camera(lerp_x = 1, lerp_y = 1, round_pixels = TRUE)

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

Stop the camera from following this rectangle.

#### Usage

    Rectangle$stop_camera_follow()

------------------------------------------------------------------------

### Method `set_scroll_factor()`

Set how much this rectangle scrolls with the camera.

#### Usage

    Rectangle$set_scroll_factor(x, y = x)

#### Arguments

- `x`:

  Numeric. Horizontal scroll factor (0 = fixed to viewport, 1 = scrolls
  with world).

- `y`:

  Numeric. Vertical scroll factor. Defaults to `x`.

------------------------------------------------------------------------

### Method `click()`

Add a click event listener to the rectangle that triggers an R function
when clicked.

#### Usage

    Rectangle$click(event_fun, input)

#### Arguments

- `event_fun`:

  A function.

- `input`:

  Shiny input object.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Rectangle$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
