# Sound

Create and manage audio in the Phaser scene. Created with
PhaserGame\$add_sound() method.

## Methods

### Public methods

- [`Sound$new()`](#method-Sound-new)

- [`Sound$play()`](#method-Sound-play)

- [`Sound$pause()`](#method-Sound-pause)

- [`Sound$resume()`](#method-Sound-resume)

- [`Sound$stop()`](#method-Sound-stop)

- [`Sound$set_volume()`](#method-Sound-set_volume)

- [`Sound$set_loop()`](#method-Sound-set_loop)

- [`Sound$clone()`](#method-Sound-clone)

------------------------------------------------------------------------

### Method `new()`

Load a sound file and register it with the Phaser scene.

#### Usage

    Sound$new(
      name,
      url,
      volume = 1,
      loop = FALSE,
      session = shiny::getDefaultReactiveDomain()
    )

#### Arguments

- `name`:

  Character. Unique key for the sound.

- `url`:

  Character. URL or path to the audio file.

- `volume`:

  Numeric. Initial playback volume from 0 to 1 (default: 1).

- `loop`:

  Logical. Whether the sound should loop by default (default: FALSE).

- `session`:

  Shiny session object.

------------------------------------------------------------------------

### Method `play()`

Play the sound.

#### Usage

    Sound$play(volume = NULL, loop = NULL)

#### Arguments

- `volume`:

  Numeric. Optional playback volume from 0 to 1. Defaults to the sound's
  current/default volume.

- `loop`:

  Logical. Optional loop setting for this playback. Defaults to the
  sound's current/default loop setting.

------------------------------------------------------------------------

### Method `pause()`

Pause the sound.

#### Usage

    Sound$pause()

------------------------------------------------------------------------

### Method `resume()`

Resume a paused sound.

#### Usage

    Sound$resume()

------------------------------------------------------------------------

### Method [`stop()`](https://rdrr.io/r/base/stop.html)

Stop the sound.

#### Usage

    Sound$stop()

------------------------------------------------------------------------

### Method `set_volume()`

Set the sound's volume.

#### Usage

    Sound$set_volume(volume)

#### Arguments

------------------------------------------------------------------------

### Method `set_loop()`

Set whether the sound loops by default.

#### Usage

    Sound$set_loop(loop)

#### Arguments

------------------------------------------------------------------------

### Method `clone()`

The objects of this class are cloneable with this method.

#### Usage

    Sound$clone(deep = FALSE)

#### Arguments
