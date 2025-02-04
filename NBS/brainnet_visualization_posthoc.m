% =========================================================================
% Script: brainnet_visualization_posthoc.m
% Purpose: Generate BrainNet visualization files (edges & nodes) for significant t-tests


%% 1. Plotting Data for the Atypical vs Typical Significant t-Test

% Define the significant connections and their corresponding indices
connections = {'F1_2_R_INSa3_R', 'STS3_L_T2_3_R', 'T2_3_L_T2_3_R', 'PUT2_L_T2_4_R', 'F1_2_L_THA4_L'};
indices = [5, 20, 21, 25, 29];

% Create a bar plot of the t-statistics for these connections
figure;
bar(1:length(indices), t_stats(indices), 0.5); 
hold on;

% Highlight significant connections
significant_indices = find(p_values(indices) < 0.05);
plot(significant_indices, t_stats(indices(significant_indices)), 'ro', 'MarkerSize', 8);

% Annotate significant connections with their p-values
p_values_specified = [0.003690, 0.016525, 0.017129, 0.016483, 0.049406];
for i = 1:length(significant_indices)
    index = significant_indices(i);
    text(index, t_stats(indices(index)), sprintf('p=%.4f', p_values_specified(i)), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
end

% Customize plot appearance
xticks(1:length(indices));
xticklabels(connections);
xtickangle(45);
xlabel('Connection');
ylabel('t-statistic');
title('T-test Results: Atypical vs Typical');
legend('t-statistics', 'Significant Connections');

hold off;

%% 2. Create Node and Edge Files for BrainNet (Atypical vs Typical)

% Extract only significant connections
only_significant_connections = indices_matrix(indices, :);
only_significant_connections(:, 3) = 1;

% Load node coordinates and labels
coordinates = readtable("Coordinates_SENSAAS.txt");
coordinates.Properties.VariableNames = {'x', 'y', 'z'};

labels = readtable("Nodes_labels_SENSAAS.txt", 'Delimiter', '\n', 'ReadVariableNames', false);
labels.Properties.VariableNames = {'node'};

% Initialize node presence vector
vector = zeros(1, 64);
vector(only_significant_connections(:, 1:2)) = 1;

% Compute nodal degree (number of connections per node)
second_vector = zeros(1, 64);
occurrences = accumarray(only_significant_connections(:, 1:2)(:), 1);
second_vector(only_significant_connections(:, 1:2)) = occurrences(only_significant_connections(:, 1:2));

% Construct node file
node_file = [coordinates, array2table(vector'), array2table(second_vector'), labels];

% Save node file
writetable(node_file, 'node_file_AtypicalTypical.txt', 'Delimiter', ' ');
disp('Node file saved: node_file_AtypicalTypical.txt');

% Generate Edge File
weighted_matrix = zeros(64, 64);
for i = 1:length(indices)
    weighted_matrix(row_indices(indices(i)), col_indices(indices(i))) = t_stats(indices(i));
end

% Save edge file
dlmwrite('edge_file_Atypical_typical.txt', weighted_matrix, 'delimiter', '\t');
disp('Edge file saved: edge_file_Atypical_typical.txt');

%% 3. Plotting Data for the Strongly Atypical vs Typical Significant t-Test

% Define the significant connections and their corresponding indices
connections = {
    'CINGp3_R_INSa1_L', 'INSa1_R_INSa3_R', 'INSa1_L_O3_1_L', 'INSa1_L_SMA3_R', ...
    'INSa1_L_T1_4_L', 'prec4_L_T1_4_L', 'F3O1_L_T2_3_L', 'INSa3_R_T2_3_L', ...
    'T1_4_R_T2_3_L', 'STS3_L_T2_3_R', 'T2_3_L_T2_3_R', 'pCENT4_R_T2_4_L', ...
    'INSa1_R_T2_4_R', 'O3_1_L_THA4_L'
};
indices = [2, 6, 7, 13, 14, 15, 16, 17, 19, 20, 21, 22, 23, 30];

% Create a bar plot of the t-statistics for these connections
figure;
bar(1:length(indices), t_stats(indices), 0.5);
hold on;

% Highlight significant connections
significant_indices = find(p_values(indices) < 0.05);
plot(significant_indices, t_stats(indices(significant_indices)), 'ro', 'MarkerSize', 8);

% Annotate significant connections with their p-values
strong_atypic_typic_corrected_p = corrected_p_values(61:end,:);
p_values_specified = strong_atypic_typic_corrected_p(indices);
for i = 1:length(significant_indices)
    index = significant_indices(i);
    text(index, t_stats(indices(index)), sprintf('p=%.4f', p_values_specified(i)), ...
        'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'center');
end

% Customize plot appearance
xticks(1:length(indices));
xticklabels(connections);
xtickangle(45);
xlabel('Connection');
ylabel('t-statistic');
title('T-test Results: Strongly Atypical vs Typical');
legend('t-statistics', 'Significant Connections');

hold off;

%% 4. Create Node and Edge Files for BrainNet (Strongly Atypical vs Typical)

% Extract only significant connections
only_significant_connections = indices_matrix(indices, :);
only_significant_connections(:, 3) = 1;

% Initialize node presence vector
vector = zeros(1, 64);
vector(only_significant_connections(:, 1:2)) = 1;

% Compute nodal degree
second_vector = zeros(1, 64);
occurrences = accumarray(only_significant_connections(:, 1:2)(:), 1);
second_vector(only_significant_connections(:, 1:2)) = occurrences(only_significant_connections(:, 1:2));

% Construct node file
node_file = [coordinates, array2table(vector'), array2table(second_vector'), labels];

% Save node file
writetable(node_file, 'node_file_StrongAtypical_Typical.txt', 'Delimiter', ' ');
disp('Node file saved: node_file_StrongAtypical_Typical.txt');

% Generate Edge File
weighted_matrix = zeros(64, 64);
for i = 1:length(indices)
    weighted_matrix(row_indices(indices(i)), col_indices(indices(i))) = t_stats(indices(i));
end

% Save edge file
dlmwrite('edge_file_strongAtypical_typical.txt', weighted_matrix, 'delimiter', '\t');
disp('Edge file saved: edge_file_strongAtypical_typical.txt');
