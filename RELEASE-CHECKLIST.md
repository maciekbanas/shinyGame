# Next-release checklist

Baseline: compare the development branch with commit `3f6bb05`, the commit that
set version 0.1.0 for the initial CRAN release.

## API review

- [x] Keep genre-neutral additions: gravity, camera following and bounds,
  scroll factor, depth, sound, visibility, browser/server actions, cooldowns,
  object snapshots, collision rectangles, and stopping motion all map directly
  to Phaser concepts or general Shiny integration.
- [x] Keep `activate_map()`. Called with only `map_key`, it is a straightforward
  tilemap activation API. Its optional player-position and object-visibility
  arguments are transition conveniences and do not need a second method with
  nearly identical semantics.
- [ ] Remove or replace `set_map_exit()` before release. An RPG map exit tied to
  a particular HTML element is too specific. If the capability is needed, expose
  a generic distance/proximity event and implement the exit UI in application
  code.
- [ ] Review AI/gameplay conveniences such as `start_approach_on_sight()` and
  `set_in_motion_random_or_toward()`. They are not RPG-only, but are higher-level
  behaviours; decide whether the package intends to include such conveniences
  or only thin Phaser bindings.
- [ ] Decide whether `load_game()` should return captured Phaser data under
  `state$phaser` or provide a separate snapshot API before the contract becomes
  stable.

## Examples and documentation

- [x] Add a standalone save/load mini-example that restores both R score state
  and a live sprite position.
- [x] Add focused snippets for gravity/HUD, sound, collision rectangles, and
  generic tilemap switching.
- [x] Replace the multi-realm Dungeon Heroes application with a focused,
  single-map `simple_rpg` example based on the Wild Forest.
- [ ] Rebuild generated Rd files, vignettes, README, and pkgdown output for the
  release commit.
- [ ] Add NEWS migration notes for the browser/server action API break and the
  removal of RPG-specific methods.

## Release mechanics

- [ ] Choose the release version and replace the development version in
  `DESCRIPTION`.
- [ ] Run `devtools::document()`, `devtools::test()`, and
  `devtools::check(args = "--as-cran")` in a clean checkout.
- [ ] Inspect `R CMD build` contents to ensure obsolete multi-realm assets are
  gone and every Simple RPG and mini-example asset is included.
- [ ] Check examples and vignettes with a clean R library and in a browser.
- [ ] Update `cran-comments.md` and `CRAN-SUBMISSION`, then perform spelling,
  URL, and reverse-dependency checks.
