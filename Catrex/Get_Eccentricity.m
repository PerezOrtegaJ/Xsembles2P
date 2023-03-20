function neuronalData = Get_Eccentricity(neuronalData,width,height)
% Identify ovelaped pixels
%
%       neuronalData = Get_Overlaping(neuronalData,x,y)
%
% By Jesus Perez-Ortega Sep 2019

nCells = numel(neuronalData);

% Get all overlaped pixels
for i = 1:nCells
    mask = zeros(height,width);
    mask(neuronalData(i).pixels) = 1;
    prop = regionprops(mask,'eccentricity','circularity','perimeter');
    
    if isempty(prop)
        neuronalData(i).Eccentricity = 0;
        neuronalData(i).Circularity = 0;
        neuronalData(i).Perimeter = 0;
    elseif length(prop)>1
        neuronalData(i).Eccentricity = prop.Eccentricity(1);
        neuronalData(i).Circularity = prop.Circularity(1);
        neuronalData(i).Perimeter = prop.Perimeter(1);
        disp(i)
    else
        neuronalData(i).Eccentricity = prop.Eccentricity;
        neuronalData(i).Circularity = prop.Circularity;
        neuronalData(i).Perimeter = prop.Perimeter;
    end
end