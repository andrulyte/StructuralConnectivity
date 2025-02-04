# Heatmap Visualization for Effect Sizes

# This script creates a heatmap of effect sizes for different network nodes 
# based on the Kruskal-Wallis test results.


setwd("~/Documents/Liverpool/Thesis/Official_Writing/Chapter7NBS")

library(dplyr)
library(tidyr)
library(ComplexHeatmap)

source("network_analysis.R")  # Ensure statistical analysis is run first

heatmap_data <- kruskal_results_table_NODES %>%
  dplyr::select(Node.Name, Metric, Effect_Size) %>%
  pivot_wider(names_from = Metric, values_from = Effect_Size)

heatmap_data[is.na(heatmap_data)] <- 0

heatmap_matrix <- as.matrix(heatmap_data[,-1]) 
rownames(heatmap_matrix) <- heatmap_data$Node.Name  

heatmap(
  heatmap_matrix,                                
  scale = "none",                                
  col = colorRampPalette(c("white", "red"))(100), 
  margins = c(10, 10),                           
  Rowv = NA,                                     
  Colv = NA,                                     
  cexCol = 0.8,                                  
  cexRow = 0.8,                                  
  las = 1                                        
)

par(fig = c(0.82, 0.85, 0.7, 0.95), new = TRUE, mar = c(0, 0, 0, 0))  
effect_size_range <- range(heatmap_matrix, na.rm = TRUE)              
color_palette <- colorRampPalette(c("white", "red"))(100)             

image(
  1, seq(effect_size_range[1], effect_size_range[2], length.out = 100),
  z = t(matrix(seq(effect_size_range[1], effect_size_range[2], length.out = 100))),
  col = color_palette,
  axes = FALSE
)

axis(4, at = seq(effect_size_range[1], effect_size_range[2], length.out = 5), 
     labels = round(seq(effect_size_range[1], effect_size_range[2], length.out = 5), 2), 
     las = 1, cex.axis = 0.7)

mtext("Effect Size", side = 3, line = 0.7, cex = 0.7)
