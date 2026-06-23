library(shiny)
library(shinyphaser)

wheel <- PhaserGame$new(id = "spin_wheel", width = 520, height = 520)

prizes <- data.frame(
  label = c("10% OFF", "FREE SHIP", "20% OFF", "TRY AGAIN",
            "$5 CREDIT", "15% OFF", "BONUS GIFT", "25% OFF"),
  title = c("You won 10% off", "Free shipping is yours", "You won 20% off",
            "So close", "You won $5 credit", "You won 15% off",
            "A bonus gift is yours", "You won 25% off"),
  code = c("SUNNY10", "SHIPFREE", "SUNNY20", NA, "CREDIT5", "SUNNY15",
           "BONUSGIFT", "SUNNY25"),
  weight = c(24, 18, 10, 8, 14, 16, 7, 3),
  stringsAsFactors = FALSE
)

ui <- fluidPage(
  tags$head(
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$link(
      rel = "preconnect",
      href = "https://fonts.googleapis.com"
    ),
    tags$link(
      rel = "stylesheet",
      href = paste0(
        "https://fonts.googleapis.com/css2?",
        "family=DM+Sans:wght@400;500;600;700&",
        "family=Manrope:wght@600;700;800&display=swap"
      )
    ),
    tags$link(rel = "stylesheet", href = "spin-and-win.css"),
    tags$script(src = "spin-and-win.js")
  ),
  div(
    class = "campaign-shell",
    div(
      class = "campaign-copy",
      div(class = "brand-mark", span("S"), "SUNROOM"),
      div(class = "eyebrow", "WEEKEND REWARD DROP"),
      h1("A little luck.", br(), span("A lot to love.")),
      p(
        class = "campaign-lead",
        "Spin for a chance to unlock an instant reward for your next order."
      ),
      div(
        class = "campaign-perks",
        div(span(class = "perk-icon", "01"), span("Every spin wins a chance")),
        div(span(class = "perk-icon", "02"), span("Rewards apply at checkout")),
        div(span(class = "perk-icon", "03"), span("No sign-up needed"))
      ),
      div(
        class = "fine-print",
        "One spin per visit. Offer valid for 48 hours."
      )
    ),
    div(
      class = "game-column",
      div(
        class = "wheel-card",
        div(class = "wheel-kicker", "YOUR REWARD IS WAITING"),
        div(class = "wheel-wrap", wheel$use_phaser()),
        actionButton(
          "spin",
          label = tagList(span("SPIN THE WHEEL"), span(class = "button-arrow", "\u2192")),
          class = "spin-button"
        ),
        div(id = "spin_status", class = "spin-status", "Tap spin to reveal your offer")
      ),
      div(class = "trust-note", span("\u2713"), "Fair odds. Instant results. Zero spam.")
    )
  )
)

server <- function(input, output, session) {
  wheel$set_shiny_session(session)
  has_spun <- reactiveVal(FALSE)
  selected_prize <- reactiveVal(NULL)

  session$onFlushed(function() {
    session$sendCustomMessage(
      "spin-wheel-init",
      list(labels = prizes$label)
    )
  }, once = TRUE)

  observeEvent(input$spin, {
    req(!has_spun())

    has_spun(TRUE)
    prize_index <- sample.int(
      nrow(prizes),
      size = 1,
      prob = prizes$weight
    )
    selected_prize(prize_index)

    session$sendCustomMessage(
      "spin-wheel-start",
      list(index = prize_index - 1)
    )
  })

  observeEvent(input$wheel_finished, {
    prize_index <- selected_prize()
    req(prize_index)
    prize <- prizes[prize_index, ]
    won <- !is.na(prize$code)

    showModal(modalDialog(
      div(
        class = "reward-modal-content",
        div(class = "reward-badge", if (won) "YOU WON" else "ONE MORE THING"),
        h2(prize$title),
        p(
          if (won) {
            "Use your reward within the next 48 hours."
          } else {
            "Here is a consolation reward: free shipping on orders over $40."
          }
        ),
        div(
          class = "coupon-row",
          code(if (won) prize$code else "SHIP40"),
          actionButton(
            "copy_code",
            "COPY CODE",
            class = "copy-button"
          )
        )
      ),
      footer = modalButton("KEEP SHOPPING"),
      easyClose = FALSE,
      size = "s"
    ))
  })

  observeEvent(input$copy_code, {
    prize_index <- selected_prize()
    req(prize_index)
    code <- prizes$code[prize_index]
    if (is.na(code)) code <- "SHIP40"

    session$sendCustomMessage("copy-reward-code", list(code = code))
  })
}

shinyApp(ui, server)
