## R/setup_runtime.R
## Runtime-safe configuration (NO installs, NO downloads)
## Professional Appsilon stack configuration

# ============================================================================
# APP METADATA
# ============================================================================
APP_TITLE <- "Apple ESG Strategy Dashboard"
APP_SUBTITLE <- "Decarbonization Progress & Risk Analysis (2015-2022)"
APP_VERSION <- "1.0.0"

# ============================================================================
# PROFESSIONAL COLOR PALETTE
# ============================================================================
COLORS <- list(
  # Primary colors
  primary = "#2C5530",        # Forest green
  secondary = "#3C3C3C",      # Charcoal gray
  accent = "#D97C3A",         # Warm amber
  
  # Supporting colors
  success = "#4A7C4E",        # Muted green  
  warning = "#E8A544",        # Golden amber
  danger = "#C65D47",         # Muted red
  
  # Text colors
  text_dark = "#2C2C2C",
  text_light = "#6C6C6C",
  
  # Background colors
  background = "#F8F9FA",
  card_bg = "#FFFFFF",
  
  # Chart colors (max 3 for multi-series)
  chart_1 = "#2C5530",        # Forest green
  chart_2 = "#3C3C3C",        # Charcoal gray
  chart_3 = "#D97C3A"         # Warm amber
)

# ============================================================================
# GGPLOT2 THEME (Professional, consulting-grade)
# ============================================================================
theme_esg <- function(base_size = 12, base_family = "") {
  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      # Text
      text = ggplot2::element_text(color = COLORS$text_dark),
      plot.title = ggplot2::element_text(
        size = base_size * 1.2,
        face = "bold",
        color = COLORS$primary,
        margin = ggplot2::margin(b = 10)
      ),
      plot.subtitle = ggplot2::element_text(
        size = base_size * 0.95,
        color = COLORS$text_light,
        margin = ggplot2::margin(b = 15)
      ),
      
      # Axes
      axis.title = ggplot2::element_text(
        size = base_size * 0.9,
        color = COLORS$text_dark,
        face = "bold"
      ),
      axis.text = ggplot2::element_text(
        size = base_size * 0.85,
        color = COLORS$text_light
      ),
      axis.line = ggplot2::element_line(color = "#E0E0E0", linewidth = 0.5),
      axis.ticks = ggplot2::element_line(color = "#E0E0E0"),
      
      # Grid
      panel.grid.major = ggplot2::element_line(color = "#F0F0F0", linewidth = 0.3),
      panel.grid.minor = ggplot2::element_blank(),
      
      # Legend
      legend.position = "bottom",
      legend.title = ggplot2::element_text(size = base_size * 0.9, face = "bold"),
      legend.text = ggplot2::element_text(size = base_size * 0.85),
      legend.background = ggplot2::element_rect(fill = "white", color = NA),
      
      # Panel
      panel.background = ggplot2::element_rect(fill = "white", color = NA),
      plot.background = ggplot2::element_rect(fill = "white", color = NA),
      
      # Margins
      plot.margin = ggplot2::margin(t = 10, r = 15, b = 10, l = 10)
    )
}

# ============================================================================
# GGIRAPH OPTIONS (Interactive tooltips styling)
# ============================================================================
GGIRAPH_OPTS <- list(
  opts_tooltip = ggiraph::opts_tooltip(
    css = paste0(
      "background-color:", COLORS$card_bg, ";",
      "color:", COLORS$text_dark, ";",
      "padding: 10px;",
      "border-radius: 4px;",
      "box-shadow: 0 2px 8px rgba(0,0,0,0.15);",
      "font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;",
      "font-size: 13px;",
      "border: 1px solid #E0E0E0;"
    ),
    opacity = 0.95,
    use_fill = FALSE,
    use_stroke = FALSE
  ),
  opts_hover = ggiraph::opts_hover(
    css = "fill-opacity: 0.8; stroke-width: 2;"
  ),
  opts_sizing = ggiraph::opts_sizing(rescale = TRUE, width = 1)
)

# ============================================================================
# NUMBER FORMATTING HELPERS
# ============================================================================

#' Format large numbers with commas
format_large <- function(x) {
  scales::comma(x, accuracy = 1)
}

#' Format emissions values (in millions of tCO2e)
format_emissions <- function(x, unit = "M") {
  if (unit == "M") {
    paste0(scales::comma(x / 1e6, accuracy = 0.1), "M tCO₂e")
  } else if (unit == "k") {
    paste0(scales::comma(x / 1e3, accuracy = 1), "k tCO₂e")
  } else {
    paste0(scales::comma(x, accuracy = 1), " tCO₂e")
  }
}

#' Format percentage values
format_pct <- function(x, digits = 1, include_sign = FALSE) {
  # Vectorized sign handling - use ifelse instead of if
  if (include_sign) {
    sign_vec <- ifelse(x > 0, "+", "")
  } else {
    sign_vec <- ""
  }
  
  paste0(sign_vec, scales::percent(x, accuracy = 10^(-digits)))
}

#' Format currency (billions)
format_currency <- function(x, unit = "B") {
  if (unit == "B") {
    paste0("$", scales::comma(x / 1e3, accuracy = 0.1), "B")
  } else {
    paste0("$", scales::comma(x, accuracy = 1), "M")
  }
}

#' Format intensity metrics
format_intensity <- function(x, per_what = "revenue") {
  if (per_what == "revenue") {
    paste0(scales::comma(x, accuracy = 0.1), " tCO₂e/$M")
  } else if (per_what == "employee") {
    paste0(scales::comma(x, accuracy = 1), " tCO₂e/employee")
  } else {
    scales::comma(x, accuracy = 0.1)
  }
}

# ============================================================================
# SEMANTIC UI HELPERS
# ============================================================================

#' Create a professional statistic card (KPI)
create_kpi_card <- function(value, label, icon = NULL, color = "green") {
  shiny.semantic::div(
    class = "ui statistic",
    if (!is.null(icon)) shiny.semantic::div(class = paste("ui", color, "icon"), icon),
    shiny.semantic::div(class = "value", value),
    shiny.semantic::div(class = "label", label)
  )
}

#' Create an insight box (Executive Brief styling)
create_insight_box <- function(title, content) {
  shiny::div(
    class = "insight-box",
    shiny::tags$strong(title),
    shiny::br(),
    content
  )
}

#' Create a risk callout box
create_risk_callout <- function(content) {
  shiny::div(
    class = "risk-callout",
    shiny::tags$strong("⚠️ Strategic Risk: "),
    content
  )
}

# ============================================================================
# DATA VALIDATION HELPERS
# ============================================================================

#' Check if processed data exists
check_data_files <- function() {
  required_files <- c(
    "data/processed/annual_totals.rds",
    "data/processed/scope_totals.rds",
    "data/processed/intensity_metrics.rds",
    "data/processed/exec_summary.rds"
  )
  
  missing <- required_files[!file.exists(required_files)]
  
  if (length(missing) > 0) {
    stop(
      "Missing processed data files. Please run data_preparation.R first.\n",
      "Missing: ", paste(missing, collapse = ", ")
    )
  }
  
  invisible(TRUE)
}

# ============================================================================
# CONSTANTS
# ============================================================================
YEAR_START <- 2015
YEAR_END <- 2022
TARGET_YEAR <- 2030

# Data source attribution
DATA_SOURCE <- "Source: Apple Inc. Environmental Progress Reports (2015-2022). Data compiled by Maven Analytics."

# Disclaimer text
DATA_DISCLAIMER <- paste(
  "Note: Emissions data are self-reported by Apple and based on company methodology.",
  "Scope 3 estimates depend on supplier disclosures.",
  "This analysis is for illustrative purposes and does not constitute investment advice."
)