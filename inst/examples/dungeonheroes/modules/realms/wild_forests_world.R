  forest_path_waypoints <- data.frame(
    x = c(1, 3, 9, 6, 16, 11, 22, 18, 29),
    y = c(0, 7, 14, 22, 31, 39, 48, 55, 63)
  )
  forest_path_x <- stats::approx(
    forest_path_waypoints$y, forest_path_waypoints$x,
    xout = 0:63, method = "linear", rule = 2
  )$y

  forest_decoration_candidates <- expand.grid(
    column = 2:30, row = 3:62, KEEP.OUT.ATTRS = FALSE
  )
  forest_decoration_candidates$path_distance <- apply(
    vapply(0:2, function(row_offset) {
      path_row <- pmin(forest_decoration_candidates$row + row_offset, 63)
      abs(forest_decoration_candidates$column - forest_path_x[path_row + 1])
    }, numeric(nrow(forest_decoration_candidates))),
    1, min
  )
  # A deterministic tie-breaker spreads objects within the areas furthest from
  # the path instead of arranging them in obvious rows.
  forest_decoration_candidates$tie_breaker <- (
    forest_decoration_candidates$column * 37 +
      forest_decoration_candidates$row * 61
  ) %% 101
  forest_decoration_candidates <- forest_decoration_candidates[
    forest_decoration_candidates$path_distance >= 3,
  ]
  forest_decoration_candidates$density_score <-
    forest_decoration_candidates$path_distance +
      forest_decoration_candidates$tie_breaker / 5
  forest_decoration_candidates <- forest_decoration_candidates[order(
    -forest_decoration_candidates$density_score
  ), ]

  forest_asset_counts <- c(
    bush_1 = 36, bush_2 = 36, bush_3 = 36, bush_4 = 36,
    big_tree_1 = 48, big_tree_2 = 24, big_tree_3 = 24, big_tree_4 = 60
  )
  forest_decoration_assets <- rep(
    names(forest_asset_counts), times = forest_asset_counts
  )
  forest_decoration_specs <- lapply(
    seq_along(forest_decoration_assets), function(index) {
      position <- forest_decoration_candidates[index, ]
      c(
        asset = forest_decoration_assets[[index]],
        x = position$column * 100 + 50,
        y = position$row * 100 + 50
      )
    }
  )
  names(forest_decoration_specs) <- unlist(lapply(
    names(forest_asset_counts), function(asset) {
      sprintf("%s_%d", asset, seq_len(forest_asset_counts[[asset]]))
    }
  ))

  forest_decorations <- lapply(names(forest_decoration_specs), function(name) {
    spec <- forest_decoration_specs[[name]]
    asset_url <- sprintf(
      "assets/dungeonheroes/terrain/wild_forests/%s.png", spec[["asset"]]
    )
    is_tall_tree <- spec[["asset"]] %in% c("big_tree_1", "big_tree_4")
    decoration <- if (is_tall_tree) {
      game$add_sprite(
        name = paste0("forest_", name), url = asset_url,
        x = as.numeric(spec[["x"]]), y = as.numeric(spec[["y"]]),
        frame_width = 200, frame_height = 400,
        frame_count = 2, frame_rate = 2
      )
    } else {
      game$add_image(
        name = paste0("forest_", name), url = asset_url,
        x = as.numeric(spec[["x"]]), y = as.numeric(spec[["y"]])
      )
    }
    # Decorations deliberately have no collider, and render over the hero.
    decoration$set_depth(20)
    decoration
  })
  names(forest_decorations) <- paste0("forest_", names(forest_decoration_specs))

  forest_collision_names <- vapply(names(forest_decoration_specs), function(name) {
    spec <- forest_decoration_specs[[name]]
    is_tree <- startsWith(spec[["asset"]], "big_tree_")
    is_tall_tree <- spec[["asset"]] %in% c("big_tree_1", "big_tree_4")
    collision_y_offset <- if (is_tall_tree) 175 else if (is_tree) 125 else 40
    collision_name <- paste0("forest_", name, "_base")
    game$add_collision_rectangle(
      name = collision_name,
      x = as.numeric(spec[["x"]]),
      y = as.numeric(spec[["y"]]) + collision_y_offset,
      width = if (is_tree) 120 else 60,
      height = if (is_tree) 50 else 20
    )
    game$add_collider("hero", collision_name)
    collision_name
  }, character(1))

  forest_berry_specs <- list(
    forest_berries_1 = c(x = 850, y = 650),
    forest_berries_2 = c(x = 2650, y = 1450),
    forest_berries_3 = c(x = 550, y = 2650),
    forest_berries_4 = c(x = 1850, y = 3450),
    forest_berries_5 = c(x = 2950, y = 4650),
    forest_berries_6 = c(x = 1550, y = 5850)
  )
  forest_berries <- lapply(names(forest_berry_specs), function(name) {
    position <- forest_berry_specs[[name]]
    game$add_static_sprite(
      name = name, url = "assets/dungeonheroes/perks/berries.png",
      x = position[["x"]], y = position[["y"]]
    )
  })
  names(forest_berries) <- names(forest_berry_specs)
  berries <- c(berries, forest_berries)
  berry_is_available <- c(
    berry_is_available,
    stats::setNames(rep(TRUE, length(forest_berries)), names(forest_berries))
  )
  add_berry_handlers(names(forest_berries))

  wild_forests_objects <- c(
    names(forest_decorations), forest_collision_names, names(forest_berries)
  )
