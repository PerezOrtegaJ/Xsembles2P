function [structures,neurons,ensemble_vectors,ensemble_indices]...
    = Get_Xsemble_Neurons(raster,vector_id,sequence)
% Get neurons from ensembles and offsembles
%
%       [structures,neurons,ensemble_vectors,ensemble_indices]...
%   = Get_Xsemble_Neurons(raster,vector_id,sequence)
%
% By Jesus Perez-Ortega, Aug 2022
% Modified Mar 2023 (EPI added)
% Modified Sep 2023 (Trinary added, ensemble replaced by onsemble)


% Get number of ensembles
ensembles = length(unique(sequence));

% Get ensemble network
for i = 1:ensembles
    
    % Get raster ensemble
    peaks = find(sequence==i);
    peak_indices = [];
    for j = 1:length(peaks)
        peak_indices = [peak_indices; find(vector_id==peaks(j))];
    end
    ensemble_vectors{i} = raster(:,peak_indices);
    ensemble_indices{i} = peak_indices;
    
    % Get ensemble activity
    ensemble_activity = false(1,size(raster,2));
    ensemble_activity(peak_indices) = true; 
    ensemble_activation(i,:) = ensemble_activity;
    
    % Detect neurons significantly active with the ensemble
    [significantly_active,belongingness,~,p,significantly_silence] = ...
        Get_Evoked_Neurons(raster,ensemble_activity);

    % Get ensemble participation index
    EPI = Get_EPI(raster,ensemble_activity);

    % Identify and sort significantly active neurons
    neurons_i = find(significantly_active);
    [~,id] = sort(belongingness(neurons_i),'descend');
    onsemble_neurons{i} = neurons_i(id);
    
    % Identify and sort significantly silent neurons
    neurons_i = find(significantly_silence);
    [~,id] = sort(belongingness(neurons_i),'ascend');
    offsemble_neurons{i} = neurons_i(id);
    
    % Add data
    structure_activated(i,:) = significantly_active;
    structure_silenced(i,:) = significantly_silence;
    structure_belongingness(i,:) = belongingness;
    structure_EPI(i,:) = EPI;
    structure_p(i,:) = p;
end

structure_trinary = double(structure_activated);
structure_trinary(structure_silenced) = -1;

% Set structures
structures.Activated = structure_activated;
structures.Silenced = structure_silenced;
structures.Trinary = structure_trinary;
structures.BelongingnessTest = structure_belongingness;
structures.EPI = structure_EPI;
structures.P = structure_p;

% Set neurons
neurons.Onsemble = onsemble_neurons;
neurons.Offsemble = offsemble_neurons;