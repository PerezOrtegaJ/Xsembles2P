function neurons = Combine_Neurons(neurons_A,neurons_B,radius,minareaintersection)
% Combine neurons from 2 neuron structures
%
%       neurons = Combine_Neurons(neurons_A,neurons_B,radius,minareaintersection)
%
%       default: minintersection = 1/3; minimum fraction of pixels overlapped between neurons
%
% By Jesus Perez-Ortega, Oct 2021

if nargin ==3
    minareaintersection = 1/3;
end

cells = Get_Intersected_ROIs(neurons_A,neurons_B,radius,minareaintersection);

% Read the IDs of intersected neurons
idA = cells.IDSameA;
idOnlyA = cells.IDOnlyA;
idOnlyB = cells.IDOnlyB;

% Get neurons combined
neuronsAB = neurons_A(idA);
neuronsOnlyA = neurons_A(idOnlyA);
neuronsOnlyB = neurons_B(idOnlyB);
neurons = [neuronsOnlyA neuronsAB neuronsOnlyB];

