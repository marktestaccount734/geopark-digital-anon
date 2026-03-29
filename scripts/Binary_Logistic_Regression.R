# ============================================================
# Binary Logistic Regression for Digital Tool Uptake in Geoparks
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
# This script performs binary logistic regression to assess the
# influence of demographic, geographic, and operational factors
# on the uptake of specific digital tools (e.g., Web App, Mobile App,
# VR, AR, Drones) in UNESCO Global Geoparks.
#
# The model includes the full set of predictors as described in the
# methods section of the manuscript.
#
# Inputs:
# - Cleaned survey dataset (Excel format)
#
# Outputs:
# - CSV file containing model coefficients, odds ratios,
#   confidence intervals, and p-values
#
# Notes:
# - This script is designed for reproducibility and dataset is available in
# repository
# - All identifiable survey data has been anonymised prior to use.
#
# Version: 1.0 (Final analysis for publication)
# Date: 2026-03-29
#
# ============================================================

# Load necessary libraries
library(readxl) # For reading Excel files
library(dplyr)  # For data manipulation
library(forcats) # For factor management

# Set the working directory
setwd("INSERT YOUR PATHNAME HERE")

# Import the dataset
data <- read_excel("Digital_Tools_UGGp_DATA_CLEANED.xlsx", sheet = "Cleaned Data UGGp")

# Convert all predictor variables to factors
data$Gender <- factor(data$Gender)
data$Position <- factor(data$Position)
data$Era <- factor(data$Era)
data$Network <- factor(data$Network)
data$Size_Category <- factor(data$Size_Category)
data$Usage <- factor(data$Usage)
data$Years_of_Employment <- factor(data$`Years of Employment`)
data$Years_Since_Initial_Evaluation_or_Revalidation <- factor(data$`Years Since Initial Evaluation or Revalidation`)

# Removing entries where Years of Employment or Gender is 'Unspecified'
data_filtered <- data %>%
  filter(Years_of_Employment != "Unspecified", Gender != "Unspecified")

# Specify the 'Component' as the outcome variable for specific technology ('Yes', 'No') 
Component <- "Web App" #remove comment for the component you want to run the model for
#Component <- "Mobile App"
#Component <- "Field Collection App"
#Component <- "VR"
#Component <- "AR"
#Component <- "Drones"
data_filtered[[Component]] <- factor(data_filtered[[Component]], levels = c("No", "Yes"))
data_filtered$Size_Category <- factor(data_filtered$Size_Category, levels = c("Small", "Medium", "Large", "Very Large"))
data_filtered$Years_Since_Initial_Evaluation_or_Revalidation <- factor(data_filtered$Years_Since_Initial_Evaluation_or_Revalidation, levels = c("Initial 0-2", "Initial 3-4", "0-2", "3-4", ">4"))
data_filtered$Network <- factor(data_filtered$Network, levels = c("EGN", "APGN", "AUGGN", "CGN", "GeoLAC"))

# Perform the binary logistic regression
model <- glm(data_filtered[[Component]] ~ Position + Era + Size_Category +
               Gender + Years_of_Employment + Years_Since_Initial_Evaluation_or_Revalidation +
               Usage + Network, 
             data = data_filtered, family = binomial)

summary(model)

# Get the summary of the model
model_summary <- summary(model)
print(model_summary)

# Extract coefficients and compute odds ratios
coef_values <- coef(model)
odds_ratios <- exp(coef_values)

# Calculate standard errors, z-values, and p-values
se_values <- sqrt(diag(vcov(model)))
z_values <- coef_values / se_values
p_values <- 2 * (1 - pnorm(abs(z_values)))

# Calculate confidence intervals for odds ratios
ci_lower <- exp(coef_values - 1.96 * se_values)
ci_upper <- exp(coef_values + 1.96 * se_values)

# Combine odds ratios and confidence intervals into a data frame
odds_ratios_df <- data.frame(
  Coefficient = names(odds_ratios),
  OddsRatio = odds_ratios,
  LowerCI = ci_lower,
  UpperCI = ci_upper,
  PValue = p_values
)

# Print the odds ratios data frame
print(odds_ratios_df)

# Construct output file name
model_summary_file <- paste0("binary_logistic_regression_results_", Component, ".csv")

# Write odds ratios and confidence intervals to a file
write.csv(odds_ratios_df, file = model_summary_file, row.names = FALSE, quote = FALSE)

# Print final summary to R console
print("Binary logistic regression results have been saved to:")
print(model_summary_file)

