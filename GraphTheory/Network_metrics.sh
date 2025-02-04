#!/bin/bash

# Network Metrics Computation Script
# ----------------------------------
# This script computes graph theory network measures using streamline and length matrices.
# It processes connectivity files, checks for missing data, and logs missing subjects.
#
# Usage:
#   ./Network_metrics.sh
#

set -e  # Exit on error

# **Define Directories**
INPUT_DIR="/Users/neuro-240/Documents/BIL_and_GIN_Visit/sensaas_atlas_streamline_connectivity"
LENGTH_DIR="/Volumes/LaCie/Parcelated BIL FILES/Length_matrices_SENSAAS"
OUTPUT_DIR="/Volumes/LaCie/Network_results"
LOG_FILE="$OUTPUT_DIR/missing_files.log"

# **Ensure output and log directories exist**
mkdir -p "$OUTPUT_DIR"
touch "$LOG_FILE"

# **Find all subjects based on the streamline file pattern**
subjects=($(ls "$INPUT_DIR"/sensaas_streamline_t0*.npy 2>/dev/null | sed 's/.*sensaas_streamline_\(t0[0-9]*\)\.npy/\1/'))

# **Check if any subjects were found**
if [[ ${#subjects[@]} -eq 0 ]]; then
    echo "⚠️ No subjects found in $INPUT_DIR. Please check the file paths."
    exit 1
fi

# **Process each subject**
for subj in "${subjects[@]}"; do
    streamline_file="$INPUT_DIR/sensaas_streamline_${subj}.npy"
    length_file="$LENGTH_DIR/sensaas_LENGTH_${subj}.npy"
    output_file="$OUTPUT_DIR/result_${subj}.json"

    # **Check if both required files exist**
    if [[ -f "$streamline_file" && -f "$length_file" ]]; then
        echo "✅ Processing subject ${subj}..."
        scil_evaluate_connectivity_graph_measures.py "$streamline_file" "$length_file" "$output_file" --append_json
    else
        echo "❌ Missing files for subject ${subj}, skipping..." | tee -a "$LOG_FILE"
    fi
done

echo -e "\n✅ Processing completed. Check $LOG_FILE for missing file details."
