## 00_setup.R - FINAL REVIEWED VERSION
## Setup script for the X Shiny App Project
## Fixes CRAN mirror errors

cat("\n🌠 Setting up X Shiny Project...\n")
cat(paste(rep("=", 60), collapse = ""))
cat("\n\n")

# FIX: Set a reliable CRAN mirror before any installation attempts
# (Pak uses its own repositories, but this ensures the initial 'pak' install works)
cat("🔧 Setting CRAN mirror to RStudio cloud...\n")
options(repos = c(CRAN = "https://cloud.r-project.org"))
cat("✅ CRAN mirror set\n\n")

# --- Installation using 'pak' ---

# 1. Ensure 'pak' itself is installed (conditional install is correct)
if (!requireNamespace("pak", quietly = TRUE)) {
  cat("Installing 'pak'...\n")
  install.packages("pak", quiet = TRUE)
}

# 2. List the desired packages
packages <- c(
  # UI & Layout (Excellent)
  "shiny", "shinydashboard", "shinyWidgets", "bslib",
  
  # Data Wrangling (Excellent)
  "tidyverse", "data.table", 
  
  # Visualization (Excellent)
  "plotly", "leaflet", "ggiraph",
  
  # Utility & Styling (Good, added one)
  "scales", "RColorBrewer", "viridis", 
  "geosphere", "here", "glue", "janitor",
  
  # === MODERN APP ADDITIONS ===
  
  # 1. New/Better UI Components
  "reactable",      # Modern, fast, customizable data tables
  "shinyjs",        # Simple JavaScript calls from R
  
  # 2. User Experience/Loading
  "shiny.semantic"  # Clean spinners for outputs

  
)

cat("📦 Using 'pak::pkg_install' to install/update packages...\n\n")

# 3. Use pak::pkg_install for fast, dependency-aware installation
tryCatch({
  # pak will check if packages are installed and install/update only what is needed.
  pak::pkg_install(packages) 
  cat("\n✅ All specified packages installed/updated successfully!\n")
}, error = function(e) {
  cat("\n❌ An error occurred during package installation with 'pak'.\n")
  cat("   Error details:", conditionMessage(e), "\n")
  cat("   Please manually review and fix the package installation issues.\n")
})

# --- Folder Creation ---

# Create folders
cat("\n📁 Creating project folders...\n")
dirs <- c(
  "data/raw", 
  "data/processed", 
  "R", 
  "www", 
  "docs",
  "_initial_setup"
  )
for (d in dirs) {
  # recursive=TRUE creates parent directories; showWarnings=FALSE suppresses messages if dir exists
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
  cat(paste0("  ✅ ", d, "/\n"))
}

# STEP 6: Create .rscignore file for deployment
# ============================================================================

cat("\n📝 Creating .rscignore for clean deployment...\n")

rscignore_content <- "# Exclude from shinyapps.io deployment
renv/library
renv/staging
renv/python
.Rproj.user
rsconnect
docs
screenshots
*.Rproj
00_setup*.R
00_data_preparation.R
.git
.gitignore
README.md
"

writeLines(rscignore_content, ".rscignore")
cat("✅ .rscignore created\n")


stop()


# ============================================================================
# STEP 7: Create helper data preparation script


cat("\n📝 Creating data preparation template...\n")

data_prep_template <- '## data_preparation.R
## Run this BEFORE launching the app
## Processes raw data into efficient .rds files for the dashboard

library(dplyr)
library(readr)
library(lubridate)

cat("\\n🚂 Processing UK Train Operations Data...\\n\\n")

# Load raw data
cat("📥 Loading raw data...\\n")
# trains_raw <- read_csv("data/raw/your_data_file.csv")

# Perform transformations
cat("🔧 Processing data...\\n")
# trains_processed <- trains_raw %>%
#   mutate(
#     date = as.Date(date),
#     hour = hour(departure_time),
#     # Add your transformations here
#   )

# Save processed data
cat("💾 Saving processed data...\\n")
# saveRDS(trains_processed, "data/processed/trains_clean.rds")

cat("✅ Data preparation complete!\\n\\n")
'

# writeLines(data_prep_template, "data_preparation.R")
cat("✅ data_preparation.R template created\n")

# ============================================================================
# FINAL MESSAGE

cat("\n", rep("=", 70), "\n", sep = "")
cat("✨ Development setup complete!\n")
cat(rep("=", 70), "\n\n", sep = "")

cat("📋 NEXT STEPS:\n\n")
cat("1. Place your UK train data in data/raw/\n")
cat("2. Edit and run data_preparation.R to process data\n")
cat("3. Use R/setup_runtime.R in your app (safe for deployment)\n")
cat("4. Never source this 00_setup.R file in your app\n\n")

cat("🚀 Ready to build your dashboard!\n\n")


