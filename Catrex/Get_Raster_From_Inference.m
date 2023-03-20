function [raster,inferenceTh] = Get_Raster_From_Inference(inference,sameTh,value)
% Get raster from spike inference by setting a given threshold or
% specific number standard deviations from each spike inference
%
%       [raster,inferenceTh,modelTh] = Get_Raster_From_Inference(inference,sameTh,value)
%
%            default: sameTh = true; value = 1;
%                     sameTh = true, same threshold to all signals given by
%                     the value variable.
%                     sameTh = false, different threshold for every signal
%                     based on a number of standard deviation times given
%                     by value variable
%
% By Jesus Perez-Ortega, Nov 2019

switch nargin 
    case 1
        sameTh = true;
        value = 1;
    case 2
        if sameTh
            value = 1;
        else
            value = 2;
        end
end

% Get number of signals
[n,f] = size(inference);
inferenceTh = zeros(n,f);

if sameTh
    % Same threshold for every signal
    raster = inference>value;
    inferenceTh(raster) = inference(raster);
else
    % Different threshold for each signal
    raster = zeros(n,f);
    for i = 1:n
        % Get the threshold for each signal
        singleInference = inference(i,:);
        %th = value*std(singleInference);
        th = mean(singleInference)+value*std(singleInference);

         % Get binary
        raster(i,singleInference>th) = 1;
        inferenceTh(i,singleInference>th) = singleInference(singleInference>th);
    end
end