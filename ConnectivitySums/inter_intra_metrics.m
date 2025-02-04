%% Interhemispheric/Intrahemispheric Connections
% Load the "SENSAAS_connectivity" struct file
load('SENSAAS_connectivity.mat');

% Read the node names from "node_table.txt"
node_table = readtable('node_table.txt');
node_names = node_table.Node_Name; % Adjust if the column name differs

% Find indices of left and right hemisphere nodes
left_indices = find(endsWith(node_names, '_L'));
right_indices = find(endsWith(node_names, '_R'));
num_subjects = 285; % Assuming the data structure holds the number of subjects

% Define group names
group_names = {'Atypical', 'Strongly_Atypical', 'Typical'};

% Initialize results table
results = table('Size', [num_subjects, 6], ...
                'VariableTypes', {'string', 'double', 'double', 'double', 'double', 'string'}, ...
                'VariableNames', {'Subject', 'Intrahemispheric_Left_Sum', 'Intrahemispheric_Right_Sum', ...
                                  'Intrahemispheric_Combined_Sum', 'Interhemispheric_Sum', 'GroupNameFull'});

% Loop through each subject
for i = 1:num_subjects
    subj_name = subject_names{i};
    conn_matrix = new_SENSAAS_connectivity.(subj_name); % 64x64 matrix
    
    % Compute intrahemispheric left connections
    left_matrix = conn_matrix(left_indices, left_indices);
    left_sum = sum(left_matrix(:));
    
    % Compute intrahemispheric right connections
    right_matrix = conn_matrix(right_indices, right_indices);
    right_sum = sum(right_matrix(:));
    
    % Compute combined intrahemispheric connectivity
    combined_sum = left_sum + right_sum;
    
    % Compute interhemispheric connectivity
    inter_matrix = conn_matrix(left_indices, right_indices);
    inter_sum = sum(inter_matrix(:));
    
    % Assign subject group based on design matrix
    if design_matrix(i, 1) == 1
        group_name = group_names{1}; % Atypical
    elseif design_matrix(i, 2) == 1
        group_name = group_names{2}; % Strongly Atypical
    elseif design_matrix(i, 3) == 1
        group_name = group_names{3}; % Typical
    else
        group_name = 'Unknown'; % Handle undefined groups
    end
    
    % Assign computed values to results table
    results.Subject(i) = subj_name;
    results.Intrahemispheric_Left_Sum(i) = left_sum;
    results.Intrahemispheric_Right_Sum(i) = right_sum;
    results.Intrahemispheric_Combined_Sum(i) = combined_sum;
    results.Interhemispheric_Sum(i) = inter_sum;
    results.GroupNameFull(i) = group_name;
end

% Display results table
disp(results);

% Save the results table as a CSV file
writetable(results, 'results_connectivity.csv');
disp('Results saved to results_connectivity.csv');
