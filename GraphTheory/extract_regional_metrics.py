#!/usr/bin/env python3
"""
Extract Regional Network Measures
----------------------------------
This script processes JSON files from network analysis, extracts nodal measures, 
assigns regions to groups, and outputs a CSV table.

Metrics Extracted:
- Nodal Strength
- Path Length
- Local Efficiency
- Clustering

"""

import json
import pandas as pd
import glob
import os

# **Define Directories**
OUTPUT_DIR = "/Volumes/LaCie/Network_results"

# **Get all JSON files**
json_files = glob.glob(os.path.join(OUTPUT_DIR, "result_*.json"))

# **Node Names & Group Mappings**
NODE_NAMES = [
    "AG2_L", "AG2_R", "AMYG_L", "AMYG_R", "CINGp3_L", "CINGp3_R",
    "f2_2_L", "f2_2_R", "F1_2_L", "F1_2_R", "F3O1_L", "F3O1_R",
    "F3t_L", "F3t_R", "FUS4_L", "FUS4_R", "HIPP2_L", "HIPP2_R",
    "INSa1_L", "INSa1_R", "INSa2_L", "INSa2_R", "INSa3_L", "INSa3_R",
    "O3_1_L", "O3_1_R", "pCENT4_L", "pCENT4_R", "pHIPP1_L", "pHIPP1_R",
    "prec3_L", "prec3_R", "prec4_L", "prec4_R", "PRECU6_L", "PRECU6_R",
    "PUT2_L", "PUT2_R", "PUT3_L", "PUT3_R", "SMA2_L", "SMA2_R",
    "SMA3_L", "SMA3_R", "SMG7_L", "SMG7_R", "STS1_L", "STS1_R",
    "STS2_L", "STS2_R", "STS3_L", "STS3_R", "STS4_L", "STS4_R",
    "T1_4_L", "T1_4_R", "T2_3_L", "T2_3_R", "T2_4_L", "T2_4_R",
    "T3_4_L", "T3_4_R", "THA4_L", "THA4_R"
]

GROUP_MAPPING = {
    "prec3": "Frontal and insula", "prec4": "Frontal and insula", "F1_2": "Frontal and insula",
    "f2_2": "Frontal and insula", "F3t": "Frontal and insula", "F3O1": "Frontal and insula",
    "INSa1": "Frontal and insula", "INSa2": "Frontal and insula", "INSa3": "Frontal and insula",
    "T1_4": "Temporal and parietal", "T2_3": "Temporal and parietal", "T2_4": "Temporal and parietal",
    "T3_4": "Temporal and parietal", "STS1": "Temporal and parietal", "STS2": "Temporal and parietal",
    "STS3": "Temporal and parietal", "STS4": "Temporal and parietal", "SMG7": "Temporal and parietal",
    "AG2": "Temporal and parietal", "O3_1": "Temporal and parietal", "FUS4": "Temporal and parietal",
    "pHIPP1": "Temporal and parietal", "HIPP2": "Temporal and parietal",
    "SMA2": "Internal surface", "SMA3": "Internal surface", "pCENT4": "Internal surface",
    "CINGp3": "Internal surface", "PRECU6": "Internal surface",
    "AMYG": "Sub-cortical", "THA4": "Sub-cortical", "PUT2": "Sub-cortical", "PUT3": "Sub-cortical"
}

# **Initialize Data Storage**
all_metrics_data = []

# **Process Each JSON File**
for file in json_files:
    subj_id = os.path.basename(file).replace("result_", "").replace(".json", "")

    with open(file, "r") as f:
        data = json.load(f)

    for i, node_name in enumerate(NODE_NAMES):
        base_name = "_".join(node_name.split("_")[:-1])  # Remove hemisphere info
        group = GROUP_MAPPING.get(base_name, "Unknown")

        region_data = {
            "Subject ID": subj_id,
            "Node Name": node_name,
            "Nodal Strength": data["nodal_strength"][0][i],
            "Path Length": data["path_length"][0][i],
            "Local Efficiency": data["local_efficiency"][0][i],
            "Clustering": data["clustering"][0][i],
            "Group": group
        }
        all_metrics_data.append(region_data)

# **Convert to DataFrame & Save**
all_metrics_df = pd.DataFrame(all_metrics_data)
output_path = os.path.join(OUTPUT_DIR, "regional_network_measures.csv")
all_metrics_df.to_csv(output_path, index=False)

print(f"✅ Regional network measures saved to {output_path}")
print(all_metrics_df.head())
