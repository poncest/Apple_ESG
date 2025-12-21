## modules/mod_emissions_reality.R
## Emissions Reality Check Module 

# ============================================================================
# MODULE UI
# ============================================================================

emissions_reality_ui <- function(id) {
  ns <- NS(id)
  
  div(
    # Page Header
    div(
      style = "margin-bottom: 2em;",
      h2(
        class = "ui header",
        style = glue("color: {COLORS$primary};"),
        icon("chart line"),
        div(
          class = "content",
          "Emissions Reality Check",
          div(
            class = "sub header",
            "Separating real progress from accounting moves"
          )
        )
      )
    ),
    
    # KEY TAKEAWAY MOVED TO TOP
    div(
      class = "insight-box",
      style = "margin-bottom: 2em;",
      tags$strong("Key Takeaway"),
      br(), br(),
      "Apple’s progress is primarily operational rather than driven by purchased removals. ",
      "Reported gross emissions declined 46% alongside 69% revenue growth. ",
      "Offset usage remains limited (1.6% of total), while emissions intensity improved 68%. ",
      "The 2018 uptick reflects iPhone X product mix rather than a structural reversal."
    ),
    
    div(
      style = "margin-bottom: 2em; padding: 0.75em 1em;
           background-color: #F8F9F8;
           border-left: 3px solid #B5B5B5;
           font-size: 0.95em; color: #3C3C3C;",
      
      tags$strong("Evidence summary & scope"),
      br(), br(),
      
      "The data indicate a substantial reduction in reported gross emissions alongside revenue growth, ",
      "limited use of carbon removals, and a footprint dominated by Scope 3 categories. ",
      "This analysis focuses on reported trends and composition; verification quality and future ",
      "feasibility are addressed in subsequent sections."
    ),
    
    # Summary Cards Row
    div(
      class = "ui four stackable cards",
      style = "margin-bottom: 2em;",
      
      # 2015 Baseline
      div(
        class = "ui card",
        div(
          class = "content center aligned",
          uiOutput(ns("card_baseline"))
        )
      ),
      
      # 2022 Current
      div(
        class = "ui card",
        div(
          class = "content center aligned",
          uiOutput(ns("card_current"))
        )
      ),
      
      # Offset Dependency
      div(
        class = "ui card",
        div(
          class = "content center aligned",
          uiOutput(ns("card_offsets"))
        )
      ),
      
      # Revenue Growth
      div(
        class = "ui card",
        div(
          class = "content center aligned",
          uiOutput(ns("card_revenue"))
        )
      )
    ),
    
    # Chart 1: Gross vs Net Trend
    div(
      class = "chart-container",
      
      div(
        class = "chart-title",
        "Absolute Emissions: Gross vs. Net"
      ),
      
      div(
        style = "margin-bottom: 0.75em; font-size: 0.9em; color: #6C6C6C;",
        "This view separates gross emissions from reported carbon removals to clarify ",
        "how much of the observed reduction reflects operational change versus purchased ",
        "or nature-based removals."
      ),
      
      girafeOutput(ns("chart_gross_net"), height = "400px")
    ),
    
    # Chart 2: Scope Breakdown 
    div(
      class = "chart-container",
      div(
        class = "chart-title",
        "Emissions by Scope (1, 2, 3)"
      ),
      
      div(
        style = "margin-bottom: 0.75em; font-size: 0.9em; color: #6C6C6C;",
        "Scope 3 emissions account for the majority (99.7%) of total emissions by magnitude. ",
        "However, magnitude should not be conflated with degree of control; many Scope 3 ",
        "categories depend on supplier practices and customer behavior."
      ),
      
      girafeOutput(ns("chart_scope_breakdown"), height = "400px")
    ),
    
    # Chart 3: side-by-side comparison
    div(
      class = "ui two column stackable grid",
      style = "margin-top: 2em;",
      
      # Left: Emissions Intensity Trend
      div(
        class = "column",
        div(
          class = "chart-container",
          div(
            class = "chart-title",
            "Emissions Intensity Trend"
          ),
          div(
            style = "margin-bottom: 1em; color: #6C6C6C; font-size: 0.9em;",
            "tCO₂e per $M revenue - down 68%"
          ),
          
          div(
            style = "margin-bottom: 0.75em; font-size: 0.9em; color: #6C6C6C;",
            "Emissions intensity normalizes emissions by revenue to contextualize growth, ",
            "but does not capture absolute climate impact.",
          ),
          
          girafeOutput(ns("chart_intensity_only"), height = "350px")
        )
      ),
      
      # Right: Revenue Growth Trend
      div(
        class = "column",
        div(
          class = "chart-container",
          div(
            class = "chart-title",
            "Revenue Growth Trend"
          ),
          div(
            style = "margin-bottom: 1em; color: #6C6C6C; font-size: 0.9em;",
            "Total revenue - up 69%"
          ),
          girafeOutput(ns("chart_revenue_only"), height = "350px")
        )
      )
    ),
    
    # Chart 4: Year-over-Year Changes (FIXED)
    div(
      class = "chart-container",
      style = "margin-top: 2em;",
      div(
        class = "chart-title",
        "Year-over-Year Emissions Change"
      ),
      girafeOutput(ns("chart_yoy"), height = "350px")
    )
  )
}

# ============================================================================
# MODULE SERVER
# ============================================================================

emissions_reality_server <- function(id, app_data) {
  moduleServer(id, function(input, output, session) {
    
    # ========================================================================
    # Reactive: Year Metrics
    # ========================================================================
    
    metrics_2015 <- reactive({
      get_year_metrics(app_data, 2015)
    }) %>% bindCache("metrics_2015")
    
    metrics_2022 <- reactive({
      get_year_metrics(app_data, 2022)
    }) %>% bindCache("metrics_2022")
    
    year_comparison <- reactive({
      compare_years(app_data, 2015, 2022)
    }) %>% bindCache("comparison_2015_2022")
    
    # ========================================================================
    # Summary Cards
    # ========================================================================
    
    # Card: 2015 Baseline
    output$card_baseline <- renderUI({
      m <- metrics_2015()
      
      div(
        class = "ui statistic",
        div(
          class = "value",
          style = "font-size: 1.8em;",
          format_emissions(m$gross_emissions)
        ),
        div(
          class = "label",
          "2015 BASELINE",
          br(),
          span(style = "font-size: 0.8em; color: #999;", "Gross emissions")
        )
      )
    })
    
    # Card: 2022 Current
    output$card_current <- renderUI({
      m <- metrics_2022()
      
      div(
        class = "ui statistic",
        div(
          class = "value",
          style = glue("font-size: 1.8em; color: {COLORS$success};"),
          format_emissions(m$gross_emissions)
        ),
        div(
          class = "label",
          "2022 CURRENT",
          br(),
          span(style = "font-size: 0.8em; color: #999;", "Gross emissions")
        )
      )
    })
    
    # Card: Offset Dependency
    output$card_offsets <- renderUI({
      m <- metrics_2022()
      
      div(
        class = "ui statistic",
        div(
          class = "value",
          style = "font-size: 1.8em;",
          format_pct(m$removals_pct, digits = 1)
        ),
        div(
          class = "label",
          "OFFSET DEPENDENCY",
          br(),
          span(style = "font-size: 0.8em; color: #999;", "Minimal vs. industry 20-30%")
        )
      )
    })
    
    # Card: Revenue Growth
    output$card_revenue <- renderUI({
      comp <- year_comparison()
      
      div(
        class = "ui statistic",
        div(
          class = "value",
          style = "font-size: 1.8em;",
          format_pct(comp$revenue_growth, include_sign = TRUE)
        ),
        div(
          class = "label",
          "REVENUE GROWTH",
          br(),
          span(style = "font-size: 0.8em; color: #999;", "2015 → 2022")
        )
      )
    })
    
    # ========================================================================
    # Charts (with bindCache for performance)
    # ========================================================================
    
    # Chart: Gross vs Net
    output$chart_gross_net <- renderGirafe({
      create_emissions_trend_chart(app_data$annual_totals)
    }) %>% bindCache("chart_gross_net")
    
    # Chart: Scope Breakdown (FIXED - ensure all scopes show)
    output$chart_scope_breakdown <- renderGirafe({
      create_scope_breakdown_chart(app_data$scope_totals)
    }) %>% bindCache("chart_scope_breakdown")
    
    # Chart: Intensity Only (REPLACEMENT for dual-axis)
    output$chart_intensity_only <- renderGirafe({
      
      plot_data <- app_data$intensity_metrics %>%
        mutate(
          tooltip = sprintf(
            "<b>%d</b><br/>Intensity: %.1f tCO₂e/$M",
            fiscal_year,
            emissions_per_revenue
          ),
          data_id = paste("intensity", fiscal_year, sep = "_")
        )
      
      p <- ggplot(plot_data, aes(x = fiscal_year, y = emissions_per_revenue)) +
        geom_line_interactive(
          aes(tooltip = tooltip, data_id = data_id),
          color = COLORS$primary,
          linewidth = 1.5
        ) +
        geom_point_interactive(
          aes(tooltip = tooltip, data_id = data_id),
          color = COLORS$primary,
          size = 4,
          shape = 21,
          fill = "white",
          stroke = 2
        ) +
        scale_x_continuous(breaks = seq(2015, 2022, 1)) +
        scale_y_continuous(labels = scales::comma_format(accuracy = 1)) +
        labs(
          x = NULL,
          y = "Emissions Intensity (tCO₂e/$M revenue)"
        ) +
        theme_esg()
      
      girafe(
        ggobj = p,
        options = c(GGIRAPH_OPTS, list(
          opts_sizing = opts_sizing(rescale = TRUE, width = 0.95)
        ))
      )
    }) %>% bindCache("chart_intensity_single")
    
    # Chart: Revenue Only (REPLACEMENT for dual-axis)
    output$chart_revenue_only <- renderGirafe({
      
      plot_data <- app_data$intensity_metrics %>%
        mutate(
          tooltip = sprintf(
            "<b>%d</b><br/>Revenue: $%.1fB",
            fiscal_year,
            revenue / 1000
          ),
          data_id = paste("revenue", fiscal_year, sep = "_")
        )
      
      p <- ggplot(plot_data, aes(x = fiscal_year, y = revenue / 1000)) +
        geom_col_interactive(
          aes(tooltip = tooltip, data_id = data_id),
          fill = COLORS$chart_2,
          alpha = 0.7,
          width = 0.7
        ) +
        scale_x_continuous(breaks = seq(2015, 2022, 1)) +
        scale_y_continuous(labels = scales::comma_format(suffix = "B")) +
        labs(
          x = NULL,
          y = "Revenue ($B)"
        ) +
        theme_esg()
      
      girafe(
        ggobj = p,
        options = c(GGIRAPH_OPTS, list(
          opts_sizing = opts_sizing(rescale = TRUE, width = 0.95)
        ))
      )
    }) %>% bindCache("chart_revenue_single")
    
    # Chart: Year-over-Year (FIXED - handle missing data)
    output$chart_yoy <- renderGirafe({
      
      # Ensure data is valid
      yoy_data <- app_data$yoy_changes %>%
        filter(!is.na(gross_yoy_change), !is.na(gross_yoy_pct))
      
      if (nrow(yoy_data) == 0) {
        # Return empty plot with message
        p <- ggplot() + 
          annotate("text", x = 0.5, y = 0.5, label = "No YoY data available", size = 6) +
          theme_void()
        return(girafe(ggobj = p))
      }
      
      create_yoy_chart(yoy_data)
    }) %>% bindCache("chart_yoy")
    
  })
}