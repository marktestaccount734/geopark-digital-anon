# ============================================================
# Chi-Square Analysis and Heatmap Visualisation for Associations
# in Digital Tool Use
# ============================================================
#
# This script forms part of the analysis for the following study:
#
# "Does Digital Transformation Drive Innovation in UNESCO Global
# Geoparks? Evidence from a Global Survey on the Role of Digital Tools"
#
# Author: Anonymous (for blind review)
#
# Status: Manuscript under review / in preparation
#
# Description:
# This script performs Chi-square tests of independence to examine
# associations between categorical variables related to digital tool use,
# including demographic, geographic, and operational characteristics of
# UNESCO Global Geoparks.
#
# For each variable pair, the script:
# - Generates contingency tables (observed and expected frequencies)
# - Calculates row and column proportions
# - Performs Chi-square tests of independence
# - Exports results to a formatted Excel file
# - Produces a heatmap visualisation of the observed contingency table
#
# These analyses correspond to the bivariate statistical analyses
# described in the methods section of the manuscript.
#
# Inputs:
# - Cleaned survey dataset (Excel format)
#
# Outputs:
# - Excel file containing:
#   - Observed frequencies
#   - Expected frequencies
#   - Row and column proportions
#   - Chi-square test statistics (χ², df, p-value)
# - PNG heatmap of observed frequencies coloured by within-row percentage
#
# Notes:
# - This script is designed for reproducibility and accompanies a public
#   data and code repository.
# - All identifiable survey data has been anonymised prior to use.
# - Rows containing "Unknown" values for either selected variable are
#   excluded before analysis.
# - Heatmap categories are ordered as High, Moderate, and Low where
#   present in the data.
#
# Version: 1.0 (Final analysis for publication)
# Date: 2026-04-11
#
# ============================================================

library(openxlsx)
library(readxl)
library(dplyr)
library(tidyr)
library(ggplot2)
library(grid)
library(tibble)

runChiSquareTest <- function(variable1_name,
                             variable2_name,
                             input_file,
                             input_sheet = "Cleaned Data UGGp",
                             output_dir = ".",
                             exclude_values = c("Unknown")) {
  
  # Import dataset
  data <- read_excel(input_file, sheet = input_sheet)
  
  # Remove missing and excluded values
  data <- data %>%
    filter(
      !is.na(.data[[variable1_name]]),
      !is.na(.data[[variable2_name]]),
      !.data[[variable1_name]] %in% exclude_values,
      !.data[[variable2_name]] %in% exclude_values
    )
  
  # Create contingency table
  table_data <- table(data[[variable1_name]], data[[variable2_name]])
  
  # Perform Chi-square test
  chi_square_result <- chisq.test(table_data)
  
  # Extract outputs
  observed <- as.matrix(chi_square_result$observed)
  expected <- as.matrix(chi_square_result$expected)
  row_proportions <- prop.table(observed, margin = 1)
  col_proportions <- prop.table(observed, margin = 2)
  
  # Extract test statistics
  x2 <- unname(chi_square_result$statistic)
  df <- unname(chi_square_result$parameter)
  p_value <- chi_square_result$p.value
  
  # Print test statistics
  cat("\n============================================================\n")
  cat("Chi-square test:", variable1_name, "vs", variable2_name, "\n")
  cat("df   =", df, "\n")
  cat("X2   =", sprintf("%.3f", x2), "\n")
  cat("Sig. =", sprintf("%.3f", p_value), "\n")
  cat("============================================================\n\n")
  
  # Combined results dataframe
  combined_df <- data.frame(
    Variable1 = rep(rownames(observed), each = ncol(observed)),
    Variable2 = rep(colnames(observed), nrow(observed)),
    Observed = c(t(observed)),
    Expected = c(t(expected)),
    Chi_Square_Statistic = rep(x2, length(observed)),
    Degrees_of_Freedom = rep(df, length(observed)),
    P_Value = rep(p_value, length(observed))
  )
  
  # Create safe file names
  safe_var1 <- gsub("[^A-Za-z0-9_]", "_", variable1_name)
  safe_var2 <- gsub("[^A-Za-z0-9_]", "_", variable2_name)
  
  # ------------------------------------------------------------
  # Export Excel workbook
  # ------------------------------------------------------------
  wb <- createWorkbook()
  
  addWorksheet(wb, "Observed")
  writeData(wb, "Observed", observed, rowNames = TRUE)
  
  addWorksheet(wb, "Expected")
  writeData(wb, "Expected", expected, rowNames = TRUE)
  
  addWorksheet(wb, "Chi-Square Results")
  writeData(wb, "Chi-Square Results", combined_df)
  
  addWorksheet(wb, "Row Proportions")
  writeData(wb, "Row Proportions", row_proportions, rowNames = TRUE)
  
  addWorksheet(wb, "Column Proportions")
  writeData(wb, "Column Proportions", col_proportions, rowNames = TRUE)
  
  excel_file_name <- paste0("Chi_Square_Results_", safe_var1, "_", safe_var2, ".xlsx")
  excel_file_path <- file.path(output_dir, excel_file_name)
  
  saveWorkbook(wb, excel_file_path, overwrite = TRUE)
  cat("Exported Excel file:", excel_file_path, "\n")
  
  # ------------------------------------------------------------
  # Prepare heatmap data from observed table
  # ------------------------------------------------------------
  data_long <- as.data.frame(observed)
  colnames(data_long) <- c("Response", "Intensity", "Count")
  
  # Order intensity levels if present
  desired_levels <- c("High", "Moderate", "Low")
  present_levels <- desired_levels[desired_levels %in% unique(data_long$Intensity)]
  data_long$Intensity <- factor(data_long$Intensity, levels = present_levels)
  
  # Calculate percentages within each response group
  data_long <- data_long %>%
    group_by(Response) %>%
    mutate(Percentage = Count / sum(Count) * 100) %>%
    ungroup()
  
  # Dynamic legend scaling
  max_percentage <- max(data_long$Percentage, na.rm = TRUE)
  breaks <- seq(0, ceiling(max_percentage / 10) * 10, by = 10)
  labels <- as.character(breaks)
  labels[1] <- ""
  
  # ------------------------------------------------------------
  # Create heatmap
  # ------------------------------------------------------------
  heatmap_plot <- ggplot(data_long, aes(x = Intensity, y = Response, fill = Percentage)) +
    geom_tile() +
    geom_text(aes(label = Count), color = "black", size = 6) +
    scale_fill_viridis_c(
      alpha = 0.8,
      limits = c(0, max(breaks)),
      breaks = breaks,
      labels = labels,
      guide = guide_colorbar(
        barheight = grid::unit(0.8, "npc"),
        barwidth = grid::unit(10, "mm")
      )
    ) +
    theme_minimal() +
    theme(
      text = element_text(size = 14),
      legend.title = element_blank(),
      legend.text = element_text(size = 14),
      axis.title.x = element_blank(),   # remove x-axis title
      axis.title.y = element_blank(),   # remove y-axis title
      axis.text = element_text(size = 14),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank()
    )
  
  print(heatmap_plot)
  
  # Save plot
  plot_file_name <- paste0("Chi_Contingency_table_", safe_var1, "_", safe_var2, ".png")
  plot_file_path <- file.path(output_dir, plot_file_name)
  
  ggsave(
    filename = plot_file_path,
    plot = heatmap_plot,
    width = 5,
    height = 3,
    dpi = 300,
    device = "png",
    bg = "white"
  )
  
  cat("Exported plot file:", plot_file_path, "\n")
  
  invisible(list(
    observed = observed,
    expected = expected,
    row_proportions = row_proportions,
    col_proportions = col_proportions,
    chi_square_result = chi_square_result,
    plot = heatmap_plot
  ))
}

# Example usage
setwd("INSERT PATH")

#Geology_Landscape
#Geotourism
#Interpretation_Education
#Management_Structure
#Sustainable_Economy

runChiSquareTest(
  variable1_name = "AR",
  variable2_name = "Management_Structure",
  input_file = "INSERT PATH",
  output_dir = getwd()
)

