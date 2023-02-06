function duplicates = Find_Duplicates(series)
% Find duplicates in a series
%
%       duplicates = Find_Duplicates(series)
%
% By Jesus Perez, Aug 2021

% Get unique indices
[~,id] = unique(series,'first');

% Identify duplicate indices
idduplicates = 1:length(series);
idduplicates(id) = [];

% Get uique duplicate values
duplicates = unique(series(idduplicates));
