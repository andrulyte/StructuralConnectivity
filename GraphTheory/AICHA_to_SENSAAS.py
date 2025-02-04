#!/usr/bin/env python3
"""
AICHA to SENSAAS Conversion (Length & Streamlines)
--------------------------------------------------
This script converts connectivity matrices (Length & Streamline) from the AICHA atlas 
to SENSAAS format by filtering based on matching node names.

Features:
- Handles both **length-based** and **streamline-based** matrices.
- Reads **AICHA node names** and **SENSAAS labels**.
- Identifies **matching nodes** and filters connectivity matrices accordingly.
- Saves the converted matrices in `.npy` format for further analysis.

Usage:
    python AICHA_to_SENSAAS.py <mode>  # Mode: "length" or "streamline"

"""

import os
import sys
import numpy as np
import pandas as pd

# **Configuration: Define Directories**
BASE_DIR = "/Users/neuro-240/Documents/BIL_and_GIN_Visit/"
AICHA_NODE_FILE = "/Users/neuro-240/Downloads/AICHA/AICHA1mm_vol3.txt"
SENSAAS_LABEL_FILE = f"{BASE_DIR}/SENSAAS_brainAtlas-main/Atlas/SENSAAS_description.csv"

# **Dataset Paths**
DATA_PATHS = {
    "length": {
        "input_dir": f"{BASE_DIR}/Parcelated BIL FILES/Length_matrices_AICHA/",
        "output_dir": f"{BASE_DIR}/Parcelated BIL FILES/Length_matrices_SENSAAS/",
        "suffix": "_connectivity_length.npy",
        "output_prefix": "sensaas_LENGTH_"
    },
    "streamline": {
        "input_dir": f"{BASE_DIR}/streamline_count_matrices/connectivity_matrices_of_interest",
        "output_dir": f"{BASE_DIR}/sensaas_atlas_streamline_connectivity/",
        "suffix": "_connectivity_streamline_count.npy",
        "output_prefix": "sensaas_streamline_"
    }
}

def load_labels():
    """Load AICHA node names and SENSAAS labels."""
    if not os.path.exists(AICHA_NODE_FILE):
        raise FileNotFoundError(f"❌ Error: AICHA node file not found: {AICHA_NODE_FILE}")
    if not os.path.exists(SENSAAS_LABEL_FILE):
        raise FileNotFoundError(f"❌ Error: SENSAAS label file not found: {SENSAAS_LABEL_FILE}")

    # **Load AICHA nodes**
    node_file = pd.read_csv(AICHA_NODE_FILE, sep='\t')
    node_names = node_file['nom_s'].values

    # **Load SENSAAS labels**
    sensaas_labels = pd.read_csv(SENSAAS_LABEL_FILE)
    sensaas_labels['Nodes'] = sensaas_labels['Abbreviation'] + '_' + sensaas_labels['Hemisphere'].str[0]

    return node_names, sensaas_labels['Nodes'].values


def convert_data(mode):
    """
    Convert AICHA connectivity matrices to SENSAAS format.
    
    :param mode: "length" or "streamline"
    """
    if mode not in DATA_PATHS:
        raise ValueError("❌ Error: Invalid mode. Use 'length' or 'streamline'.")

    input_dir = DATA_PATHS[mode]["input_dir"]
    output_dir = DATA_PATHS[mode]["output_dir"]
    suffix = DATA_PATHS[mode]["suffix"]
    output_prefix = DATA_PATHS[mode]["output_prefix"]

    # **Ensure Output Directory Exists**
    os.makedirs(output_dir, exist_ok=True)

    # **Load Labels & Identify Matching Nodes**
    node_names, sensaas_nodes = load_labels()
    indices = np.isin(node_names, sensaas_nodes)

    # **Get Connectivity Files**
    npy_files = [f for f in os.listdir(input_dir) if f.endswith(suffix)]

    if not npy_files:
        print(f"⚠️ No {mode} .npy files found in {input_dir}.")
        return

    for npy_file in npy_files:
        input_path = os.path.join(input_dir, npy_file)
        try:
            npy_data = np.load(input_path)

            # **Filter Matrix**
            filtered_matrix = npy_data[indices][:, indices]

            # **Save Filtered Matrix**
            subject_id = npy_file.split('_')[0]
            output_filename = f"{output_prefix}{subject_id}.npy"
            output_path = os.path.join(output_dir, output_filename)

            np.save(output_path, filtered_matrix)
            print(f"✅ Saved: {output_filename}")

        except Exception as e:
            print(f"❌ Error processing {npy_file}: {e}")

    print(f"\n✅ {mode.capitalize()} conversion complete! Files saved in {output_dir}")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python AICHA_to_SENSAAS.py <mode>  # Mode: 'length' or 'streamline'")
        sys.exit(1)

    convert_data(sys.argv[1])
