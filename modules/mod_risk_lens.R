
## modules/mod_risk_lens.R
## Risk & Tradeoff Lens Module - Strategic risk analysis (consulting-safe revision)

# ============================================================================
# MODULE UI
# ============================================================================

risk_lens_ui <- function(id) {
  ns <- NS(id)
  
  div(
    # Page Header
    div(
      style = "margin-bottom: 2em;",
      h2(
        class = "ui header",
        style = glue("color: {COLORS$primary};"),
        icon("warning sign"),
        div(
          class = "content",
          "Risk & Tradeoff Lens",
          div(
            class = "sub header",
            "Understanding dependencies, constraints, and strategic choices"
          )
        )
      )
    ),
    
    # Risk Matrix Chart
    div(
      class = "chart-container",
      div(
        class = "chart-title",
        "Emission Sources: Controllability vs. Impact"
      ),
      div(
        style = "margin-bottom: 1em; color: #6C6C6C; font-size: 0.9em;",
        "So what: prioritize levers that are both material and influenceable. ",
        "Large sources are not always the most controllable."
      ),
      girafeOutput(ns("chart_risk_matrix"), height = "500px")
    ),
    
    # Scenario Analysis Section
    div(
      class = "ui segment",
      style = glue("margin-top: 2em; border-left: 4px solid {COLORS$accent};"),
      
      h3(
        style = glue("color: {COLORS$primary};"),
        "Scenario: What If Scope 3 Progress Slows?"
      ),
      
      div(
        style = "margin-bottom: 1em; color: #6C6C6C; font-size: 0.9em;",
        "So what: stress-testing Scope 3 reduction rates highlights how quickly ",
        "the 2030 pathway becomes partner- and investment-constrained."
      ),
      
      # Scenario controls
      div(
        class = "ui form",
        style = "margin-bottom: 2em;",
        div(
          class = "two fields",
          div(
            class = "field",
            tags$label("Assume Scope 3 annual reduction rate:"),
            uiOutput(ns("slider_scope3_rate"))
          ),
          div(
            class = "field",
            tags$label("Target year:"),
            div(
              style = "padding-top: 8px; font-size: 1.2em; font-weight: 600;",
              "2030"
            )
          )
        )
      ),
      
      # Scenario results
      div(
        class = "ui three statistics",
        uiOutput(ns("scenario_results"))
      )
    ),
    
    # Risk Categories
    div(
      class = "ui two column stackable grid",
      style = "margin-top: 2em;",
      
      # Column 1: Primary Risks
      div(
        class = "column",
        div(
          class = "ui segment",
          style = glue("border-left: 4px solid {COLORS$danger};"),
          
          h4(
            style = glue("color: {COLORS$danger};"),
            "🔴 Primary Risks"
          ),
          
          tags$ol(
            tags$li(
              tags$strong("Supplier concentration risk"),
              br(),
              "A small number of upstream manufacturing partners can represent a ",
              "disproportionate share of Scope 3 emissions. ",
              "Progress may be vulnerable to changes in supplier energy sourcing."
            ),
            br(),
            tags$li(
              tags$strong("Grid decarbonization dependency"),
              br(),
              "Product use emissions depend on regional electricity grids. ",
              "Apple cannot directly control grid mix, only influence outcomes ",
              "through efficiency and design."
            ),
            br(),
            tags$li(
              tags$strong("Innovation plateau risk"),
              br(),
              "Incremental product efficiency gains may deliver smaller reductions ",
              "over time as physical and economic constraints increase."
            ),
            br(),
            tags$li(
              tags$strong("Credibility exposure"),
              br(),
              "With limited reliance on carbon removals, progress depends heavily ",
              "on continued operational and value-chain improvements."
            )
          )
        )
      ),
      
      # Column 2: Strategic Options
      div(
        class = "column",
        div(
          class = "ui segment",
          style = glue("border-left: 4px solid {COLORS$success};"),
          
          h4(
            style = glue("color: {COLORS$success};"),
            "✓ Strategic Options"
          ),
          
          tags$ol(
            tags$li(
              tags$strong("Lock in supplier commitments"),
              br(),
              "Use long-term renewable energy and process commitments to ",
              "convert dependency into shared accountability."
            ),
            br(),
            tags$li(
              tags$strong("Invest in breakthrough materials"),
              br(),
              "Advance recycled and low-carbon material innovation. ",
              "Higher uncertainty, longer time horizon."
            ),
            br(),
            tags$li(
              tags$strong("Accelerate circular economy levers"),
              br(),
              "Extend product life through repair, reuse, and trade-in programs ",
              "to reduce manufacturing demand."
            ),
            br(),
            tags$li(
              tags$strong("Revisit milestones if needed"),
              br(),
              "If feasibility assessments indicate low likelihood of meeting ",
              "2030 targets under current levers, leadership may consider ",
              "adjusting interim milestones with transparent communication."
            )
          )
        )
      )
    ),
    
    # Trade-offs table
    div(
      class = "ui segment",
      style = "margin-top: 2em;",
      
      h3(
        style = glue("color: {COLORS$primary};"),
        "Leadership Tradeoffs"
      ),
      
      div(
        class = "ui celled table",
        tags$table(
          class = "ui celled table",
          tags$thead(
            tags$tr(
              tags$th("Strategic Choice"),
              tags$th("Benefit"),
              tags$th("Cost / Risk"),
              tags$th("Time Horizon")
            )
          ),
          tags$tbody(
            tags$tr(
              tags$td(tags$strong("Supplier commitments")),
              tags$td("Improves influence and predictability"),
              tags$td("Higher costs, partner negotiation risk"),
              tags$td("3–5 years")
            ),
            tags$tr(
              tags$td(tags$strong("Breakthrough R&D")),
              tags$td("Enables next step-change in reductions"),
              tags$td("Uncertain outcomes"),
              tags$td("5–10 years")
            ),
            tags$tr(
              tags$td(tags$strong("Circular economy focus")),
              tags$td("Reduces new production demand"),
              tags$td("Business model complexity"),
              tags$td("10+ years")
            ),
            tags$tr(
              tags$td(tags$strong("Milestone adjustment")),
              tags$td("Preserves credibility"),
              tags$td("Short-term scrutiny"),
              tags$td("Immediate")
            )
          )
        )
      )
    ),
    
    # Synthesis
    div(
      class = "insight-box",
      style = glue("margin-top: 2em; border-left: 4px solid {COLORS$primary};"),
      tags$strong("Leadership Synthesis"),
      br(), br(),
      "The data suggest that meeting long-term climate goals will depend less ",
      "on incremental efficiency and more on coordinated action across suppliers, ",
      "materials innovation, and product life-cycle strategies. ",
      "Risk management centers on aligning ambition with feasible levers and ",
      "maintaining transparency as constraints emerge."
    )
  )
}

# ============================================================================
# MODULE SERVER
# ============================================================================

risk_lens_server <- function(id, app_data) {
  moduleServer(id, function(input, output, session) {
    
    output$chart_risk_matrix <- renderGirafe({
      create_risk_matrix_chart(app_data$risk_matrix_data)
    }) %>% bindCache("chart_risk_matrix")
    
    output$slider_scope3_rate <- renderUI({
      ns <- session$ns
      sliderInput(
        ns("scope3_reduction_rate"),
        label = NULL,
        min = 0,
        max = 10,
        value = 5.5,
        step = 0.5,
        post = "% per year"
      )
    })
    
    scenario_data <- reactive({
      req(input$scope3_reduction_rate)
      
      current_emissions <- app_data$annual_totals %>%
        filter(fiscal_year == 2022) %>%
        pull(total_gross)
      
      years_to_target <- 2030 - 2022
      annual_rate <- input$scope3_reduction_rate / 100
      
      projected_2030 <- current_emissions * (1 - annual_rate)^years_to_target
      gap <- projected_2030
      gap_pct <- gap / current_emissions
      
      list(
        current = current_emissions,
        projected = projected_2030,
        gap = gap,
        gap_pct = gap_pct,
        assumed_rate = annual_rate
      )
    }) %>% bindCache(input$scope3_reduction_rate)
    
    output$scenario_results <- renderUI({
      scenario <- scenario_data()
      
      projected_color <- if(scenario$projected > scenario$current * 0.3) {
        COLORS$danger
      } else if(scenario$projected > scenario$current * 0.1) {
        COLORS$accent
      } else {
        COLORS$success
      }
      
      gap_color <- if(scenario$gap_pct > 0.5) {
        COLORS$danger
      } else {
        COLORS$accent
      }
      
      div(
        style = "max-width: 900px; margin: 2em auto;",
        div(
          class = "ui three column stackable grid",
          
          div(
            class = "column",
            div(
              class = "ui segment",
              style = "text-align: center; min-height: 180px;",
              div(
                style = glue("font-size: 2.5em; font-weight: 700; margin: 0.3em 0; color: {projected_color};"),
                format_emissions(scenario$projected)
              ),
              div(style = "font-size: 1em; font-weight: 600;", "PROJECTED 2030 EMISSIONS"),
              div(style = "font-size: 0.85em; color: #6C6C6C;", "At assumed reduction rate")
            )
          ),
          
          div(
            class = "column",
            div(
              class = "ui segment",
              style = "text-align: center; min-height: 180px;",
              div(
                style = glue("font-size: 2.5em; font-weight: 700; margin: 0.3em 0; color: {gap_color};"),
                format_emissions(scenario$gap)
              ),
              div(style = "font-size: 1em; font-weight: 600;", "EMISSIONS REMAINING"),
              div(style = "font-size: 0.85em; color: #6C6C6C;", glue("{format_pct(scenario$gap_pct)} of current"))
            )
          ),
          
          div(
            class = "column",
            div(
              class = "ui segment",
              style = "text-align: center; min-height: 180px;",
              div(
                style = "font-size: 1.6em; font-weight: 600; margin: 1em 0;",
                "Directional stress test"
              ),
              div(style = "font-size: 0.85em; color: #6C6C6C;",
                  "Illustrative, not a forecast")
            )
          )
        )
      )
    })
    
  })
}
