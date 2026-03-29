# ============================================================
# Negative Binomial Regression for Digital Tool Adoption in Geoparks
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
# This script performs negative binomial regression to assess the
# influence of demographic, geographic, and operational factors
# on the extent of digital tool adoption across UNESCO Global Geoparks.
#
# A full model including all predictors is first specified, followed by
# backward selection based on AIC to derive a reduced model. The final
# model retains only predictors that significantly contribute to model fit,
# as described in the methods section of the manuscript.
#
# Inputs:
# - Cleaned survey dataset (Excel format)
#
# Outputs:
# - CSV file containing model coefficients, incidence rate ratios (IRR),
#   confidence intervals, and p-values for the final reduced model
#
# Notes:
# - This script is designed for reproducibility and accompanies a public
#   data and code repository.
# - All identifiable survey data has been anonymised prior to use.
#
# Version: 1.0 (Final analysis for publication)
# Date: 2026-03-29
#
# ============================================================


# Load necessary libraries
library(readxl)  # For reading Excel files
library(dplyr)   # For data manipulation
library(forcats) # For working with factors
library(ggplot2)  # For plotting
library(MASS)     # For negative binomial regression

# Set the working directory
setwd("INSERT PATHNAME HERE")

# Import the dataset
data <- read_excel("Digital_Tools_UGGp_DATA_CLEANED_GITHUB.xlsx", sheet = "Cleaned Data UGGp")

# Convert all predictor variables to factors with explicit levels and labels as required
data$Gender <- factor(data$Gender, levels = c("Female", "Male", "Unspecified"))
data$Position <- factor(data$Position, levels = c("Geopark manager", "Geoscientist", "Other", "Senior personnel"))
data$Era <- factor(data$Era, levels = c("2004 - 2010", "2011 - 2014", "2015 - 2023"))
data$Network <- factor(data$Network, levels = c("EGN", "APGN", "AUGGN", "CGN", "GeoLAC"))
data$Size_Category <- factor(data$Size_Category, levels = c("Small", "Medium", "Large", "Very Large"))
data$Usage <- factor(data$Usage, levels = c("Daily", "Weekly", "Monthly", "Less than Monthly", "I don't use digital tools", "I'm not sure what digital tools are"))
data$Years_of_Employment <- factor(data$`Years of Employment`, levels = c("0-2", "3-5", "6-10", "11+", "Unspecified"))
data$Years_Since_Initial_Evaluation_or_Revalidation <- factor(data$`Years Since Initial Evaluation or Revalidation`, levels = c("Initial 0-2", "Initial 3-4", "0-2", "3-4", ">4"))

# Removing entries where digital tools were not reported specified as 'Unknown'
data_filtered <- data %>% 
  filter(Adoption_Rate != "Unknown", Gender != "Unspecified", `Years of Employment` != "Unspecified")

# Fit the Negative Binomial regression model
nb_model_full <- glm.nb(as.numeric(Adoption_Count) ~ Position + Era + Size_Category + Gender +
                          Years_of_Employment + Years_Since_Initial_Evaluation_or_Revalidation +
                          Usage + Network, data = data_filtered)

# Perform backward elimination based on AIC for Negative Binomial model
nb_backward_reduced_model <- step(nb_model_full, direction = "backward")

#Null model with only the intercept (stepwise selection)
nb_null_model <- glm.nb(as.numeric(Adoption_Count) ~ 1, data = data_filtered)

# Perform stepwise selection
nb_stepwise_model <- step(nb_null_model, scope = list(lower = nb_null_model, upper = nb_model_full), direction = "both")

# Define the minimal model with only the intercept
nb_minimal_model <- glm.nb(as.numeric(Adoption_Count) ~ 1, data = data_filtered)

# Perform forward selection
nb_forward_selected_model <- step(nb_minimal_model, scope = list(lower = nb_minimal_model, upper = nb_model_full),
                                  direction = "forward", trace = TRUE)  # trace = TRUE will show the steps

# Calculate IRR by exponentiating the coefficients
irrs <- exp(coef(nb_forward_selected_model))

# Extract summary data
extract_model_summary <- function(model) {
  summary_df <- summary(model)$coefficients
  data.frame(Term = rownames(summary_df), Estimate = summary_df[, "Estimate"],
             StdError = summary_df[, "Std. Error"], zValue = summary_df[, "z value"],
             Pr = summary_df[, "Pr(>|z|)"], IRR = irrs, check.names = FALSE)
}

# Create data frames for each model summary
forward_summary <- extract_model_summary(nb_forward_selected_model)
stepwise_summary <- extract_model_summary(nb_stepwise_model)
backward_summary <- extract_model_summary(nb_backward_reduced_model)

# Add a column to identify the model
forward_summary$Model <- "Forward Selection"
stepwise_summary$Model <- "Stepwise Selection"
backward_summary$Model <- "Backward Elimination"

#test reduced model (backward elimination) using likelihood ratio test
#lrt_result <- anova(nb_model_full, nb_backward_reduced_model, test = "Chisq")
#print(lrt_result)

# Coefficients table which includes Estimate and Std. Error
coefficients_summary <- coef(summary(nb_forward_selected_model))

# Calculate 95% confidence intervals
ci_limits <- confint(nb_forward_selected_model)

# Since confint() by default provides 95% CI on the log scale, we need to exponentiate
ci_limits_exp <- exp(ci_limits)

# Alternatively, manually calculate the 95% CI if confint does not work as expected
beta <- coefficients_summary[, "Estimate"]
se_beta <- coefficients_summary[, "Std. Error"]

# Lower and upper bounds
lower_bounds <- beta - 1.96 * se_beta
upper_bounds <- beta + 1.96 * se_beta

# Exponentiating the bounds to get them on the original scale as IRRs
ci_lower <- exp(lower_bounds)
ci_upper <- exp(upper_bounds)

# Extract the coefficient summary from the model
coeff_summary <- summary(nb_forward_selected_model)$coefficients
# Convert coefficient summary to data frame
coeff_df <- as.data.frame(coeff_summary)
coeff_df$Predictor <- rownames(coeff_summary)  # Add predictor names as a column
# Merge the coefficients data frame with the CI data frame
final_df <- merge(coeff_df, ci_df, by = "Predictor")
# Write the final combined data frame to a CSV file
write.csv(final_df, "nb_regression_results_with_CI.csv", row.names = TRUE)
