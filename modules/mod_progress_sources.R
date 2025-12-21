## modules/mod_progress_sources.R
## Where Progress Lives Module - Corporate vs Product breakdown

# ============================================================================
# MODULE UI
# ============================================================================

progress_sources_ui <- function(id) {
  ns <- NS(id)
  
  div(
    # Page Header
    div(
      style = "margin-bottom: 2em;",
      h2(
        class = "ui header",
        style = glue("color: {COLORS$primary};"),
        icon("search"),
        div(
          class = "content",
          "Where Progress Lives",
          div(
            class = "sub header",
            "Understanding the corporate vs. product life cycle split"
          )
        )
      )
    ),
    
    # Intro insight
    div(
      class = "insight-box",
      style = "margin-bottom: 2em;",
      tags$strong("The ~95/5 Split"),
      br(), br(),
      "In this dataset, Apple’s reported footprint is concentrated in the value chain—supplier manufacturing, logistics, product use, and end-of-life—rather than corporate operations. ",
      "Product life cycle emissions account for ~95%+ of reported totals over the period, while corporate emissions are comparatively small. ",
      "This pattern is common for product-centric businesses and materially shapes where leadership can intervene."
    ),
    
    div(
      style = "margin-bottom: 2em; padding: 0.75em 1em;
           background-color: #F8F9F8;
           border-left: 3px solid #B5B5B5;
           font-size: 0.95em; color: #3C3C3C;",
      
      "Large categories are not always the most controllable; this section separates where emissions sit ",
      "from where decisions can move them."
    ),
    
    # Chart 1: Category Comparison
    div(
      class = "chart-container",
      div(
        class = "chart-title",
        "Corporate Operations vs. Product Life Cycle"
      ),
      div(
        style = "margin-bottom: 0.75em; font-size: 0.9em; color: #6C6C6C;",
        "Most of the footprint sits outside corporate operations; progress depends on value-chain engagement."
      ),
      girafeOutput(ns("chart_category_split"), height = "400px")
    ),
    
    # Two-column layout for details
    div(
      class = "ui two column stackable grid",
      style = "margin-top: 2em;",
      
      # Left column: Scope 3 detail
      div(
        class = "column",
        div(
          class = "chart-container",
          div(
            class = "chart-title",
            "Top Scope 3 Contributors (2022)"
          ),
          div(
            style = "margin-bottom: 0.75em; font-size: 0.9em; color: #6C6C6C;",
            "Emissions are concentrated in a small number of categories, focusing where supplier action matters most."
          ),
          girafeOutput(ns("chart_scope3_detail"), height = "400px")
        )
      ),
      
      # Right column: iPhone footprint
      div(
        class = "column",
        div(
          class = "chart-container",
          div(
            class = "chart-title",
            "iPhone Carbon Footprint Trend"
          ),div(
            style = "margin-bottom: 0.75em; font-size: 0.9em; color: #6C6C6C;",
            "Product redesign can reduce emissions, but improvements may slow as designs mature."
          ),
          girafeOutput(ns("chart_iphone_footprint"), height = "400px")
        )
      )
    ),
    
    # Controllability Analysis
    div(
      class = "ui segment",
      style = glue("margin-top: 2em; border-left: 4px solid {COLORS$accent};"),
      
      h4(
        style = glue("color: {COLORS$primary};"),
        "What Apple Can Actually Control"
      ),
      div(
        style = "margin: 0.25em 0 1.25em 0; color: #6C6C6C; font-size: 0.9em;",
        tags$strong("So what: "),
        "The biggest emission sources are often influenced indirectly; execution depends on partners, contracts, and incentive alignment."
      ),
      
      div(
        class = "ui three column stackable grid",
        
        # Direct Control
        div(
          class = "column",
          div(
            style = glue("padding: 1em; background: {COLORS$background}; border-radius: 4px;"),
            tags$strong(
              style = glue("color: {COLORS$success};"),
              "✓ Direct Control"
            ),
            tags$ul(
              tags$li("Corporate facilities (Scope 1/2)"),
              tags$li("Business travel policies"),
              tags$li("Product design choices"),
              tags$li("Packaging materials")
            )
          )
        ),
        
        # Influence through partners
        div(
          class = "column",
          div(
            style = glue("padding: 1em; background: {COLORS$background}; border-radius: 4px;"),
            tags$strong(
              style = glue("color: {COLORS$accent};"),
              "⚠ Influence Through Partners"
            ),
            tags$ul(
              tags$li("Supplier energy contracts"),
              tags$li("Transportation methods"),
              tags$li("Supplier selection"),
              tags$li("Component specifications")
            )
          )
        ),
        
        # Primarily External
        div(
          class = "column",
          div(
            style = glue("padding: 1em; background: {COLORS$background}; border-radius: 4px;"),
            tags$strong(
              style = glue("color: {COLORS$danger};"),
              "⚡Primarily External"
            ),
            tags$ul(
              tags$li("Customer product use"),
              tags$li("Electricity grid mix"),
              tags$li("Third-party logistics"),
              tags$li("End-of-life disposal")
            )
          )
        )
      )
    ),
    
    # Strategic Implications
  div(
    class = "insight-box",
    style = "margin-top: 2em;",
    tags$strong("Strategic Implications"),
    br(), br(),
    "Progress tends to come from three levers: (1) ", tags$strong("product design"), 
    " (materials, efficiency, packaging), (2) ", tags$strong("supplier execution"), 
    " (renewable energy adoption and process changes), and (3) ", tags$strong("customer context"), 
    " (grid mix and usage patterns) which can be influenced but not controlled. ",
    br(), br(),
    "The data also suggest potential diminishing returns from incremental efficiency alone. ",
    "Additional reductions may depend on supplier decarbonization at scale, higher recycled-content materials, and circularity programs—each with tradeoffs in cost, adoption, and timeline."
  )
)
}


# ============================================================================
# MODULE SERVER
# ============================================================================

progress_sources_server <- function(id, app_data) {
  moduleServer(id, function(input, output, session) {
    
    # ========================================================================
    # Charts (all cached for performance)
    # ========================================================================
    
    # Chart: Category Split (Corporate vs Product)
    output$chart_category_split <- renderGirafe({
      create_category_chart(app_data$category_totals)
    }) %>% bindCache("chart_category")
    
    # Chart: Scope 3 Detail
    output$chart_scope3_detail <- renderGirafe({
      create_scope3_detail_chart(app_data$scope3_detail, year = 2022)
    }) %>% bindCache("chart_scope3_detail")
    
    # Chart: iPhone Footprint
    output$chart_iphone_footprint <- renderGirafe({
      create_iphone_trend_chart(app_data$iphone_footprint)
    }) %>% bindCache("chart_iphone")
    
  })
}