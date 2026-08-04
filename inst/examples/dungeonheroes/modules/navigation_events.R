  shiny::observeEvent(input$leave_map, {
    session$sendCustomMessage(
      "phaser", list(js = "setNavigationOverlayVisible(true);")
    )
    map_navigation_background$show()
    # Keep the player out of the realm navigation display by rendering it
    # behind the opaque navigation background.
    hero$set_depth(98)
    lapply(navigation_images, function(image) image$show())
  }, ignoreInit = TRUE)

  show_controls_alert <- function() {
    shinyalert::shinyalert(
      title = "Use Space to attack and interact",
      type = "info"
    )
  }

  move_realm_marker <- function(realm) {
    session$sendCustomMessage(
      "phaser",
      list(js = sprintf(
        paste0(
          "document.getElementById('realm_character_marker').classList.remove(",
          "'mushroom_swamps','wild_forests','grey_mountains','magma_hills');",
          "document.getElementById('realm_character_marker').classList.add(%s);"
        ),
        jsonlite::toJSON(realm, auto_unbox = TRUE)
      ))
    )
  }
