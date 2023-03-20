function image = Highlight_Neurons_Selected(neurons,selected_id,width,height,color)
% Create an image of the spatial location of neurons highlighting 
% selected neurons
%
%       image = Highlight_Neurons_Selected(neurons,selected_id,width,height,color)
%
% By Jesus Perez-Ortega, Feb 2023

if nargin<5
    color = [0 1 0];
end

% Get number of neurons
n_neurons = length(neurons);

% Set max brightness
brightness = 1;

% Set mask highlighting the selected ensemble
accepted_hsv = rgb2hsv(color);

% Initialize values
hues = zeros(1,n_neurons);
saturation = zeros(1,n_neurons);

hues(selected_id) = accepted_hsv(1);
saturation(selected_id) = accepted_hsv(2);

mask = Get_ROIs_Image(neurons,width,height,brightness,hues,saturation);

image = cast(rescale(mask)*double(intmax('uint8')),'uint8');