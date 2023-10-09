function [ensemble_activity,on_activity,off_activity,structure_weights,structure_weights_significant] =...
    Get_Xsemble_Activity(raster,ensemble_indices,ensemble_vectors,structure_on,structure_off)
% Extract ensemble activity
%
%       [ensemble_activity,on_activity,off_activity,structure_weights,structure_weights_significant] =...
%   Get_Xsemble_Activity(raster,ensemble_indices,ensemble_vectors,structure_on,structure_off)
%
% By Jesus Perez Ortega, Sep 2023

[neurons,frames] = size(raster); 
n_clusters = length(ensemble_indices);

% Initialize variables
on_activity = zeros(n_clusters,frames);
off_activity = zeros(n_clusters,frames);
structure_weights = zeros(n_clusters,neurons);

% Get fraction of active neurons
for i = 1:n_clusters
    id = ensemble_indices{i};
    on_activity(i,id) = mean(ensemble_vectors{i}(structure_on(i,:)>0,:));
    off_activity(i,id) = mean(ensemble_vectors{i}(structure_off(i,:)>0,:));

    % Get weights (probability of participation)
    structure_weights(i,:) = mean(ensemble_vectors{i},2);
end
structure_weights_significant = structure_weights;
structure_weights_significant(~structure_on|~structure_off) = 0;

% Binary activity
ensemble_activity = on_activity>0;