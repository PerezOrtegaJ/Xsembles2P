function color = Get_Color(index,colormap,total)
% Get the RGB color from a colormap given an index
%
%       color = Get_Color(index,colormap,total)
%
%       default: map = 'lines'; total = 256
%
% By Jesus Perez-Ortega, Sep 2021
% Modified Dec 2021

switch nargin
    case 1
        colormap = 'lines';
        total = 256;
    case 2
        total = 256;
end

% Get the colormap
if strcmp(colormap,'jp')
    colors = Read_Colors(20);
else
    colors = evalin('caller',[colormap '(' num2str(total) ')']);
end

% Set the color
color = colors(index,:);