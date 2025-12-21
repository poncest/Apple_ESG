## modules/mod_executive_brief.R
## Executive Brief Module - Text-first strategic insights

# ============================================================================
# MODULE UI
# ============================================================================

executive_brief_ui <- function(id) {
  ns <- NS(id)
  
  div(
    class = "executive-brief-container",
    
    # Page Header
    div(
      style = "margin-bottom: 2em;",
      h2(
        class = "ui header",
        style = glue("color: {COLORS$primary};"),
        icon("target"),
        div(
          class = "content",
          "Executive Brief",
          div(
            class = "sub header",
            "Three insights that matter to leadership"
          )
        )
      )
    ),
    
    # KPI Cards Row
    div(
      class = "ui three stackable cards",
      style = "margin-bottom: 2em;",
      
      # KPI 1: Total Emissions Change
      div(
        class = "ui card",
        div(
          class = "content",
          div(class = "center aligned",
              uiOutput(ns("kpi_emissions_change"))
          )
        )
      ),
      
      # KPI 2: Intensity Improvement
      div(
        class = "ui card",
        div(
          class = "content",
          div(class = "center aligned",
              uiOutput(ns("kpi_intensity"))
          )
        )
      ),
      
      # KPI 3: Scope 3 Dominance
      div(
        class = "ui card",
        div(
          class = "content",
          div(class = "center aligned",
              uiOutput(ns("kpi_scope3"))
          )
        )
      )
    ),
    
    # Main Insights Section
    div(
      class = "executive-brief",
      
      h3(
        style = glue("color: {COLORS$primary}; margin-top: 0;"),
        "Strategic Insights"
      ),
      
      # Insight 1
      div(
        class = "insight-box",
        tags$strong("1. Evidence consistent with decoupling beyond accounting effects"),
        br(), br(),
        "Apple reduced gross emissions by 46% (38.4M → 20.6M tCO₂e) while ",
        "revenue grew 69% ($234B → $394B). Relative to approaches that rely more heavily on purchased removals, ",
        "Apple's offset dependency is minimal at 1.6%. This pattern is consistent with genuine ",
        "operational progress rather than reliance on purchased removals. ",
      ),
      
      
      # Insight 2
      div(
        class = "insight-box",
        tags$strong("2. Scope 3 dependency is both success story and strategic risk"),
        br(), br(),
        "Scope 3 (supply chain and product use) represents 99.7% of total emissions. ",
        "Corporate operations (Scope 1 & 2) are essentially carbon-neutral. ",
        "This reflects the structural reality of a product-centric business model. ",
        "But it creates strategic dependency: future progress requires supplier innovation, not just ",
        "internal action. Apple achieved a 46% reduction by engaging suppliers and ",
        "redesigning products, but this leverage has limits."
      ),
      
      # Insight 3
      div(
        class = "insight-box",
        tags$strong("3. Reaching 2030 net zero likely requires breakthrough, not optimization"),
        br(), br(),
        "Linear extrapolation of current progress won't reach net zero by 2030. ",
        "The iPhone carbon footprint improved 29% (79kg → 56kg) from 2017 to 2023, ",
        "but further gains likely require step-change innovations—new materials, circular ",
        "design, renewable manufacturing at scale. Incremental efficiency has ",
        "diminishing returns. Leadership faces a choice: invest in breakthrough ",
        "technologies or adjust target timelines."
      ),
      
      # Risk Callout
      div(
        class = "risk-callout",
        tags$strong("⚠️ Strategic Risk"),
        br(), br(),
        "If Scope 3 progress plateaus, credibility risk increases materially. With 99.7% of ",
        "emissions outside direct control, Apple's reputation depends on supplier ",
        "performance. A single major supplier reverting to coal-powered manufacturing ",
        "could reverse years of progress. The offset path is closed (minimal current ",
        "use signals commitment to real reductions). Leadership could prioritize ",
        "supplier lock-in through long-term renewable energy contracts."
      )
    ),
    div(
      class = "ui message",
      style = glue(
        "margin-top: 2em;
     border-left: 4px solid {COLORS$primary};
     background-color: {COLORS$background};"
      ),
      tags$strong("Leadership implication"),
      br(), br(),
      "Future progress depends less on internal efficiency and more on supplier and ecosystem coordination."
    ),
     
    # Chart: Gross vs Net Emissions
    div(
      class = "chart-container",
      style = "margin-top: 2em;",
      div(
        class = "chart-title",
        "Supporting Evidence: Gross vs. Net Emissions (2015-2022)"
      ),
      girafeOutput(ns("chart_emissions_trend"), height = "400px")
    ),
    
    # Data Notes
    div(
      class = "data-notes",
      tags$strong("Data Notes & Limitations"),
      br(),
      "• Emissions data are self-reported by Apple Inc. based on company methodology",
      br(),
      "• Scope 3 estimates depend on supplier disclosures and may have measurement uncertainty",
      br(),
      "• Product footprint data limited to baseline iPhone models",
      br(),
      "• This analysis is for illustrative purposes and does not constitute investment advice",
      br(), br(),
      tags$em(DATA_SOURCE)
    )
  )
}

# ============================================================================
# MODULE SERVER
# ============================================================================

executive_brief_server <- function(id, app_data) {
  moduleServer(id, function(input, output, session) {
    
    # ========================================================================
    # Reactive: Executive Summary Metrics
    # ========================================================================
    
    exec_metrics <- reactive({
      app_data$exec_summary
    }) %>% bindCache("exec_summary")  # Cache - data doesn't change
    
    # ========================================================================
    # KPI Outputs
    # ========================================================================
    
    # KPI 1: Emissions Change
    output$kpi_emissions_change <- renderUI({
      metrics <- exec_metrics()
      
      change_pct <- format_pct(metrics$gross_change_pct, include_sign = TRUE)
      
      div(
        class = "ui statistic",
        div(
          class = "value",
          style = glue("color: {COLORS$success};"),
          change_pct
        ),
        div(
          class = "label",
          "GROSS EMISSIONS CHANGE",
          br(),
          span(
            style = "font-size: 0.8em; color: #999;",
            "2015 → 2022"
          )
        )
      )
    })
    
    # KPI 2: Intensity Improvement
    output$kpi_intensity <- renderUI({
      metrics <- exec_metrics()
      
      improvement_pct <- format_pct(abs(metrics$intensity_change_pct))
      
      div(
        class = "ui statistic",
        div(
          class = "value",
          style = glue("color: {COLORS$success};"),
          improvement_pct
        ),
        div(
          class = "label",
          "INTENSITY IMPROVEMENT",
          br(),
          span(
            style = "font-size: 0.8em; color: #999;",
            "tCO₂e per $M revenue"
          )
        )
      )
    })
    
    # KPI 3: Scope 3 Dominance
    output$kpi_scope3 <- renderUI({
      metrics <- exec_metrics()
      
      scope3_pct <- format_pct(metrics$scope3_pct, digits = 1)
      
      div(
        class = "ui statistic",
        div(
          class = "value",
          style = glue("color: {COLORS$accent};"),
          scope3_pct
        ),
        div(
          class = "label",
          "SCOPE 3 DOMINANCE",
          br(),
          span(
            style = "font-size: 0.8em; color: #999;",
            "Supply chain + product use"
          )
        )
      )
    })
    
    # ========================================================================
    # Chart: Emissions Trend
    # ========================================================================
    
    output$chart_emissions_trend <- renderGirafe({
      # Use cached chart function
      create_emissions_trend_chart(app_data$annual_totals)
    })
    
  })
}