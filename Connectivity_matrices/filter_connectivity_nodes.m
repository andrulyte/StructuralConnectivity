% This script processes FA connectivity matrices, filters nodes using the
% SENSAAS atlas, applies a binary mask, and saves results in a MATLAB file.

clc; clear; close all;

%% Setup Paths
data_dir = '/beegfs_data/scratch/iandrulyte-diffusion';  % Base directory on HPC
filtered_dir = fullfile(data_dir, 'Filtered_connectivity');  % Output directory
output_dir = fullfile(filtered_dir, 'SENSAAS_con');  % Processed output

% Create output directory if it doesn't exist
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%%Load FA Connectivity Matrices
disp('Loading FA connectivity matrices...');
AICHA = load_FA_connectivity(fullfile(data_dir, 'FA_connectivity'));

%% Load AICHA Atlas Nodes
disp('Loading AICHA atlas nodes...');
node_file_path = fullfile(data_dir, 'AICHA', 'AICHA1mm_vol3.txt');
node_names = load_AICHA_nodes(node_file_path);

%% Load SENSAAS Labels
disp('Loading SENSAAS labels...');
sensaas_file_path = fullfile(data_dir, 'SENSAAS_brainAtlas-main', 'Atlas', 'SENSAAS_description.csv');
SENSAAS_labels = load_SENSAAS_labels(sensaas_file_path);

%% Find Matching Nodes
disp('Finding matching nodes...');
indices = find_matching_nodes(node_names, SENSAAS_labels.Nodes);

%% Filter Connectivity Matrices
disp('Filtering connectivity matrices...');
SENSAAS_connectivity = filter_connectivity_matrices(AICHA, indices);

%% Save Filtered Connectivity Matrices
disp('Saving filtered connectivity matrices...');
save(fullfile(output_dir, 'SENSAAS_connectivity.mat'), 'SENSAAS_connectivity', '-v7.3');

%% Save Node Labels
disp('Saving node labels...');
write_labels_to_file(fullfile(output_dir, 'Nodes_labels_SENSAAS.txt'), SENSAAS_labels.Nodes);

%% Save Coordinates
disp('Saving node coordinates...');
save_coordinates(SENSAAS_labels, fullfile(output_dir, 'Coordinates_SENSAAS.txt'));

%% Apply Binary Mask and Save Results
disp('Applying binary mask...');
binary_mask_path = fullfile(data_dir, 'out_mask.npy');
filtered_data = apply_binary_mask(SENSAAS_connectivity, binary_mask_path, node_names);
save(fullfile(output_dir, 'SENSAAS_connectivity_filtered.mat'), 'filtered_data', '-v7.3');

disp('Processing complete!');
