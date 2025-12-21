## modules/mod_data_explorer.R
## Data Explorer Module - Interactive table with filters and download
## Purpose: transparency + analyst drill-down (consulting-safe wording)

# ============================================================================
# MODULE UI
# ============================================================================

data_explorer_ui <- function(id) {
  ns <- NS(id)
  
  div(
    # Page Header
    div(
      style = "margin-bottom: 2em;",
      h2(
        class = "ui header",
        style = glue("color: {COLORS$primary};"),
        icon("table"),
        div(
          class = "content",
          "Data Explorer",
          div(
            class = "sub header",
            "Filter, inspect, and export the rows used in this analysis"
          )
        )
      )
    ),
    
    # Quick framing (lightweight, non-chart)
    div(
      style = "margin: 0 0 1.25em 0; padding: 0.75em 1em;
           background-color: #F8F9F8;
           border-left: 3px solid #B5B5B5;
           font-size: 0.95em; color: #3C3C3C;",
      tags$strong("So what: "),
      "This tab is about transparency. Use it to validate what’s driving a number, ",
      "trace a spike to specific categories, and export a filtered view for follow-up."
    ),
    
    # Filters Row
    div(
      class = "ui segment",
      
      h4("Filters"),
      
      div(
        class = "ui form",
        div(
          class = "three fields",
          
          # Year range filter
          div(
            class = "field",
            tags$label("Year range"),
            uiOutput(ns("filter_years"))
          ),
          
          # Category filter
          div(
            class = "field",
            tags$label("Category"),
            uiOutput(ns("filter_category"))
          ),
          
          # Scope filter
          div(
            class = "field",
            tags$label("Scope"),
            uiOutput(ns("filter_scope"))
          )
        )
      ),
      
      div(
        style = "margin-top: 0.5em; font-size: 0.85em; color: #6C6C6C;",
        tags$strong("Note: "),
        "Totals below reflect the sum of the rows currently shown (post-filter)."
      )
    ),
    
    # Summary Stats
    div(
      class = "ui three statistics",
      style = "margin: 2em 0;",
      uiOutput(ns("summary_stats"))
    ),
    
    # Data Table
    div(
      class = "ui segment",
      
      div(
        style = "display: flex; justify-content: space-between; align-items: center; margin-bottom: 1em;",
        h4("Emissions detail", style = "margin: 0;"),
        div(
          downloadLink(
            ns("download_csv"),
            label = tagList(icon("download"), "Download filtered CSV"),
            class = "ui primary button"
          )
        )
      ),
      
      reactableOutput(ns("data_table"))
    ),
    
    # Data documentation
    div(
      class = "data-notes",
      style = "margin-top: 2em;",
      tags$strong("About this table"),
      br(), br(),
      tags$ul(
        tags$li(tags$strong("Fiscal year:"), " Apple fiscal year (Oct–Sep)."),
        tags$li(tags$strong("Category:"), " Corporate operations vs. product life cycle."),
        tags$li(tags$strong("Scope:"), " GHG Protocol classification (Scope 1/2/3)."),
        tags$li(tags$strong("Description:"), " The reporting line item (e.g., Manufacturing, Product use)."),
        tags$li(tags$strong("Gross emissions:"), " Reported emissions before removals (tCO₂e)."),
        tags$li(tags$strong("Net emissions:"), " Reported emissions after removals (tCO₂e).")
      ),
      tags$p(
        style = "font-style: italic; color: #6C6C6C; margin-top: 1em;",
        "Source: Apple Inc. Environmental Progress Reports (FY2015–FY2022). Data compiled by Maven Analytics."
      )
    )
  )
}

# ============================================================================
# MODULE SERVER
# ============================================================================

data_explorer_server <- function(id, app_data) {
  moduleServer(id, function(input, output, session) {
    
    # ========================================================================
    # Filter Controls
    # ========================================================================
    
    output$filter_years <- renderUI({
      ns <- session$ns
      sliderInput(
        ns("year_range"),
        label = NULL,
        min = 2015,
        max = 2022,
        value = c(2015, 2022),
        step = 1,
        sep = ""
      )
    })
    
    output$filter_category <- renderUI({
      ns <- session$ns
      selectInput(
        ns("category_filter"),
        label = NULL,
        choices = c(
          "All categories" = "all",
          "Corporate emissions" = "Corporate emissions",
          "Product life cycle emissions" = "Product life cycle emissions"
        ),
        selected = "all"
      )
    })
    
    output$filter_scope <- renderUI({
      ns <- session$ns
      selectInput(
        ns("scope_filter"),
        label = NULL,
        choices = c("Scope 1", "Scope 2", "Scope 3"),
        selected = c("Scope 1", "Scope 2", "Scope 3"),
        multiple = TRUE
      )
    })
    
    # ========================================================================
    # Reactive: Filtered Data (with caching)
    # ========================================================================
    
    filtered_data <- reactive({
      req(input$year_range, input$category_filter, input$scope_filter)
      
      # Expected columns: fiscal_year, category, scope_clean, description, gross_emissions, net_emissions
      data <- app_data$scope_totals
      
      data <- data %>%
        filter(
          fiscal_year >= input$year_range[1],
          fiscal_year <= input$year_range[2]
        )
      
      if (input$category_filter != "all") {
        data <- data %>%
          filter(category == input$category_filter)
      }
      
      # Always filter to selected scopes (defaults to all 3)
      data <- data %>%
        filter(scope_clean %in% input$scope_filter)
      
      data
    }) %>% bindCache(input$year_range, input$category_filter, input$scope_filter)
    
    # ========================================================================
    # Summary Statistics
    # ========================================================================
    
    output$summary_stats <- renderUI({
      data <- filtered_data()
      
      n_rows <- nrow(data)
      gross_total <- sum(data$gross_emissions, na.rm = TRUE)
      net_total <- sum(data$net_emissions, na.rm = TRUE)
      
      div(
        class = "ui three column stackable grid",
        style = "margin: 2em 0;",
        
        div(
          class = "column",
          div(
            class = "ui segment",
            style = "text-align: center; padding: 3em 1.5em; display: flex; flex-direction: column; justify-content: center; min-height: 200px;",
            div(
              style = "font-size: 3em; font-weight: 700; margin-bottom: 0.5em; color: #3C3C3C; line-height: 1;",
              scales::comma(n_rows)
            ),
            div(
              style = "font-size: 1em; font-weight: 600; color: #6C6C6C; letter-spacing: 1px;",
              "ROWS"
            )
          )
        ),
        
        div(
          class = "column",
          div(
            class = "ui segment",
            style = "text-align: center; padding: 3em 1.5em; display: flex; flex-direction: column; justify-content: center; min-height: 200px;",
            div(
              style = glue("font-size: 3em; font-weight: 700; margin-bottom: 0.5em; color: {COLORS$primary}; line-height: 1;"),
              format_emissions(gross_total)
            ),
            div(
              style = "font-size: 1em; font-weight: 600; color: #6C6C6C; letter-spacing: 1px;",
              "GROSS TOTAL"
            )
          )
        ),
        
        div(
          class = "column",
          div(
            class = "ui segment",
            style = "text-align: center; padding: 3em 1.5em; display: flex; flex-direction: column; justify-content: center; min-height: 200px;",
            div(
              style = glue("font-size: 3em; font-weight: 700; margin-bottom: 0.5em; color: {COLORS$success}; line-height: 1;"),
              format_emissions(net_total)
            ),
            div(
              style = "font-size: 1em; font-weight: 600; color: #6C6C6C; letter-spacing: 1px;",
              "NET TOTAL"
            )
          )
        )
      )
    })
    
    # ========================================================================
    # Data Table (reactable)
    # ========================================================================
    
    output$data_table <- renderReactable({
      data <- filtered_data()
      
      display_data <- data %>%
        select(
          Year = fiscal_year,
          Category = category,
          Scope = scope_clean,
          Description = description,
          `Gross emissions` = gross_emissions,
          `Net emissions` = net_emissions
        ) %>%
        mutate(
          `Gross emissions` = round(`Gross emissions`, 0),
          `Net emissions` = round(`Net emissions`, 0)
        )
      
      reactable(
        display_data,
        searchable = TRUE,
        defaultSorted = "Year",
        defaultSortOrder = "asc",
        defaultPageSize = 20,
        striped = TRUE,
        highlight = TRUE,
        bordered = TRUE,
        
        columns = list(
          Year = colDef(width = 90, align = "center"),
          Category = colDef(minWidth = 200),
          Scope = colDef(width = 120, align = "center"),
          Description = colDef(minWidth = 260),
          `Gross emissions` = colDef(
            width = 170,
            align = "right",
            format = colFormat(separators = TRUE),
            cell = function(value) formatC(value, format = "f", big.mark = ",", digits = 0)
          ),
          `Net emissions` = colDef(
            width = 170,
            align = "right",
            format = colFormat(separators = TRUE),
            cell = function(value) formatC(value, format = "f", big.mark = ",", digits = 0)
          )
        ),
        
        theme = reactableTheme(
          borderColor = "#E0E0E0",
          stripedColor = "#F8F9FA",
          highlightColor = "#F0F0F0",
          headerStyle = list(
            backgroundColor = COLORS$background,
            color = COLORS$text_dark,
            fontWeight = "600",
            borderBottom = glue("2px solid {COLORS$primary}")
          )
        )
      )
    })
    
    # ========================================================================
    # Download Handler (filtered view)
    # ========================================================================
    
    output$download_csv <- downloadHandler(
      filename = function() {
        paste0("apple-esg-emissions-filtered-", format(Sys.Date(), "%Y%m%d"), ".csv")
      },
      content = function(file) {
        readr::write_csv(filtered_data(), file)
      }
    )
    
  })
}
