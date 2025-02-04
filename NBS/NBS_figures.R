# ===========================================================================
# Script: plot_NBS_results.R
# Purpose: Generate Heatmaps & Circos Plots from Posthoc_NBS_results.csv


# Load required libraries
library(ggplot2)
library(dplyr)
library(circlize)

# Read the CSV file and store it as 'for_heatmap'
for_heatmap <- read.csv("Posthoc_NBS_results.csv")

# Display the first few rows of the dataframe
head(for_heatmap)

# Correct P-values for multiple comparisons using Bonferroni correction
for_heatmap <- for_heatmap %>%
  mutate(
    Correctedp = pmin(p_Atypical_Typical * nrow(for_heatmap), 1), # Bonferroni correction
    Connection = gsub("([RL])_", "\\1 - ", Connection), # Formatting connections for readability
    Effect_Size = abs(T_Statistic) / sqrt(nrow(for_heatmap)) # Calculate Cohen's d
  )

# Display the updated dataframe
head(for_heatmap)

# ==========================
# 1. Heatmap of Effect Size
# ==========================
ggplot(for_heatmap, aes(x = Connection, y = Comparison)) +
  geom_tile(aes(fill = Effect_Size), size = 1.5) +  # Use Effect Size
  scale_fill_gradient(low = "lightblue", high = "darkblue", na.value = "transparent") +  
  labs(
    x = "", y = "", title = "Heatmap of Effect Size for Network Connections",
    fill = "Effect Size"
  ) +  
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1),
    legend.position = "right",
    panel.grid = element_blank(),
    panel.border = element_blank()
  ) +
  geom_text(aes(label = ifelse(Correctedp < 0.05, "*", "")), 
            color = "white", size = 5, fontface = "bold") +
  coord_fixed()

# ================================
# 2. Circos Plot - Atypical < Typical
# ================================
# Define significant connections and their effect sizes
connections <- c('F1_2_R_INSa3_R', 'STS3_L_T2_3_R', 'T2_3_L_T2_3_R', 'PUT2_L_T2_4_R', 'F1_2_L_THA4_L')
weights <- c(-4.1397, -3.7677, -3.5706, -3.7622, -3.7702)

# Convert into a Circos-compatible dataframe
Atypical_Typical_Circos <- data.frame(
  from = sub("(_R|_L).*", "\\1", connections),  
  to = sub(".*_R_|.*_L_", "", connections),     
  weight = weights                              
)

# Map lobes
Atypical_Typical_Circos$fromLOBE <- Local_network_measures$Group[match(Atypical_Typical_Circos$from, Local_network_measures$Node.Name)]
Atypical_Typical_Circos$toLOBE <- Local_network_measures$Group[match(Atypical_Typical_Circos$to, Local_network_measures$Node.Name)]

# Generate a lobe-level connection map
lobe_network <- data.frame(
  from = Atypical_Typical_Circos$fromLOBE,
  to = Atypical_Typical_Circos$toLOBE,
  weight = rep(1, nrow(Atypical_Typical_Circos))  
)

# Set Circos parameters
circos.par(
  cell.padding = c(0, 0, 0, 0),
  gap.after = rep(5, length(unique(c(Atypical_Typical_Circos$fromLOBE, lobe_network$toLOBE))))
)

# Define colour mapping for groups
group_colours <- c(
  'Frontal and insula' = 'lightblue',
  'Temporal and parietal' = 'lightpink',
  'Sub-cortical' = 'mediumpurple',
  'Internal surface' = 'lightgreen'
)

# Create Circos plot
chordDiagram(
  lobe_network[, c("from", "to", "weight")], 
  transparency = 0.5, 
  annotationTrack = c("grid"),  
  preAllocateTracks = list(track.height = 0.1),  
  grid.col = group_colours  
)

# Adjust text labels around the circle
circos.trackPlotRegion(track.index = 1, panel.fun = function(x, y) {
  circos.text(CELL_META$xcenter, CELL_META$ylim[2] + 0.2,  
              CELL_META$sector.index, 
              facing = "bending", niceFacing = TRUE, cex = 3)  
}, bg.border = NA)

circos.clear()

# ================================
# 3. Circos Plot - Strongly Atypical vs Typical
# ================================
Strongat_Typical_Circos <- data.frame(
  from = c('CINGp3_R', 'INSa1_R', 'INSa1_L', 'INSa1_L', 'INSa1_L', 
           'prec4_L', 'F3O1_L', 'INSa3_R', 'T1_4_R', 'STS3_L', 
           'T2_3_L', 'pCENT4_R', 'INSa1_R', 'O3_1_L'),
  to = c('INSa1_L', 'INSa3_R', 'O3_1_L', 'SMA3_R', 'T1_4_L', 
         'T1_4_L', 'T2_3_L', 'T2_3_L', 'T2_3_L', 'T2_3_R', 
         'T2_3_R', 'T2_4_L', 'T2_4_R', 'THA4_L'),
  weight = c(-5.4666, -3.5599, -5.4666, -5.4666, -3.6902, 
             -3.5684, -3.7613, -5.4666, -8.2642, -5.4666, 
             -4.2000, -4.5919, -5.4666, -5.4666)
)

# Map lobes
Strongat_Typical_Circos$fromLOBE <- Local_network_measures$Group[match(Strongat_Typical_Circos$from, Local_network_measures$Node.Name)]
Strongat_Typical_Circos$toLOBE <- Local_network_measures$Group[match(Strongat_Typical_Circos$to, Local_network_measures$Node.Name)]

# Ensure lobes are correctly set
Strongat_Typical_Circos$fromLOBE <- as.factor(Strongat_Typical_Circos$fromLOBE)
Strongat_Typical_Circos$toLOBE <- as.factor(Strongat_Typical_Circos$toLOBE)

# Print confirmation of Circos data
print(Strongat_Typical_Circos)
