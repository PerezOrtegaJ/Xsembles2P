function [id_neurons,id_xy] = Find_Neurons_By_XY(neurons,xy,radius)
% Get the neuron number ("neurons" variable from Xsembles_2P.m) based on xy
% coordinates
%
%       [id_neurons,id_xy] = Find_Neurons_By_XY(neurons,xy,radius)
%
%       default: radius = 3
%
% By Jesus Perez-Ortega, Feb 2023

if nargin<3
    radius = 3;
end

% Get neurons XY
xy_neurons = [neurons(:).x_median; neurons(:).y_median]';

% Compute distance between coordinates
dist = pdist2(xy,xy_neurons,'euclidean');
[min_dist,id_close] = min(dist,[],2);

% Identify minimum distance required (<diameter)
xy_close = min_dist<2*radius;

% Get ids of neurons closest to the xy given
id_xy = find(xy_close);
id_neurons = id_close(xy_close);