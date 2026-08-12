  # Bind the game to this Shiny session before creating the single realm.
  game$set_shiny_session(session)
  game$set_world_bounds(world_width, world_height)

  game$add_map(
    map_key = "mushroom_swamps",
    map_url = "assets/dungeonheroes/maps/mushroom_swamps.json",
    tileset_urls = c(
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_grass_1.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_swamp_1.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_bottom.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_bottom_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_left.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_left_bottom.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_left_bottom_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_bottom_left_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_left.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_left_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_bottom.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_bottom_left.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_top_bottom_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/ms_bank_left_right.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_grass_2.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_grass_3.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_grass_4.png",
      "assets/dungeonheroes/terrain/mushroom_swamps/mushroom_swamps_grass_5.png"
    ),
    tileset_names = c(
      "mushroom_swamps_grass_1",
      "mushroom_swamps_swamp_1",
      "mushroom_swamps_swamp_bank_bottom",
      "mushroom_swamps_swamp_bank_bottom_right",
      "mushroom_swamps_swamp_bank_left",
      "mushroom_swamps_swamp_bank_left_bottom",
      "mushroom_swamps_swamp_bank_left_bottom_right",
      "mushroom_swamps_swamp_bank_right",
      "mushroom_swamps_swamp_bank_top_bottom_left_right",
      "mushroom_swamps_swamp_bank_top_left",
      "mushroom_swamps_swamp_bank_top_left_right",
      "mushroom_swamps_swamp_bank_top_right",
      "mushroom_swamps_swamp_bank_top",
      "mushroom_swamps_swamp_bank_top_bottom",
      "mushroom_swamps_swamp_bank_top_bottom_left",
      "mushroom_swamps_swamp_bank_top_bottom_right",
      "mushroom_swamps_swamp_bank_left_right",
      "mushroom_swamps_grass_2",
      "mushroom_swamps_grass_3",
      "mushroom_swamps_grass_4",
      "mushroom_swamps_grass_5"
    ),
    layer_name = "terrain"
  )
