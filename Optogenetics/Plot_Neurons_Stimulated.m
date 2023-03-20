function Plot_Neurons_Stimulated(data,new_figure)
% Highlight optogenetic stimulated neurons
%
%       Plot_Neurons_Stimulated(data,new_figure)
%
%       default: new_figure = false;
%
% By Jesus Perez-Ortega, Feb 2023

if nargin<2
    new_figure = false;
end

% Read stim XY
xy_stim = data.Optogenetics.XY;
radius = data.ROIs.NeuronRadius;
neurons = data.Neurons;
width = data.Movie.Width;
height = data.Movie.Height;

% Find stimulated neurons
id_neurons = Find_Neurons_By_XY(neurons,xy_stim,radius);

% Get image
im = Highlight_Neurons_Selected(neurons,id_neurons,width,height,[0 1 0]);

% Plot neurons
if new_figure
    Set_Figure('Neurons optogenetically stimulated',[0 0 500 500])
end

h_im = imshow(im,'InitialMagnification',200); hold on

% Plot stimulated coordinates
plot(h_im.Parent,xy_stim(:,1),xy_stim(:,2),'xr')
