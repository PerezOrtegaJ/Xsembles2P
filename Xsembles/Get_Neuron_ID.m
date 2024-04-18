function [neuron_id,ensemble_order] = Get_Neuron_ID(data,mode,ensemble_order)
% Get neuronal IDs
%
%   [neuron_id,ensemble_order] = Vector_and_Neuron_ID(data,mode,ensemble_order)
%
%   default: mode = 'on-off' (options: 'none', 'on', 'off', 'on-off', and 'on-off-only')
%
% By Jesus Perez-Ortega, Feb 2024

if nargin<3
    ensemble_order = [];
    if nargin<2
        mode = 'on-off';
    end
end

% Get ensemble order
if isempty(ensemble_order)
    ensemble_order = 1:data.Analysis.Ensembles.Count;
end

if strcmp(mode,'none')
    neuron_id = 1:data.Analysis.Neurons;
    return
end

% Get neuron ID
onsemble_structure = data.Analysis.Ensembles.StructureOn.*data.Analysis.Ensembles.EPI;
offsemble_structure = data.Analysis.Ensembles.StructureOff.*data.Analysis.Ensembles.EPI;
on_neurons = sum(onsemble_structure)>0;
off_neurons = sum(offsemble_structure)>0;

% Get shared and exclusive neurons
onoff_neurons = find(on_neurons&off_neurons);
only_on_neurons = find(on_neurons&~off_neurons);
only_off_neurons = find(~on_neurons&off_neurons);

% Make trinary structure
ensemble_structure = double(onsemble_structure);
ensemble_structure(offsemble_structure<0) = -offsemble_structure(offsemble_structure<0)-1;
ensemble_structure(ensemble_structure==0) = -2;

% Get neuron IDs
switch mode
    case {'on'}
        [~,neuron_id] = Sort_Raster(onsemble_structure(ensemble_order,:)','descend');
    case {'off'}
        [~,neuron_id] = Sort_Raster(offsemble_structure(ensemble_order,:)','ascend');
    case {'on-off'}
        [~,neuron_id] = Sort_Raster(ensemble_structure(ensemble_order,:)','descend');
    case {'on-off-only'}
        % Sort vectors by group: onoff, only on, and only off neurons
        [~,id] = Sort_Raster(ensemble_structure(ensemble_order,onoff_neurons)','descend');
        id_onoff = onoff_neurons(id);
        [~,id] = Sort_Raster(ensemble_structure(ensemble_order,only_on_neurons)','descend');
        id_only_on = only_on_neurons(id);
        [~,id] = Sort_Raster(ensemble_structure(ensemble_order,only_off_neurons)','ascend');
        id_only_off = only_off_neurons(id);
        id_extra = find(~on_neurons&~off_neurons);
        
        % Join all indices
        neuron_id = [id_onoff id_only_on id_only_off id_extra];
end