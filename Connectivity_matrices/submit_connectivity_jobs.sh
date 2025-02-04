#!/bin/bash

# Base directory containing subject folders
subjects_folder="/beegfs_data/scratch/iandrulyte-diffusion"

# Submit a SLURM job for each subject
for subj_folder in "$subjects_folder"/t0*
do
    sbatch generate_connectivity_matrices.sh "$subj_folder"
done
