function [widths,n_peaks] = Get_Ensembles_Length(indices,sequence)
% Identify the legnth of the ensembles
%
%       widths = Plot_Ensembles_Length(indices,sequence)
%
% By Jesus Perez-Ortega, Apr 2020
% Modified Oct 2021

% Find vectors
id = find(indices>0);

% Get the ensemble id
ensembles = unique(sequence)';
n_ensembles = length(ensembles);

for i = 1:n_ensembles
    seq_ensemble = [];
    
    % Create binary signal to identify the lenght of each activation
    seq_ensemble(id(sequence==ensembles(i))) = 1;
    
    % find peaks
    [~,w] = Find_Peaks(seq_ensemble);
    
    % get number of peaks
    n_peaks(i) = length(w);
    
    % assign widths
    widths{ensembles(i)} = w;
end


