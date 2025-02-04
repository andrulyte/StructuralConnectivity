% =========================================================================
% Script: prepare_NBS_data.m
% Purpose: Prepare data files for Network-Based Statistic (NBS) analysis
% Author: Ieva Andrulyte
% Date: 2025-02-04
% =========================================================================

%% Load Handedness Data
handedness = readtable("data_cog2_.csv");  % Load handedness file
handedness_subj = handedness.Participants_list_ieva(2:end);  % Remove first entry
handedness_only = handedness.EdinburgScore(2:end);  % Remove first entry

%% Load Demographics Data
demog = readtable("HFLI_good.csv");  % Load demographics file

%% Define Class Labels and Combinations
classes = {'Atypical', 'Strong-Atypical', 'Typical'};
combinations = {'Atypical', 'Strong-Atypical'; 'Atypical', 'Typical'; 'Strong-Atypical', 'Typical'};
classNames = {'Atypical_StrongAtypical', 'Atypical_Typical', 'StrongAtypical_Typical'};

%% Load SENSAAS Connectivity Data
load('SENSAAS_connectivity.mat', 'SENSAAS_connectivity');

%% Generate Design Matrices and Filtered Connectivity Data
for i = 1:size(combinations, 1)
    % Filter demographics for the current class combination
    filtered_demog_combination = demog(ismember(demog.AtypPROD3Classes, combinations(i, :)), :);

    % Create binary group membership lists
    binaryList1 = ismember(filtered_demog_combination.AtypPROD3Classes, combinations{i, 1});
    binaryList2 = ismember(filtered_demog_combination.AtypPROD3Classes, combinations{i, 2});

    % Construct the design matrix
    design_matrix = [binaryList1, binaryList2];

    % Save design matrix for this combination
    dlmwrite(sprintf('design_matrix_%s.txt', classNames{i}), design_matrix, ' ');

    % Filter SENSAAS connectivity data
    selected_subjects = filtered_demog_combination.NSujet;
    available_subjects = fieldnames(SENSAAS_connectivity);
    common_subjects = intersect(available_subjects, string(selected_subjects));

    % Retain only relevant subjects in the connectivity structure
    filtered_data_combination = rmfield(SENSAAS_connectivity, setdiff(available_subjects, common_subjects));

    % Save filtered data for this combination
    save(sprintf('filtered_data_%s.mat', classNames{i}), 'filtered_data_combination');
end

%% Create Design Matrix for All Subjects
% Identify missing subjects
demog_NSujet = string(demog.NSujet);
SENSAAS_fieldnames = fieldnames(SENSAAS_connectivity);
missing_subjects = setdiff(demog_NSujet, SENSAAS_fieldnames);

% Filter out missing subjects from demographics
filtered_demog = demog(~ismember(demog_NSujet, missing_subjects), :);

% Convert sex variable to numeric (0 = Female, 1 = Male)
sexe = double(strcmp(filtered_demog.sexe, 'H'));  % 'H' -> 1, 'F' -> 0

% Filter Handedness Data
missing_handedness = setdiff(handedness_subj, SENSAAS_fieldnames);
filtered_handedness = handedness_only(~ismember(handedness_subj, missing_handedness));
filtered_handedness_subj = handedness_subj(~ismember(handedness_subj, missing_handedness));

% Create a table for handedness data
handedness_table = table(filtered_handedness, string(filtered_handedness_subj), ...
                         'VariableNames', {'Handedness', 'Subject'});

% Merge Handedness with Demographics
handedness_table.Subject = string(handedness_table.Subject);
filtered_demog.NSujet = string(filtered_demog.NSujet);
[isMatch, matchIdx] = ismember(handedness_table.Subject, filtered_demog.NSujet);
merged_table = [handedness_table(isMatch, :), filtered_demog(matchIdx(isMatch), :)];

% Initialize Design Matrix for All Groups (3 for ANOVA)
design_matrix = zeros(size(merged_table, 1), 3);

% Encode class membership
design_matrix(:, 1) = ismember(merged_table.AtypPROD3Classes, classes{2});
design_matrix(:, 2) = ismember(merged_table.AtypPROD3Classes, classes{3});

% Convert sex to numeric
sexe = double(strcmp(merged_table.sexe, 'H'));

% Extract covariates
age_IRM_Anat = merged_table.age_IRM_Anat;
Handedness = merged_table.Handedness;

% Append covariates to design matrix
design_matrix(:, 4) = age_IRM_Anat;
design_matrix(:, 5) = sexe;
design_matrix(:, 6) = Handedness;

% Remove missing values
design_matrix_covariates_clean = rmmissing(design_matrix, 'MinNumMissing', 1);

% Save design matrix
save('design_matrix_anova.mat', "design_matrix_covariates_clean");

%% Filter SENSAAS Connectivity Data for Common Subjects
common_subjects = intersect(string(merged_table.Subject), fieldnames(SENSAAS_connectivity));

% Initialize new structure
new_SENSAAS_connectivity = struct();
for i = 1:length(common_subjects)
    new_SENSAAS_connectivity.(common_subjects{i}) = SENSAAS_connectivity.(common_subjects{i});
end

% Save cleaned connectivity matrices
save('matrices_SENSAAS_clean_new.mat', "new_SENSAAS_connectivity");

%% Create Structured File for NBS Analysis
% =========================================================================
% This step converts the filtered connectivity data into a format suitable 
% for NBS analysis. It stacks all connectivity matrices into a 3D array.
% =========================================================================

% Initialize a 3D array to store all matrices (assuming 64x64 matrices)
num_subjects = numel(fieldnames(new_SENSAAS_connectivity));
all_matrices = zeros(64, 64, num_subjects);

% Initialize a cell array to store subject IDs
subject_ids_array = cell(num_subjects, 1);

% Extract field names (subject IDs)
subject_ids = fieldnames(new_SENSAAS_connectivity);

% Populate the 3D array with connectivity matrices
for subject_index = 1:num_subjects
    subject_id = subject_ids{subject_index};
    all_matrices(:, :, subject_index) = new_SENSAAS_connectivity.(subject_id);
    subject_ids_array{subject_index} = subject_id; % Store subject ID
end

% Save subject IDs to a text file
fileID = fopen('subject_ids.txt', 'w');
for i = 1:numel(subject_ids_array)
    fprintf(fileID, '%s\n', subject_ids_array{i});
end
fclose(fileID);

% Save NBS-compatible matrices
save("SENSAAS_NBS.mat", "all_matrices");

disp('NBS preparation complete. All files saved successfully.');
