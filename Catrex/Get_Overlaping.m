function neuronalData = Get_Overlaping(neuronalData,width,height)
% Identify ovelaped pixels
%
%       neuronalData = Get_Overlaping(neuronalData,x,y)
%
% By Jesus Perez-Ortega Sep 2019

mask = zeros(height,width);
nCells = numel(neuronalData);

% Get all overlaped pixels
for i = 1:nCells
   mask(neuronalData(i).pixels) = mask(neuronalData(i).pixels) + 1;
end

% Get fraction of overlaped cells
for i = 1:nCells
   neuronalData(i).overlap = mask(neuronalData(i).pixels)>1;
   neuronalData(i).overlap_fraction = mean(neuronalData(i).overlap); 
end