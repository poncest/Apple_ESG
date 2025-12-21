## app.R
## Apple ESG Strategy Dashboard - Main Application
## Using shiny.semantic for modern professional appearance

# ============================================================================
# CRITICAL: Source global.R first
# ============================================================================
source("global.R")

# ============================================================================
# Source Modules
# ============================================================================
source("modules/mod_executive_brief.R")
source("modules/mod_emissions_reality.R")
source("modules/mod_progress_sources.R")
source("modules/mod_risk_lens.R")
source("modules/mod_data_explorer.R")

# ============================================================================
# UI
# ============================================================================
ui <- semanticPage(
  
  # Custom CSS and theme
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
    tags$style(HTML("
      body {
        background-color: #F8F9FA !important;
        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      }
      .ui.menu {
        background-color: #2C5530 !important;
        margin-bottom: 0 !important;
      }
      .ui.vertical.menu {
        background-color: #2C2C2C !important;
      }
      .main-content {
        padding: 20px;
      }
    "))
  ),
  # About Modal
  div(
    class = "ui modal about",
    div(
      class = "header",
      style = glue("background: {COLORS$primary}; color: white;"),
      icon("circle-info"),
      " About This Dashboard"
    ),
    div(
      class = "content",
      
      # Purpose
      tags$h3("Purpose"),
      tags$p(
        "Executive-style analysis of Apple's emissions strategy and progress toward carbon neutrality, designed for strategic decision-makers and ESG stakeholders."
      ),
      
      # Data
      tags$h3("Data"),
      tags$ul(
        tags$li("Apple Environmental Progress Reports (2015-2022)"),
        tags$li("Sourced from Maven Analytics Apple ESG dataset"),
        tags$li("Covers Scope 1, 2, and 3 emissions across corporate and product life cycle categories"),
        tags$li("Includes carbon removal offsets and emissions intensity metrics")
      ),
      
      # How to Use
      tags$h3("How to Use"),
      tags$ul(
        tags$li(tags$strong("Executive Brief:"), " High-level KPIs and strategic insights for quick assessment."),
        tags$li(tags$strong("Emissions Reality:"), " Detailed emissions trends, scope breakdown, and year-over-year changes."),
        tags$li(tags$strong("Where Progress Lives:"), " Analysis of emission sources, controllability, and iPhone footprint trends."),
        tags$li(tags$strong("Risk Lens:"), " Risk-based framework for dependencies, constraints, and strategic tradeoffs."),
        tags$li(tags$strong("Data Explorer:"), " Interactive table with filters and CSV download for deeper analysis.")
      ),
      
      # Disclaimer
      tags$h3("Disclaimer"),
      tags$ul(
        tags$li("Portfolio project demonstrating analytics and dashboard design skills."),
        tags$li("Analysis and insights are interpretations for demonstration purposes."),
        tags$li("Not affiliated with Apple Inc. or any official ESG reporting body."),
        tags$li("Data is publicly available from Maven Analytics educational resources.")
      ),
      
      # Tech Stack
      tags$h3("Technology"),
      tags$p(
        tags$strong("Built with:"), " R Shiny, shiny.semantic, shinydashboard, ggiraph, reactable, tidyverse"
      ),
      
      # Links
      div(
        style = "margin-top: 2em; display: flex; gap: 1em; flex-wrap: wrap;",
        tags$a(
          class = "ui button",
          href = "https://github.com/poncest/apple-esg-dashboard", # update
          target = "_blank",
          icon("github"), " GitHub"
        ),
        tags$a(
          class = "ui button",
          href = "https://www.linkedin.com/in/stevenponce/",
          target = "_blank",
          icon("linkedin"), " LinkedIn"
        ),
        tags$a(
          class = "ui primary button",
          href = "https://stevenponce.netlify.app/",
          target = "_blank",
          icon("briefcase"), " Portfolio"
        )
      )
    ),
    div(
      class = "actions",
      tags$button(
        class = "ui green button",
        onclick = "$('.ui.modal.about').modal('hide');",
        "OK"
      )
    )
  ),
  
  # Initialize shinyjs and waiter
  useShinyjs(),
  use_waiter(),
  
  # Top Navigation Menu
  div(
    class = "ui inverted menu",
    style = "margin: 0; border-radius: 0;",
    div(class = "header item", 
        style = "font-size: 1.3em; font-weight: 600;",
        "Apple ESG Strategy Dashboard"),
    div(class = "right menu",
        div(class = "item", 
            style = "font-size: 0.9em;",
            "v1.0.0 | 2015-2022"))
  ),
  
  # About button in sidebar
  div(
    style = "padding: 15px 20px;",
    tags$button(
      class = "ui fluid button",
      style = glue("background: {COLORS$primary}; color: white;"),
      onclick = "$('.ui.modal.about').modal('show');",
      icon("circle-info"),
      " About"
    )
  ),
  
  # Sidebar Layout
  div(
    class = "ui grid",
    style = "margin: 0; min-height: 100vh;",
    
    # Sidebar (3 wide)
    div(
      class = "three wide column",
      style = "padding: 0; background: #2C2C2C; min-height: 100vh;",
      div(
        class = "ui vertical inverted menu",
        style = "width: 100%; margin: 0; border-radius: 0;",
        
        uiOutput("sidebar_menu")
      )
    ),
    
    # Main Content (13 wide)
    div(
      class = "thirteen wide column main-content",
      
      uiOutput("main_content")
    ),
    
    # Footer
    tags$footer(
      class = "main-footer",
      style = "
        position: relative;
        left: 50%;
        right: 50%;
        margin-left: -50vw;
        margin-right: -50vw;
        width: 100vw;
        background: #2C2C2C;
        color: #B0B0B0;
        padding: 2em 0;
        margin-top: 4em;
        text-align: center;
      ",
      div(
        class = "container",
        # App title and tech stack
        div(
          style = "margin-bottom: 1em; font-size: 0.95em;",
          "Apple ESG Strategy Dashboard | Built with Appsilon Stack | Data: 2015-2022"
        ),
        # Copyright
        div(
          style = "margin-bottom: 1em; font-size: 0.9em; color: #999;",
          "© 2025 Steven Ponce | All Rights Reserved | v1.0 · Dec 2025"
        ),
        # Social links
        div(
          style = "display: flex; justify-content: center; gap: 2em; margin-top: 1em; flex-wrap: wrap;",
          tags$a(
            href = "https://github.com/poncest",
            target = "_blank",
            style = "color: #B0B0B0; text-decoration: none; font-size: 1.1em;",
            icon("github"), " GitHub"
          ),
          tags$a(
            href = "https://www.linkedin.com/in/stevenponce/",
            target = "_blank",
            style = "color: #B0B0B0; text-decoration: none; font-size: 1.1em;",
            icon("linkedin"), " LinkedIn"
          ),
          tags$a(
            href = "https://x.com/sponce1",
            target = "_blank",
            style = "color: #B0B0B0; text-decoration: none; font-size: 1.1em;",
            icon("x-twitter"), " X"
          )
        )
      )
    )
  )
)

# ============================================================================
# SERVER
# ============================================================================
server <- function(input, output, session) {
  
  # Show loading screen on startup
  waiter_show(
    html = tags$div(
      style = "color: white; text-align: center;",
      tags$h2("Loading Apple ESG Dashboard..."),
      spin_fading_circles()
    ),
    color = "#2C5530"
  )
  
  # Hide loading screen
  Sys.sleep(0.5)
  waiter_hide()
  
  # ========================================================================
  # Reactive: Current Tab
  # ========================================================================
  current_tab <- reactiveVal("executive_brief")
  
  # ========================================================================
  # Sidebar Menu
  # ========================================================================
  output$sidebar_menu <- renderUI({
    
    menu_items <- list(
      list(id = "executive_brief", label = "Executive Brief", icon = "target"),
      list(id = "emissions_reality", label = "Emissions Reality", icon = "chart line"),
      list(id = "progress_sources", label = "Where Progress Lives", icon = "search"),
      list(id = "risk_lens", label = "Risk Lens", icon = "warning sign"),
      list(id = "data_explorer", label = "Data Explorer", icon = "table")
    )
    
    # Create menu items
    menu_ui <- lapply(menu_items, function(item) {
      active_class <- if (current_tab() == item$id) "active" else ""
      
      actionLink(
        inputId = paste0("nav_", item$id),
        label = div(
          class = paste("item", active_class),
          icon(item$icon),
          item$label
        ),
        style = "width: 100%; text-decoration: none; color: inherit;"
      )
    })
    
    tagList(menu_ui)
  })
  
  # ========================================================================
  # Navigation Observers
  # ========================================================================
  observeEvent(input$nav_executive_brief, { current_tab("executive_brief") })
  observeEvent(input$nav_emissions_reality, { current_tab("emissions_reality") })
  observeEvent(input$nav_progress_sources, { current_tab("progress_sources") })
  observeEvent(input$nav_risk_lens, { current_tab("risk_lens") })
  observeEvent(input$nav_data_explorer, { current_tab("data_explorer") })
  
  # ========================================================================
  # Main Content
  # ========================================================================
  output$main_content <- renderUI({
    
    content <- switch(current_tab(),
                      "executive_brief" = executive_brief_ui("executive_brief"),
                      "emissions_reality" = emissions_reality_ui("emissions_reality"),
                      "progress_sources" = progress_sources_ui("progress_sources"),
                      "risk_lens" = risk_lens_ui("risk_lens"),
                      "data_explorer" = data_explorer_ui("data_explorer"),
                      # Default
                      executive_brief_ui("executive_brief")
    )
    
    content
  })
  
  # ========================================================================
  # Call Module Servers (always active)
  # ========================================================================
  
  executive_brief_server("executive_brief", app_data)
  emissions_reality_server("emissions_reality", app_data)
  progress_sources_server("progress_sources", app_data)
  risk_lens_server("risk_lens", app_data)
  data_explorer_server("data_explorer", app_data)
}

# ============================================================================
# Run App
# ============================================================================
shinyApp(ui = ui, server = server)