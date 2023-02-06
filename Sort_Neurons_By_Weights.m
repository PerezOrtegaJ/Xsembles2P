function [structure_sorted,neuron_id] = Sort_Neurons_By_Weights(structure)
% Sort ensemble structure weighted
%
%   [structure_sorted,neuron_id] = Sort_Neurons_By_Weights(structure)
%
% Jesús Pérez-Ortega, March 2022

% Get the number of ensembles and neurons
[n_ensembles,n_neurons] = size(structure);

% Sort neurons
neuron_id = 1:n_neurons;
for i = n_ensembles:-1:1
   [~,id] = sort(structure(i,:),'descend');
   structure = structure(:,id);
   neuron_id = neuron_id(id); 
end

% Set structure sorted
structure_sorted = structure(:,neuron_id);