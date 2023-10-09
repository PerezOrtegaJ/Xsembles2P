function [widths,n_activations] = Ensemble_Duration(indices,sequence)
% Measure the length of duration of each ensembles activation, and the
% number of activations.
%
%       [widths,n_activations] = Ensemble_Duration(indices,sequence)
%
% By Jesus Perez-Ortega, Apr 2020
% Modified Oct 2021
% Modified Sep 2023 (variable intialization and names changed)
 
% Find vectors
id = find(indices>0);

% Get the ensemble id
ensembles = unique(sequence);
n_ensembles = length(ensembles);

% Initialize variables
n_activations = zeros(1,n_ensembles);
widths = cell(1,n_ensembles);

for i = 1:n_ensembles
    % Initialize variable
    seq_ensemble = zeros(size(id));
    
    % Create binary signal to identify the lenght of each activation
    seq_ensemble(id(sequence==ensembles(i))) = 1;
    
    % Find activations
    [~,w] = Find_Peaks(seq_ensemble);
    
    % Get number of activations
    n_activations(i) = length(w);
    
    % assign widths
    widths{ensembles(i)} = w;
end