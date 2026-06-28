devtools::load_all()

game <- PhaserGame$new(width = 800, height = 800)

ui <- shiny::tagList(
  game$use_phaser()
)

server <- function(input, output, session) {
  points <- 0

  game$set_shiny_session()
  game$set_world_bounds(width = 1600, height = 800)

  game$add_image(
    name = "sky",
    url = "assets/bear/terrain/sky.png",
    x = 800,
    y = 400
  )

  bear <- game$add_sprite(
    name = "bear",
    url = "assets/bear/player_sprites/bear_idle.png",
    x = 100,
    y = 550,
    frame_width = 100,
    frame_height = 100,
    frame_rate = 4
  )
  bear$add_animation(
    suffix = "move_right",
    url = "assets/bear/player_sprites/bear_move_right.png",
    frame_width = 100,
    frame_height = 100,
    frame_rate = 6
  )
  bear$add_animation(
    suffix = "move_left",
    url = "assets/bear/player_sprites/bear_move_left.png",
    frame_width = 100,
    frame_height = 100,
    frame_rate = 6
  )
  bear$add_animation(
    suffix = "jump",
    url = "assets/bear/player_sprites/bear_jump.png",
    frame_width = 100,
    frame_height = 100,
    frame_rate = 6
  )
  bear$add_player_controls(
    directions = c("left", "right"),
    speed = 300
  )
  bear$follow_camera()

  game$add_control(
    "Space",
    action = function() {
      bear$set_velocity_y(-600)
      bear$play_animation(
        anim_name = "bear_jump",
        duration = 250
      )
    },
    input
  )
  bear$set_gravity(
    x = 0,
    y = 1200
  )

  apples <- game$add_static_group(
    name = "apples",
    url = "assets/bear/perks/apple.png"
  )
  apples$create(
    x = 600,
    y = 600
  )
  apples$create(
    x = 1000,
    y = 600
  )
  apples$create(
    x = 1200,
    y = 600
  )

  grass <- game$add_static_sprite(
    name = "grass",
    url = "assets/bear/terrain/grass.png",
    x = 800,
    y = 755
  )

  wooden_box <- game$add_sprite(
    name = "wooden_box",
    url = "assets/bear/obstacles/wooden_box.png",
    x = 300,
    y = 600,
    frame_width = 80,
    frame_height = 80
  )
  wooden_box$set_gravity(
    x = 0,
    y = 500
  )

  points_text <- game$add_text(
    text = "apples gathered: 0",
    id = "points_text",
    x = 100,
    y = 100
  )
  points_text$follow_camera()

  game$add_collider(
    object_one = "bear",
    object_two = "grass",
    input = input
  )
  game$add_collider(
    object_one = "wooden_box",
    object_two = "grass",
    input = input
  )
  game$add_overlap(
    object_one = "bear",
    object_two = "wooden_box",
    callback_fun = function(evt) {
      wooden_box$set_in_motion(
        dir_x = 1,
        dir_y = 0,
        speed = 350,
        distance = 50,
        lag = 0
      )
    },
    input = input
  )
  game$add_overlap(
    object_one = "bear",
    group = "apples",
    callback_fun = function(evt) {
      points <<- points + 1
      points_text$set(paste0("apples gathered: ", points))
      apples$disable(evt)
    },
    input = input
  )
}

shiny::shinyApp(ui, server)
