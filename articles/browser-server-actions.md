# Choose between browser and server actions

Event handlers in **shinyphaser** can do work in two different places:

- `browser_action` runs immediately in the player’s browser; and
- `server_action` runs as ordinary R code in the Shiny server session.

You can use either one or both. The right choice depends on whether the
work needs low latency, arbitrary R code, or authoritative server state.

## Quick decision guide

| Use | Best for | Important constraint |
|----|----|----|
| `browser_action` | Animations, sound, movement, text changes, and other immediate feedback | Only supported shinyphaser methods and browser-action conditions can be used |
| `server_action` | Reactive state, databases, files, R packages, validation, and game rules managed by R | Requires a browser-to-server round trip |
| Both | Immediate feedback followed by authoritative R processing | The browser action runs without waiting for the server action |

A useful rule is: **show feedback in the browser, but make important
decisions on the server**.

## Browser actions

Declare browser work with the
[`browser_actions()`](../reference/browser_actions.md) constructor. It
captures the calls without running them in R and compiles them into
commands understood by the JavaScript game runtime.

``` r

game$add_control(
  key = "Space",
  browser_action = browser_actions(
    jump_sound$play(),
    hero$set_velocity_y(-600),
    hero$play_animation("hero_jump", duration = 250)
  )
)
```

This is appropriate for a jump because the player should see and hear it
as soon as the key is pressed. No Shiny input event is emitted when an
event has only a browser action.

[`browser_actions()`](../reference/browser_actions.md) is not a general
R expression evaluator. For example, it cannot update a `reactiveVal()`,
query a database, read a file, or call an arbitrary R helper:

``` r

# Not valid browser work
game$add_control(
  key = "Space",
  browser_action = browser_actions(
    score(score() + 1),
    save_score_to_database()
  )
)
```

Move such work to `server_action` instead. Unsupported browser calls
fail when the handler is registered rather than silently falling back to
the server.

### Supported browser expressions

The following table is the complete browser-action surface. Methods not
listed here are ordinary server-side methods and cannot be placed in
[`browser_actions()`](../reference/browser_actions.md).

| Object | Supported methods inside [`browser_actions()`](../reference/browser_actions.md) |
|----|----|
| `Text` | `show()`, `hide()`, `set()` |
| `Image`, `Rectangle` | `show()`, `hide()` |
| `Sound` | `play()`, `pause()`, `resume()`, [`stop()`](https://rdrr.io/r/base/stop.html) |
| `Sprite` | `show()`, `hide()`, `play_animation()`, `set_in_motion()`, `set_velocity_x()`, `set_velocity_y()`, `stop_motion()`, `add_player_controls()`, `destroy()` |
| `StaticSprite` | `show()`, `hide()`, `destroy()` |
| `Group` | `show()`, `hide()` |
| `StaticGroup` | `show()`, `hide()`, `disable()` |
| Browser state returned by `game$add_state()` | `set()`, `increment()`, `decrement()`, `add()`, `subtract()` |
| Browser cooldown returned by `game$add_cooldown()` | `trigger()` |
| `PhaserGame` | `alert()`, `emit()`, `after()` |

An `if` block may combine `&&`, `||`, `!`, and the comparison operators
`==`, `!=`, `<`, `<=`, `>`, and `>=`. Conditions may call `overlaps()`
or [`exists()`](https://rdrr.io/r/base/exists.html) on scene objects,
`is_true()` or `is_false()` on browser state, and `ready()` on a browser
cooldown. These condition and state/cooldown methods are a small R-like
language captured by
[`browser_actions()`](../reference/browser_actions.md); do not call them
as ordinary R methods outside an action block.

Literal values, local scalar values, and named arguments are supported.
Code that calls any other function, mutates an R object, or depends on a
reactive value belongs in `server_action`.

## Server actions

A server action is a function that receives the event sent by the
browser. It can contain ordinary R code and use the rest of the Shiny
server environment. Pass the Shiny `input` object whenever you register
one.

``` r

score <- shiny::reactiveVal(0)

game$add_overlap(
  object_one = "hero",
  object_two = "coin",
  input = input,
  server_action = function(event) {
    score(score() + 1)
    saveRDS(score(), "score.rds")
  }
)
```

Supplying `server_action` automatically enables the corresponding
browser-to- server event. You do not need to create a separate
`observeEvent()` for the generated input ID.

The event payload depends on the handler. An overlap event can include
object coordinates, while a keyboard event includes its key code. Name
the argument even when a callback does not need its value:

``` r

game$add_control(
  key = "Space",
  input = input,
  server_action = function(event) {
    showNotification(paste("Pressed", event$code))
  }
)
```

## Use both for responsive, server-authoritative behavior

Some interactions need immediate feedback and server processing. Supply
both parameters on the same handler:

``` r

game$add_overlap(
  object_one = "hero",
  object_two = "wizard",
  input = input,
  browser_action = browser_actions(
    talk_prompt$show(),
    wizard$play_animation("wizard_talk"),
    greeting_sound$play()
  ),
  server_action = function(event) {
    visits_to_wizard(visits_to_wizard() + 1)
    load_dialogue_from_database()
  }
)
```

The browser action runs immediately. The server action runs after Shiny
receives the event; it does not block the browser action.

Avoid making the two sides independently change the same authoritative
state. For example, the browser may play an attack animation
immediately, but the server should decide whether the attack hit and how
much damage it caused. After that decision, use normal shinyphaser
methods to send the result back to the browser.

## Example: a server-managed Space interaction

The same key may mean different things in a larger game: pick up an
item, talk to a character, or attack an enemy. If those conditions live
in R, keep the decision in one server action:

``` r

handle_space <- function(event) {
  if (sword_in_range && !has_sword) {
    has_sword <<- TRUE
    sword$destroy()
    inventory_text$set("weapon: sword")
    return(invisible(NULL))
  }

  if (wizard_in_range) {
    shinyalert::shinyalert("The wizard has a quest for you.")
    return(invisible(NULL))
  }

  attack_enemy_in_range()
}

game$add_control(
  key = "Space",
  input = input,
  server_action = handle_space
)
```

There is no browser action here because the server must first determine
what Space means. A browser action can be added later if the required
interaction state is also maintained safely in the browser.

## Supported event registrations

The split action interface is available on:

- `game$add_control()`;
- `game$add_collider()`;
- `game$add_overlap()`; and
- `game$add_overlap_end()`.

For overlaps, `mode = "enter"` remains the default. Use `mode = "stay"`
and an appropriate `interval` only when an action really must repeat
while the objects remain overlapped. A repeating `server_action`
produces repeating network traffic, so prefer browser actions for
high-frequency visual feedback.

## Common mistakes

### Passing a regular list

Use the constructor, not [`list()`](https://rdrr.io/r/base/list.html):

``` r

# Correct
browser_action = browser_actions(sound$play(), hero$destroy())

# Incorrect
browser_action = list(sound$play(), hero$destroy())
```

A regular list evaluates its elements as R expressions and does not
describe a browser action.

### Omitting `input` for a server action

``` r

# input is required because this callback runs through Shiny
game$add_control(
  "Space",
  input = input,
  server_action = function(event) do_server_work()
)
```

### Using the server for every animation

A server action is valid for arbitrary R logic, but unnecessary round
trips can make controls and animations feel delayed. If an operation is
fully supported by
[`browser_actions()`](../reference/browser_actions.md) and does not
require a server decision, keep it in the browser.
