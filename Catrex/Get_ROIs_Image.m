function image = Get_ROIs_Image(neurons,width,height,brightness,hues,saturation)
% Draw ROI clusters from  neurons data (generated by CaTrEx GUI)
%
%       image = Get_ROIs_Image(neurons,width,height,brightness,hues,saturation)
%
% Modified by Jesus Perez-Ortega, July 2019
% Modified Oct 2019
% Modified Dec 2019
% Modified Apr 2020
% Modified Dec 2021
% Modified Feb 2023


if nargin<6
    saturation = 1;
    if nargin<5
        hues = 1/3;
        if nargin<4
            brightness = 1;
            if nargin<3
                error('Image height and width must be specified.')
            end
        end
    end
end

n_neurons = length(neurons);
if length(brightness)==1
     brightness = brightness*ones(n_neurons,1);
end

if length(hues)==1
    hues = hues*ones(n_neurons,1);
end

if length(saturation)==1
     saturation = saturation*ones(n_neurons,1);
end

% Set value/brightness
value = zeros(height,width);
cells = zeros(height,width);
for i = 1:n_neurons
    value(neurons(i).pixels) = rescale(neurons(i).weight_pixels,0.1,0.9)*brightness(i);
    cells(neurons(i).pixels) = i;
end
% maxValue = quantile(value(value>0),0.95);
% value(value>maxValue) = maxValue;
%value = rescale(value,0.1,1);

% Get hues
hue = zeros(height,width);
hue(cells>0) = hues(cells(cells>0));
hue = reshape(hue,height,width);

% Get saturation
sat = zeros(height,width);
sat(cells>0) = saturation(cells(cells>0));
sat = reshape(sat,height,width);

% Create image
image = hsv2rgb(cat(3,hue,sat,value));