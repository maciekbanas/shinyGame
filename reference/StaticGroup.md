# Static Group

Create and manage groups of static sprites in the Phaser scene. Created
with PhaserGame\$add_static_group() method.

## Methods

### Public methods

- [`StaticGroup$new()`](#method-StaticGroup-new)

- [`StaticGroup$create()`](#method-StaticGroup-create)

- [`StaticGroup$show()`](#method-StaticGroup-show)

- [`StaticGroup$hide()`](#method-StaticGroup-hide)

- [`StaticGroup$disable()`](#method-StaticGroup-disable)

- [`StaticGroup$clone()`](#method-StaticGroup-clone)

------------------------------------------------------------------------

### Method `new()`

Create a static group from a base image.

#### Usage

    StaticGroup$new(name, url, session = shiny::getDefaultReactiveDomain())

#### Arguments

- `name`:

  Character. Unique name of the group.

- `url`:

  Character. URL or path to image file.

- `session`:

  Shiny session object.

------------------------------------------------------------------------

### Method `create()`

Create one static group member at a coordinate.

#### Usage

    StaticGroup$create(x, y)

#### Arguments

- `x`:

  Numeric. X-coordinate in pixels.

- `y`:

  Numeric. Y-coordinate in pixels.

------------------------------------------------------------------------

### Method `show()`

Show all current members of this static group.

#### Usage

    StaticGroup$show()

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `hide()`

Hide all current members of this static group.

#### Usage

    StaticGroup$hide()

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `disable()`

Disable a static group member body based on overlap event payload.

#### Usage

    StaticGroup$disable(evt)

#### Arguments

- `evt`:

  List-like event payload containing x2 and y2 values.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    StaticGroup$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
