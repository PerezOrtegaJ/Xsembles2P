function [neuronalData,idsRemoved] = Evaluate_Neurons(neuronalData,minPixels,maxPixels,...
    minCircularity,maxPerimeter,maxEccentricity,x,y,outline)
% Remove neurons less than n number of pixels
%
%       [neuronalData,idsRemoved] = Evaluate_Neurons(neuronalData,minPixels,maxPixels,
%            minCircularity,maxPerimeter,maxEccentricity,x,y,outline)
%
% By Jesus Perez-Ortega, July 2019
% Modified Sep 2019
% Modified Oct 2019
% Modified Oct 2021

% id to be removed
idsRemoved = zeros(1,length(neuronalData),'logical');

% Neurons with less than n number of pixels
id = [neuronalData.num_pixels]<minPixels;
idsRemoved = idsRemoved | id;
disp(['      ' num2str(nnz(id)) ' neurons removed with less than ' num2str(minPixels)...
    ' number of pixels.'])

% Neurons with more than n number of pixels
id = [neuronalData.num_pixels]>maxPixels;
idsRemoved = idsRemoved | id;
disp(['      ' num2str(nnz(id)) ' neurons removed with more than ' num2str(maxPixels)...
    ' number of pixels.'])

% Neurons from boundaries
id1 = [neuronalData.x_median]>x-outline;
id2 = [neuronalData.x_median]<=outline;
id3 = [neuronalData.y_median]>y-outline;
id4 = [neuronalData.y_median]<=outline;
id = id1 | id2 | id3 | id4;
idsRemoved = idsRemoved | id;
disp(['      ' num2str(nnz(id)) ' neurons removed of the boundaries.'])

% Neurons less than minimum circularity
id = [neuronalData.Circularity]<minCircularity;
idsRemoved = idsRemoved | id;
disp(['      ' num2str(nnz(id)) ' neurons removed with less than ' num2str(minCircularity)...
    ' circularity.'])

% Neurons more Eccentricity than maximum eccentricity
id = [neuronalData.Eccentricity]>maxEccentricity;
idsRemoved = idsRemoved | id;
disp(['      ' num2str(nnz(id)) ' neurons removed with more than ' num2str(maxEccentricity)...
    ' eccentricity.'])

% Neurons more Perimeter than maximum perimeter
id = [neuronalData.Perimeter]>maxPerimeter;
idsRemoved = idsRemoved | id;
disp(['      ' num2str(nnz(id)) ' neurons removed with more than ' num2str(maxPerimeter)...
    ' pixels of perimeter.'])

% Remove neurons
neuronalData(idsRemoved) = [];
idsRemoved = find(idsRemoved);
disp(['    ' num2str(nnz(idsRemoved)) ' neurons were removed in total.'])