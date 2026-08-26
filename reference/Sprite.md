# Sprite

Create and manage animated sprites in the Phaser scene. Created with
PhaserGame\$add_sprite() method.

## Methods

### Public methods

- [`Sprite$new()`](#method-Sprite-new)

- [`Sprite$add_animation()`](#method-Sprite-add_animation)

- [`Sprite$play_animation()`](#method-Sprite-play_animation)

- [`Sprite$stop_motion()`](#method-Sprite-stop_motion)

- [`Sprite$show()`](#method-Sprite-show)

- [`Sprite$hide()`](#method-Sprite-hide)

- [`Sprite$add_player_controls()`](#method-Sprite-add_player_controls)

- [`Sprite$set_player_animation_prefix()`](#method-Sprite-set_player_animation_prefix)

- [`Sprite$follow_camera()`](#method-Sprite-follow_camera)

- [`Sprite$stop_camera_follow()`](#method-Sprite-stop_camera_follow)

- [`Sprite$set_scroll_factor()`](#method-Sprite-set_scroll_factor)

- [`Sprite$set_depth()`](#method-Sprite-set_depth)

- [`Sprite$set_velocity_x()`](#method-Sprite-set_velocity_x)

- [`Sprite$set_velocity_y()`](#method-Sprite-set_velocity_y)

- [`Sprite$set_gravity()`](#method-Sprite-set_gravity)

- [`Sprite$set_bounce()`](#method-Sprite-set_bounce)

- [`Sprite$destroy()`](#method-Sprite-destroy)

- [`Sprite$set_in_motion()`](#method-Sprite-set_in_motion)

- [`Sprite$start_approach_on_sight()`](#method-Sprite-start_approach_on_sight)

- [`Sprite$clone()`](#method-Sprite-clone)

------------------------------------------------------------------------

### Method `new()`

#### Usage

    Sprite$new(
      name,
      url,
      x,
      y,
      frame_width,
      frame_height,
      frame_count = NULL,
      frame_rate,
      session = getDefaultReactiveDomain()
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

  Numeric. Number of frames in the spritesheet. If NULL, auto-detect
  from spritesheet dimensions.

- `frame_rate`:

  Numeric. Frames per second for the idle animation.

- `session`:

  Shiny session object.

------------------------------------------------------------------------

### Method `add_animation()`

Load a custom animation for any sprite previously added.

#### Usage

    Sprite$add_animation(
      suffix,
      url,
      frame_width,
      frame_height,
      frame_count = NULL,
      frame_rate
    )

#### Arguments

- `suffix`:

  Character. Identifier for this animation (e.g. "move_left").

- `url`:

  Character. URL or path to the spritesheet.

- `frame_width`:

  Numeric. Width of each frame.

- `frame_height`:

  Numeric. Height of each frame.

- `frame_count`:

  Numeric. Number of frames in the spritesheet. If NULL, auto-detect
  from spritesheet dimensions.

- `frame_rate`:

  Numeric. Frames per second for playback.

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `play_animation()`

Play a loaded animation for the sprite.

#### Usage

    Sprite$play_animation(anim_name, duration = Inf)

#### Arguments

- `anim_name`:

  Character. Identifier for the animation to play (e.g. " move_left").

- `duration`:

  Numeric. Optional duration in milliseconds to play the animation
  before reverting to idle (defaults to Inf, which loops indefinitely
  until another animation is played).

------------------------------------------------------------------------

### Method `stop_motion()`

Stop this sprite's current scripted movement.

#### Usage

    Sprite$stop_motion()

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `show()`

Show this sprite.

#### Usage

    Sprite$show()

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `hide()`

Hide this sprite.

#### Usage

    Sprite$hide()

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `add_player_controls()`

Enable movement controls (arrow keys) for a player sprite.

#### Usage

    Sprite$add_player_controls(
      directions = c("left", "right", "down", "up"),
      speed = 200
    )

#### Arguments

- `directions`:

  Character vector. Directions to enable (defaults to
  c("left","right","down","up")).

- `speed`:

  Numeric. Movement speed in pixels/second (default: 200).

------------------------------------------------------------------------

### Method `set_player_animation_prefix()`

Choose the animation prefix used by player controls.

#### Usage

    Sprite$set_player_animation_prefix(prefix)

#### Arguments

- `prefix`:

  Character. Prefix for idle and directional movement animation keys.

#### Returns

Invisible; sends a custom message to the client.

------------------------------------------------------------------------

### Method `follow_camera()`

Make the camera follow this sprite as it moves through the world.

#### Usage

    Sprite$follow_camera(lerp_x = 1, lerp_y = 1, round_pixels = TRUE)

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

Stop the camera from following this sprite.

#### Usage

    Sprite$stop_camera_follow()

------------------------------------------------------------------------

### Method `set_scroll_factor()`

Set how much this sprite scrolls with the camera.

#### Usage

    Sprite$set_scroll_factor(x, y = x)

#### Arguments

- `x`:

  Numeric. Horizontal scroll factor (0 = fixed to viewport, 1 = scrolls
  with world).

- `y`:

  Numeric. Vertical scroll factor. Defaults to `x`.

------------------------------------------------------------------------

### Method `set_depth()`

Set the sprite's rendering depth. Objects with a larger depth are
rendered in front of objects with a smaller depth.

#### Usage

    Sprite$set_depth(depth)

#### Arguments

- `depth`:

  Numeric. Phaser rendering depth.

#### Returns

This sprite object, invisibly, to support method chaining.

------------------------------------------------------------------------

### Method `set_velocity_x()`

Set the sprite's velocity in the x direction.

#### Usage

    Sprite$set_velocity_x(x = 100)

#### Arguments

- `x`:

  Numeric. Velocity in pixels/second (positive = right, negative =
  left).

------------------------------------------------------------------------

### Method `set_velocity_y()`

Set the sprite's velocity in the y direction.

#### Usage

    Sprite$set_velocity_y(x = 100)

#### Arguments

- `x`:

  Numeric. Velocity in pixels/second (positive = down, negative = up).

------------------------------------------------------------------------

### Method `set_gravity()`

Set the sprite's velocity in both x and y directions.

#### Usage

    Sprite$set_gravity(x = 100, y = 100)

#### Arguments

- `x`:

  Numeric. Velocity in pixels/second (positive = right, negative =
  left).

- `y`:

  Numeric. Velocity in pixels/second (positive = down, negative = up).

------------------------------------------------------------------------

### Method `set_bounce()`

Set the sprite's bounce factor.

#### Usage

    Sprite$set_bounce(x)

#### Arguments

- `x`:

  Numeric. Bounce factor.

------------------------------------------------------------------------

### Method `destroy()`

Remove sprite from the scene.

#### Usage

    Sprite$destroy()

------------------------------------------------------------------------

### Method `set_in_motion()`

Move sprite along a vector for a set distance.

#### Usage

    Sprite$set_in_motion(dir_x, dir_y, speed, distance, lag = distance/speed)

#### Arguments

- `dir_x`:

  Numeric. Horizontal direction (-1 = left, +1 = right, 0 = none).

- `dir_y`:

  Numeric. Vertical direction (-1 = up, +1 = down, 0 = none).

- `speed`:

  Numeric. Speed in pixels/second.

- `distance`:

  Numeric. Distance in pixels to travel before stopping.

- `lag`:

  Numeric. Optional delay before sending the command (defaults to
  distance/speed).

------------------------------------------------------------------------

### Method `start_approach_on_sight()`

Start client-side sight checks that make this sprite alert, wander while
the target is out of range, and approach the target when it is in range.
This is a reusable browser-side behaviour rather than an RPG-specific
rule.

#### Usage

    Sprite$start_approach_on_sight(
      target_name,
      sight_range,
      speed,
      distance,
      check_interval = 250,
      alert_duration = 1200,
      wander_interval = 1500
    )

#### Arguments

- `target_name`:

  Character. Name of the target sprite to approach.

- `sight_range`:

  Numeric. Maximum distance in pixels at which the target is noticed.

- `speed`:

  Numeric. Approach speed in pixels/second.

- `distance`:

  Numeric. Distance in pixels to travel for each approach step.

- `check_interval`:

  Numeric. Milliseconds between sight checks.

- `alert_duration`:

  Numeric. Milliseconds to show the alert while approaching.

- `wander_interval`:

  Numeric. Milliseconds between random movements while the target is out
  of sight.

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Sprite$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
