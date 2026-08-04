  realm_routes <- list(
    castle = choose_castle,
    wild_forests = choose_wild_forests,
    mushroom_swamps = choose_mushroom_swamps,
    grey_mountains = choose_grey_mountains,
    magma_hills = choose_magma_hills
  )

  castle_map_image$click(function(event) select_realm("castle"), input)
  wild_forests_map_image$click(function(event) select_realm("wild_forests"), input)
  mushroom_swamps_map_image$click(function(event) select_realm("mushroom_swamps"), input)
  grey_mountains_map_image$click(function(event) select_realm("grey_mountains"), input)
  magma_hills_map_image$click(function(event) select_realm("magma_hills"), input)
