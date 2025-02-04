#!/bin/bash
#SBATCH --job-name=generate_connectivity
#SBATCH --output="$subj_folder".out
#SBATCH --error="$subj_folder".err

subj_folder="$1"

# Change directory to subject's output folder
cd "$subj_folder"/final_outputs/"$subj"/mni_space || exit

AICHA_atlas="/beegfs_data/scratch/iandrulyte-diffusion/AICHA_v3_1x1x1_conv.nii.gz"

# Extract subject name from folder path
subj=$(basename "$subj_folder")

# Step 1: Compute tractography-based connectivity matrices
scil_decompose_connectivity.py "$subj_folder"/final_outputs/"$subj"/mni_space/"$subj"__plausible_mni_space.trk "$AICHA_atlas" "$subj_folder"/final_outputs/"$subj"/mni_space/"$subj"_parcelation.h5

# Step 2: Compute connectivity matrices
scil_compute_connectivity.py "$subj_folder"/final_outputs/"$subj"/mni_space/"$subj"_parcelation.h5 "$AICHA_atlas" --streamline_count "$subj_folder"/final_outputs/"$subj"/mni_space/connectivity_streamline_count.npy 

scil_compute_connectivity.py "$subj_folder"/final_outputs/"$subj"/mni_space/"$subj"_parcelation.h5 "$AICHA_atlas" --length "$subj_folder"/final_outputs/"$subj"/mni_space/connectivity_length.npy

# Step 3: Compute FA-based connectivity matrix
scil_compute_connectivity.py "$subj_folder"/final_outputs/"$subj"/mni_space/"$subj"_parcelation.h5 "$AICHA_atlas" \
    --metrics /beegfs_data/scratch/iandrulyte-diffusion/FA_maps/for_Ieva_FA_maps/"$subj"/*__fa_in_JHU_MNI.nii.gz \
    /beegfs_data/scratch/iandrulyte-diffusion/FA_maps/"$subj"/"$subj"_AICHA_connectivity_FA.npy
