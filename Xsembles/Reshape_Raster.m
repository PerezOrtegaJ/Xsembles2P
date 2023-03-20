function new_raster = Reshape_Raster(raster,window,binary)
% Reshape raster
%
% Binarize the raster by a given window
%
%       new_raster = Reshape_Raster(raster,window,binary)
%
%       default: binary = true;
%
% Pérez-Ortega Jesús - May 2018
% Modeified, Jun 2021

if nargin==2
    binary = true;
end

[c,n] = size(raster);

if window==1
    new_raster = raster;
else
    new_n = floor(n/window);
    new_raster = zeros(c,new_n);
    for i = 1:new_n
        ini = (i-1)*window+1;
        fin = i*window;
        new_raster(:,i) = sum(raster(:,ini:fin),2);
    end
end

if binary
    new_raster = logical(new_raster);
end