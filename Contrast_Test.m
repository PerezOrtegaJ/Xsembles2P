function [clusters_recommended,indices,avg_indices,sem_indices] =...
    Contrast_Test(tree,similarity,clustering_range,method,exclude)
% Get indexes for evaluating clustering from hierarchical cluster tree.
%
%       [clusters_recommended,indices,avg_indices,sem_indices] =...
%   Contrast_Test(tree,similarity,clustering_range,method,exclude)
%
%       default: clustering_range = 2:30; method = 'max' (or 'firstpeak', 'bigincrease',
%                'maxsem', 'firstpeaksem'); exclude = false
%
% Inputs:
%       tree = hierarchical cluster tree
%       similarity = matrix VxV, where V is the number of vectors
%       clustering_range = range of groups to analyze
%       method = method to select the best contrast index
%       exclude = specify if exclude one of the cluster from the meassure
%
% Outputs:
%       clusters_recommended = recommended number of clusters
%       indices = contrast indices of the clustering range
%      
%
% By Jesus Perez-Ortega, March 2022

switch nargin
    case 2
        clustering_range = 2:30;
        method = 'max';
        exclude = false;
    case 3
        method = 'max';
        exclude = false;
    case 4
        exclude = false;
end

j = 1;
avg_indices = zeros(1,length(clustering_range));
sem_indices = zeros(1,length(clustering_range));
for n_clusters = clustering_range
    % Get indices of clustering
    T = cluster(tree,'maxclust',n_clusters);

    % Get contrast index
    [avg_indices(j),sem_indices(j)] = Contrast_Index(n_clusters,similarity,T,exclude);    
    j = j+1;
end

% Substract the standard error
indices = avg_indices-sem_indices;

switch method
    case 'max'
        % Select the maximum index
        id = Select_Best_Index(indices,'max');
        
        % If the maximum is the biggest number of clusters try the
        % following strategy:
        
        % Find maximum without substracting SEM
        if id==length(clustering_range)
            id = Select_Best_Index(avg_indices,'max');
        end

        % Find the first peak
        if id==length(clustering_range)
            id = Select_Best_Index(avg_indices,'firstpeak');
        end

        % Find first semi peak
        if id==length(clustering_range)
            % find first valley of the first derivative
            id = Select_Best_Index(max(diff(avg_indices))-diff(avg_indices),'firstpeak')+1;
        end

    otherwise
        % Select the best index
        id = Select_Best_Index(indices,method);
end

% Get recommended
clusters_recommended = clustering_range(id);