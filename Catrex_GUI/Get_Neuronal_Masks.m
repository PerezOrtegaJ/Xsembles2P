function [cellMasks,auraMasks,cellWMasks] = Get_Neuronal_Masks(neuronalData,neuropil,radiusAura,imageSize)
% Generate de binary mask from the cells
%
%       [cellMasks,auraMasks,cellWMasks] = Get_Neuronal_Masks(neuronalData,neuropil,radiusAura,imageSize)
%
% By Jesus Perez-Ortega
% Modified March 2021

% Get size
h = imageSize(1);
w = imageSize(2);

% Get coordinates
n_cells = length(neuronalData);
x = [neuronalData.x_median]';
y = [neuronalData.y_median]';
xy = [x y];

% Get masks of every cell
cellMasks = zeros(n_cells,h*w);
cellWMasks = zeros(n_cells,h*w);
auraMasks = zeros(n_cells,h*w);
for i = 1:n_cells
    % Create a mask from the cell without overlaping
    cellMask = zeros(h,w);
    cellMask(neuronalData(i).pixels(~neuronalData(i).overlap)) = 1;
    
    % Create a circular mask sround the cell
    auraMask = Circle_Mask(imageSize,xy(i,:),radiusAura);
    auraMask = xor(auraMask,cellMask);
    
    % Add masks to arrays
    cellMasks(i,:) = cellMask(:);
    auraMasks(i,:) = auraMask(:);
    cellWMasks(i,cellMask(:)>0) = neuronalData(i).weight_pixels(~neuronalData(i).overlap);
end

% Delete ROIs pixels from auras
auraMasks = bsxfun(@times,auraMasks,neuropil);

% Make 1 the sum of pixels
cellMasks = cellMasks./sum(cellMasks,2);
cellWMasks = cellWMasks./sum(cellWMasks,2);
auraMasks = auraMasks./sum(auraMasks,2);

% Make 0s the NaNs
cellMasks(isnan(cellMasks)) = 0;
cellWMasks(isnan(cellWMasks)) = 0;
auraMasks(isnan(auraMasks)) = 0;

% Reshape masks
cellMasks = reshape(cellMasks',h,w,[]);
cellWMasks = reshape(cellWMasks',h,w,[]);
auraMasks = reshape(auraMasks',h,w,[]);