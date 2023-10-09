function coactivity = Pairwise_Coactivity(raster)
% Get adjacency matrix from raster peaks
%
%       coactivity = Pairwise_Coactivity(raster)
%
% Modified from 'Get_Adjacency_From_Raster.m'
% By Perez-Ortega Jesus, Sep 2023

% Get coactivity
coactivity = raster*raster';

% Get diagonal id
diagonal_id = 1:length(coactivity)+1:numel(coactivity);

% Set diagonal values to zero
coactivity(diagonal_id) = 0;