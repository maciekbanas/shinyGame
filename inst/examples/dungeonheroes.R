# Compatibility launcher for users who previously sourced this file directly.
# Prefer the development namespace loaded by devtools::load_all(); fall back to
# the installed package when this file is run outside the source repository.
if (exists("run_dungeonheroes", mode = "function", inherits = TRUE)) {
  run_dungeonheroes()
} else {
  shinyphaser::run_dungeonheroes()
}
