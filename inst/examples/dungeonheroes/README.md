# Dungeon Heroes example

When developing shinyphaser, load the working tree and run the example with:

```r
devtools::load_all()
run_dungeonheroes()
```

Use the unqualified function name after `devtools::load_all()`: the `::` operator
can still address an older installed copy of shinyphaser in the same R session.

Installed-package users must first install a version containing this example,
then can call the exported function:

```r
devtools::install()
shinyphaser::run_dungeonheroes()
```

The entry point only establishes shared game state and loads focused modules:

- `ui.R` contains menus, styles, and browser-side save controls.
- `modules/game_state.R` contains combat state and status helpers.
- `modules/hero.R` configures the Orc hero sprite and animations.
- `modules/navigation_setup.R` loads the Mushroom Swamps map, while `modules/navigation.R` starts the game directly in that realm.
- `modules/saving.R` owns save/load observers.
- `modules/realms/mushroom_swamps_world.R` contains the swamp enemies, perks, and NPCs.

Modules are sourced into the active Shiny server invocation in the order listed
in `app.R`; this lets callbacks share session state without turning the example
back into one large file.
