% This file contains helper functions for processing connectivity matrices.
% Used in: filter_connectivity_nodes.m

%% Function: Load FA Connectivity Matrices
function data = load_FA_connectivity(npy_dir)
    files = dir(fullfile(npy_dir, '*connectivity_FA.npy'));
    data = struct;
    
    for i = 1:numel(files)
        file_path = fullfile(npy_dir, files(i).name);
        npy_data = readNPY(file_path);
        
        % Extract subject ID
        [~, file_name, ~] = fileparts(files(i).name);
        subject_id = strtok(file_name, '_');
        
        data.(subject_id) = npy_data;
    end
end

%% Function: Load AICHA Atlas Nodes
function node_names = load_AICHA_nodes(node_file_path)
    node_table = readtable(node_file_path);
    node_names = string(node_table.nom_s);
end

%% Function: Load SENSAAS Labels
function SENSAAS_labels = load_SENSAAS_labels(sensaas_file_path)
    SENSAAS_labels = readtable(sensaas_file_path);
    
    % Merge Abbreviation & Hemisphere
    first_letter = cellfun(@(x) x(1), SENSAAS_labels.Hemisphere, 'UniformOutput', true);
    SENSAAS_labels.Nodes = strcat(SENSAAS_labels.Abbreviation, '_', first_letter);
end

%% Function: Find Matching Nodes
function indices = find_matching_nodes(node_names, SENSAAS_nodes)
    indices = ismember(node_names, SENSAAS_nodes);
end

%% Function: Filter Connectivity Matrices
function SENSAAS_connectivity = filter_connectivity_matrices(AICHA, indices)
    SENSAAS_connectivity = struct;
    fields = fieldnames(AICHA);
    
    for i = 1:numel(fields)
        filtered_matrix = AICHA.(fields{i})(indices, indices);
        SENSAAS_connectivity.(fields{i}) = filtered_matrix;
    end
end

%% Function: Save Node Labels to File
function write_labels_to_file(filename, labels)
    fid = fopen(filename, 'w');
    for i = 1:numel(labels)
        fprintf(fid, '%s\n', labels{i});
    end
    fclose(fid);
end

%% Function: Save Node Coordinates
function save_coordinates(SENSAAS_labels, filename)
    coordinates = SENSAAS_labels(:, 6:8);
    writetable(coordinates, filename, 'Delimiter', '\t', 'WriteVariableNames', false);
end

%% Function: Apply Binary Mask
function filtered_data = apply_binary_mask(SENSAAS_connectivity, binary_mask_path, node_names)
    binary_mask = readNPY(binary_mask_path);
    valid_nodes = any(binary_mask, 2);
    
    % Save filtered labels
    write_labels_to_file('labels_filtered.txt', node_names(valid_nodes));

    % Filter Connectivity Data
    filtered_data = struct();
    fields = fieldnames(SENSAAS_connectivity);
    for i = 1:numel(fields)
        filtered_data.(fields{i}) = SENSAAS_connectivity.(fields{i})(valid_nodes, valid_nodes);
    end
end
