## R/data_helpers.R
## Data manipulation and filtering functions
## Reactive-safe helpers for the Shiny app

library(dplyr)
library(tidyr)

# ============================================================================
# DATA LOADING
# ============================================================================

#' Load all processed datasets
#' @return list of data frames
load_all_data <- function() {
  list(
    annual_totals = readRDS("data/processed/annual_totals.rds"),
    scope_totals = readRDS("data/processed/scope_totals.rds"),
    category_totals = readRDS("data/processed/category_totals.rds"),
    scope3_detail = readRDS("data/processed/scope3_detail.rds"),
    intensity_metrics = readRDS("data/processed/intensity_metrics.rds"),
    yoy_changes = readRDS("data/processed/yoy_changes.rds"),
    iphone_footprint = readRDS("data/processed/iphone_footprint.rds"),
    exec_summary = readRDS("data/processed/exec_summary.rds"),
    risk_matrix_data = readRDS("data/processed/risk_matrix_data.rds"),
    normalizing_factors = readRDS("data/processed/normalizing_factors.rds")
  )
}

# ============================================================================
# FILTERING FUNCTIONS
# ============================================================================

#' Filter data by year range
#' @param data Data frame with fiscal_year column
#' @param year_range Vector of c(min_year, max_year)
#' @return Filtered data frame
filter_by_year <- function(data, year_range) {
  if (is.null(year_range) || length(year_range) != 2) {
    return(data)
  }
  
  data %>%
    filter(fiscal_year >= year_range[1], fiscal_year <= year_range[2])
}

#' Filter scope data by selected scopes
#' @param data scope_totals data frame
#' @param scopes Character vector of scope names
#' @return Filtered data frame
filter_by_scope <- function(data, scopes = c("Scope 1", "Scope 2", "Scope 3")) {
  if (is.null(scopes) || length(scopes) == 0) {
    return(data)
  }
  
  data %>%
    filter(scope_clean %in% scopes)
}

# ============================================================================
# AGGREGATION FUNCTIONS
# ============================================================================

#' Calculate total emissions by year
#' @param data scope_totals data frame
#' @return Aggregated data frame
aggregate_total_by_year <- function(data) {
  data %>%
    group_by(fiscal_year) %>%
    summarize(
      total_gross = sum(gross_emissions, na.rm = TRUE),
      total_net = sum(net_emissions, na.rm = TRUE),
      .groups = "drop"
    )
}

#' Calculate scope percentages
#' @param data scope_totals data frame
#' @return Data frame with percentage columns
calculate_scope_percentages <- function(data) {
  data %>%
    group_by(fiscal_year) %>%
    mutate(
      total = sum(gross_emissions, na.rm = TRUE),
      pct_of_total = gross_emissions / total
    ) %>%
    ungroup()
}

#' Get top N Scope 3 contributors
#' @param data scope3_detail data frame
#' @param year Fiscal year to filter
#' @param n Number of top contributors
#' @return Filtered and sorted data frame
get_top_scope3_sources <- function(data, year = 2022, n = 8) {
  data %>%
    filter(fiscal_year == year) %>%
    arrange(desc(emissions)) %>%
    head(n)
}

# ============================================================================
# CALCULATION FUNCTIONS
# ============================================================================

#' Calculate emissions intensity metrics
#' @param emissions_data annual_totals data frame
#' @param normalizing_data normalizing_factors data frame
#' @return Data frame with intensity metrics
calculate_intensity <- function(emissions_data, normalizing_data) {
  emissions_data %>%
    left_join(normalizing_data, by = "fiscal_year") %>%
    mutate(
      emissions_per_revenue = (total_gross / 1e6) / (revenue / 1e6),
      emissions_per_employee = total_gross / employees,
      emissions_per_market_cap = (total_gross / 1e6) / market_capitalization
    )
}

#' Calculate year-over-year changes
#' @param data Data frame with fiscal_year and emissions columns
#' @param value_col Name of the emissions column
#' @return Data frame with YoY change columns
calculate_yoy_change <- function(data, value_col = "total_gross") {
  data %>%
    arrange(fiscal_year) %>%
    mutate(
      yoy_change = !!sym(value_col) - lag(!!sym(value_col)),
      yoy_pct = (!!sym(value_col) - lag(!!sym(value_col))) / lag(!!sym(value_col))
    )
}

#' Calculate cumulative reduction from baseline
#' @param data Data frame with fiscal_year and emissions columns
#' @param baseline_year Year to use as baseline
#' @param value_col Name of the emissions column
#' @return Data frame with cumulative reduction columns
calculate_cumulative_reduction <- function(data, baseline_year = 2015, 
                                           value_col = "total_gross") {
  baseline_value <- data %>%
    filter(fiscal_year == baseline_year) %>%
    pull(!!sym(value_col))
  
  if (length(baseline_value) == 0) {
    stop("Baseline year not found in data")
  }
  
  data %>%
    mutate(
      cumulative_change = !!sym(value_col) - baseline_value,
      cumulative_pct = (!!sym(value_col) - baseline_value) / baseline_value
    )
}

# ============================================================================
# SUMMARY STATISTICS
# ============================================================================

#' Get key metrics for a given year
#' @param data List of data frames (from load_all_data)
#' @param year Fiscal year
#' @return Named list of key metrics
get_year_metrics <- function(data, year = 2022) {
  annual <- data$annual_totals %>% filter(fiscal_year == year)
  intensity <- data$intensity_metrics %>% filter(fiscal_year == year)
  scope3_pct <- data$scope_totals %>%
    filter(fiscal_year == year, scope_clean == "Scope 3") %>%
    summarize(total = sum(gross_emissions)) %>%
    pull(total) / annual$total_gross
  
  list(
    year = year,
    gross_emissions = annual$total_gross,
    net_emissions = annual$total_net,
    removals = abs(annual$total_removals),
    removals_pct = abs(annual$total_removals) / annual$total_gross,
    scope3_pct = scope3_pct,
    emissions_per_revenue = intensity$emissions_per_revenue,
    revenue = intensity$revenue,
    employees = intensity$employees
  )
}

#' Calculate comparison between two years
#' @param data List of data frames
#' @param year1 First year (baseline)
#' @param year2 Second year (comparison)
#' @return Named list of changes
compare_years <- function(data, year1 = 2015, year2 = 2022) {
  metrics1 <- get_year_metrics(data, year1)
  metrics2 <- get_year_metrics(data, year2)
  
  list(
    year1 = year1,
    year2 = year2,
    gross_change = metrics2$gross_emissions - metrics1$gross_emissions,
    gross_change_pct = (metrics2$gross_emissions - metrics1$gross_emissions) / 
      metrics1$gross_emissions,
    net_change = metrics2$net_emissions - metrics1$net_emissions,
    net_change_pct = (metrics2$net_emissions - metrics1$net_emissions) / 
      metrics1$net_emissions,
    intensity_change_pct = (metrics2$emissions_per_revenue - metrics1$emissions_per_revenue) /
      metrics1$emissions_per_revenue,
    revenue_growth = (metrics2$revenue - metrics1$revenue) / metrics1$revenue
  )
}

# ============================================================================
# SCENARIO CALCULATIONS
# ============================================================================

#' Project emissions to target year (linear extrapolation)
#' @param data annual_totals data frame
#' @param target_year Year to project to
#' @param baseline_years Vector of years to use for trend calculation
#' @return Projected emissions value
project_emissions_linear <- function(data, target_year = 2030, 
                                     baseline_years = c(2015, 2022)) {
  baseline_data <- data %>%
    filter(fiscal_year %in% baseline_years) %>%
    arrange(fiscal_year)
  
  if (nrow(baseline_data) < 2) {
    stop("Need at least 2 years for linear projection")
  }
  
  # Simple linear regression
  model <- lm(total_gross ~ fiscal_year, data = baseline_data)
  
  # Predict
  predicted <- predict(model, newdata = data.frame(fiscal_year = target_year))
  
  list(
    target_year = target_year,
    projected_emissions = as.numeric(predicted),
    annual_reduction_rate = coef(model)[2],
    model_r_squared = summary(model)$r.squared
  )
}

#' Calculate gap to net zero target
#' @param projected_value Projected emissions value
#' @param current_value Current emissions value
#' @param current_year Current year
#' @param target_year Target year
#' @return List with gap analysis
calculate_target_gap <- function(projected_value, current_value, 
                                 current_year = 2022, target_year = 2030) {
  years_remaining <- target_year - current_year
  required_annual_reduction <- current_value / years_remaining
  projected_gap <- projected_value
  gap_pct <- projected_gap / current_value
  
  list(
    target_year = target_year,
    years_remaining = years_remaining,
    current_value = current_value,
    projected_value = projected_value,
    gap = projected_gap,
    gap_pct = gap_pct,
    required_annual_reduction = required_annual_reduction
  )
}

# ============================================================================
# DATA EXPORT HELPERS
# ============================================================================

#' Prepare data for download
#' @param data Data frame
#' @param format Format type ("csv" or "excel")
#' @return Formatted data frame ready for download
prepare_for_download <- function(data, format = "csv") {
  # Clean column names
  data_clean <- data %>%
    janitor::clean_names()
  
  # Format numeric columns for readability
  if (format == "csv") {
    data_clean <- data_clean %>%
      mutate(across(where(is.numeric), ~ round(., 2)))
  }
  
  return(data_clean)
}

# ============================================================================
# VALIDATION HELPERS
# ============================================================================

#' Validate year input
#' @param year Year value to validate
#' @param min_year Minimum valid year
#' @param max_year Maximum valid year
#' @return TRUE if valid, error otherwise
validate_year <- function(year, min_year = 2015, max_year = 2022) {
  if (is.null(year) || is.na(year)) {
    stop("Year cannot be NULL or NA")
  }
  
  if (year < min_year || year > max_year) {
    stop(sprintf("Year must be between %d and %d", min_year, max_year))
  }
  
  TRUE
}

#' Check for data completeness
#' @param data Data frame
#' @param required_cols Required column names
#' @return TRUE if complete, warning otherwise
check_completeness <- function(data, required_cols) {
  missing_cols <- setdiff(required_cols, names(data))
  
  if (length(missing_cols) > 0) {
    warning(sprintf("Missing columns: %s", paste(missing_cols, collapse = ", ")))
    return(FALSE)
  }
  
  TRUE
}