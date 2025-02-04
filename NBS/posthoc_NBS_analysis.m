% =========================================================================
% Script: posthoc_NBS_analysis.m
% Purpose: Perform post-hoc t-tests on significant NBS connections


%% Extract Significant Connections from NBS
global nbs

% Identify significant connections
[i, j] = find(nbs.NBS.con_mat{1}); 

% Compute test statistics for significant connections
test_stats = nbs.NBS.test_stat(sub2ind(size(nbs.NBS.test_stat), i, j));

% Store connection labels
significant_connections_vector = cell(length(test_stats), 1);
for n = 1:length(test_stats)
    i_lab = nbs.NBS.node_label{i(n)}; 
    j_lab = nbs.NBS.node_label{j(n)}; 
    significant_connections_vector{n} = [i_lab '_' j_lab];
end

%% Extract Group Connectivity Matrices
% Extract subject indices for each group
Atypical_Group_Indices = find(design_matrix(:, 1) == 1);
StrongAtypical_Group_Indices = find(design_matrix(:, 2) == 1);
Typical_Group_Indices = find(design_matrix(:, 3) == 1);

% Extract group-specific connectivity matrices
Atypical_Group_matrices = all_matrices(:,:,Atypical_Group_Indices);
StrongAtypical_Group_matrices = all_matrices(:,:,StrongAtypical_Group_Indices);
Typical_Group_matrices = all_matrices(:,:,Typical_Group_Indices);

% Initialize network matrices
num_edges = length(i);
atypical_network = zeros(num_edges, length(Atypical_Group_Indices));
Strong_atypical_network = zeros(num_edges, length(StrongAtypical_Group_Indices));
typical_network = zeros(num_edges, length(Typical_Group_Indices));

% Extract only significant connections for each group
for subj = 1:length(Atypical_Group_Indices)
    subj_matrix = Atypical_Group_matrices(:,:,subj);
    atypical_network(:, subj) = subj_matrix(sub2ind(size(subj_matrix), i, j));
end

for subj = 1:length(StrongAtypical_Group_Indices)
    subj_matrix = StrongAtypical_Group_matrices(:,:,subj);
    Strong_atypical_network(:, subj) = subj_matrix(sub2ind(size(subj_matrix), i, j));
end

for subj = 1:length(Typical_Group_Indices)
    subj_matrix = Typical_Group_matrices(:,:,subj);
    typical_network(:, subj) = subj_matrix(sub2ind(size(subj_matrix), i, j));
end

%% Perform Post-Hoc t-Tests
% Function to perform t-tests between two groups
perform_ttest = @(group1, group2) arrayfun(@(idx) ttest2(group1(idx, :), group2(idx, :)), 1:num_edges);

% Compute p-values and t-statistics for each comparison
[p_values_atypicals, ~] = perform_ttest(atypical_network, Strong_atypical_network);
[p_values_Strongat_typical, ~] = perform_ttest(Strong_atypical_network, typical_network);
[p_values_atypical_typical, ~] = perform_ttest(typical_network, atypical_network);

% Identify significant edges (p < 0.05)
find_significant_edges = @(p_values) find(p_values < 0.05);
significant_edges_atypicals = find_significant_edges(p_values_atypicals);
significant_edges_Strongat_typical = find_significant_edges(p_values_Strongat_typical);
significant_edges_atypical_typical = find_significant_edges(p_values_atypical_typical);

% Display significant connections before correction
fprintf('Significant connections before correction:\n');
display_significant_connections = @(edges, p_values, label) ...
    arrayfun(@(idx) fprintf('%s - Connection %d: %s, p-value: %.4f\n', ...
    label, idx, significant_connections_vector{idx}, p_values(idx)), edges);

display_significant_connections(significant_edges_atypicals, p_values_atypicals, 'Atypical vs Strong Atypical');
display_significant_connections(significant_edges_Strongat_typical, p_values_Strongat_typical, 'Strong Atypical vs Typical');
display_significant_connections(significant_edges_atypical_typical, p_values_atypical_typical, 'Atypical vs Typical');

%% Multiple Comparisons Correction (Bonferroni)
% Concatenate all p-values
all_p_values = [p_values_atypical_typical; p_values_atypicals; p_values_Strongat_typical];

% Apply Bonferroni correction
num_total_comparisons = numel(all_p_values);
alpha = 0.05;
corrected_p_values = min(all_p_values * num_total_comparisons, 1);

% Identify significant edges after correction
significant_indices = find(corrected_p_values < alpha);

% Define group names
group_names = {'Atypical_Typical', 'Atypicals', 'StrongAtypical_Typical'};

% Display significant connections after correction
disp('Significant connections after correction for multiple comparisons:');
for i = 1:length(significant_indices)
    index = significant_indices(i);
    group_index = ceil(index / numel(p_values_atypical_typical));
    relative_index = mod(index - 1, numel(p_values_atypical_typical)) + 1;
    group_name = group_names{group_index};
    fprintf('%s - Connection %d: %s, Corrected p-value: %f\n', ...
        group_name, relative_index, significant_connections_vector{relative_index}, corrected_p_values(index));
end

%% Save Results
% Create table for significant connections
significant_table = table(significant_connections_vector, p_values_atypical_typical, ...
    p_values_atypicals, p_values_Strongat_typical, corrected_p_values, ...
    'VariableNames', {'Connection', 'p_Atypical_Typical', 'p_Atypicals', 'p_StrongAtypical_Typical', 'Corrected_p'});

% Save results
writetable(significant_table, 'Posthoc_NBS_results.csv');
save('Posthoc_NBS_analysis.mat', 'significant_table');

disp('Post-hoc analysis results saved: Posthoc_NBS_results.csv and Posthoc_NBS_analysis.mat');
