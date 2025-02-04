% =========================================================================
% Script: save_NBS_results.m
% Purpose: Extract and save significant connections from NBS ANOVA analysis


%% Extract Raw NBS Values - ANOVA
global nbs

% Identify significant connections in the network
[i, j] = find(nbs.NBS.con_mat{1}); 

% Compute test statistics for significant connections
test_stats = nbs.NBS.test_stat(sub2ind(size(nbs.NBS.test_stat), i, j));

% Sort connections by test statistic (highest to lowest)
[sorted_stats, sorted_indices] = sort(test_stats, 'descend');

% Initialize a cell array to store results
num_connections = length(sorted_indices);
nbs_results = cell(num_connections, 3);

% Extract and display sorted connections
fprintf('Significant connections sorted by test statistic:\n');
for n = 1:num_connections
    i_lab = nbs.NBS.node_label{i(sorted_indices(n))}; 
    j_lab = nbs.NBS.node_label{j(sorted_indices(n))}; 
    stat = sorted_stats(n);
    
    fprintf('%s to %s. Test stat: %0.2f\n', i_lab, j_lab, stat);
    
    % Store results in cell array
    nbs_results{n, 1} = i_lab;
    nbs_results{n, 2} = j_lab;
    nbs_results{n, 3} = stat;
end

% Save NBS structure and results table
save('ANOVA_NBS.mat', 'nbs');
writetable(nbs_table, 'ANOVA_NBS_results.csv');

disp('NBS results saved successfully: ANOVA_NBS.mat and ANOVA_NBS_results.csv');
