# Image

Create and manage images in the Phaser scene. Created with
PhaserGame\$add_image() method.

## Methods

### Public methods

- [`Image$new()`](#method-Image-new)

- [`Image$show()`](#method-Image-show)

- [`Image$hide()`](#method-Image-hide)

- [`Image$follow_camera()`](#method-Image-follow_camera)

- [`Image$stop_camera_follow()`](#method-Image-stop_camera_follow)

- [`Image$set_scroll_factor()`](#method-Image-set_scroll_factor)

- [`Image$set_depth()`](#method-Image-set_depth)

- [`Image$click()`](#method-Image-click)

- [`Image$clone()`](#method-Image-clone)

------------------------------------------------------------------------

### Method `new()`

Add an image object to the Phaser scene.

#### Usage

    Image$new(
      name,
      url,
      x,
      y,
      visible,
      clickable,
      session = getDefaultReactiveDomain()
    )

#### Arguments

- `name`:

  Character. Unique name of the image.

- `url`:

  Character. URL or path to image file.

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

- `visible`:

  Logical. Whether image is initially visible.

- `clickable`:

  Logical. Whether image emits click events.

- `session`:

  Shiny session object.

------------------------------------------------------------------------

### Method `show()`

Show a previously added image.

#### Usage

    Image$show()

------------------------------------------------------------------------

### Method `hide()`

Hide a previously added image.

#### Usage

    Image$hide()

------------------------------------------------------------------------

### Method `follow_camera()`

Make the camera follow this image as it moves through the world.

#### Usage

    Image$follow_camera(lerp_x = 1, lerp_y = 1, round_pixels = TRUE)

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

Stop the camera from following this image.

#### Usage

    Image$stop_camera_follow()

------------------------------------------------------------------------

### Method `set_scroll_factor()`

Set how much this image scrolls with the camera.

#### Usage

    Image$set_scroll_factor(x, y = x)

#### Arguments

- `x`:

  Numeric. Horizontal scroll factor (0 = fixed to viewport, 1 = scrolls
  with world).

- `y`:

  Numeric. Vertical scroll factor. Defaults to `x`.

------------------------------------------------------------------------

### Method `set_depth()`

Set the image's rendering depth. Objects with a larger depth are
rendered in front of objects with a smaller depth.

#### Usage

    Image$set_depth(depth)

#### Arguments

- `depth`:

  Numeric. Phaser rendering depth.

#### Returns

This image object, invisibly, to support method chaining.

------------------------------------------------------------------------

### Method `click()`

Add a click event listener to the image that triggers an R function when
clicked.

#### Usage

    Image$click(event_fun, input)

#### Arguments

- `event_fun`:

  A function.

- `input`:

  Shiny input object.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Image$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
