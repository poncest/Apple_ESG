## 00_setup_appsilon.R - Apple ESG Strategy Dashboard
## Modern Appsilon Stack Setup
## RUN ONCE LOCALLY - Professional enterprise-grade Shiny

cat("\n🍎 Apple ESG Strategy Dashboard - Appsilon Stack\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")

# ============================================================================
# CRITICAL: Set CRAN mirror
# ============================================================================
cat("🔧 Setting CRAN mirror...\n")
options(repos = c(CRAN = "https://cloud.r-project.org"))
cat("✅ CRAN mirror set\n\n")

# ============================================================================
# Ensure pak is available
# ============================================================================
if (!requireNamespace("pak", quietly = TRUE)) {
  cat("📦 Installing pak...\n")
  install.packages("pak", quiet = TRUE)
}

# ============================================================================
# Appsilon Enterprise Stack + Core Packages
# ============================================================================
packages <- c(
  # === APPSILON FRAMEWORK ===
  "shiny.semantic",     # Semantic UI for Shiny (modern, professional)
  "semantic.dashboard", # Dashboard layout with Semantic UI
  "shiny.router",       # Client-side routing (optional but professional)
  
  # === CORE SHINY ===
  "shiny",
  "bslib",              # Keep for potential custom theming
  
  # === DATA MANIPULATION (Explicit) ===
  "dplyr",
  "tidyr", 
  "readr",
  "purrr",
  "stringr",
  
  # === VISUALIZATION ===
  "ggplot2",
  "ggiraph",            # Interactive SVG (professional, lightweight)
  "patchwork",          # Compose multi-panel plots
  
  # === TABLES ===
  "reactable",          # Best-in-class data tables
  
  # === UTILITIES ===
  "scales",             # Number formatting
  "glue",               # String interpolation
  "janitor",            # Data cleaning
  
  # === UI ENHANCEMENTS ===
  "shinyjs",            # JavaScript helpers
  "waiter"              # Loading screens (professional spinners)
)

cat("📦 Installing Appsilon stack + supporting packages...\n")
cat("   (This may take a few minutes)\n\n")

tryCatch({
  pak::pkg_install(packages)
  cat("\n✅ All packages installed successfully!\n")
}, error = function(e) {
  cat("\n❌ Package installation error:\n")
  cat("   ", conditionMessage(e), "\n")
  cat("   Please review and fix manually.\n")
})

# ============================================================================
# Project folders
# ============================================================================
cat("\n📁 Creating project folders...\n")

dirs <- c(
  "data/raw",
  "data/processed",
  "R",
  "www",
  "www/css",
  "www/images",
  "docs",
  "_initial_setup"
)

for (d in dirs) {
  dir.create(d, recursive = TRUE, showWarnings = FALSE)
  cat(sprintf("  ✅ %s/\n", d))
}

# ============================================================================
# Custom CSS for Semantic UI refinements
# ============================================================================
cat("\n🎨 Creating custom CSS...\n")

custom_css <- '/* Custom CSS for Apple ESG Dashboard */
/* Professional Semantic UI refinements */

:root {
  --color-primary: #2C5530;      /* Forest green */
  --color-secondary: #3C3C3C;    /* Charcoal gray */
  --color-accent: #D97C3A;       /* Warm amber */
  --color-success: #4A7C4E;      /* Muted green */
  --color-text-dark: #2C2C2C;
  --color-text-light: #6C6C6C;
  --color-bg: #F8F9FA;
  --color-card-bg: #FFFFFF;
}

/* Global overrides */
body {
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif;
  color: var(--color-text-dark);
  background-color: var(--color-bg);
}

/* Header styling */
.ui.menu.dashboard-header {
  background: var(--color-primary) !important;
  border: none;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  margin-bottom: 0;
}

.ui.menu.dashboard-header .header.item {
  color: white !important;
  font-weight: 600;
  font-size: 1.3em;
}

/* Sidebar refinements */
.ui.sidebar.menu {
  background: #2C2C2C !important;
}

.ui.sidebar.menu .item {
  color: #E0E0E0 !important;
}

.ui.sidebar.menu .active.item {
  background: var(--color-primary) !important;
  color: white !important;
}

/* Card enhancements */
.ui.card, .ui.cards > .card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  border: 1px solid #E8E8E8;
  border-radius: 8px;
}

.ui.card > .content > .header {
  color: var(--color-text-dark);
  font-weight: 600;
}

/* Statistic cards (KPIs) */
.ui.statistic > .value {
  color: var(--color-primary) !important;
  font-weight: 600;
}

.ui.statistic > .label {
  color: var(--color-text-light) !important;
  font-size: 0.95em;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

/* Segment refinements */
.ui.segment {
  border: 1px solid #E0E0E0;
  border-radius: 8px;
  box-shadow: 0 1px 4px rgba(0,0,0,0.05);
}

/* Executive brief styling */
.executive-brief {
  background: white;
  padding: 2em;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  margin-bottom: 1.5em;
}

.executive-brief h2 {
  color: var(--color-primary);
  margin-bottom: 1em;
  font-weight: 600;
}

.insight-box {
  background: #F8F9FA;
  border-left: 4px solid var(--color-primary);
  padding: 1em 1.5em;
  margin-bottom: 1em;
  border-radius: 4px;
}

.insight-box strong {
  color: var(--color-primary);
}

/* Risk callout */
.risk-callout {
  background: #FFF8F0;
  border-left: 4px solid var(--color-accent);
  padding: 1em 1.5em;
  margin-top: 1em;
  border-radius: 4px;
}

/* Data notes section */
.data-notes {
  background: #F5F5F5;
  padding: 1em;
  border-radius: 4px;
  font-size: 0.9em;
  color: var(--color-text-light);
  margin-top: 2em;
}

/* Chart containers */
.chart-container {
  background: white;
  padding: 1.5em;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
  margin-bottom: 1.5em;
}

.chart-title {
  color: var(--color-text-dark);
  font-size: 1.1em;
  font-weight: 600;
  margin-bottom: 1em;
}

/* Buttons */
.ui.button.primary {
  background: var(--color-primary) !important;
  color: white !important;
}

.ui.button.primary:hover {
  background: #234428 !important;
}

/* Remove excessive borders */
.ui.celled.grid > .row > .column,
.ui.celled.grid > .column {
  box-shadow: none;
}

/* Tabs refinement */
.ui.tabular.menu .active.item {
  border-color: var(--color-primary) !important;
  color: var(--color-primary) !important;
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .executive-brief {
    padding: 1em;
  }
  
  .ui.statistics {
    flex-direction: column !important;
  }
}
'

writeLines(custom_css, "www/css/custom.css")
cat("  ✅ www/css/custom.css\n")

# ============================================================================
# Create design system documentation
# ============================================================================
cat("\n📐 Creating design system reference...\n")

design_system <- '# Apple ESG Dashboard - Design System

## Color Palette

### Primary Colors
- **Forest Green** (#2C5530): Primary brand, headers, key metrics
- **Charcoal Gray** (#3C3C3C): Secondary text, borders
- **Warm Amber** (#D97C3A): Accent, warnings, highlights

### Supporting Colors  
- **Muted Green** (#4A7C4E): Success states, positive trends
- **Dark Text** (#2C2C2C): Primary text
- **Light Text** (#6C6C6C): Secondary text, labels
- **Background** (#F8F9FA): Page background
- **Card Background** (#FFFFFF): Card surfaces

## Typography

- **Font Family**: System fonts (-apple-system, Segoe UI, Roboto)
- **Headers**: 600 weight
- **Body**: 400 weight
- **Labels**: 500 weight, uppercase, letter-spacing

## Component Guidelines

### KPI Cards
- Use `ui.statistic()` from semantic.dashboard
- Value in primary green
- Label in light gray, uppercase

### Charts
- ggiraph for all interactive charts
- Single color for simple charts (forest green)
- Max 3 colors for multi-series (green, gray, amber)
- Clean axes, minimal gridlines
- Professional fonts

### Executive Brief
- Text-first approach
- Boxed insights with left border
- Minimal decoration
- Clear hierarchy

### Layout
- White cards on light gray background
- 8px border radius
- Subtle shadows (0 2px 8px rgba(0,0,0,0.08))
- Generous whitespace

## Principles

1. **Restraint**: Less is more - avoid visual clutter
2. **Consistency**: Use palette strictly
3. **Hierarchy**: Size and weight for emphasis, not color
4. **Accessibility**: Maintain WCAG AA contrast ratios
5. **Professional**: Consulting-grade, not consumer app
'

writeLines(design_system, "docs/design_system.md")
cat("  ✅ docs/design_system.md\n")

# ============================================================================
# Update .rscignore
# ============================================================================
cat("\n📝 Creating .rscignore...\n")

rscignore_content <- "# Exclude from deployment
renv/library
renv/staging
renv/python
.Rproj.user
.Rhistory
.RData

# Setup scripts
00_setup*.R
00_data_preparation.R

# Documentation
docs/
README.md

# Design files
www/images/screenshots/

# Version control
.git/
.gitignore

# Deployment tracking
rsconnect/

# Project files
*.Rproj
"

writeLines(rscignore_content, ".rscignore")
cat("  ✅ .rscignore\n")

# ============================================================================
# Summary
# ============================================================================
cat("\n")
cat(paste(rep("=", 70), collapse = ""), "\n")
cat("✅ Appsilon stack setup complete!\n\n")

cat("🎨 Design System:\n")
cat("  • Semantic UI framework (enterprise-grade)\n")
cat("  • Professional color palette (forest green + charcoal + amber)\n")
cat("  • Custom CSS for refinements\n")
cat("  • Design documentation in docs/\n\n")

cat("📦 Key Packages:\n")
cat("  • shiny.semantic: Modern UI components\n")
cat("  • semantic.dashboard: Dashboard layouts\n")
cat("  • ggiraph: Interactive SVG visualizations\n")
cat("  • reactable: Professional data tables\n")
cat("  • waiter: Loading screens\n\n")

cat("📋 Next Steps:\n")
cat("  1. Create runtime-safe R scripts\n")
cat("  2. Build chart generation functions (ggiraph)\n")
cat("  3. Develop app.R with semantic.dashboard\n")
cat("  4. Test locally, deploy to shinyapps.io\n\n")

cat(paste(rep("=", 70), collapse = ""), "\n")

