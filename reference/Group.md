# Group

Create and manage groups of sprites in the Phaser scene. Created with
PhaserGame\$add_group() method.

## Methods

### Public methods

- [`Group$new()`](#method-Group-new)

- [`Group$add_animation()`](#method-Group-add_animation)

- [`Group$create()`](#method-Group-create)

- [`Group$show()`](#method-Group-show)

- [`Group$hide()`](#method-Group-hide)

- [`Group$clone()`](#method-Group-clone)

------------------------------------------------------------------------

### Method `new()`

Create a dynamic group in the Phaser scene.

#### Usage

    Group$new(name, session = shiny::getDefaultReactiveDomain())

#### Arguments

- `name`:

  Character. Unique name of the group.

- `session`:

  Shiny session object.

------------------------------------------------------------------------

### Method `add_animation()`

Add an animation that can be used by members of this group.

#### Usage

    Group$add_animation(
      suffix,
      url,
      frame_width,
      frame_height,
      frame_count,
      frame_rate
    )

#### Arguments

- `suffix`:

  Character. Animation suffix/key.

- `url`:

  Character. URL or path to spritesheet.

- `frame_width`:

  Numeric. Width of each frame.

- `frame_height`:

  Numeric. Height of each frame.

- `frame_count`:

  Numeric. Number of frames.

- `frame_rate`:

  Numeric. Frames per second.

------------------------------------------------------------------------

### Method `create()`

Create one group member at a coordinate.

#### Usage

    Group$create(x, y)

#### Arguments

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

------------------------------------------------------------------------

### Method `show()`

Show all current members of this group.

#### Usage

    Group$show()

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `hide()`

Hide all current members of this group.

#### Usage

    Group$hide()

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Group$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
