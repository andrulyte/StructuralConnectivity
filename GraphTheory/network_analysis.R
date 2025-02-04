# Statistical Analysis for Network Metrics
# ----------------------------------------
# This script performs normality tests, ANCOVA, and Kruskal-Wallis tests
# for **individual network nodes** based on handedness & demographic data.
#

# **Setup Working Directory**
setwd("~/Documents/Liverpool/Thesis/Official_Writing/Chapter7NBS")

# **Load Required Libraries**
library(dplyr)
library(tidyr)

# **Load Data**
Global_efficiency <- read.csv("global_efficiency_measures.csv")
demog <- read.csv("demographics_with_handedness.csv")

# **Select and Merge Relevant Demographic Data**
demog_selected <- demog[, c("NSujet", "age_IRM_Anat", "HFLI_PROD_SentMWord", "sexe_demog", "EdinburgScore", "AtypPROD3Classes_demog")]
merged_data <- merge(Global_efficiency, demog_selected, by.x = "Subject.ID", by.y = "NSujet")

# **Check Normality for Global Efficiency**
shapiro_test <- shapiro.test(merged_data$Global.Efficiency)
print(shapiro_test)

# **Shapiro-Wilk Tests for Each Global Efficiency Group**
group_shapiro_tests <- list(
  Typical = shapiro.test(merged_data %>% filter(AtypPROD3Classes_demog == "Typical") %>% pull(Global.Efficiency)),
  Atypical = shapiro.test(merged_data %>% filter(AtypPROD3Classes_demog == "Atypical") %>% pull(Global.Efficiency)),
  Strong_Atypical = shapiro.test(merged_data %>% filter(AtypPROD3Classes_demog == "Strong-Atypical") %>% pull(Global.Efficiency))
)
print(group_shapiro_tests)

# **Ensure Correct Data Types**
merged_data <- merged_data %>%
  mutate(
    Global.Efficiency = as.numeric(Global.Efficiency),
    age_IRM_Anat = as.numeric(age_IRM_Anat),
    EdinburgScore = as.numeric(EdinburgScore),
    AtypPROD3Classes_demog = as.factor(AtypPROD3Classes_demog),
    sexe_demog = factor(sexe_demog, levels = c("H", "F"), labels = c("Male", "Female"))
  )

# **ANCOVA Model**
ancova_model <- aov(Global.Efficiency ~ AtypPROD3Classes_demog + age_IRM_Anat + sexe_demog + EdinburgScore, data = merged_data)
print(summary(ancova_model))

# **Load Local Network Measures**
Local_network_measures <- read.csv("all_measures_with_group.csv")

# **Merge with Demographics**
merged_data_local <- merge(Local_network_measures, demog_selected, by.x = "Subject.ID", by.y = "NSujet")

# **Data Cleaning Function**
clean_data <- function(data) {
  data %>%
    filter(across(c(Nodal.Strength, Path.Length, Local.Efficiency, Clustering, sexe_demog, EdinburgScore, age_IRM_Anat), 
                  ~ !is.na(.) & !is.infinite(.) & . >= 0))
}

# **Clean Data Before Kruskal-Wallis Tests**
merged_data_clean <- clean_data(merged_data_local)

# **Assign Hemisphere Labels**
merged_data_clean <- merged_data_clean %>%
  mutate(Hemisphere = ifelse(grepl("_L$", Node.Name), "Left", "Right"))

# **Perform Normality Tests on Each Node**
node_names <- unique(merged_data_clean$Node.Name)
metrics <- c("Nodal.Strength", "Path.Length", "Local.Efficiency", "Clustering")

normality_tests_clean <- list()

for (node in node_names) {
  node_data <- merged_data_clean %>% filter(Node.Name == node)
  
  node_tests <- lapply(metrics, function(metric) {
    if (length(node_data[[metric]]) > 2) {  # Ensure we have enough data points for testing
      return(shapiro.test(node_data[[metric]]))
    } else {
      return(NA)
    }
  })
  
  names(node_tests) <- metrics
  normality_tests_clean[[node]] <- node_tests
}

print(normality_tests_clean)  # **Print all normality test results for nodes**

# **Initialize Kruskal-Wallis Results Table**
kruskal_results_table <- data.frame()

# **Perform Kruskal-Wallis Tests for Each Node**
for (node in node_names) {
  subset_data <- merged_data_clean %>% filter(Node.Name == node)
  
  for (metric in metrics) {
    lm_model <- lm(as.formula(paste(metric, "~ sexe_demog + EdinburgScore + age_IRM_Anat")), data = subset_data)
    subset_data$residuals <- residuals(lm_model)
    
    kruskal_test <- kruskal.test(residuals ~ AtypPROD3Classes_demog, data = subset_data)

    group_counts <- table(subset_data$AtypPROD3Classes_demog)
    total_count <- sum(group_counts)

    kruskal_results_table <- rbind(kruskal_results_table, data.frame(
      Node.Name = node,
      Metric = metric,
      P.Value = kruskal_test$p.value,
      Chi_Square = kruskal_test$statistic,
      Typical_Count = ifelse("Typical" %in% names(group_counts), group_counts["Typical"], 0),
      Atypical_Count = ifelse("Atypical" %in% names(group_counts), group_counts["Atypical"], 0),
      Strong_Atypical_Count = ifelse("Strong-Atypical" %in% names(group_counts), group_counts["Strong-Atypical"], 0),
      Total_Count = total_count,
      Effect_Size = kruskal_test$statistic / (total_count - 1)
    ))
  }
}

# **Adjust for Multiple Comparisons**
kruskal_results_table$Adjusted_Pval <- p.adjust(kruskal_results_table$P.Value, method = "fdr")

# **Print Final Kruskal-Wallis Results**
print(kruskal_results_table)
