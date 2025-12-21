## global.R
## Lightweight global setup - loads in < 3 seconds
## NO package installations, NO downloads, NO heavy processing

# ============================================================================
# Load Required Packages
# ============================================================================
suppressPackageStartupMessages({
  library(shiny)
  library(shiny.semantic)  # Modern Semantic UI
  library(ggplot2)
  library(ggiraph)
  library(dplyr)
  library(tidyr)
  library(reactable)
  library(scales)
  library(glue)
  library(shinyjs)
  library(waiter)
})

# ============================================================================
# Source Runtime-Safe Scripts
# ============================================================================
source("R/setup_runtime.R")    # Constants, theme, formatting helpers
source("R/data_helpers.R")     # Data manipulation functions
source("R/charts.R")           # Chart generation functions

# ============================================================================
# Check Data Files Exist
# ============================================================================
check_data_files()

# ============================================================================
# Load Processed Data (Fast - all precomputed)
# ============================================================================
cat("📂 Loading processed data...\n")

app_data <- list(
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

cat("✅ Data loaded successfully\n")

# ============================================================================
# App Metadata
# ============================================================================
APP_INFO <- list(
  title = APP_TITLE,
  subtitle = APP_SUBTITLE,
  version = APP_VERSION,
  data_source = DATA_SOURCE,
  disclaimer = DATA_DISCLAIMER
)



# ============================================================================
# Navigation Menu Items
# ============================================================================
MENU_ITEMS <- list(
  list(
    id = "executive_brief",
    label = "Executive Brief",
    icon = "target"
  ),
  list(
    id = "emissions_reality",
    label = "Emissions Reality Check", 
    icon = "chart line"
  ),
  list(
    id = "progress_sources",
    label = "Where Progress Lives",
    icon = "search"
  ),
  list(
    id = "risk_lens",
    label = "Risk & Tradeoff Lens",
    icon = "warning sign"
  ),
  list(
    id = "data_explorer",
    label = "Data Explorer",
    icon = "table"
  )
)

cat("✅ Global setup complete\n")