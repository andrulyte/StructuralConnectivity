% =========================================================================
% Script: generate_BrainNet_files.m
% Purpose: Generate edge and node files for BrainNet visualization 


%% Extract Significant Connections from NBS
global nbs

% Identify significant connections
[i, j] = find(nbs.NBS.con_mat{1}); 

% Calculate the test statistic for each connection
test_stats = nbs.NBS.test_stat(sub2ind(size(nbs.NBS.test_stat), i, j));

% Print significant connections and their corresponding test statistics
fprintf('Significant connections with test statistics:\n');
for n = 1:length(i)
    i_lab = nbs.NBS.node_label{i(n)};
    j_lab = nbs.NBS.node_label{j(n)};
    stat = test_stats(n);
    fprintf('%s to %s. Test stat: %0.2f\n', i_lab, j_lab, stat);
end

%% Generate Edge File for BrainNet
% Convert adjacency matrix to full format
binary_matrix = full(nbs.NBS.con_mat{1});  

% Initialize a full matrix to store test statistics
full_matrix_stats = zeros(size(binary_matrix));

% Assign test statistics to corresponding positions
for n = 1:length(i)
    full_matrix_stats(i(n), j(n)) = test_stats(n);
end

% Save the full matrix as an edge file
dlmwrite("Anova_edge_file_full.txt", full_matrix_stats, 'delimiter', ' ');

disp('Edge file saved: Anova_edge_file_full.txt');

%% Generate Node File for BrainNet
% Read node coordinates
node_file = readtable("Coordinates_SENSAAS.txt");

% Find row and column indices of significant connections
[row_indices, col_indices] = find(binary_matrix == 1);
indices_matrix = [row_indices, col_indices];

% Initialize node presence vector (1 = node involved in significant connection)
node_presence = zeros(1, 64);
node_presence(indices_matrix(:, 1)) = 1;
node_presence(indices_matrix(:, 2)) = 1;

% Initialize nodal degree vector (number of times a node is involved in a connection)
nodal_degree = zeros(1, 64);
occurrences = accumarray(indices_matrix(:), 1);
nodal_degree(indices_matrix(:, 1)) = occurrences(indices_matrix(:, 1));
nodal_degree(indices_matrix(:, 2)) = occurrences(indices_matrix(:, 2));

% Append node information to the coordinate file
node_file(:, 4) = array2table(node_presence');  % Column 4: Presence (binary)
node_file(:, 5) = array2table(nodal_degree');   % Column 5: Degree (number of connections)

% Save node file
writetable(node_file, 'node_file_ANOVA.txt', 'Delimiter', ' ');

disp('Node file saved: node_file_ANOVA.txt');
