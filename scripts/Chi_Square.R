# ============================================================
# Chi-Square Analysis for Associations in Digital Tool Use
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
# - Exports results to a formatted Excel file with conditional styling
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
#
# Notes:
# - This script is designed for reproducibility and accompanies a public
#   data and code repository.
# - All identifiable survey data has been anonymised prior to use.
# - Colour styling (low, medium, high proportions) is applied for
#   interpretability and does not affect statistical results.
#
# Version: 1.0 (Final analysis for publication)
# Date: 2026-03-29
#
# ============================================================
library(openxlsx)

runChiSquareTest <- function(variable1_name, variable2_name) {
  # Define styles for color-coding
  lowStyle <- createStyle(fontColour = "#9C0006", fontSize = 12, halign = "center") # Red for low
  mediumStyle <- createStyle(fontColour = "orange", fontSize = 12, halign = "center") # Yellow for medium
  highStyle <- createStyle(fontColour = "#006100", fontSize = 12, halign = "center") # Green for high
  
  # Import the dataset
  data <- read_excel("INSERT PATHNAME HERE", sheet = "Cleaned Data UGGp")
  
  # Remove rows with missing values in the selected variables
  data <- data %>%
    filter(!is.na(.[[variable1_name]]) & !is.na(.[[variable2_name]]))
  
  # Create a contingency table
  table_data <- table(data[[variable1_name]], data[[variable2_name]])
  
  # Perform the Chi-Square Test
  chi_square_result <- chisq.test(table_data)
  
  # Extract categories and frequencies
  observed <- as.matrix(chi_square_result$observed)
  expected <- as.matrix(chi_square_result$expected)
  
  # Calculate proportions
  row_proportions <- prop.table(observed, margin = 1)
  col_proportions <- prop.table(observed, margin = 2)
  
  # Combined dataframe
  combined_df <- data.frame(
    Variable1 = rep(rownames(observed), each = ncol(observed)),
    Variable2 = rep(colnames(observed), nrow(observed)),
    Observed = c(t(observed)),
    Expected = c(t(expected)),
    Chi_Square_Statistic = rep(chi_square_result$statistic, length(observed)),
    Degrees_of_Freedom = rep(chi_square_result$parameter, length(observed)),
    P_Value = rep(chi_square_result$p.value, length(observed))
  )
  
  print(combined_df$P_Value)
  
  # Prepare Excel file for output
  wb <- createWorkbook()
  addWorksheet(wb, "Observed")
  writeData(wb, "Observed", observed)
  addWorksheet(wb, "Chi-Square Results")
  writeData(wb, "Chi-Square Results", combined_df)
  
  # Write and style Row Proportions
  addWorksheet(wb, "Row Proportions")
  writeData(wb, "Row Proportions", row_proportions)
  styleProportions(wb, "Row Proportions", row_proportions, lowStyle, mediumStyle, highStyle)
  
  # Write and style Column Proportions
  addWorksheet(wb, "Column Proportions")
  writeData(wb, "Column Proportions", col_proportions)
  styleProportions(wb, "Column Proportions", col_proportions, lowStyle, mediumStyle, highStyle)
  
  # Construct Excel file name
  excel_file_name <- paste0("Chi_Square_Results_", variable1_name, "_", variable2_name, ".xlsx")
  
  # Save the workbook
  saveWorkbook(wb, excel_file_name, overwrite = TRUE)
  cat("Exported Excel file:", excel_file_name, "\n")
}


styleProportions <- function(wb, sheetName, proportions, lowStyle, mediumStyle, highStyle) {
  nrows <- nrow(proportions)
  ncols <- ncol(proportions)
  for (row in 1:nrows) {
    for (col in 1:ncols) {
      value <- proportions[row, col]
      # Calculate the style based on the value
      style <- if (value <= 0.2) {
        lowStyle
      } else if (value > 0.8) {
        highStyle
      } else {
        mediumStyle
      }
      addStyle(wb, sheet = sheetName, style = style, rows = row + 1, cols = col + 1, gridExpand = FALSE)
    }
  }
  # Auto-size the columns to fit content
  setColWidths(wb, sheetName, cols = 1:ncols, widths = "auto")
}

# Example usage
runChiSquareTest("AR", "Management_Structure")
