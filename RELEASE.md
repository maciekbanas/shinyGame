# Release readiness

This checklist compares the development version (`0.1.0.9014`) with the first
CRAN release (`0.1.0`). It deliberately separates reusable Phaser concepts from
helpers that were introduced to support a particular example game.

## Before submitting

- [ ] Choose the release version and add a dated heading to `NEWS.md`.
- [ ] Run `devtools::document()` with the package's declared roxygen2 version and
  review the generated `NAMESPACE` and `man/` changes.
- [ ] Run `devtools::check()` locally, `R CMD check --as-cran`, and checks on the
  oldest and newest supported R versions.
- [ ] Run the Shiny browser tests in an environment with Chrome.
- [ ] Check the three small examples in `inst/examples/` after removing Dungeon
  Heroes and ensure that no documentation links to its assets.
- [ ] Review bundled asset licenses and package size, then update
  `cran-comments.md` with check results and any incoming-check notes.
- [ ] Build the pkgdown site only after the public API and generated reference
  files are final.

## API audit

The following development additions map directly to general Phaser concepts and
should remain public: world gravity and bounds, sound controls, camera following,
scroll factors, display depth, visibility, sprite motion/velocity/gravity/bounce,
colliders, overlaps, keyboard controls, and browser/server actions.

The browser action system is also general, but it is intentionally a small DSL,
not arbitrary R evaluation. Its supported methods and error behaviour should be
treated as public API and kept covered by compiler and JavaScript runtime tests.

The following methods need a decision before release:

| Method | Assessment | Recommended release action |
|---|---|---|
| `PhaserGame$add_map()` | The name is generic, but the implementation creates exactly one tilemap layer, calls it terrain internally, enables collision from a `collides` tile property, and changes world/camera bounds. | Rename to `add_tilemap_layer()` or extend it with explicit layer, collision-property, and bounds options. Keep `add_map()` as a deprecated alias if compatibility is required. There is no `activate_map()` method in the current R API. |
| `PhaserGame$enable_terrain_collision()` | “Terrain” and “player” terminology in the JavaScript helper are RPG-oriented; the operation is a collider between a scene object and a tilemap layer. | Replace with an object/layer API such as `add_tilemap_collider(object, layer)`. |
| `Sprite$set_in_motion_random_or_toward()` | Encodes a particular NPC behaviour (random wandering, sight distance, then chasing). | Move to an example helper or replace with composable position, distance, and movement primitives. |
| `Sprite$start_approach_on_sight()` | Encodes enemy perception, alerting, and approach timing. | Move to the Dungeon Heroes example before that example is removed; do not promise it as core API. |
| `StaticGroup$disable(evt)` | The operation is useful for collectibles, but requiring an overlap payload is narrower than a normal group/member API. | Keep only if the event-payload contract is documented; eventually return member handles from `create()` and disable/destroy those handles. |
| `PhaserGame$are_overlap()` | General concept, but the current method contains an undefined fallback variable and continuously registers a browser check. | Fix its object-only input ID and define lifecycle/cleanup semantics before release. |

## Save/load scope

Saving and loading is possible today when R owns the authoritative state. The
`inst/examples/save-load.R` example saves an R list with `saveRDS()`, restores it
with `readRDS()`, and reapplies the value through the existing `Text$set()` API.
An application can use a database instead of an RDS file with the same pattern.

The current API cannot create a complete snapshot of a running browser-owned
scene. In particular, `BrowserState` is write-only from R, and scene object
positions, velocities, animation state, disabled group members, camera state,
and sound playback cannot be queried as one serializable value. A future generic
persistence API should therefore provide an explicit browser-to-Shiny state
request (or scene snapshot) and stable setters for every state that can be
restored. It should not embed filesystem or RPG-specific save-slot policy in the
Phaser interface.
