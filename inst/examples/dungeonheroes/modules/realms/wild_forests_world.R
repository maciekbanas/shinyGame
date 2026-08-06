  forest_decoration_specs <- list(
    bush_1_1 = c(asset = "bush_1", x = 450, y = 450),
    bush_1_2 = c(asset = "bush_1", x = 2450, y = 1250),
    bush_1_3 = c(asset = "bush_1", x = 750, y = 3550),
    bush_1_4 = c(asset = "bush_1", x = 2750, y = 5150),
    bush_1_5 = c(asset = "bush_1", x = 1650, y = 2350),
    bush_1_6 = c(asset = "bush_1", x = 2350, y = 4550),
    bush_2_1 = c(asset = "bush_2", x = 1450, y = 750),
    bush_2_2 = c(asset = "bush_2", x = 550, y = 2250),
    bush_2_3 = c(asset = "bush_2", x = 2050, y = 4050),
    bush_2_4 = c(asset = "bush_2", x = 1150, y = 5650),
    bush_2_5 = c(asset = "bush_2", x = 3050, y = 2050),
    bush_2_6 = c(asset = "bush_2", x = 350, y = 6050),
    bush_3_1 = c(asset = "bush_3", x = 2850, y = 550),
    bush_3_2 = c(asset = "bush_3", x = 1750, y = 1850),
    bush_3_3 = c(asset = "bush_3", x = 450, y = 4550),
    bush_3_4 = c(asset = "bush_3", x = 2550, y = 5950),
    bush_3_5 = c(asset = "bush_3", x = 1250, y = 4150),
    bush_3_6 = c(asset = "bush_3", x = 2150, y = 5450),
    bush_4_1 = c(asset = "bush_4", x = 950, y = 1250),
    bush_4_2 = c(asset = "bush_4", x = 2750, y = 2850),
    bush_4_3 = c(asset = "bush_4", x = 1450, y = 4750),
    bush_4_4 = c(asset = "bush_4", x = 3050, y = 6250),
    bush_4_5 = c(asset = "bush_4", x = 350, y = 1650),
    bush_4_6 = c(asset = "bush_4", x = 1850, y = 6150),
    big_tree_1 = c(asset = "big_tree_1", x = 450, y = 1050),
    big_tree_2 = c(asset = "big_tree_1", x = 2250, y = 1750),
    big_tree_3 = c(asset = "big_tree_1", x = 1150, y = 2950),
    big_tree_4 = c(asset = "big_tree_1", x = 2750, y = 3850),
    big_tree_5 = c(asset = "big_tree_1", x = 650, y = 5350),
    big_tree_6 = c(asset = "big_tree_1", x = 1550, y = 1450),
    big_tree_7 = c(asset = "big_tree_1", x = 3050, y = 2450),
    big_tree_8 = c(asset = "big_tree_1", x = 1850, y = 5050)
  )

  forest_decorations <- lapply(names(forest_decoration_specs), function(name) {
    spec <- forest_decoration_specs[[name]]
    asset_url <- sprintf(
      "assets/dungeonheroes/terrain/wild_forests/%s.png", spec[["asset"]]
    )
    decoration <- if (identical(spec[["asset"]], "big_tree_1")) {
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
    is_tree <- identical(spec[["asset"]], "big_tree_1")
    collision_name <- paste0("forest_", name, "_base")
    game$add_collision_rectangle(
      name = collision_name,
      x = as.numeric(spec[["x"]]),
      y = as.numeric(spec[["y"]]) + if (is_tree) 175 else 40,
      width = if (is_tree) 200 else 100,
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
