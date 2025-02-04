# Save results to CSV
library(tidyr)
library(dplyr)

# Read the CSV file
df <- read.csv("connectivity_results.csv")

# Convert to long format 
results <- df %>%
  pivot_longer(cols = c(Intrahemispheric_Left_Sum, Intrahemispheric_Right_Sum, Interhemispheric_Sum), 
               names_to = "Connectivity_Type", 
               values_to = "Connectivity_Value")

# Load necessary libraries
library(ggplot2)

# Define dependent variables
dependent_vars <- results[, c("Intrahemispheric_Left_Sum", "Intrahemispheric_Right_Sum", "Interhemispheric_Sum")]

# Calculate Mahalanobis distance
mahalanobis_dist <- mahalanobis(dependent_vars, colMeans(dependent_vars, na.rm = TRUE), cov(dependent_vars, use = "complete.obs"))

# Set threshold for outliers
threshold <- qchisq(0.975, df = ncol(dependent_vars))  # 97.5% confidence level

# Identify outliers
outliers <- which(mahalanobis_dist > threshold)

# Print subjects and group names for outliers
cat("Outliers:\n")
print(data.frame(
  Subject = results$Subject[outliers],
  GroupNameFull = results$GroupNameFull[outliers]
))

# Create a new dataset without outliers
results_clean <- results[-outliers, ]

# Run MANOVA model
manova_model <- manova(cbind(Intrahemispheric_Left_Sum, Intrahemispheric_Right_Sum, Interhemispheric_Sum) ~ GroupNameFull + Age + Sex + Handedness, data = results_clean)
summary(manova_model)
