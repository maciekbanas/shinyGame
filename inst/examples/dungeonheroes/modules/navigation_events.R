  shiny::observeEvent(input$leave_map, {
    session$sendCustomMessage(
      "phaser", list(js = "setNavigationOverlayVisible(true);")
    )
    map_navigation_background$show()
    # Keep the player out of the realm navigation display by rendering it
    # behind the opaque navigation background.
    hero$set_depth(98)
    lapply(navigation_images, function(image) image$show())
    session$sendCustomMessage(
      "phaser", list(js = sprintf("setNavigationRealm('%s');", current_realm))
    )
  }, ignoreInit = TRUE)

  move_realm_marker <- function(realm) {
    session$sendCustomMessage(
      "phaser",
      list(js = sprintf(
        paste0(
          "document.getElementById('realm_character_marker').classList.remove(",
          "'castle','mushroom_swamps','wild_forests','grey_mountains','magma_hills');",
          "document.getElementById('realm_character_marker').classList.add(%s);"
        ),
        jsonlite::toJSON(realm, auto_unbox = TRUE)
      ))
    )
  }

  select_realm <- function(realm) {
    current_realm <<- realm
    move_realm_marker(realm)
    session$sendCustomMessage("phaser", list(js = sprintf(
      "setNavigationRealm(%s);",
      jsonlite::toJSON(realm, auto_unbox = TRUE)
    )))
  }

  shiny::observeEvent(input$navigation_realm_selected, {
    realm <- as.character(input$navigation_realm_selected$realm)
    if (realm %in% c("castle", "wild_forests", "mushroom_swamps", "grey_mountains", "magma_hills")) {
      select_realm(realm)
    }
  }, ignoreInit = TRUE)

  shiny::observeEvent(input$navigation_enter_realm, {
    realm <- as.character(input$navigation_enter_realm$realm)
    if (realm %in% names(realm_routes)) realm_routes[[realm]](input$navigation_enter_realm)
  }, ignoreInit = TRUE)
