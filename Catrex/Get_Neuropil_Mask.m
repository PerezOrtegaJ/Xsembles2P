function neuropil = Get_Neuropil_Mask(neuronalData,imageSize)
% Generate a binary mask based on the neurons found
%
%       neuropil = Get_Neuropil_Mask(neuronalData,imageSize)
%
% By Jesus Perez-Ortega, Sep 2019

% Get size
h = imageSize(1);
w = imageSize(2);

% Get coordinates
n_cells = length(neuronalData);

% Get masks of every cell
wholeCellMasks = zeros(n_cells,h*w);
for i = 1:n_cells    
    % Create a mask from the cell without overlaping
    wholeCellMask = zeros(h,w);
    wholeCellMask(neuronalData(i).pixels) = 1;
    
    % Add masks to arrays
    wholeCellMasks(i,:) = wholeCellMask(:);
end

% Delete ROIs pixels from auras
neuropil = sum(wholeCellMasks)==0;
