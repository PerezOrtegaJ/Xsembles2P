function adjacency = Get_Adjacency_From_Raster(raster,connectivity_method)
% Get adjacency matrix from raster peaks
%
%       adjacency = Get_Adjacency_From_Raster(raster,connectivity_method)
%
%       default: connectivity_method = 'coactivity'
%
% Negative numbers and NaNs are set to 0s
%
% Perez-Ortega Jesus, Mar 2018
% Modified, May 2018
% Modified, Jun 2018
% Modified, Jun 2023

if nargin==1
    connectivity_method = 'coactivity';
end

cells=size(raster,1);
switch(connectivity_method)
    case 'coactivity'
        %warning('Data is set to binary to obtain the adjacency matrix.')
        %raster = double(raster>0);
        %adjacency = raster*raster'.*(1-eye(cells));
        raster = single(raster);
        raster_t = raster';
        adjacency = raster*raster_t;
        diagonal_id = 1:length(adjacency)+1:numel(adjacency);
        adjacency(diagonal_id) = 0;
    case 'jaccard'
        %warning('Data is set to binary to obtain the adjacency matrix.')
        raster=double(raster>0);
        adjacency=squareform(1-pdist(raster,'jaccard'));
        adjacency(isnan(adjacency))=0;
    otherwise
        adjacency=corr(raster','type',connectivity_method);
        adjacency(adjacency<0)=0;
        adjacency(isnan(adjacency))=0;
        adjacency=adjacency.*(ones(cells)-eye(cells));
end