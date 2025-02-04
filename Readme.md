# Connectivity Matrices Processing Pipeline

## Overview
This repository contains scripts for computing diffusion MRI connectivity matrices, intra- and inter-hemispheric connectivity, graph theory measures, and Network-Based Statistics (NBS) analysis. Additionally, it includes statistical analyses to examine group differences across these metrics.

## Directory Structure
```
📂 Connectivity_matrices/
 ├── connectivity_functions.m      # Helper functions for connectivity processing
 ├── filter_connectivity_nodes.m   # Filters connectivity matrices using SENSAAS atlas
 ├── generate_connectivity_matrices.sh  # SLURM script for generating connectivity matrices
 ├── submit_connectivity_jobs.sh  # SLURM batch script to process multiple subjects

📂 ConnectivitySums/
 ├── inter_intra_metrics.m   # Computes inter- and intra-hemispheric connectivity sums
 ├── MANOVA.r   # Performs MANOVA on connectivity metrics

📂 GraphTheory/
 ├── network_analysis.R       # Performs statistical analysis on network metrics
 ├── network_heatmap.R        # Generates heatmaps for network effect sizes
 ├── extract_global_efficiency.py  # Extracts global efficiency metrics
 ├── extract_regional_metrics.py   # Extracts regional network metrics
 ├── AICHA_to_SENSAAS.py      # Converts AICHA atlas to SENSAAS atlas
 ├── Network_metrics.sh       # Computes graph theory metrics using streamline and length matrices

📂 NBS/
 ├── brainnet_visualization_posthoc.m   # Generates BrainNet visualization files for post-hoc t-tests
 ├── generate_BrainNet_files.m   # Generates node and edge files for BrainNet visualization
 ├── NBS_figures.R   # Creates heatmaps and Circos plots for NBS results
 ├── posthoc_NBS_analysis.m   # Performs post-hoc t-tests on NBS connections
 ├── prepare_NBS_data.m   # Prepares data for NBS analysis
 ├── save_NBS_results.m   # Extracts and saves significant NBS connections
```

## Folder Descriptions
### `Connectivity_matrices/`
Contains scripts for generating and filtering diffusion MRI-based connectivity matrices using the SENSAAS atlas. These scripts are used to extract structural connectivity information and store it in `.npy` format for further processing.

### `ConnectivitySums/`
Includes scripts for computing inter- and intra-hemispheric connectivity sums and running MANOVA analysis on extracted connectivity metrics. These analyses help quantify how hemispheric connectivity differs across groups.

### `GraphTheory/`
Contains scripts for computing graph theory measures, including global efficiency, nodal strength, and clustering coefficients. Analyses involve statistical testing of graph-theoretic metrics to assess differences between groups.

### `NBS/`
Holds scripts for running Network-Based Statistics (NBS) analyses, performing post-hoc tests, and generating visualizations such as BrainNet edge/node files and Circos plots to examine connectivity differences between groups.


## Dependencies
### MATLAB
- `readNPY.m`

### R
- `tidyr`, `dplyr`, `ggplot2`, `circlize`

### Python
- `numpy`, `pandas`, `networkx`, `scilpy`

### HPC Environment
- SLURM workload manager



