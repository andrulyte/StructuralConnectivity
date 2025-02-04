#!/usr/bin/env python3
"""
Extract Global Efficiency
-------------------------
This script processes JSON files from network analysis and extracts global efficiency 
measures for each subject.

"""

import json
import pandas as pd
import glob
import os

# **Define Directories**
OUTPUT_DIR = "/Volumes/LaCie/Network_results"

# **Get all JSON files**
json_files = glob.glob(os.path.join(OUTPUT_DIR, "result_*.json"))

# **Initialize Data Storage**
global_efficiency_data = []

# **Process Each JSON File**
for file in json_files:
    subj_id = os.path.basename(file).replace("result_", "").replace(".json", "")

    with open(file, "r") as f:
        data = json.load(f)

    subj_data = {
        "Subject ID": subj_id,
        "Global Efficiency": data["global_efficiency"][0]
    }
    global_efficiency_data.append(subj_data)

# **Convert to DataFrame & Save**
global_efficiency_df = pd.DataFrame(global_efficiency_data)
output_path = os.path.join(OUTPUT_DIR, "global_efficiency_measures.csv")
global_efficiency_df.to_csv(output_path, index=False)

print(f"✅ Global efficiency data saved to {output_path}")
print(global_efficiency_df.head())
