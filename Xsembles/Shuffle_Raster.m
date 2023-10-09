function raster_shuffled = Shuffle_Raster(raster,parallel)
% Shulfe neuronal raster by circular shifting randomly in time each neuron
% separatedly
%
%       raster_shuffled = Shuffle_Raster(raster)
%
% Based on shuffle.m % jzaremba 01/2012 'time_shift' - shifts the time trace of each cell by a random amount
%           each cell maintains its pattern of activity
%
% modified Perez-Ortega Jesus, Sep 2023

if nargin<2
    parallel = false;
end

% Get size
[n_neurons,n_samples] = size(raster);

% Initialize raster shuffled
raster_shuffled = zeros(n_neurons,n_samples);

% Define the shifts for each row
rand_id = randi(n_samples,1,n_neurons);

if parallel
    parfor i = 1:n_neurons
        raster_shuffled(i,:) = circshift(raster(i,:),rand_id(i)); 
    end
else
    for i = 1:n_neurons
        raster_shuffled(i,:) = circshift(raster(i,:),rand_id(i)); 
    end
end