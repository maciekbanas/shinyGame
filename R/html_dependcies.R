phaser_dependency <- function() {
  htmltools::htmlDependency(
    name = "phaser",
    version = "3.55.2",
    src = c(href = "https://cdn.jsdelivr.net/npm/phaser@3.55.2/dist"),
    script = "phaser.js"
  )
}
