function [indices,count] = Get_Peak_Indices(data,threshold,detect_peaks)
% Get peak or valley indices 
%
%       [indices,count] = Get_Peak_Indices(data,threshold,detect_peaks)
%
%       default: detect_peaks = true;
%
% by Jesus E. Perez-Ortega - Feb 2012
% Modified June 2019
% Modified Oct 2021

if nargin == 2
    detect_peaks = true;
end

if detect_peaks
    indices = find(data>threshold);
else
    % detect valleys
    indices = find(data<threshold);
end
count = numel(indices);