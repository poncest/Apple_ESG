## data_preparation.R
## Apple ESG Strategy Dashboard - Data Preprocessing
## RUN THIS ONCE LOCALLY to create analysis-ready datasets
## Output: Processed RDS files in data/processed/

library(dplyr)
library(tidyr)
library(readr)
library(janitor)

cat("\n🍎 Processing Apple ESG Data\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")

# ============================================================================
# 1. LOAD RAW DATA
# ============================================================================
cat("📂 Loading raw data from Maven Analytics...\n")

emissions_raw <- read_csv(
  "data/raw/greenhouse_gas_emissions.csv",
  col_types = cols(
    `Fiscal Year` = col_integer(),
    Category = col_character(),
    Type = col_character(),
    Scope = col_character(),
    Description = col_character(),
    Emissions = col_double()
  )
) %>% 
  clean_names()

products_raw <- read_csv(
  "data/raw/carbon_footprint_by_product.csv",
  col_types = cols(
    `Release Year` = col_integer(),
    Product = col_character(),
    `Baseline Storage` = col_integer(),
    `Carbon Footprint` = col_double()
  )
) %>% 
  clean_names()

normalizing_raw <- read_csv(
  "data/raw/normalizing_factors.csv",
  col_types = cols(
    `Fiscal Year` = col_integer(),
    Revenue = col_double(),
    `Market Capitalization` = col_double(),
    Employees = col_integer()
  )
) %>% 
  clean_names()

cat(sprintf("  ✅ Emissions: %d rows\n", nrow(emissions_raw)))
cat(sprintf("  ✅ Products: %d rows\n", nrow(products_raw)))
cat(sprintf("  ✅ Normalizing: %d rows\n\n", nrow(normalizing_raw)))

# ============================================================================
# 2. CLEAN EMISSIONS DATA
# ============================================================================
cat("🔧 Processing emissions data...\n")

# Standardize scope names for consistency
emissions_clean <- emissions_raw %>%
  mutate(
    # Extract clean scope identifier
    scope_clean = case_when(
      grepl("Scope 1", scope) ~ "Scope 1",
      grepl("Scope 2", scope) ~ "Scope 2",
      grepl("Scope 3", scope) ~ "Scope 3",
      TRUE ~ "Other"
    ),
    # Flag market-based vs location-based where relevant
    is_market_based = grepl("market-based", scope, ignore.case = TRUE),
    # Flag carbon removals
    is_removal = type == "Carbon removals"
  )

cat("  ✅ Cleaned scope categories\n")

# ============================================================================
# 3. AGGREGATE BY SCOPE AND YEAR
# ============================================================================
cat("📊 Creating scope-level aggregations...\n")

scope_totals <- emissions_clean %>%
  group_by(fiscal_year, category, scope_clean) %>%
  summarize(
    gross_emissions = sum(emissions[type == "Gross emissions"], na.rm = TRUE),
    carbon_removals = sum(emissions[type == "Carbon removals"], na.rm = TRUE),
    net_emissions = gross_emissions + carbon_removals,
    .groups = "drop"
  )

# Annual totals across all scopes
annual_totals <- scope_totals %>%
  group_by(fiscal_year) %>%
  summarize(
    total_gross = sum(gross_emissions, na.rm = TRUE),
    total_removals = sum(carbon_removals, na.rm = TRUE),
    total_net = sum(net_emissions, na.rm = TRUE),
    .groups = "drop"
  )

cat("  ✅ Scope totals by year\n")
cat("  ✅ Annual totals calculated\n")

# ============================================================================
# 4. CATEGORY BREAKDOWN (Corporate vs Product Life Cycle)
# ============================================================================
cat("📈 Creating category breakdowns...\n")

category_totals <- scope_totals %>%
  group_by(fiscal_year, category) %>%
  summarize(
    gross_emissions = sum(gross_emissions, na.rm = TRUE),
    carbon_removals = sum(carbon_removals, na.rm = TRUE),
    net_emissions = sum(net_emissions, na.rm = TRUE),
    .groups = "drop"
  )

cat("  ✅ Corporate vs Product Life Cycle split\n")

# ============================================================================
# 5. DETAILED SCOPE 3 BREAKDOWN
# ============================================================================
cat("🔍 Breaking down Scope 3 sources...\n")

scope3_detail <- emissions_clean %>%
  filter(scope_clean == "Scope 3") %>%
  group_by(fiscal_year, category, description) %>%
  summarize(
    emissions = sum(emissions[type == "Gross emissions"], na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(fiscal_year, desc(emissions))

cat("  ✅ Detailed Scope 3 sources\n")

# ============================================================================
# 6. INTENSITY METRICS
# ============================================================================
cat("💡 Calculating intensity metrics...\n")

intensity_metrics <- annual_totals %>%
  left_join(normalizing_raw, by = "fiscal_year") %>%
  mutate(
    # Emissions per million dollars revenue
    emissions_per_revenue = (total_gross / 1e6) / (revenue / 1e6),
    # Emissions per employee
    emissions_per_employee = total_gross / employees,
    # Emissions per billion market cap
    emissions_per_market_cap = (total_gross / 1e6) / market_capitalization
  )

cat("  ✅ Emissions per $M revenue\n")
cat("  ✅ Emissions per employee\n")
cat("  ✅ Emissions per $B market cap\n")

# ============================================================================
# 7. YEAR-OVER-YEAR CHANGES
# ============================================================================
cat("📉 Computing year-over-year changes...\n")

yoy_changes <- annual_totals %>%
  arrange(fiscal_year) %>%
  mutate(
    gross_yoy_change = total_gross - lag(total_gross),
    gross_yoy_pct = (total_gross - lag(total_gross)) / lag(total_gross),
    net_yoy_change = total_net - lag(total_net),
    net_yoy_pct = (total_net - lag(total_net)) / lag(total_net)
  )

cat("  ✅ YoY absolute and percentage changes\n")

# ============================================================================
# 8. PRODUCT FOOTPRINT (iPhone as indicator)
# ============================================================================
cat("📱 Processing iPhone carbon footprint trajectory...\n")

iphone_footprint <- products_raw %>%
  filter(grepl("iPhone", product, ignore.case = TRUE)) %>%
  arrange(release_year) %>%
  mutate(
    # Calculate YoY change
    footprint_change = carbon_footprint - lag(carbon_footprint),
    footprint_change_pct = (carbon_footprint - lag(carbon_footprint)) / lag(carbon_footprint)
  )

cat("  ✅ iPhone footprint trend (2015-2023):", nrow(iphone_footprint), "models\n")

# ============================================================================
# 9. EXECUTIVE SUMMARY STATISTICS
# ============================================================================
cat("📋 Computing executive summary statistics...\n")

exec_summary <- list(
  # Baseline and current year
  year_start = min(annual_totals$fiscal_year),
  year_end = max(annual_totals$fiscal_year),
  
  # Total emissions (2015 vs 2022)
  emissions_2015_gross = annual_totals$total_gross[annual_totals$fiscal_year == 2015],
  emissions_2022_gross = annual_totals$total_gross[annual_totals$fiscal_year == 2022],
  emissions_2015_net = annual_totals$total_net[annual_totals$fiscal_year == 2015],
  emissions_2022_net = annual_totals$total_net[annual_totals$fiscal_year == 2022],
  
  # Overall change
  gross_change_pct = (annual_totals$total_gross[annual_totals$fiscal_year == 2022] - 
                        annual_totals$total_gross[annual_totals$fiscal_year == 2015]) / 
    annual_totals$total_gross[annual_totals$fiscal_year == 2015],
  
  net_change_pct = (annual_totals$total_net[annual_totals$fiscal_year == 2022] - 
                      annual_totals$total_net[annual_totals$fiscal_year == 2015]) / 
    annual_totals$total_net[annual_totals$fiscal_year == 2015],
  
  # Offset dependency
  removals_2022 = abs(annual_totals$total_removals[annual_totals$fiscal_year == 2022]),
  removals_pct_2022 = abs(annual_totals$total_removals[annual_totals$fiscal_year == 2022]) / 
    annual_totals$total_gross[annual_totals$fiscal_year == 2022],
  
  # Scope 3 dominance
  scope3_pct_2022 = scope_totals %>%
    filter(fiscal_year == 2022, scope_clean == "Scope 3") %>%
    pull(gross_emissions) %>%
    sum() / annual_totals$total_gross[annual_totals$fiscal_year == 2022],
  
  # Revenue decoupling
  revenue_growth = (normalizing_raw$revenue[normalizing_raw$fiscal_year == 2022] -
                      normalizing_raw$revenue[normalizing_raw$fiscal_year == 2015]) /
    normalizing_raw$revenue[normalizing_raw$fiscal_year == 2015],
  
  intensity_change_pct = (intensity_metrics$emissions_per_revenue[intensity_metrics$fiscal_year == 2022] -
                            intensity_metrics$emissions_per_revenue[intensity_metrics$fiscal_year == 2015]) /
    intensity_metrics$emissions_per_revenue[intensity_metrics$fiscal_year == 2015]
)

cat("  ✅ Executive statistics computed\n")

# ============================================================================
# 10. RISK MATRIX DATA
# ============================================================================
cat("🎯 Creating risk matrix data...\n")

# Classify emission sources by controllability and impact
risk_matrix_data <- scope3_detail %>%
  filter(fiscal_year == 2022) %>%
  mutate(
    # Assign controllability (1-5 scale, 5 = most controllable)
    controllability = case_when(
      grepl("Manufacturing|purchased goods", description, ignore.case = TRUE) ~ 2,
      grepl("Product use", description, ignore.case = TRUE) ~ 2,
      grepl("transportation", description, ignore.case = TRUE) ~ 3,
      grepl("Business travel|Employee commute", description, ignore.case = TRUE) ~ 4,
      grepl("End-of-life", description, ignore.case = TRUE) ~ 2,
      TRUE ~ 3
    ),
    # Impact is proportional to emissions (normalize to 1-5 scale)
    impact_raw = emissions,
    impact = scales::rescale(emissions, to = c(1, 5))
  )

cat("  ✅ Controllability × Impact matrix\n")

# ============================================================================
# 11. SAVE PROCESSED DATASETS
# ============================================================================
cat("\n💾 Saving processed datasets...\n")

saveRDS(emissions_clean, "data/processed/emissions_clean.rds")
cat("  ✅ emissions_clean.rds\n")

saveRDS(scope_totals, "data/processed/scope_totals.rds")
cat("  ✅ scope_totals.rds\n")

saveRDS(annual_totals, "data/processed/annual_totals.rds")
cat("  ✅ annual_totals.rds\n")

saveRDS(category_totals, "data/processed/category_totals.rds")
cat("  ✅ category_totals.rds\n")

saveRDS(scope3_detail, "data/processed/scope3_detail.rds")
cat("  ✅ scope3_detail.rds\n")

saveRDS(intensity_metrics, "data/processed/intensity_metrics.rds")
cat("  ✅ intensity_metrics.rds\n")

saveRDS(yoy_changes, "data/processed/yoy_changes.rds")
cat("  ✅ yoy_changes.rds\n")

saveRDS(iphone_footprint, "data/processed/iphone_footprint.rds")
cat("  ✅ iphone_footprint.rds\n")

saveRDS(exec_summary, "data/processed/exec_summary.rds")
cat("  ✅ exec_summary.rds\n")

saveRDS(risk_matrix_data, "data/processed/risk_matrix_data.rds")
cat("  ✅ risk_matrix_data.rds\n")

saveRDS(normalizing_raw, "data/processed/normalizing_factors.rds")
cat("  ✅ normalizing_factors.rds\n")

# ============================================================================
# 12. SUMMARY REPORT
# ============================================================================
cat("\n")
cat(paste(rep("=", 70), collapse = ""), "\n")
cat("✅ Data processing complete!\n\n")

cat("📊 Dataset Summary:\n")
cat(sprintf("  • Years covered: %d-%d\n", exec_summary$year_start, exec_summary$year_end))
cat(sprintf("  • Total gross emissions (2022): %.1fM tCO₂e\n", exec_summary$emissions_2022_gross / 1e6))
cat(sprintf("  • Total net emissions (2022): %.1fM tCO₂e\n", exec_summary$emissions_2022_net / 1e6))
cat(sprintf("  • Gross change (2015-2022): %.1f%%\n", exec_summary$gross_change_pct * 100))
cat(sprintf("  • Offset dependency (2022): %.1f%%\n", exec_summary$removals_pct_2022 * 100))
cat(sprintf("  • Scope 3 as %% of total: %.1f%%\n", exec_summary$scope3_pct_2022 * 100))
cat(sprintf("  • Revenue growth (2015-2022): %.1f%%\n", exec_summary$revenue_growth * 100))
cat(sprintf("  • Intensity improvement: %.1f%%\n", exec_summary$intensity_change_pct * 100))

cat("\n📁 Processed files saved to: data/processed/\n")
cat("🚀 Ready to build the Shiny app!\n")
cat(paste(rep("=", 70), collapse = ""), "\n")