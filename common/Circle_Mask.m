function mask = Circle_Mask(image_size,xy_center,radius)
% Create a circle mask
%
%       mask = Circle_Mask(image_size,xy_center,radius)
%
% Jesus Perez-Ortega, jesus.epo@gmail.com
% March 2019
% March 2022 (double added)

% Make data double
xy_center = double(xy_center);

% Get size of image
h = image_size(1);
w = image_size(2);
[x,y] = meshgrid(1:w,1:h);

% Get mask
mask = sqrt((x-xy_center(1)).^2 + (y-xy_center(2)).^2) < radius;