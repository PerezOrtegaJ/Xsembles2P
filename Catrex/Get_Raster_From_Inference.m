function [raster,inference_th,threshold,b] = Get_Raster_From_Inference(inference,PSNR,b)
% Get raster from spike inference by setting a given threshold based on PSNR.
%
%       [raster,inference_th,threshold,b] = Get_Raster_From_Inference(inference,PSNR,b)
%
% By Jesus Perez-Ortega, April 2023
% MOdified May 2023

if nargin<3
    b = [];
    if nargin<2
        PSNR = [];
    end
end

if isempty(b)
    %b = mean(inference(:))+std(inference(:));
    %b = b*[1 -1/20];
    %b = b*[1 -1/30];

    % b = mean(PSNR(:));
    % b = b/600*[1 -1/30];

    b = [0.04 -0.002];
end

if isempty(PSNR)
    PSNR = zeros(length(inference),1);
end

% Get number of signals
[n_neurons,n_frames] = size(inference);
inference_th = zeros(n_neurons,n_frames);

% Get threshold base on a linear model proportional to PSNR (30dB or more th=0)
% b1 = 0.6 and b2 = -0.02 (0dB th=0.6)
% b1 = 0.3 and b2 = -0.01 (0dB th=0.3)
% b1 = 0.15 and b2 = -0.005 (0dB th=0.15)
% b1 = 0.09 and b2 = -0.003 (0dB th=0.09)
% b1 = 0.04 and b2 = -0.002 (0dB th=0.04)
threshold = b(1)+b(2)*PSNR;
threshold(threshold<0) = 0;

% Different threshold for each signal
raster = zeros(n_neurons,n_frames,'logical');
for i = 1:n_neurons
    single = inference(i,:);
    th = threshold(i);

    % Get binary
    raster(i,single>th) = true;
    inference_th(i,single>th) = single(single>th);
end