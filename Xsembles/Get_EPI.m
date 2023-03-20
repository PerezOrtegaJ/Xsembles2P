function EPI = Get_EPI(raster,ensemble_times)
% Compute Ensemble Participation Index (EPI)
%
%       EPI = Get_EPI(raster,ensemble_times)
%
% By Jesus Perez-Ortega, Jul 2022
% Modified Mar 2023 (EPI)

% Get number of neurons
n_neurons = size(raster,1);

% Initialize
EPI = zeros(1,n_neurons);

% Get EBI for each neuron
for i = 1:n_neurons
    % Get fraction of active frames during
    fraction_ensemble = mean(raster(i,ensemble_times));
    fraction_noensemble = mean(raster(i,~ensemble_times));
    
    % Compute EPI
    EPI(i) = (fraction_ensemble-fraction_noensemble)/...
             (fraction_ensemble+fraction_noensemble);
end
