function [vector_id,neuron_id,id_for_vector_order] = Vector_and_Neuron_ID(data,mode)
% Get vector and neuronal IDs
%
%   [vector_id,neuron_id] = Vector_and_Neuron_ID(data,mode)
%
%   default: mode = 'none' (options 'none' and 'ori')
%
% By Jesus Perez-Ortega, Jun 2023
% Modified Sep 2023 (mode input added and data fields changed )

if nargin<2
    mode = 'none';
end

switch mode
    case 'none'
        id_for_vector_order = 1:data.Analysis.Ensembles.Count;
        id_for_neuron_order = id_for_vector_order;
        vector_id = data.Analysis.Ensembles.VectorID;
    case {'ori','ori onoff'}
        % Get tuned ensembles
        ensemble_best = Find_Ori_Ensembles(data);
        ensemble_best(isnan(ensemble_best)) = [];
        ensemble_others = setdiff(1:data.Analysis.Ensembles.Count,ensemble_best);
        id_for_vector_order = [ensemble_best ensemble_others];
        id_for_neuron_order = ensemble_best;

        % Set vector ID
        vector_id = zeros(1,sum(data.Analysis.Ensembles.FrameActivationCount));
        activations = cumsum([1 data.Analysis.Ensembles.FrameActivationCount(id_for_vector_order)]);
        for i = 1:data.Analysis.Ensembles.Count
            ensemble = id_for_vector_order(i);
            vector_id(activations(i):(activations(i+1)-1)) = data.Analysis.Ensembles.Indices{ensemble};
        end

    otherwise
        error('The ''mode'' options are only ''none'' or ''ori''.')
end


% Get neuron ID
onsemble_structure = data.Analysis.Ensembles.StructureOn(id_for_neuron_order,:);
offsemble_structure = data.Analysis.Ensembles.StructureOff(id_for_neuron_order,:);
on_neurons = sum(onsemble_structure)>0;
off_neurons = sum(offsemble_structure)>0;

onoff_neurons = find(on_neurons&off_neurons);
only_on_neurons = find(on_neurons&~off_neurons);
only_off_neurons = find(~on_neurons&off_neurons);

% Make trinary structure
structure_trinary = double(onsemble_structure);
structure_trinary(offsemble_structure) = 0.5;

switch mode
    case {'none','ori'}
        [~,neuron_id] = Sort_Raster(structure_trinary','descend');
    case {'ori onoff'}
        % Sort vectors by group: onoff, only on, and only off neurons
        [~,id] = Sort_Raster(structure_trinary(:,onoff_neurons)','descend');
        id_onoff = onoff_neurons(id);
        [~,id] = Sort_Raster(structure_trinary(:,only_on_neurons)','descend');
        id_only_on = only_on_neurons(id);
        [~,id] = Sort_Raster(structure_trinary(:,only_off_neurons)','ascend');
        id_only_off = only_off_neurons(id);
        id_extra = find(~on_neurons&~off_neurons);
        
        % Join all indices
        neuron_id = [id_onoff id_only_on id_only_off id_extra];
end