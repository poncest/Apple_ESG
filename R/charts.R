## R/charts.R
## Professional chart generation using ggiraph
## All charts follow the design system (forest green + charcoal + amber)

library(ggplot2)
library(ggiraph)
library(dplyr)
library(scales)

# ============================================================================
# 1. EMISSIONS TREND - Gross vs Net (Area Chart)
# ============================================================================

#' Create gross vs net emissions trend chart
#' @param data annual_totals data frame
#' @return ggiraph object
create_emissions_trend_chart <- function(data) {
  
  # Prepare data for area chart
  plot_data <- data %>%
    select(fiscal_year, total_gross, total_net) %>%
    tidyr::pivot_longer(
      cols = c(total_gross, total_net),
      names_to = "type",
      values_to = "emissions"
    ) %>%
    mutate(
      type_label = case_when(
        type == "total_gross" ~ "Gross Emissions",
        type == "total_net" ~ "Net Emissions"
      ),
      tooltip = sprintf(
        "<b>%s</b><br/>Year: %d<br/>Emissions: %s",
        type_label,
        fiscal_year,
        format_emissions(emissions)
      ),
      data_id = paste(type, fiscal_year, sep = "_")
    )
  
  p <- ggplot(plot_data, aes(x = fiscal_year, y = emissions / 1e6, 
                             group = type, fill = type_label, color = type_label)) +
    # Non-interactive filled area (background)
    geom_area(
      alpha = 0.6,
      position = "identity"
    ) +
    # Interactive line on top (this captures the hover)
    geom_line_interactive(
      aes(tooltip = tooltip, data_id = data_id),
      linewidth = 2
    ) +
    # Interactive points for better tooltip targeting
    geom_point_interactive(
      aes(tooltip = tooltip, data_id = data_id),
      size = 3,
      alpha = 0  # Invisible but still interactive
    ) +
    scale_fill_manual(
      values = c("Gross Emissions" = COLORS$primary, "Net Emissions" = COLORS$chart_2),
      name = ""
    ) +
    scale_color_manual(
      values = c("Gross Emissions" = COLORS$primary, "Net Emissions" = COLORS$chart_2),
      name = ""
    ) +
    scale_x_continuous(breaks = seq(2015, 2022, 1)) +
    scale_y_continuous(labels = scales::comma_format(suffix = "M")) +
    labs(
      title = "Total Emissions: Gross vs. Net",
      subtitle = "Minimal offset dependency demonstrates real operational progress",
      x = NULL,
      y = "Emissions (million tCO₂e)"
    ) +
    theme_esg() +
    theme(legend.position = "bottom")
  
  girafe(
    ggobj = p,
    options = c(GGIRAPH_OPTS, list(
      opts_sizing = opts_sizing(rescale = TRUE, width = 0.95)
    ))
  )
}

# ============================================================================
# 2. SCOPE BREAKDOWN - Stacked Bar Chart
# ============================================================================

#' Create scope breakdown by year
#' @param data scope_totals data frame
#' @return ggiraph object

create_scope_breakdown_chart <- function(data) {
  
  # Explicitly calculate totals for each scope, filtering out "Other"
  plot_data <- data %>%
    filter(scope_clean != "Other", scope_clean != "") %>%  # Remove "Other" and empty
    group_by(fiscal_year, scope_clean) %>%
    summarize(emissions = sum(gross_emissions, na.rm = TRUE), .groups = "drop") %>%
    # Remove any remaining zeros
    filter(emissions > 0) %>%
    mutate(
      tooltip = sprintf(
        "<b>%s</b><br/>Year: %d<br/>Emissions: %s",
        scope_clean,
        fiscal_year,
        format_emissions(emissions)
      ),
      data_id = paste(scope_clean, fiscal_year, sep = "_")
    )
  
  # DEBUG: Print the data to console
  cat("\n=== SCOPE BREAKDOWN CHART DATA ===\n")
  print(plot_data)
  cat("=================================\n\n")
  
  p <- ggplot(plot_data, aes(x = fiscal_year, y = emissions / 1e6, fill = scope_clean)) +
    geom_col_interactive(
      aes(tooltip = tooltip, data_id = data_id),
      position = position_stack(),  # Explicit position
      width = 0.7
    ) +
    scale_fill_manual(
      values = c(
        "Scope 1" = "#D97C3A",   # Amber (top)
        "Scope 2" = "#3C3C3C",   # Charcoal (middle)
        "Scope 3" = "#2C5530"    # Forest green (bottom/largest)
      ),
      name = "",
      breaks = c("Scope 1", "Scope 2", "Scope 3")
    ) +
    scale_x_continuous(breaks = seq(2015, 2022, 1)) +
    scale_y_continuous(labels = scales::comma_format(suffix = "M")) +
    labs(
      title = "Emissions by Scope",
      subtitle = "Note: Scope 1 & 2 are tiny slivers at top (0.3% combined)",
      x = NULL,
      y = "Emissions (million tCO₂e)"
    ) +
    theme_esg() +
    theme(legend.position = "bottom")
  
  girafe(
    ggobj = p,
    options = c(GGIRAPH_OPTS, list(
      opts_sizing = opts_sizing(rescale = TRUE, width = 0.95)
    ))
  )
}

# ============================================================================
# 3. INTENSITY METRICS - Dual Y-Axis (Revenue vs Emissions)
# ============================================================================

#' Create intensity trend chart (emissions per $M revenue)
#' @param data intensity_metrics data frame
#' @return ggiraph object
create_intensity_chart <- function(data) {
  
  plot_data <- data %>%
    mutate(
      tooltip_emissions = sprintf(
        "<b>Emissions Intensity</b><br/>Year: %d<br/>%s",
        fiscal_year,
        format_intensity(emissions_per_revenue, "revenue")
      ),
      tooltip_revenue = sprintf(
        "<b>Revenue</b><br/>Year: %d<br/>%s",
        fiscal_year,
        format_currency(revenue)
      ),
      data_id_emissions = paste("emissions", fiscal_year, sep = "_"),
      data_id_revenue = paste("revenue", fiscal_year, sep = "_")
    )
  
  # Calculate scaling factor for secondary axis
  max_emissions <- max(plot_data$emissions_per_revenue, na.rm = TRUE)
  max_revenue <- max(plot_data$revenue / 1e3, na.rm = TRUE)
  scale_factor <- max_emissions / max_revenue
  
  p <- ggplot(plot_data, aes(x = fiscal_year)) +
    # Revenue bars
    geom_col_interactive(
      aes(y = (revenue / 1e3) * scale_factor, 
          tooltip = tooltip_revenue,
          data_id = data_id_revenue),
      fill = "#E8E8E8",
      alpha = 0.5,
      width = 0.6
    ) +
    # Emissions intensity line
    geom_line_interactive(
      aes(y = emissions_per_revenue, 
          tooltip = tooltip_emissions,
          data_id = data_id_emissions),
      color = COLORS$primary,
      linewidth = 1.5
    ) +
    geom_point_interactive(
      aes(y = emissions_per_revenue,
          tooltip = tooltip_emissions,
          data_id = data_id_emissions),
      color = COLORS$primary,
      size = 3,
      shape = 21,
      fill = "white",
      stroke = 2
    ) +
    scale_x_continuous(breaks = seq(2015, 2022, 1)) +
    scale_y_continuous(
      name = "Emissions Intensity (tCO₂e/$M revenue)",
      labels = scales::comma_format(accuracy = 1),
      sec.axis = sec_axis(
        ~ . / scale_factor,
        name = "Revenue ($B)",
        labels = scales::comma_format(accuracy = 1)
      )
    ) +
    labs(
      title = "Decoupling Growth from Emissions",
      subtitle = "Revenue grew 69% while emissions intensity improved 68%",
      x = NULL
    ) +
    theme_esg() +
    theme(
      axis.title.y.right = element_text(color = COLORS$text_light),
      axis.text.y.right = element_text(color = COLORS$text_light)
    )
  
  girafe(
    ggobj = p,
    options = c(GGIRAPH_OPTS, list(
      opts_sizing = opts_sizing(rescale = TRUE, width = 0.95)
    ))
  )
}

# ============================================================================
# 4. CATEGORY SPLIT - Corporate vs Product Life Cycle
# ============================================================================

#' Create category comparison chart
#' @param data category_totals data frame
#' @return ggiraph object
create_category_chart <- function(data) {
  
  plot_data <- data %>%
    mutate(
      tooltip = sprintf(
        "<b>%s</b><br/>Year: %d<br/>Gross: %s<br/>Net: %s",
        category,
        fiscal_year,
        format_emissions(gross_emissions),
        format_emissions(net_emissions)
      ),
      data_id = paste(category, fiscal_year, sep = "_")
    )
  
  p <- ggplot(plot_data, aes(x = fiscal_year, y = gross_emissions / 1e6, 
                             color = category, group = category)) +
    geom_line_interactive(
      aes(tooltip = tooltip, data_id = data_id),
      linewidth = 1.5
    ) +
    geom_point_interactive(
      aes(tooltip = tooltip, data_id = data_id),
      size = 3,
      shape = 21,
      fill = "white",
      stroke = 2
    ) +
    scale_color_manual(
      values = c(
        "Corporate emissions" = COLORS$chart_2,
        "Product life cycle emissions" = COLORS$primary
      ),
      name = ""
    ) +
    scale_x_continuous(breaks = seq(2015, 2022, 1)) +
    scale_y_continuous(labels = scales::comma_format(suffix = "M")) +
    labs(
      title = "Corporate vs. Product Life Cycle Emissions",
      subtitle = "Product life cycle represents 95%+ of total footprint",
      x = NULL,
      y = "Gross Emissions (million tCO₂e)"
    ) +
    theme_esg()
  
  girafe(
    ggobj = p,
    options = c(GGIRAPH_OPTS, list(
      opts_sizing = opts_sizing(rescale = TRUE, width = 0.95)
    ))
  )
}

# ============================================================================
# 5. SCOPE 3 DETAIL - Top Contributors (Horizontal Bar)
# ============================================================================

#' Create detailed Scope 3 breakdown
#' @param data scope3_detail data frame (filtered to one year)
#' @param year Year to display
#' @return ggiraph object
create_scope3_detail_chart <- function(data, year = 2022) {
  
  plot_data <- data %>%
    filter(fiscal_year == year) %>%
    arrange(desc(emissions)) %>%
    head(8) %>%
    mutate(
      description = forcats::fct_reorder(description, emissions),
      tooltip = sprintf(
        "<b>%s</b><br/>%s<br/>%.1f%% of total Scope 3",
        description,
        format_emissions(emissions),
        emissions / sum(emissions) * 100
      ),
      data_id = paste("scope3", description, sep = "_")
    )
  
  p <- ggplot(plot_data, aes(x = emissions / 1e6, y = description)) +
    geom_col_interactive(
      aes(tooltip = tooltip, data_id = data_id),
      fill = COLORS$primary,
      width = 0.7
    ) +
    scale_x_continuous(labels = scales::comma_format(suffix = "M")) +
    labs(
      title = sprintf("Top Scope 3 Emission Sources (%d)", year),
      subtitle = "Manufacturing dominates product life cycle footprint",
      x = "Emissions (million tCO₂e)",
      y = NULL
    ) +
    theme_esg() +
    theme(
      panel.grid.major.y = element_blank()
    )
  
  girafe(
    ggobj = p,
    options = c(GGIRAPH_OPTS, list(
      opts_sizing = opts_sizing(rescale = TRUE, width = 0.95)
    ))
  )
}

# ============================================================================
# 6. iPHONE FOOTPRINT TREND
# ============================================================================

#' Create iPhone carbon footprint trend
#' @param data iphone_footprint data frame
#' @return ggiraph object
create_iphone_trend_chart <- function(data) {
  
  plot_data <- data %>%
    mutate(
      tooltip = sprintf(
        "<b>%s</b><br/>Year: %d<br/>Footprint: %d kg CO₂e",
        product,
        release_year,
        carbon_footprint
      ),
      data_id = paste("iphone", release_year, sep = "_")
    )
  
  p <- ggplot(plot_data, aes(x = release_year, y = carbon_footprint)) +
    geom_line_interactive(
      aes(tooltip = tooltip, data_id = data_id),
      color = COLORS$primary,
      linewidth = 1.5
    ) +
    geom_point_interactive(
      aes(tooltip = tooltip, data_id = data_id),
      color = COLORS$primary,
      size = 3,
      shape = 21,
      fill = "white",
      stroke = 2
    ) +
    scale_x_continuous(breaks = seq(2015, 2023, 1)) +
    scale_y_continuous(labels = scales::comma_format(suffix = " kg")) +
    labs(
      title = "iPhone Carbon Footprint per Device",
      subtitle = "Baseline models show 29% improvement (2017 peak → 2023)",
      x = NULL,
      y = "Carbon Footprint (kg CO₂e)"
    ) +
    theme_esg()
  
  girafe(
    ggobj = p,
    options = c(GGIRAPH_OPTS, list(
      opts_sizing = opts_sizing(rescale = TRUE, width = 0.95)
    ))
  )
}

# ============================================================================
# 7. RISK MATRIX - Controllability × Impact
# ============================================================================

#' Create risk matrix scatter plot
#' @param data risk_matrix_data data frame
#' @return ggiraph object
create_risk_matrix_chart <- function(data) {
  
  plot_data <- data %>%
    mutate(
      emissions_mt = emissions / 1e6,  # convert tCO2e -> MtCO2e
      tooltip = sprintf(
        "<b>%s</b><br/>Controllability: %d/5<br/>Impact: %.1f/5<br/>Emissions: %.2f MtCO₂e",
        description,
        controllability,
        impact,
        emissions_mt
      ),
      data_id = paste0("risk_", gsub("\\s+", "_", description))
    )
  
  # Choose nice legend breaks (adjust if your range changes)
  size_breaks <- c(0.01, 0.1, 1, 5, 10)
  size_breaks <- size_breaks[size_breaks <= max(plot_data$emissions_mt, na.rm = TRUE)]
  
  p <- ggplot(plot_data, aes(x = controllability, y = impact)) +
    
    # Quadrant lines
    geom_hline(yintercept = 3, linetype = "dashed", color = COLORS$text_light, linewidth = 0.6, alpha = 0.6) +
    geom_vline(xintercept = 3, linetype = "dashed", color = COLORS$text_light, linewidth = 0.6, alpha = 0.6) +
    
    # Points (filled circles read as "volume")
    geom_point_interactive(
      aes(tooltip = tooltip, data_id = data_id, size = emissions_mt),
      shape = 21,
      fill  = COLORS$primary,
      color = COLORS$primary,
      alpha = 0.28,
      stroke = 1.2
    ) +
    
    # Quadrant labels (non-overlapping)
    annotate(
      "label", x = 1.1, y = 5.35,
      label = "High impact\nLow control",
      hjust = 0, vjust = 1,
      size = 3.5, fontface = "bold",
      label.size = 0, fill = "white", alpha = 0.85
    ) +
    annotate(
      "label", x = 5.35, y = 5.35,
      label = "High impact\nHigh control",
      hjust = 1, vjust = 1,
      size = 3.5, fontface = "bold",
      label.size = 0, fill = "white", alpha = 0.85
    ) +
    annotate(
      "label", x = 1.1, y = 0.95,
      label = "Low impact\nLow control",
      hjust = 0, vjust = 0,
      size = 3.5, fontface = "bold",
      label.size = 0, fill = "white", alpha = 0.85
    ) +
    annotate(
      "label", x = 5.35, y = 0.95,
      label = "Low impact\nHigh control",
      hjust = 1, vjust = 0,
      size = 3.5, fontface = "bold",
      label.size = 0, fill = "white", alpha = 0.85
    ) +
    
    # Scales / labels
    scale_size_continuous(
      range = c(3, 22),
      breaks = size_breaks,
      labels = function(x) paste0(x, " Mt"),
      name = "Emissions (MtCO₂e)"
    ) +
    scale_x_continuous(breaks = 1:5, limits = c(0.5, 5.5)) +
    scale_y_continuous(breaks = 1:5, limits = c(0.5, 5.5)) +
    labs(
      # title = "Emission Sources: Controllability vs. Impact",
      subtitle = "Bubble size reflects emissions volume (MtCO₂e).\nDashed lines mark the midpoint threshold (3/5).",
      x = "Controllability (1 = low, 5 = high)",
      y = "Impact on total emissions (1 = low, 5 = high)"
    ) +
    theme_esg() +
    theme(
      legend.position = "right"
    )
  
  girafe(
    ggobj = p,
    options = c(
      GGIRAPH_OPTS,
      list(opts_sizing = opts_sizing(rescale = TRUE, width = 0.95))
    )
  )
}


# ============================================================================
# 8. YEAR-OVER-YEAR CHANGE (Waterfall-style)
# ============================================================================

#' Create YoY change chart
#' @param data yoy_changes data frame
#' @return ggiraph object
create_yoy_chart <- function(data) {
  
  # Clean the data properly
  plot_data <- data %>%
    filter(
      !is.na(gross_yoy_change),
      !is.na(gross_yoy_pct),
      fiscal_year >= 2016  # Only years with prior year data
    ) %>%
    mutate(
      is_increase = gross_yoy_change > 0,
      tooltip = sprintf(
        "<b>%d → %d</b><br/>Change: %s<br/>%s",
        as.integer(fiscal_year - 1),
        as.integer(fiscal_year),
        format_emissions(gross_yoy_change),
        format_pct(gross_yoy_pct, include_sign = TRUE)
      ),
      data_id = paste0("yoy_", fiscal_year)
    )
  
  # Debug
  cat("YoY chart - rows:", nrow(plot_data), "\n")
  
  if (nrow(plot_data) == 0) {
    # Empty state
    p <- ggplot() +
      annotate("text", x = 2019, y = 0, label = "No year-over-year data available", 
               size = 5, color = "#999") +
      xlim(2016, 2022) +
      ylim(-5, 5) +
      theme_esg()
    
    return(girafe(ggobj = p))
  }
  
  p <- ggplot(plot_data, aes(x = fiscal_year, y = gross_yoy_change / 1e6)) +
    geom_col_interactive(
      aes(fill = is_increase, tooltip = tooltip, data_id = data_id),
      width = 0.6
    ) +
    scale_fill_manual(
      values = c("TRUE" = "#C65D47", "FALSE" = "#4A7C4E"),
      guide = "none"
    ) +
    scale_x_continuous(breaks = seq(2016, 2022, 1)) +
    scale_y_continuous(labels = scales::comma_format(suffix = "M")) +
    geom_hline(yintercept = 0, color = "#2C2C2C", linewidth = 0.5) +
    labs(
      title = "Year-over-Year Emissions Change",
      subtitle = "Consistent decline except 2018 (product mix shift)",
      x = NULL,
      y = "Change in Emissions (million tCO₂e)"
    ) +
    theme_esg()
  
  girafe(
    ggobj = p,
    options = c(GGIRAPH_OPTS, list(
      opts_sizing = opts_sizing(rescale = TRUE, width = 0.95)
    ))
  )
}