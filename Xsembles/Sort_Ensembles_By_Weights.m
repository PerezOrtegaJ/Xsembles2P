function [structure_sorted,ensemble_id,avg_weights] = Sort_Ensembles_By_Weights(structure)
% Sort ensemble by structure weighted. This function sort the ensembles by
% the number of neurons and weight of them. Firt ensemble more neurons with
% more weights, and so on.
%
%       [structure_sorted,ensemble_id,avg_weights] = Sort_Ensembles_By_Weights(structure)
%
% Jesús Pérez-Ortega, March 2022

% Sort ensembles
avg_weights = mean(structure,2);
[structure_sorted,ensemble_id] = sort(avg_weights,'descend');
