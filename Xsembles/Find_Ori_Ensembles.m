function ensemble_id = Find_Ori_Ensembles(data)
% Get ensembles from data (variable from Xsembles2P) and analyzed
% orientation selectivity
%
%   ensemble_order = Find_Ori_Ensembles(data)
%
% By Jesus Perez-Ortega, Sep 2023

% Read data
stimuli = data.VoltageRecording.Stimuli;

% Compute cirvar
raster_ensemble = data.Analysis.Ensembles.Activity;

% Get tuning of ensembles
[cirvar_ensemble,~,tuning_ensemble] = Get_Ori_Cirvar(raster_ensemble,stimuli);

% Get tuned ensembles
ensemble_id = Select_Tuned_Neurons(tuning_ensemble,cirvar_ensemble,'best');