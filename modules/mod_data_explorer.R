## modules/mod_data_explorer.R
## Data Explorer Module - Interactive table with filters and download

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
            "Interactive table with filters and download options"
          )
        )
      )
    ),
    
    # Filters Row
    div(
      class = "ui segment",
      
      h4("Filter Data"),
      
      div(
        class = "ui form",
        div(
          class = "three fields",
          
          # Year range filter
          div(
            class = "field",
            tags$label("Year Range"),
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
        h4("Emissions Data", style = "margin: 0;"),
        div(
          downloadLink(
            ns("download_csv"),
            label = tagList(icon("download"), " Download CSV"),
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
      tags$strong("About This Data"),
      br(), br(),
      tags$strong("Columns:"),
      tags$ul(
        tags$li(tags$strong("Fiscal Year:"), " Apple's fiscal year (October-September)"),
        tags$li(tags$strong("Category:"), " Corporate emissions vs. Product life cycle emissions"),
        tags$li(tags$strong("Scope:"), " Scope 1 (direct), Scope 2 (electricity), Scope 3 (indirect)"),
        tags$li(tags$strong("Description:"), " Specific emission source"),
        tags$li(tags$strong("Type:"), " Gross emissions vs. Carbon removals (offsets)"),
        tags$li(tags$strong("Emissions:"), " Metric tons CO₂ equivalent (tCO₂e)")
      ),
      br(),
      tags$strong("Methodology:"),
      br(),
      "Emissions data compiled from Apple's annual Environmental Progress Reports. ",
      "Scope 3 estimates rely on supplier disclosures and lifecycle assessment models. ",
      "Market-based Scope 2 reflects renewable energy procurement contracts.",
      br(), br(),
      tags$em(DATA_SOURCE)
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
    
    # Year range slider
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
    
    # Category dropdown
    output$filter_category <- renderUI({
      ns <- session$ns
      
      selectInput(
        ns("category_filter"),
        label = NULL,
        choices = c(
          "All Categories" = "all",
          "Corporate Emissions" = "Corporate emissions",
          "Product Life Cycle" = "Product life cycle emissions"
        ),
        selected = "all"
      )
    })
    
    # Scope dropdown
    output$filter_scope <- renderUI({
      ns <- session$ns
      
      selectInput(
        ns("scope_filter"),
        label = NULL,
        choices = c(
          "All Scopes" = "all",
          "Scope 1" = "Scope 1",
          "Scope 2" = "Scope 2",
          "Scope 3" = "Scope 3"
        ),
        selected = "all",
        multiple = TRUE
      )
    })
    
    # ========================================================================
    # Reactive: Filtered Data (with caching)
    # ========================================================================
    
    filtered_data <- reactive({
      req(input$year_range, input$category_filter)
      
      # Load the category totals data (has all the info we need)
      data <- app_data$category_totals
      
      validate(
        need(!is.null(data), "Data is not available (category_totals is NULL)."),
        need(is.data.frame(data), "Data is not in a tabular format."),
        need(nrow(data) > 0, "Data is empty.")
      )
      
      # Filter by year
      data <- data %>%
        filter(fiscal_year >= input$year_range[1],
               fiscal_year <= input$year_range[2])
      
      # Filter by category
      if (input$category_filter != "all") {
        data <- data %>%
          filter(category == input$category_filter)
      }
      
      # Filter by scope - handle NULL and "all" cases
      if (!is.null(input$scope_filter) && length(input$scope_filter) > 0) {
        if (!("all" %in% input$scope_filter)) {
          data <- data %>%
            filter(scope_clean %in% input$scope_filter)
        }
      }
      
      data
    }) %>% bindCache(
      input$year_range,
      input$category_filter,
      input$scope_filter
    )
    
    # ========================================================================
    # Summary Statistics
    # ========================================================================
    
    output$summary_stats <- renderUI({
      data <- filtered_data()
      
      # Calculate stats - category_totals has gross_emissions and net_emissions columns
      total_records <- nrow(data)
      gross_emissions <- sum(data$gross_emissions, na.rm = TRUE)
      net_emissions <- sum(data$net_emissions, na.rm = TRUE)
      
      div(
        class = "ui three column stackable grid",
        style = "margin: 2em 0;",
        
        # Stat 1: Records
        div(
          class = "column",
          div(
            class = "ui segment",
            style = "text-align: center; padding: 3em 1.5em; display: flex; flex-direction: column; justify-content: center; min-height: 200px;",
            div(
              style = "font-size: 3em; font-weight: 700; margin-bottom: 0.5em; color: #3C3C3C; line-height: 1;",
              scales::comma(total_records)
            ),
            div(
              style = "font-size: 1em; font-weight: 600; color: #6C6C6C; letter-spacing: 1px;",
              "RECORDS"
            )
          )
        ),
        
        # Stat 2: Gross Emissions
        div(
          class = "column",
          div(
            class = "ui segment",
            style = "text-align: center; padding: 3em 1.5em; display: flex; flex-direction: column; justify-content: center; min-height: 200px;",
            div(
              style = glue("font-size: 3em; font-weight: 700; margin-bottom: 0.5em; color: {COLORS$primary}; line-height: 1;"),
              format_emissions(gross_emissions)
            ),
            div(
              style = "font-size: 1em; font-weight: 600; color: #6C6C6C; letter-spacing: 1px;",
              "GROSS EMISSIONS"
            )
          )
        ),
        
        # Stat 3: Net Emissions  
        div(
          class = "column",
          div(
            class = "ui segment",
            style = "text-align: center; padding: 3em 1.5em; display: flex; flex-direction: column; justify-content: center; min-height: 200px;",
            div(
              style = glue("font-size: 3em; font-weight: 700; margin-bottom: 0.5em; color: {COLORS$success}; line-height: 1;"),
              format_emissions(net_emissions)
            ),
            div(
              style = "font-size: 1em; font-weight: 600; color: #6C6C6C; letter-spacing: 1px;",
              "NET EMISSIONS"
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
      
      # Prepare display data - using category_totals structure
      if (!"scope_clean" %in% names(data) && "scope" %in% names(data)) {
        data <- data %>% mutate(scope_clean = scope)
      }

      display_data <- data %>%
        select(
          `Year` = fiscal_year,
          Category = category,
          Scope = scope_clean,
          Description = description,
          `Gross Emissions` = gross_emissions,
          `Net Emissions` = net_emissions
        ) %>%
        mutate(
          `Gross Emissions` = round(`Gross Emissions`, 0),
          `Net Emissions` = round(`Net Emissions`, 0)
        )
      
      reactable(
        display_data,
        searchable = TRUE,
        filterable = FALSE,
        defaultPageSize = 20,
        striped = TRUE,
        highlight = TRUE,
        bordered = TRUE,
        
        # Column definitions
        columns = list(
          Year = colDef(
            width = 80,
            align = "center"
          ),
          Category = colDef(
            width = 180
          ),
          Scope = colDef(
            width = 100,
            align = "center"
          ),
          Description = colDef(
            minWidth = 200
          ),
          Type = colDef(
            width = 140,
            align = "center"
          ),
          Emissions = colDef(
            width = 130,
            align = "right",
            format = colFormat(separators = TRUE, suffix = " tCO₂e"),
            style = function(value) {
              if (value < 0) {
                list(color = COLORS$success, fontWeight = "600")
              } else {
                list(color = COLORS$text_dark)
              }
            }
          )
        ),
        
        # Styling
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
    # Download Handler
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