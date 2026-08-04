# Dungeon Heroes example

Run the installed example with:

```r
shinyphaser::run_dungeonheroes()
```

Package developers can also use
`shiny::runApp("inst/examples/dungeonheroes")` from the repository root.

The entry point only establishes shared game state and loads focused modules:

- `ui.R` contains menus, styles, and browser-side save controls.
- `R/game_state.R` contains combat state and status helpers.
- `R/hero.R` configures playable character sprites and animations.
- `R/navigation*.R` configures the realm map and navigation events.
- `R/saving.R` owns save/load observers.
- `R/realms/` contains realm-specific maps, objects, and entry handlers.

Modules are sourced into the Shiny server environment in the order listed in
`app.R`; this lets callbacks share session state without turning the example
back into one large file.
