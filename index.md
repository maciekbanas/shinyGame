# shinyphaser ![shinyphaser Logo](reference/figures/shinyphaser.png)

This package provides an R Shiny interface to selected features of the
[Phaser 3](https://phaser.io/) game framework.

## What you can do with shinyphaser

With the current API, you can build small-to-medium 2D game-like
interactions in Shiny, including:

- 🎮 creating a game canvas in your Shiny UI,
- 🧩 adding images and animated sprites,
- ⌨️ attaching keyboard-based player controls,
- 💥 defining overlap and collision rules between objects,
- 🔔 reacting to game events from R server logic.

## Installation

Install the stable release from CRAN:

``` r

install.packages("shinyphaser")
```

Install the development version from GitHub:

``` r

# install.packages("pak")
pak::pak("maciekbanas/shinyphaser")
```

## API scope

`shinyphaser` is intentionally more than a one-to-one translation of the
Phaser API. Alongside wrappers for scene objects and physics operations,
it includes reusable, browser-side behaviours when they remove
substantial Shiny round trips and are useful across game genres. For
example, `Sprite$start_approach_on_sight()` can drive guards, animals,
vehicles, or simulation agents.

Higher-level helpers belong in the package when they:

- operate on generic Phaser concepts rather than an example’s story or
  rules,
- need browser-speed updates that would be inefficient through the Shiny
  server, and
- remain composable with lower-level methods such as `set_in_motion()`
  and `stop_motion()`.

Example-specific quests, combat rules, dialogue, and map progression
remain in example applications. This keeps the core API broadly useful
without limiting it to thin Phaser bindings.

## Quick start

You can run the built-in sample app:

``` r

shinyphaser::run_sample_app()
```

## Learn by example

For a full walkthrough (from static background to movement, animation,
overlap, and collision), see [**Build your first shinyphaser
game**](https://maciekbanas.github.io/shinyphaser/articles/first-game.html)

For the complete list of supported browser expressions and guidance on
when to use ordinary R callbacks, see [**Choose between browser and
server
actions**](https://maciekbanas.github.io/shinyphaser/articles/browser-server-actions.html).

![](man/hedgehog_example.gif)

## Example games created with `shinyphaser`

- [hedgehog](https://maciekbanas.shinyapps.io/hedgehog)

The package also includes a larger modular example. Run it locally with:

``` r

shinyphaser::run_swamps_rpg()
```
