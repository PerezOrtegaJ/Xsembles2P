function Set_Colormap_Blue_White_Red()
% Set colormap blue-white-red
%
%       Set_Colormap_Blue_White_Red()
%
% By Jesús Pérez-Ortega jan-2018
% Modified Aug 2021

% Get blue map
bluemap = gray(32)+repmat([0 0 1],32,1);
bluemap(bluemap>1)=1;

% Get red map
redmap = flipud(gray(32))+repmat([1 0 0],32,1);
redmap(redmap>1)=1;

% Combine and set blue and red maps
colormap(gca,[bluemap;redmap])
